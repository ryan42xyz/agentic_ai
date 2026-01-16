# How to Use `control_flow/` (Minimal End-to-End Workflow)

This doc shows a minimal, replayable workflow for using the `control_flow/` skills with OpenSpec artifacts.

Core idea: **one OpenSpec change = one auditable loop**.

Loop:
1) `request.md` (human intent, immutable)
2) `actions/` (one action at a time)
3) `evidence/` (raw outputs only)
4) `state/` (compiled snapshots only)
5) validate + diff (control)
6) repeat

## When to use which flow

- **Feature dev (“implementation change”)**: you usually end up with `evidence/change_authoring/patch.diff` and then apply it to the repo via your normal workflow.
- **Infra ops / oncall (“analysis-first change”)**: you usually end up with evidence + decisions; **no patch** unless you explicitly upgrade to an implementation change.

See also:
- `control_flow/1-dev-flow.md`
- `control_flow/2-oncall-flow.md`
- `control_flow/workflow-runner/SKILL.md` (meta-orchestrator with a strict approval hook)

## Minimal directory layout

Create:

```text
openspec/changes/<change-name>/
  request.md
  actions/
  evidence/
  state/
  notes/
```

Notes:
- Only `control/execution_state_compiler` is allowed to write `state/**`.
- Everything else writes under `actions/**` or `evidence/**`.

## Step-by-step (one full loop)

### 0) Initialize (human)

Create `openspec/changes/<change-name>/request.md` with raw intent and constraints.

Minimal template:

```md
# Request

## Goal
<one sentence>

## Success criteria
- <observable pass/fail>

## Constraints
- <no refactors, no new deps, etc.>

## Context
- <links, commands, paths, logs, repro steps>
```

### 1) Compile initial state (control)

Run `control/execution_state_compiler` to produce:
- `openspec/changes/<change-name>/state/00_initial.yaml`
- `openspec/changes/<change-name>/state/current.yaml`
- `openspec/changes/<change-name>/notes/open-questions.md` (optional)

### 2) Validate state (control)

Run `control/state_validator`:
- Writes `openspec/changes/<change-name>/evidence/state_validator/validation.md`

If there are **blocking violations**, fix the artifact structure (not the conclusions) and re-run.

### 3) Pick exactly one uncertainty (decision)

Run `decision/plan_refiner`:
- Writes `openspec/changes/<change-name>/actions/action-XXX-plan.md`

`action-XXX-plan.md` must identify:
- one target open-question id
- why it blocks
- action type: `info_retrieval` | `execution_run` | `code_change` | `wait` | `defer`

Minimal template:

```md
# Plan Action: action-XXX

Target open question id: OQ-XXX
Why it blocks progress: <one sentence>
Action type needed: info_retrieval

Definition of done:
- <what evidence file(s) will exist>
```

### 4) Declare one executable action (decision)

Run `decision/action_selector`:
- Writes `openspec/changes/<change-name>/actions/action-XXX-exec.md`

`action-XXX-exec.md` should be executable and bounded:

```md
# Exec Action: action-XXX

Action type: info_retrieval
Adapter: shell

Scope (bounded):
- <exact commands, exact paths>

Forbidden side effects:
- No writes outside `openspec/changes/<change-name>/evidence/**`
- No network (unless explicitly allowed)
- No installs / commits / refactors
```

### 5) Execute exactly one action (execution)

Pick one based on the declared action:

- `execution/info_retrieval`
  - Writes raw excerpts under `openspec/changes/<change-name>/evidence/<source>/<artifact>.md`
- `execution/execution_runner`
  - Writes raw stdout/stderr under `openspec/changes/<change-name>/evidence/run/<run-id>.md`
- `execution/change_authoring` (feature dev only)
  - Writes `openspec/changes/<change-name>/evidence/change_authoring/patch.diff`
  - Does **not** apply the patch to the repo

Evidence file minimum fields (no interpretation):

```md
# Evidence: <type>

Source: <where it came from>
Retrieval method: <how>
Time window: <start-end, timezone>

## Raw excerpt
<verbatim output>
```

### 6) Re-compile state (control)

Run `control/execution_state_compiler` again to produce a new snapshot:
- `openspec/changes/<change-name>/state/NN_<short-description>.yaml`
- update `openspec/changes/<change-name>/state/current.yaml`

### 7) Check progress (control)

Run `control/state_diff_tracker` to verify progress isn’t just rephrasing:
- Writes `openspec/changes/<change-name>/evidence/state_diff_tracker/state_diff.md`

### 8) Repeat

Repeat steps 2–7 until stop conditions are met.

## Scenario notes

### Feature dev (implementation change)

Typical action mix:
- `info_retrieval` (read code, inspect configs)
- `execution_run` (run targeted tests/build)
- `code_change` → `change_authoring` emits `patch.diff`
- `execution_run` again to validate (evidence-only)

Hand-off point:
- once `patch.diff` exists and validation evidence exists, apply the patch via your normal repo workflow.

### Infra ops / oncall (analysis-first change)

Default constraints:
- only `info_retrieval` and `execution_run`
- no patch unless explicitly upgraded

Useful decision points to encode:
- roll back vs mitigate vs wait
- escalate vs continue investigating

Upgrade path (explicit):
- create a *new* change (or explicitly mark scope change) for implementation work and allow `change_authoring`.
