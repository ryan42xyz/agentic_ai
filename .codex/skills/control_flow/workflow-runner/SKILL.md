---
name: workflow-runner
description: Orchestrate the OpenSpec control-flow loop with a strict single-question approval hook before running any other skill; proposes the next step but does not execute unless approved.
---

# Workflow Runner (Meta-Orchestrator)

## Purpose

Provide a safe, low-friction “driver” for the `control_flow/` skill suite by:

1) Inspecting the current OpenSpec change artifacts
2) Proposing exactly one next step (which skill to run next)
3) Stopping on a single, explicit approval question (hook)

This skill is designed to minimize repeated user prompting while keeping the user in control before *every* skill execution.

## Core Contract

### Strict hook (mandatory)

Before running any other skill (including validators), the runner MUST:

1) Present a bounded proposal (one next skill invocation)
2) Ask exactly **one** user question
3) Stop and wait for the user’s choice

### Default execution granularity

The runner MUST default to **single-step** operation (one skill invocation at a time), unless the user explicitly chooses an auto-loop mode.

### Forbidden

This skill MUST NOT:

- Execute any other skill without explicit user approval
- Run shell commands or tests directly
- Write to the repo or to `openspec/**`
- Generate or modify `openspec/changes/<change-name>/request.md`

## Inputs (provided by the user)

Required:
- `<change-name>`: OpenSpec change directory name under `openspec/changes/`
- `mode`: `feature_dev` | `infra_ops` | `oncall`

Optional:
- `max_rounds`: integer, default `1`
- `policy_overrides`:
  - allow_network: boolean (default false)
  - allow_patch: boolean (default true for `feature_dev`, false for `oncall`)
  - allowed_action_types: subset of `info_retrieval`, `execution_run`, `code_change`, `wait`, `defer`
  - command_allowlist: list of approved commands/patterns (recommended for oncall/infra ops)

## Read Targets (no execution)

The runner may read (if present):
- `openspec/changes/<change-name>/request.md`
- `openspec/changes/<change-name>/state/current.yaml`
- `openspec/changes/<change-name>/state/*.yaml`
- `openspec/changes/<change-name>/actions/*.md`
- `openspec/changes/<change-name>/evidence/**`
- `openspec/changes/<change-name>/notes/open-questions.md`

## Step Selection Rules (proposal logic)

The runner MUST propose the next skill based on these rules (top to bottom):

1) If `state/current.yaml` is missing → propose `control/execution_state_compiler`
2) Else if `evidence/state_validator/validation.md` is missing or stale → propose `control/state_validator`
3) Else if validation has blocking violations → propose “fix artifact structure” (no skill execution)
4) Else if no pending `actions/action-XXX-plan.md` for the next open question → propose `decision/plan_refiner`
5) Else if latest plan action lacks an exec declaration → propose `decision/action_selector`
6) Else propose the corresponding execution skill for the declared action type:
   - `info_retrieval` → `execution/info_retrieval`
   - `execution_run` → `execution/execution_runner`
   - `code_change` → `execution/change_authoring` (only if `allow_patch` is true)
   - `wait` / `defer` → stop with a single question (no execution)
7) After an execution step is completed (evidence exists), propose `control/execution_state_compiler`
8) After a new snapshot is produced, propose `control/state_diff_tracker`

Notes:
- The runner proposes exactly one next step each time.
- Any ambiguity becomes an explicit user choice via the hook question.

## Mode Policies (defaults)

### `feature_dev`

- allowed_action_types: `info_retrieval`, `execution_run`, `code_change`, `wait`, `defer`
- allow_patch: true
- allow_network: false (unless overridden)

### `infra_ops`

- allowed_action_types: `info_retrieval`, `execution_run`, `wait`, `defer`
- allow_patch: false by default (explicit upgrade required)
- command_allowlist: strongly recommended

### `oncall`

- allowed_action_types: `info_retrieval`, `execution_run`, `wait`, `defer`
- allow_patch: false (unless explicitly upgraded to an implementation change)
- allow_network: false by default
- emphasize: “止血优先于根因；证据优先于解释”

## Approval Hook (single question)

After presenting the proposal, the runner MUST ask exactly one question in this shape:

> Choose: (1) Run this one step (single-step) (2) Auto-loop up to `max_rounds` (3) Generate actions only (no execution) (4) Cancel

Rules:
- Do not ask any additional questions.
- If required input is missing (e.g., `<change-name>`), the single question becomes: “What is `<change-name>`?” and the runner must stop.

## Output Template (proposal block)

The runner should output a concise proposal block:

- Change: `<change-name>`
- Mode: `<mode>`
- Next skill: `<skill-name>`
- Reads: `<paths>`
- Writes (expected): `<paths>`
- Side effects: `none` | `runs commands` | `produces patch` (must be explicit)
- Reason: `<one sentence anchored in current artifacts>`

Then the single approval question.

## Example (feature dev)

Proposal:
- Change: `chg-001-login-bug`
- Mode: `feature_dev`
- Next skill: `control/execution_state_compiler`
- Reads: `openspec/changes/chg-001-login-bug/request.md`
- Writes (expected): `openspec/changes/chg-001-login-bug/state/00_initial.yaml`, `openspec/changes/chg-001-login-bug/state/current.yaml`
- Side effects: none
- Reason: `state/current.yaml` not found

Choose: (1) Run this one step (single-step) (2) Auto-loop up to `max_rounds` (3) Generate actions only (no execution) (4) Cancel

