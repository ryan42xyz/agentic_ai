===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/SKILL.md =====
---
name: api-test-creator
description: Create runnable API smoke tests as shell scripts (.sh) based on user requirements and repo context. Use when the user asks to add/author API tests, HTTP endpoint checks, or a repeatable script that starts a service, runs requests, saves logs/artifacts, and scans logs for errors. This skill must NOT modify application source code—only add new scripts and artifacts.
---

# Api Test Creator

## Workflow

1. Read project constraints and context:
   - `openspec/AGENTS.md` and `openspec/project.md`
   - repo `AGENTS.md` and any `PROJECT.md` / service docs / run scripts
2. Confirm inputs (do not guess):
   - How to start the service (command, cwd, env), or “already running”
   - Base URL, readiness endpoint/path, auth method, required headers
   - Endpoints to test + expectations (status, JSON fields, regex, etc.)
3. Choose implementation mode:
   - **Shell-only (default)**: Scaffold `.sh` scripts under `scripts/api_test/` via `scripts/scaffold_api_test_suite.py`.
   - **Existing framework (optional)**: Only use if the user explicitly requests adding tests to the repo’s test framework.
4. Implement the tests:
   - Prefer deterministic checks: status codes, required headers, and minimal `grep` checks.
   - Keep test data isolated; avoid destructive endpoints unless explicitly requested.
5. Run and capture evidence:
   - If starting the service, run it in background, save `service.log`, poll readiness, run cases, and save `results.json` under an artifacts directory.
   - Scan logs for obvious error signatures and surface them in the results (do not “fix” silently; report).
6. If OpenSpec is being used for changes:
   - Draft/extend the change proposal first, then apply code changes, then run verification per repo policy.

## Output Contract (default)

- Do not modify existing application code. Prefer only adding new files under `./scripts/api_test/` (unless the user explicitly requests otherwise).
- **When scaffolding**: Create `./scripts/api_test/` containing:
  - `run.sh` (runs endpoint checks via `curl`)
  - `start_and_test.sh` (optional: start service, wait ready, run `run.sh`, kill service, scan log)
  - `endpoints.txt` (editable list of endpoints and expectations; starts from `endpoints.example.txt`)
- **Artifacts** (runtime output, not necessarily committed): `./artifacts/api-test/<timestamp>/` containing `service.log` (if started), `run.log`, `results.json`.

## Bundled Resources

### scripts/
- `scripts/scaffold_api_test_suite.py`: Copy a minimal, shell-only API test suite into the current repo.

### references/
- `references/sh-format.md`: `endpoints.txt` format and supported expectations.

===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/assets/endpoints.example.txt =====
# One per line:
# METHOD PATH EXPECT_STATUS [EXPECT_GREP_SUBSTRING]
GET /healthz 200 ok


===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/assets/run.sh =====
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

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%$'\r'}"
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  method="$(awk '{print $1}' <<<"$line")"
  path="$(awk '{print $2}' <<<"$line")"
  expect_status="$(awk '{print $3}' <<<"$line")"
  expect_grep="$(cut -d' ' -f4- <<<"$line" | sed -e 's/^[[:space:]]*//')"

  if [[ -z "$method" || -z "$path" || -z "$expect_status" ]]; then
    echo "SKIP invalid line: $line" | tee -a "$RUN_LOG"
    continue
  fi

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

  if [[ "$http_code" != "$expect_status" ]]; then
    ok=0
    reason="expected $expect_status got $http_code"
  fi

  if [[ -n "$expect_grep" ]]; then
    if ! grep -F -q -- "$expect_grep" "$tmp_body"; then
      ok=0
      reason="${reason:+$reason; }missing body substring: $expect_grep"
    fi
  fi

  if [[ "$ok" -eq 1 ]]; then
    passed=$((passed+1))
    echo "PASS $method $path ($http_code)" | tee -a "$RUN_LOG"
  else
    failed=$((failed+1))
    echo "FAIL $method $path ($http_code) - $reason" | tee -a "$RUN_LOG"
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

===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/assets/start_and_test.sh =====
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


===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/references/sh-format.md =====
# Shell API Test Format (`endpoints.txt`)

This skill scaffolds a shell-only API smoke test suite under `scripts/api_test/`.

## `endpoints.txt` format

One endpoint per line:

```
METHOD PATH EXPECT_STATUS [EXPECT_GREP]
```

Examples:

```
GET /healthz 200 ok
GET /metrics 200
POST /v1/login 200 '"token":'
```

Notes:
- Blank lines and lines starting with `#` are ignored.
- `EXPECT_GREP` is optional. If present, `run.sh` checks the response body contains this substring.
- This is intentionally simple and dependency-free (no `jq` required).


===== FILE: /Users/rshao/work/code_repos/agentic_ai/.codex/skills/.dev/api-test-creator/scripts/scaffold_api_test_suite.py =====
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
import stat
from pathlib import Path


def _skill_dir() -> Path:
    return Path(__file__).resolve().parents[1]


def _copy_file(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Scaffold a minimal, shell-only API test suite into the current repo."
    )
    parser.add_argument(
        "--out-dir",
        default="scripts/api_test",
        help="Output directory inside the target repo (default: scripts/api_test)",
    )
    parser.add_argument("--force", action="store_true", help="Overwrite existing files if present.")
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    if out_dir.exists() and not args.force:
        raise SystemExit(f"refusing to overwrite existing {out_dir}; pass --force")

    if out_dir.exists() and args.force:
        shutil.rmtree(out_dir)

    out_dir.mkdir(parents=True, exist_ok=True)

    skill_dir = _skill_dir()
    endpoints_src = skill_dir / "assets" / "endpoints.example.txt"
    run_sh_src = skill_dir / "assets" / "run.sh"
    start_and_test_src = skill_dir / "assets" / "start_and_test.sh"

    _copy_file(endpoints_src, out_dir / "endpoints.example.txt")
    _copy_file(endpoints_src, out_dir / "endpoints.txt")
    _copy_file(run_sh_src, out_dir / "run.sh")
    _copy_file(start_and_test_src, out_dir / "start_and_test.sh")

    for script in ["run.sh", "start_and_test.sh"]:
        path = out_dir / script
        path.chmod(path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    print(f"[OK] Scaffolded: {out_dir}")
    print("Next:")
    print(f"  - Edit {out_dir / 'endpoints.txt'} to add endpoints")
    print(f"  - Run: BASE_URL=http://localhost:8080 {out_dir / 'run.sh'}")
    print(f"  - Or:  START_CMD='...' BASE_URL=http://localhost:8080 {out_dir / 'start_and_test.sh'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

