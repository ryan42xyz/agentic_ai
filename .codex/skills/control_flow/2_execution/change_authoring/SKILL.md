---
name: change-authoring
description: Produce a minimal, scoped code change as a patch artifact based on an executable action. Never writes directly to the repo.
---

# Change Authoring

## Purpose

Produce a minimal, scoped change as a patch artifact.

## Inputs (read-only)

- `openspec/changes/<change-name>/actions/action-XXX-exec.md`
- Working repo (read-only)

## Outputs (write-only)

- Write only:
  - `openspec/changes/<change-name>/evidence/change_authoring/patch.diff`
- Do not write anywhere else.

## Forbidden

- Direct repo writes
- Refactors / cleanup outside declared scope
- Validation
- Writing or modifying state
- Writing decision outputs

