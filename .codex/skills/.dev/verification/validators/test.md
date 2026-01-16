# Test Validator

## Purpose

Verify that existing automated tests pass after the change.

## Input

- Current working tree or patch
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

## Procedure

- Run the standard project test suite defined by project docs or the change proposal.
- If the standard test command is not defined, stop and request clarification from a human.

## Output

- pass or fail
- failing test names and logs (verbatim)

## Constraints

- Do not add or modify tests.
- Do not skip tests.
- Do not reinterpret failures as acceptable.
