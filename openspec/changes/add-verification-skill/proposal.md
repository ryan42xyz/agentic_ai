# Proposal: Add verification skill with validators

## Goal

Create a Verification Skill with separate validator documents (compile, test) to encode stage-gated validation rules and human-only overrides, plus an example validation report format.

## Scope

- Add a new Verification Skill under `.ai/skills/verification/`:
  - `skill.md` (legal/guardrail definition)
  - `policy.md` (validation policy and failure semantics)
  - `validators/compile.md`
  - `validators/test.md`
- Define validator inputs, procedures, outputs, and constraints to prevent reinterpretation of failures.
- Encode explicit human-only override requirements in policy.
- Include an example validation report format.

## Out of Scope

- Any application code changes
- Any tooling or CLI changes
- Any changes outside `.ai/skills/verification/`

## Deliverables

`.ai/skills/verification/skill.md`
`.ai/skills/verification/policy.md`
`.ai/skills/verification/validators/compile.md`
`.ai/skills/verification/validators/test.md`

## Open Questions

1. None.
