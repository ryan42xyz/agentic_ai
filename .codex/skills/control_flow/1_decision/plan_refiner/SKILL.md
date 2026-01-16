---
name: plan-refiner
description: Select one and only one unresolved uncertainty to address next, based on `state/current.yaml` and validation evidence. Writes a single plan action file under `actions/`.
---

# Plan Refiner

## Purpose

Select one and only one unresolved uncertainty to address next.

## Inputs (read-only)

- `openspec/changes/<change-name>/state/current.yaml`
- `openspec/changes/<change-name>/evidence/state_validator/validation.md` (if exists)
- `openspec/changes/<change-name>/notes/open-questions.md` (if exists)

## Outputs (write-only)

- Write only:
  - `openspec/changes/<change-name>/actions/action-XXX-plan.md`
- Do not write anywhere else.

## Output Must Specify

- Target open question ID
- Why it blocks progress
- What type of action is needed:
  - `info_retrieval`
  - `code_change`
  - `execution_run`
  - `wait`
  - `defer`

## Forbidden

- Solving the question
- Designing the solution
- Bundling multiple actions
- Writing evidence
- Writing or modifying state

