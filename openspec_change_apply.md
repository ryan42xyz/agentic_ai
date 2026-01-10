===== FILE: .codex/skills/.dev/openspec_change_apply/SKILL.md =====
---
name: change-execution
description: Execute an OpenSpec change proposal in a human-led, stage-gated way. Use when a user asks to apply, implement, or execute an OpenSpec change, or to run the review/refine/validate/implement stages for a change document in openspec/changes/.
---

# Change Execution

This skill assists with executing an OpenSpec change proposal.

It is designed to be human-led and stage-gated. Stages are internal steps; they are not free-form tools.

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

===== FILE: .codex/skills/.dev/openspec_change_apply/stages/01_review.md =====
# Stage 01: Review

Purpose
- Surface ambiguity, missing information, and decision points early.

Inputs
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

Process
- Read the change document as the single source of intent.
- Identify unclear requirements, unstated assumptions, and risks.
- List any missing inputs or artifacts needed to proceed.

Outputs
- `ambiguities`
- `assumptions`
- `decision_points`
- `missing_inputs`

Stop
- Always stop after review and wait for human approval to proceed.

===== FILE: .codex/skills/.dev/openspec_change_apply/stages/02_refine.md =====
# Stage 02: Refine

Purpose
- Clarify the change document without expanding scope.
- Make uncertainty explicit rather than "optimizing" the plan.

Inputs
- Change document in `openspec/changes/<change-name>/...`
- Output from Stage 01

Constraints
- Only modify the change document.
- Do not introduce new scope or new feature points.
- Do not add new requirements.
- Do not rewrite for style; focus on clarity and precision.

Process
- Turn ambiguities into explicit statements or questions.
- Mark unknowns clearly.
- Make assumptions explicit and bounded.

Outputs
- Proposed edits to the change document (diff or patch)
- A short list of items that still require human decision

Stop
- Always stop after refine and wait for human approval to proceed.

===== FILE: .codex/skills/.dev/openspec_change_apply/stages/03_validate.md =====
# Stage 03: Validate

Purpose
- Compliance and constraints check, not a technical review.

Inputs
- Change document in `openspec/changes/<change-name>/...`
- `openspec/project.md`
- `openspec/AGENTS.md`

Checks
- Conflicts with documented constraints
- Missing approvals or required human decisions
- Edge cases that violate the stated scope

Outputs
- `violations`
- `edge_cases`
- `needs_human_decision`

Stop
- If any item exists in outputs, stop and wait for human decision.
- Do not proceed to implementation without explicit approval.

===== FILE: .codex/skills/.dev/openspec_change_apply/stages/04_implement.md =====
# Stage 04: Implement

Purpose
- Execute the approved change as a contractor, not an engineer.

Inputs
- Approved change document in `openspec/changes/<change-name>/...`
- Any files explicitly referenced by the change document

Constraints
- Output must be a diff or patch only.
- Do not apply changes directly.
- Do not refactor or clean up unrelated code.
- Do not introduce new scope or features.
- If requirements are unclear, stop.

Output
- A single patch/diff that implements the change.

Stop
- If you cannot produce a safe, direct patch, stop and ask for human guidance.

===== FILE: .codex/skills/.dev/openspec_change_apply/stages/05_sync_knowledge.md =====
# Stage 05: Sync Knowledge

Purpose
- Determine whether the change alters any system facts that must be reflected
  in human-facing or system-level knowledge artifacts.
- Prevent silent knowledge drift between code and documentation.

Inputs
- Approved change document in `openspec/changes/<change-name>/...`
- Implementation context (what was actually changed)
- `openspec/project.md`
- `openspec/AGENTS.md`

Process
- Treat the change document as the source of intent.
- Compare intended behavior with post-implementation behavior.
- Identify whether the change affects any of the following knowledge domains:
  - Usage and public behavior (e.g. README)
  - System structure or boundaries (e.g. Architecture)
  - Data contracts or schemas (e.g. Schema / API contracts)
  - Operational assumptions (e.g. runbooks, limits, invariants)
- For each affected domain:
  - Describe what system fact has changed.
  - Assess the impact level (low / medium / high).
  - State whether human review and update is required.

Outputs
- `knowledge_impacts`:
  - domain
  - description of changed fact
  - impact_level
  - requires_human_update (yes / no)
- `update_recommendations`:
  - which artifacts may need to be updated
  - why they are impacted
- `risk_notes` (if any):
  - potential consequences of leaving knowledge unsynchronized

Stop
- Always stop after analysis.
- Do NOT update any documents.
- Do NOT assume updates will be performed.
- Wait for explicit human decision on whether and how to update knowledge artifacts.

