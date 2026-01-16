---
name: execution-runner
description: Execute a declared command/test and capture raw output as evidence. No interpretation or retries.
---

# Execution Runner

## Purpose

Execute a declared command or test and capture raw output.

## Inputs (read-only)

- `openspec/changes/<change-name>/actions/action-XXX-exec.md`

## Outputs (write-only)

- Write only:
  - `openspec/changes/<change-name>/evidence/run/<run-id>.md`
- Do not write anywhere else.

## Forbidden

- Explaining results
- Declaring success/failure
- Retrying automatically
- Writing or modifying state
- Writing decision outputs

