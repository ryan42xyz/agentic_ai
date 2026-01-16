---
name: execution-state-compiler
description: Compile execution traces into a verifiable, replayable execution state for a single OpenSpec change. This skill is the only writer of `openspec/changes/<change-name>/state/**`.
---

# Execution State Compiler

## Purpose (Execution Contract)

Compile free-form agent execution traces into a verifiable, replayable execution state anchored to a single OpenSpec change.

This skill does not plan, decide, execute, or explain. Its sole responsibility is to extract control-relevant state and persist it to fixed locations.

## Preconditions (ALL required)

The following must be true:

1. `openspec/changes/<change-name>/` exists
2. `openspec/changes/<change-name>/request.md` exists (original human intent; must never be modified)
3. The caller provides `<change-name>` explicitly

If any condition is missing, STOP and request correction.

## Inputs

All inputs are read-only.

### Primary Inputs (required)

- `openspec/changes/<change-name>/request.md`
- One or more execution artifacts, including (when present):
  - `openspec/changes/<change-name>/actions/**`
  - `openspec/changes/<change-name>/evidence/**`

### Secondary Inputs (optional)

- Previous execution state snapshots:
  - `openspec/changes/<change-name>/state/*.yaml`
- Existing open questions register:
  - `openspec/changes/<change-name>/notes/open-questions.md`

## Output Paths (strict)

This skill is strictly write-scoped.

✅ Allowed write locations (only):

1) Execution state snapshots

- `openspec/changes/<change-name>/state/NN_<short-description>.yaml` (immutable snapshot)
- `openspec/changes/<change-name>/state/current.yaml` (pointer to latest snapshot)

Rules:

- Each invocation produces one new immutable snapshot.
- `current.yaml` MUST be updated to point to the latest snapshot.
- Previous snapshots MUST NOT be modified or deleted.

`current.yaml` MUST be YAML with this shape:

```yaml
latest_snapshot: NN_<short-description>.yaml
```

2) Open questions register

- `openspec/changes/<change-name>/notes/open-questions.md`

Rules:

- Append or update unresolved questions only.
- Do NOT resolve questions here.
- Do NOT invent questions without evidence.

## Execution State Schema (required structure)

Each snapshot MUST be YAML containing only the following top-level sections:

```yaml
plan:
  goal:
  subgoals:
  dependencies:
  success_criteria:
  stop_conditions:

evidence:
  - id:
    type:
    source:
    path:
    time_window:
    excerpt:

decision_points:
  - id:
    condition:
    required_evidence:
    branches:

open_questions:
  - id:
    description:
    blocking:
    suggested_next_action:
```

If information does not fit the schema, it MUST be omitted.

## Strict Rules

- No free-form prose outside schema fields.
- No speculative language.
- No recommendations.
- No summaries.
- No “thoughts”.
- Evidence must not be reinterpreted; excerpts are verbatim.

## Constraints

This skill MUST NOT:

- Propose solutions
- Generate plans
- Decide next steps
- Execute commands
- Write or modify code
- Run tests
- Search documentation
- Resolve open questions
- Reinterpret evidence
- Introduce assumptions

If tempted to do any of the above, leave the relevant field empty and record an Open Question instead.

## Failure Modes (MUST stop)

STOP and report failure if any are true:

- Evidence is cited without a source
- Evidence entries are missing a `time_window`
- Decision points lack `required_evidence`
- Conclusions appear without supporting evidence
- Open questions are silently dropped (when prior snapshots exist)

Partial output is allowed; silent corruption is not.

## Idempotency & Replay

Re-running this skill on the same inputs MUST produce:

- a new state snapshot
- with identical semantic content

Differences between snapshots must be explainable via evidence changes.

## Interaction With Other Skills

Consumes outputs from:

- `decision/*` (actions)
- `execution/*` (evidence)
- `control/*` (evidence reports only; this skill remains the only state writer)

Feeds into:

- `control/state_validator` (reads state and evidence)
- `decision/*` (reads state and evidence)

This skill never directly triggers any other skill.
