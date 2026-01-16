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
- Write only:
  - `openspec/changes/<change-name>/evidence/change_authoring/patch.diff`

The patch MUST be the minimal diff that implements the approved change and nothing else.

Stop
- If you cannot produce a safe, direct patch, stop and ask for human guidance.
