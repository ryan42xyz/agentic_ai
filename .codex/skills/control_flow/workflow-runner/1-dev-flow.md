# Feature Development Flow (Condensed)

Use this when adding a new feature to an existing repo with OpenSpec.

For a minimal end-to-end template (files + action/evidence/state examples), see `control_flow/how_to_use_workflow.md`.

## 0) Initialize (human)

- Create `openspec/changes/<change-name>/request.md` with the raw intent.

## 1) Compile initial state (control)

- Run `control/execution_state_compiler`.
- Outputs:
  - `openspec/changes/<change-name>/state/00_initial.yaml`
  - `openspec/changes/<change-name>/state/current.yaml`
  - `openspec/changes/<change-name>/notes/open-questions.md`

## 2) Validate state (control)

- Run `control/state_validator`.
- Output:
  - `openspec/changes/<change-name>/evidence/state_validator/validation.md`

## 3) Decide next action (decision)

- Run `decision/plan_refiner` to pick exactly one open question.
- Output:
  - `openspec/changes/<change-name>/actions/action-XXX-plan.md`
- Run `decision/action_selector` to declare a single executable action.
- Output:
  - `openspec/changes/<change-name>/actions/action-XXX-exec.md`

## 4) Execute one action (execution)

Exactly one:

- `execution/info_retrieval` -> `openspec/changes/<change-name>/evidence/<source>/<artifact>.md`
- `execution/change_authoring` -> `openspec/changes/<change-name>/evidence/change_authoring/patch.diff`
- `execution/execution_runner` -> `openspec/changes/<change-name>/evidence/run/<run-id>.md`

## 5) Re-compile state (control)

- Run `control/execution_state_compiler` again to produce:
  - `openspec/changes/<change-name>/state/NN_<short-description>.yaml`
  - `openspec/changes/<change-name>/state/current.yaml` (updated)

## 6) Check progress (control)

- Run `control/state_diff_tracker`.
- Output:
  - `openspec/changes/<change-name>/evidence/state_diff_tracker/state_diff.md`

## 7) Loop

Repeat steps 2-6 until:

- All blocking open questions are closed
- All decision points are resolved
- A patch exists (if code change is required)

Only `control/execution_state_compiler` writes `state/**`.
