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
  if [[ "$code" =~ ^[23] ]]; then
    last="$code"
    break
  fi
  last="$code"
  sleep "$READY_INTERVAL_S"
done

if [[ ! "$last" =~ ^[23] ]]; then
  echo "Service not ready after ${READY_TIMEOUT_S}s ($ready_url); last status=$last" | tee "$RUN_LOG"
  exit 3
fi

BASE_URL="$BASE_URL" ENDPOINTS_FILE="$ENDPOINTS_FILE" ARTIFACTS_DIR="$ARTIFACTS_DIR" \
  bash "scripts/api_test/run.sh" | tee -a "$RUN_LOG"

if grep -E -n "(ERROR|FATAL|PANIC|EXCEPTION|Traceback \\(most recent call last\\):)" "$SERVICE_LOG" >/dev/null 2>&1; then
  echo "Log scan: found error signatures in service.log" | tee -a "$RUN_LOG"
  exit 4
fi

echo "Artifacts: $ARTIFACTS_DIR" | tee -a "$RUN_LOG"

