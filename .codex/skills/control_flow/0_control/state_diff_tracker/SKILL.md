---
name: state-diff-tracker
description: Detect whether the execution state has meaningfully progressed by diffing state snapshots; writes only evidence and never modifies state.
---

# State Diff Tracker

## Purpose

Detect whether the execution state has meaningfully progressed (vs. just rephrased).

## Inputs

- `openspec/changes/<change-name>/state/current.yaml`
- A previous state snapshot:
  - `openspec/changes/<change-name>/state/<previous>.yaml` (provided by the caller, or selected from history)

## Output Paths (strict)

- Write only:
  - `openspec/changes/<change-name>/evidence/state_diff_tracker/state_diff.md`
- Do not write anywhere else.

## Diff Rules

Progress is valid only if at least one occurs:

- An open question is resolved with evidence
- A decision point is conclusively branched
- New evidence replaces speculation

Language-only changes do NOT count.

## Procedure

- Compare `<previous>.yaml` vs `current.yaml`.
- Report only observable structural changes, including:
  - added/removed/changed open questions
  - added/removed/changed decision points
  - evidence entries added/removed/changed (by `id`/`path`/`time_window`)

## Constraints

- Do not update `openspec/changes/<change-name>/state/**`.
- Do not modify code or change proposal documents.
- Do not provide value judgments or recommendations.
