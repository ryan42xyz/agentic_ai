---
name: state-validator
description: Validate the current execution state for logical, evidential, and structural integrity. Writes only evidence; never modifies state.
---

# State Validator

## Purpose

Validate the current execution state for logical, evidential, and structural integrity.

This skill does not modify state. It only flags violations and risks.

## Inputs (read-only)

- `openspec/changes/<change-name>/state/current.yaml`
- `openspec/changes/<change-name>/state/*.yaml` (optional history, if present)
- `openspec/changes/<change-name>/evidence/**`

## Output Paths (strict)

- Write only:
  - `openspec/changes/<change-name>/evidence/state_validator/validation.md`
- Do not write anywhere else.

## Validation Checks (mandatory)

The validator MUST check:

### 1) Execution State Schema

- `state/current.yaml` exists and is valid YAML.
- Top-level keys are exactly: `plan`, `evidence`, `decision_points`, `open_questions`.
- No free-form prose outside schema fields.

### 2) Evidence Integrity

For each evidence entry in state:

- `source` must exist.
- `time_window` must exist.
- `path` must exist and must be under `openspec/changes/<change-name>/evidence/**`.
- `excerpt` must be verbatim (no interpretation language).

### 3) Decision Point Discipline

For each decision point:

- `required_evidence` is present and non-empty.
- Branch definitions are explicit (no “TBD” without an associated open question).

### 4) Open Question Preservation (if history exists)

If there are prior snapshots:

- Open questions must not disappear without evidence-backed resolution.
- If an open question is removed from current state, there must be evidence indicating closure (reference by id/path).

### 5) Plan Discipline

- Plan fields must not imply execution (no commands, no “run X now”, no “implement”).
- Hidden assumptions must be represented as open questions instead.

## Forbidden

This skill MUST NOT:

- Edit state files
- Propose fixes
- Suggest next steps
- Introduce new evidence
- Reinterpret evidence

If a problem is found, only report it.

## Output Format

`validation.md` MUST contain:

- `❌ Violations (blocking)`
- `⚠️ Warnings (non-blocking)`
- `✅ Passed checks`

No recommendations.

