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
- Write only:
  - `openspec/changes/<change-name>/evidence/change_execution/05_sync_knowledge.md`

The report MUST include:
- `knowledge_impacts`:
  - domain
  - description_of_changed_fact
  - impact_level (low|medium|high)
  - requires_human_update (yes|no)
- `update_recommendations` (if any)
- `risk_notes` (if any)

Stop
- Always stop after analysis.
- Do NOT update any documents.
- Do NOT assume updates will be performed.
- Wait for explicit human decision on whether and how to update knowledge artifacts.
