---
title: ".dev/* + OpenSpec strict checklist"
scope: "OpenSpec hard-require workflows"
---

# One-page checklist: `.dev/*` as UX, OpenSpec as kernel

## Preconditions (hard-require)

- `openspec/changes/<change-name>/` exists
- `openspec/changes/<change-name>/request.md` exists
- `openspec/project.md` exists
- `openspec/AGENTS.md` exists
- You have an explicit `<change-name>` (no guessing)

If any are missing: STOP and ask the human to scaffold/init OpenSpec (or point to the correct repo).

## Output discipline (always)

- Write only under `openspec/changes/<change-name>/actions/**` or `openspec/changes/<change-name>/evidence/**` (and `state/**` only via `skills/0_control/execution_state_compiler`).
- Evidence is verbatim (raw outputs/excerpts), with source + method + time window.
- No “verdict” from execution; go/no-go is a human decision based on evidence.

## `.dev/openspec_change_apply` stage contract

- Stage 01 Review → `openspec/changes/<change-name>/evidence/change_execution/01_review.md`
  - Must include: `ambiguities`, `assumptions`, `decision_points`, `missing_inputs`
  - Stop for human approval.

- Stage 02 Refine → `openspec/changes/<change-name>/evidence/change_execution/02_refine.patch`
  - Patch only; do not apply.
  - Only edits the change document; no scope expansion; no new requirements.
  - Stop for human approval.

- Stage 03 Validate → `openspec/changes/<change-name>/evidence/change_execution/03_validate.md`
  - Must include: `violations`, `edge_cases`, `needs_human_decision`
  - If any exist: STOP (human decision required).

- Stage 04 Implement → `openspec/changes/<change-name>/evidence/change_authoring/patch.diff`
  - Minimal diff only; do not apply; no refactors; no unrelated cleanup.
  - If requirements are unclear: STOP.

- Stage 05 Sync Knowledge → `openspec/changes/<change-name>/evidence/change_execution/05_sync_knowledge.md`
  - Must include: `knowledge_impacts`, plus optional `update_recommendations`, `risk_notes`
  - Do not update docs; stop for human decision.

## `.dev/verification` contract (evidence-only)

- Required validators come from `.dev/verification/policy.md`
- Commands must be explicitly defined by the human (or already specified in change docs); if missing: STOP.
- Write only: `openspec/changes/<change-name>/evidence/verification/verification.md`
  - For each validator: `command`, `cwd/env notes (human-provided)`, timestamps, `exit_code`, raw stdout/stderr excerpt (or file paths).

## Canonical OpenSpec kernel skills (when you want strict replayability)

- Decide “next single action”: `skills/1_decision/plan_refiner`
- Translate plan → exec declaration: `skills/1_decision/action_selector`
- Produce patch artifact (no repo writes): `skills/2_execution/change_authoring`
- Run commands/tests and capture raw output: `skills/2_execution/execution_runner`
- Retrieve raw info and store as evidence: `skills/2_execution/info_retrieval`
- Compile snapshots (only state writer): `skills/0_control/execution_state_compiler`
- Validate state structure/integrity: `skills/0_control/state_validator`
- Detect meaningful progress vs rephrase: `skills/0_control/state_diff_tracker`

