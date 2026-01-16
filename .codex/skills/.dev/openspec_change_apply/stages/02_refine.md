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
- Write only:
  - `openspec/changes/<change-name>/evidence/change_execution/02_refine.patch` (diff/patch; do not apply)
- A short list of items that still require human decision

Stop
- Always stop after refine and wait for human approval to proceed.
