# API Test Validator

## Purpose

Verify that API-level checks pass after the change. This validator is intended for integration / end-to-end API tests (for example: Postman/Newman collections, contract tests, smoke tests, or HTTP-level test suites).

## Input

- Current working tree or patch
- A human-defined API test command (and any required env vars)
- Optional: a human-defined server start command if the API tests require a local running service
- Optional: a human-defined health check command to confirm readiness (for example: `curl -fsS http://127.0.0.1:PORT/healthz`)
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

## Procedure

- If the standard API test command is not defined, stop and request clarification from a human.
- If a server start command is defined:
  - Start the server in background mode.
  - Redirect STDOUT and STDERR to a log file.
  - Capture the PID at start time and persist it for all further actions.
  - Wait for a fixed delay (default: 30 seconds) or run the provided readiness check command once per second until it succeeds (bounded by the delay).
- Execute the API test command with a bounded timeout (default: 10 minutes).
- Record the exit code and capture output verbatim.
- If a server was started, terminate the captured PID after tests complete.
- Only terminate the captured PID and verify it still belongs to the original command before termination. If PID ownership verification fails, abort termination.

## Output

- pass or fail (based on API test command exit code)
- API test command executed
- captured exit code
- API test output (verbatim)
- if a server was started:
  - server start command executed
  - log file path
  - captured PID
  - readiness check result (if provided)
  - termination result

## Constraints

- Do not modify code.
- Do not skip API tests.
- Do not reinterpret failures as acceptable.
- Do not hit external environments unless the human explicitly defines and approves the target.
