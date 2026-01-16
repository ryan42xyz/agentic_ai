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
- Write only:
  - `openspec/changes/<change-name>/evidence/change_execution/03_validate.md`

The report MUST include these sections:
- `violations`
- `edge_cases`
- `needs_human_decision`

Stop
- If any item exists in outputs, stop and wait for human decision.
- Do not proceed to implementation without explicit approval.
