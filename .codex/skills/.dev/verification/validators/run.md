# Run Validator

## Purpose

Provide a runtime validation signal by executing the target program in a controlled, bounded, and auditable manner. This is used to detect obvious runtime failures (for example, crash on startup, immediate fatal errors, misconfiguration).

## Input

- Current working tree or patch
- A human-defined run command and expected environment
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

## Procedure

- If the standard run command is not defined, stop and request clarification from a human.
- Execute the program in background mode.
- Redirect STDOUT and STDERR to a log file.
- Capture the PID at start time and persist it for all further actions.
- Wait for a fixed delay (default: 60 seconds).
- Verify whether the process is still running after the delay.
- Terminate the process after verification.
- Only terminate the captured PID and verify it still belongs to the original command before termination. If PID ownership verification fails, abort termination.

## Output

- pass or fail (based only on procedure completion, not interpretation of logs)
- command executed
- log file path
- captured PID
- whether the process was still running after the delay
- termination result
- notable log output (verbatim, no interpretation)

## Constraints

- Do not modify code.
- Do not restart the process.
- Do not extend runtime beyond the defined delay.
- Do not interpret runtime behavior as success or failure.
- Do not kill by process name, port, or pattern matching.
