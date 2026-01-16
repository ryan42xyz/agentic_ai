---
name: change-execution
description: Execute an OpenSpec change proposal in a human-led, stage-gated way. Use when a user asks to apply, implement, or execute an OpenSpec change, or to run the review/refine/validate/implement stages for a change document in openspec/changes/.
---

# Change Execution

This skill assists with executing an OpenSpec change proposal.

It is designed to be human-led and stage-gated. Stages are internal steps; they are not free-form tools.

## OpenSpec strict mode (hard-require)

This skill is only valid when the target repository has a working OpenSpec change workspace.

Preconditions (ALL required):
- `openspec/changes/<change-name>/` exists
- `openspec/changes/<change-name>/request.md` exists
- `openspec/project.md` exists
- `openspec/AGENTS.md` exists

If any precondition is missing, STOP and ask the human to run OpenSpec init/scaffold (or point you at the correct repo).

## First principles

A valid run must state all of the following:

1. Applicable scenario
2. Inputs
3. Outputs
4. Prohibitions
5. Mandatory human stop points

If any of the above are missing, stop and ask for clarification.

## Guardrails

The assistant must never:
- Modify application code outside an explicit, approved change proposal
- Introduce new scope or new feature points beyond the change document
- Skip stages or merge stages without human approval
- Apply code changes directly during implementation
- "Clean up" or refactor unrelated code

## Inputs

Required:
- The change document at `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

Optional:
- Any files explicitly referenced by the change document

## Outputs

Stage outputs are defined in the stage files:
- `stages/01_review.md`
- `stages/02_refine.md`
- `stages/03_validate.md`
- `stages/04_implement.md`
- `stages/05_sync_knowledge.md`

All persistent artifacts MUST be written under `openspec/changes/<change-name>/evidence/**` (never into app code or OpenSpec state).

## Mandatory stop points

- After each stage, wait for explicit human approval before moving on.
- If the change document is ambiguous or incomplete, stop.
- If validation finds violations, edge cases, or needs-human-decisions, stop.

## Stages

Follow in order:
1. Review
2. Refine
3. Validate
4. Implement
5. Sync Knowledge

See each stage file for exact constraints and outputs.
