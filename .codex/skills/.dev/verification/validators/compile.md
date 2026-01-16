# Compile Validator

## Purpose

Verify that the codebase compiles successfully after applying the change.

## Input

- Current working tree or patch
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

## Procedure

- Run the standard project compilation command(s) defined by project docs or the change proposal.
- If the standard compile command is not defined, stop and request clarification from a human.

## Output

- pass or fail
- verbatim compiler output

## Constraints

- Do not modify code to make compilation pass.
- Do not reinterpret failures as acceptable.
