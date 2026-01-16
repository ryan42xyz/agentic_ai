#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:?set BASE_URL, e.g. http://localhost:8080}"
ENDPOINTS_FILE="${ENDPOINTS_FILE:-scripts/api_test/endpoints.txt}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts/api-test/$(date -u +%Y%m%d-%H%M%S)}"

mkdir -p "$ARTIFACTS_DIR"

RUN_LOG="$ARTIFACTS_DIR/run.log"
RESULTS_JSON="$ARTIFACTS_DIR/results.json"

passed=0
failed=0
total=0

echo "BASE_URL=$BASE_URL" | tee "$RUN_LOG"
echo "ENDPOINTS_FILE=$ENDPOINTS_FILE" | tee -a "$RUN_LOG"
echo "ARTIFACTS_DIR=$ARTIFACTS_DIR" | tee -a "$RUN_LOG"

tmp_body="$(mktemp)"
trap 'rm -f "$tmp_body"' EXIT

json_escape() {
  # Minimal JSON string escape for typical URLs/paths.
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# Check if jq is available for JSON parsing
HAS_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=1
fi

# Extract JSON field value using jq (if available) or grep fallback
extract_json_field() {
  local json_file="$1"
  local json_path="$2"
  
  if [[ "$HAS_JQ" -eq 1 ]]; then
    jq -r "$json_path" "$json_file" 2>/dev/null || echo ""
  else
    # Fallback: extract value using grep/sed (limited support)
    local field_name="${json_path##*.}"
    field_name="${field_name//\$/}"
    grep -o "\"$field_name\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" "$json_file" 2>/dev/null | sed 's/.*"\([^"]*\)"/\1/' | head -1
  fi
}

# Check JSON field value
check_json_field() {
  local json_file="$1"
  local spec="$2"
  local json_path="${spec%%=*}"
  local expected="${spec#*=}"
  
  if [[ "$HAS_JQ" -eq 1 ]]; then
    local actual
    actual="$(jq -r "$json_path" "$json_file" 2>/dev/null || echo "")"
    if [[ "$expected" == "*" ]]; then
      # Wildcard: just check field exists and is non-empty
      [[ -n "$actual" && "$actual" != "null" ]]
    else
      [[ "$actual" == "$expected" ]]
    fi
  else
    # Fallback: use grep
    if [[ "$expected" == "*" ]]; then
      local field_name="${json_path##*.}"
      field_name="${field_name//\$/}"
      grep -q "\"$field_name\"" "$json_file"
    else
      grep -F -q "\"$expected\"" "$json_file"
    fi
  fi
}

# Check boundary constraints
check_boundary() {
  local url="$1"
  local spec="$2"
  local param="${spec%%=*}"
  local range="${spec#*=}"
  local min_val="${range%%,*}"
  local max_val="${range##*,}"
  
  # Extract parameter from URL
  if [[ "$url" == *"$param="* ]]; then
    local param_value="${url##*$param=}"
    param_value="${param_value%%&*}"
    local len="${#param_value}"
    
    # Check if it's numeric or string
    if [[ "$param_value" =~ ^[0-9]+$ ]]; then
      # Numeric boundary check
      [[ "$param_value" -ge "$min_val" && "$param_value" -le "$max_val" ]]
    else
      # String length boundary check
      [[ "$len" -ge "$min_val" && "$len" -le "$max_val" ]]
    fi
  else
    # Parameter not in URL, consider it a failure if boundary is required
    false
  fi
}

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%$'\r'}"
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  method="$(awk '{print $1}' <<<"$line")"
  path="$(awk '{print $2}' <<<"$line")"
  expect_status="$(awk '{print $3}' <<<"$line")"
  
  # Extract all remaining parts for parsing
  remaining="$(cut -d' ' -f4- <<<"$line" | sed -e 's/^[[:space:]]*//')"

  if [[ -z "$method" || -z "$path" || -z "$expect_status" ]]; then
    echo "SKIP invalid line: $line" | tee -a "$RUN_LOG"
    continue
  fi

  # Parse test options
  is_negative=0
  expect_grep=""
  json_checks=()
  boundary_checks=()
  
  for part in $remaining; do
    if [[ "$part" == "NEGATIVE" ]]; then
      is_negative=1
    elif [[ "$part" =~ ^JSON: ]]; then
      json_checks+=("${part#JSON:}")
    elif [[ "$part" =~ ^BOUNDARY: ]]; then
      boundary_checks+=("${part#BOUNDARY:}")
    else
      # Legacy: simple grep check (if not a special option)
      if [[ -z "$expect_grep" ]]; then
        expect_grep="$part"
      fi
    fi
  done

  url="${BASE_URL%/}$path"
  total=$((total+1))

  http_code="$(
    curl -sS -X "$method" \
      -o "$tmp_body" \
      -w "%{http_code}" \
      "$url" \
      || echo "000"
  )"

  ok=1
  reason=""
  test_type="normal"

  # For negative tests, invert the status check logic
  if [[ "$is_negative" -eq 1 ]]; then
    test_type="negative"
    # Negative test: expect failure status (4xx or 5xx)
    if [[ ! "$http_code" =~ ^[45] ]]; then
      ok=0
      reason="negative test: expected 4xx/5xx but got $http_code"
    fi
  else
    # Normal test: expect exact status match
    if [[ "$http_code" != "$expect_status" ]]; then
      ok=0
      reason="expected $expect_status got $http_code"
    fi
  fi

  # Legacy grep check
  if [[ -n "$expect_grep" && "$ok" -eq 1 ]]; then
    if ! grep -F -q -- "$expect_grep" "$tmp_body"; then
      ok=0
      reason="${reason:+$reason; }missing body substring: $expect_grep"
    fi
  fi

  # JSON field checks
  for json_check in "${json_checks[@]}"; do
    if [[ "$ok" -eq 1 ]]; then
      if ! check_json_field "$tmp_body" "$json_check"; then
        ok=0
        reason="${reason:+$reason; }JSON field mismatch: $json_check"
      fi
    fi
  done

  # Boundary checks
  for boundary_check in "${boundary_checks[@]}"; do
    if [[ "$ok" -eq 1 ]]; then
      if ! check_boundary "$url" "$boundary_check"; then
        ok=0
        reason="${reason:+$reason; }boundary violation: $boundary_check"
      fi
    fi
  done

  if [[ "$ok" -eq 1 ]]; then
    passed=$((passed+1))
    echo "PASS [$test_type] $method $path ($http_code)" | tee -a "$RUN_LOG"
  else
    failed=$((failed+1))
    echo "FAIL [$test_type] $method $path ($http_code) - $reason" | tee -a "$RUN_LOG"
    cp "$tmp_body" "$ARTIFACTS_DIR/body_${total}.txt" || true
  fi
done <"$ENDPOINTS_FILE"

cat >"$RESULTS_JSON" <<EOF
{
  "ok": $([[ "$failed" -eq 0 ]] && echo true || echo false),
  "counts": { "total": $total, "passed": $passed, "failed": $failed },
  "base_url": "$(json_escape "$BASE_URL")",
  "endpoints_file": "$(json_escape "$ENDPOINTS_FILE")",
  "artifacts_dir": "$(json_escape "$ARTIFACTS_DIR")"
}
EOF

echo "Summary: total=$total passed=$passed failed=$failed" | tee -a "$RUN_LOG"
echo "Artifacts: $ARTIFACTS_DIR"

if [[ "$failed" -eq 0 ]]; then
  exit 0
fi
exit 2

*** Add File: .codex/skills/.dev/api-test-creator/assets/start_and_test.sh
#!/usr/bin/env bash
set -euo pipefail

START_CMD="${START_CMD:?set START_CMD, e.g. 'npm run dev' or './bin/server'}"
START_CWD="${START_CWD:-.}"
BASE_URL="${BASE_URL:?set BASE_URL, e.g. http://localhost:8080}"
READY_PATH="${READY_PATH:-/healthz}"
READY_TIMEOUT_S="${READY_TIMEOUT_S:-60}"
READY_INTERVAL_S="${READY_INTERVAL_S:-1}"
ENDPOINTS_FILE="${ENDPOINTS_FILE:-scripts/api_test/endpoints.txt}"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts/api-test/$(date -u +%Y%m%d-%H%M%S)}"
mkdir -p "$ARTIFACTS_DIR"

SERVICE_LOG="$ARTIFACTS_DIR/service.log"
RUN_LOG="$ARTIFACTS_DIR/run.log"

echo "START_CMD=$START_CMD" >"$ARTIFACTS_DIR/env.txt"
echo "START_CWD=$START_CWD" >>"$ARTIFACTS_DIR/env.txt"
echo "BASE_URL=$BASE_URL" >>"$ARTIFACTS_DIR/env.txt"
echo "READY_PATH=$READY_PATH" >>"$ARTIFACTS_DIR/env.txt"
echo "ENDPOINTS_FILE=$ENDPOINTS_FILE" >>"$ARTIFACTS_DIR/env.txt"

service_pid=""
cleanup() {
  if [[ -n "$service_pid" ]]; then
    kill "$service_pid" >/dev/null 2>&1 || true
    wait "$service_pid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

(cd "$START_CWD" && bash -lc "$START_CMD") >"$SERVICE_LOG" 2>&1 &
service_pid="$!"

deadline=$(( $(date +%s) + READY_TIMEOUT_S ))
ready_url="${BASE_URL%/}${READY_PATH}"
last=""
while [[ "$(date +%s)" -lt "$deadline" ]]; do
  code="$(curl -sS -o /dev/null -w "%{http_code}" "$ready_url" || echo "000")"
  if [[ "$code" =~ ^2|3 ]]; then
    last="$code"
    break
  fi
  last="$code"
  sleep "$READY_INTERVAL_S"
done

if [[ ! "$last" =~ ^2|3 ]]; then
  echo "Service not ready after ${READY_TIMEOUT_S}s ($ready_url); last status=$last" | tee "$RUN_LOG"
  exit 3
fi

BASE_URL="$BASE_URL" ENDPOINTS_FILE="$ENDPOINTS_FILE" ARTIFACTS_DIR="$ARTIFACTS_DIR" \
  bash "scripts/api_test/run.sh" | tee -a "$RUN_LOG"

if rg -n "(ERROR|FATAL|PANIC|EXCEPTION|Traceback \\(most recent call last\\):)" "$SERVICE_LOG" >/dev/null 2>&1; then
  echo "Log scan: found error signatures in service.log" | tee -a "$RUN_LOG"
  exit 4
fi

echo "Artifacts: $ARTIFACTS_DIR" | tee -a "$RUN_LOG"
