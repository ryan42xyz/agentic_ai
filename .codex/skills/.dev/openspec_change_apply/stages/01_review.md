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
- Write only:
  - `openspec/changes/<change-name>/evidence/change_execution/01_review.md`

The report MUST include these sections:
- `ambiguities`
- `assumptions`
- `decision_points`
- `missing_inputs`

Stop
- Always stop after review and wait for human approval to proceed.
