# Verification Policy

## Required Validators

- compile
- test
- api_test
- run

## Failure Semantics

- Any failure in a required validator blocks the change.
- Failures must be reported verbatim.
- Partial success is not sufficient.

## Overrides

- Overrides require explicit human acknowledgment.
- The reason for override must be documented.
- The skill must not proceed without the human decision.

## Example Validation Report Format

```text
verification_report:
  change_id: add-verification-skill
  required_validators:
    - name: compile
      command: "<compile command here>"
      exit_code: "<exit code here>"
      output: |
        <verbatim compiler output>
    - name: test
      command: "<test command here>"
      exit_code: "<exit code here>"
      output: |
        <verbatim test output>
    - name: run
      command: "<run command here>"
      exit_code: "<exit code here>"
      output: |
        <verbatim run output>
  overrides:
    requested: "<human-only>"
    approved_by: "<human-only>"
    reason: "<human-only>"
```
