# Proposal: Add openspec_change_apply skill

## Goal

Add a new skill for OpenSpec change execution that is stage-gated and human-led, with clear guardrails and stop conditions.

## Scope

- Create a new skill under `.ai/skills/openspec_change_apply/` with a skill definition file and four stage files:
  - `skill.md` (or `SKILL.md` if required by the skill system)
  - `stages/01_review.md`
  - `stages/02_refine.md`
  - `stages/03_validate.md`
  - `stages/04_implement.md`
- Encode the five first-principles requirements:
  - Applicable scenarios
  - Inputs
  - Outputs
  - Prohibitions
  - Mandatory human stop points
- Stage semantics:
  - Review: surface ambiguity and decision points
  - Refine: only clarify within the existing change document (no scope expansion)
  - Validate: compliance/legal review; emit violations/edge cases/needs-human-decision
  - Implement: produce patch/diff only; no direct apply; no refactors

## Out of Scope

- Any application code changes
- Any new OpenSpec CLI scripts or tooling
- Any changes outside `.ai/skills/openspec_change_apply/`

## Deliverables

- `.ai/skills/openspec_change_apply/skill.md` (or `SKILL.md` if required)
- `.ai/skills/openspec_change_apply/stages/01_review.md`
- `.ai/skills/openspec_change_apply/stages/02_refine.md`
- `.ai/skills/openspec_change_apply/stages/03_validate.md`
- `.ai/skills/openspec_change_apply/stages/04_implement.md`

## Open Questions

1. Should the skill definition file be named `skill.md` to match the requested structure, or `SKILL.md` to match existing skill conventions?
2. Should the frontmatter follow the existing `SKILL.md` format (YAML with `name` and `description`) if the file is named `skill.md`?

