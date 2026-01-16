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
   - How to start the service (command, cwd, env), or "already running"
   - Base URL, readiness endpoint/path, auth method, required headers
   - Endpoints to test + expectations (status, JSON fields, regex, etc.)
   - Parameter boundaries (min/max length, numeric ranges) if needed
3. Choose implementation mode:
   - **Shell-only (default)**: Scaffold `.sh` scripts under `scripts/api_test/` via `scripts/scaffold_api_test_suite.py`.
   - **Existing framework (optional)**: Only use if the user explicitly requests adding tests to the repo's test framework.
4. Implement the tests:
   - **Basic tests**: Status codes, required headers, and substring checks.
   - **Output comparison**: Use `JSON:path=value` for structured JSON field validation.
   - **Negative test cases**: Add `NEGATIVE` flag or use `generate_test_cases.py` to auto-generate error scenarios.
   - **Boundary checking**: Use `BOUNDARY:param=min,max` to validate parameter constraints.
   - Keep test data isolated; avoid destructive endpoints unless explicitly requested.
5. Run and capture evidence:
   - If starting the service, run it in background, save `service.log`, poll readiness, run cases, and save `results.json` under an artifacts directory.
   - Scan logs for obvious error signatures and surface them in the results (do not "fix" silently; report).
6. If OpenSpec is being used for changes:
   - Draft/extend the change proposal first, then apply code changes, then run verification per repo policy.

## Output Contract (default)

- Do not modify existing application code. Prefer only adding new files under `./scripts/api_test/` (unless the user explicitly requests otherwise).
- **When scaffolding**: Create `./scripts/api_test/` containing:
  - `run.sh` (runs endpoint checks via `curl` with support for JSON comparison, boundary checking, and negative tests)
  - `start_and_test.sh` (optional: start service, wait ready, run `run.sh`, kill service, scan log)
  - `endpoints.txt` (editable list of endpoints and expectations; starts from `endpoints.example.txt`)
  - `generate_test_cases.py` (utility script to auto-generate negative and boundary test cases)
- **Artifacts** (runtime output, not necessarily committed): `./artifacts/api-test/<timestamp>/` containing `service.log` (if started), `run.log`, `results.json`, and `body_*.txt` (failed test response bodies).

## Features

### 1. Testing (基础测试)
- HTTP method validation (GET, POST, PUT, DELETE, etc.)
- Status code verification
- Response body substring matching
- Test result tracking and reporting

### 2. Output Comparison (输出对比)
- **Status code comparison**: Exact match validation
- **Substring matching**: Simple grep-based checks (legacy)
- **JSON field comparison**: Structured field validation using `jq` syntax
  - Supports nested paths: `JSON:$.user.name=John`
  - Wildcard check: `JSON:$.token=*` (field exists and non-empty)
  - Falls back to grep if `jq` unavailable

### 3. Counterexample Construction (反例构造)
- **Negative test flag**: Add `NEGATIVE` to expect error responses (4xx/5xx)
- **Auto-generation**: `generate_test_cases.py --negative` creates invalid input scenarios
  - Invalid HTTP methods
  - Missing/invalid path parameters
  - Unauthorized access attempts
- **Manual specification**: Define expected error cases explicitly

### 4. Boundary Checking (边界检查)
- **Parameter validation**: `BOUNDARY:param=min,max` format
- **String length**: Validates parameter length boundaries
- **Numeric ranges**: Validates numeric parameter min/max values
- **Auto-generation**: `generate_test_cases.py --boundary` creates boundary test cases
- **Combined validation**: Multiple boundary checks per endpoint

## Bundled Resources

### scripts/
- `scripts/scaffold_api_test_suite.py`: Copy a minimal, shell-only API test suite into the current repo.
- `scripts/generate_test_cases.py`: Generate negative and boundary test cases automatically.

### references/
- `references/sh-format.md`: `endpoints.txt` format and supported expectations (including JSON comparison, boundary checking, and negative tests).

## Usage Examples

**Basic test:**
```bash
BASE_URL=http://localhost:8080 bash scripts/api_test/run.sh
```

**With auto-generated test cases:**
```bash
# Generate additional test cases
python scripts/api_test/generate_test_cases.py --negative --boundary

# Run all tests (including generated ones)
cat scripts/api_test/endpoints.txt scripts/api_test/endpoints.generated.txt > /tmp/all_tests.txt
ENDPOINTS_FILE=/tmp/all_tests.txt BASE_URL=http://localhost:8080 bash scripts/api_test/run.sh
```

**Full test suite with service startup:**
```bash
START_CMD='npm run dev' BASE_URL=http://localhost:8080 bash scripts/api_test/start_and_test.sh
```
