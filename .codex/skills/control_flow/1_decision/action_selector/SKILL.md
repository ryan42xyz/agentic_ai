---
name: action-selector
description: Translate a single approved plan action into a single executable action declaration. Writes only to `openspec/changes/<change-name>/actions/`.
---

# Action Selector

## Purpose

Translate a refined plan into a single executable action declaration.

## Inputs (read-only)

- `openspec/changes/<change-name>/actions/action-XXX-plan.md`

## Outputs (write-only)

- Write only:
  - `openspec/changes/<change-name>/actions/action-XXX-exec.md`
- Do not write anywhere else.

## Output Format

The action declaration MUST include:

- Action type
- Adapter to use
- Scope (explicitly bounded)
- Forbidden side effects (explicit)

## Forbidden

- Execution
- Validation
- Replanning
- Writing evidence
- Writing or modifying state

