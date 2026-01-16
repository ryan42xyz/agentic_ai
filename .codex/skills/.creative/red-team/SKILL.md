---
name: red-team
description: Red-team (对抗性审查) a skill/agent/workflow for safety and reliability. Use when a user asks to audit a skill, find failure modes, create an adversarial test pack, define boundaries/guardrails, or produce a minimal patch plan to prevent real-world “flip” failures (hallucinated certainty, unsafe actions, bypassed human gates, bad tool use).
---

# Red Team

This skill performs adversarial review of a target “decision function” (a skill, prompt, workflow, or agent behavior) to find high-risk failures and force crisp boundaries, evidence requirements, and gated actions.

It is designed to be human-led and stage-gated. Stages are internal steps; they are not free-form tools.

## First principles

A valid run must state all of the following:

1. Applicable scenario
2. Inputs
3. Outputs
4. Prohibitions
5. Mandatory human stop points

If any of the above are missing, stop and ask for clarification.

## Guardrails

The assistant must never:
- Claim something is “safe” or “correct” without evidence
- Invent test results or operational facts
- Recommend or execute destructive / irreversible actions
- Provide real-world offensive instructions; keep adversarial content scoped to testing the target skill/workflow
- Apply patches unless explicitly requested by the human

## Inputs

Required:
- Target artifact(s): skill folder, SKILL.md, policy/docs, prompt, or workflow description
- Intended operating context (where/when it will be used)

Optional (high leverage):
- Known incidents or “near-miss” examples
- Risk tolerance / prohibited actions list
- Interfaces and tools the target may call (shell, network, PRs, deploys, etc.)

## Outputs

Stage outputs are defined in the stage files:
- `stages/01_scope.md`
- `stages/02_attack_surface.md`
- `stages/03_test_pack.md`
- `stages/04_patch_plan.md`

## Mandatory stop points

- After each stage, wait for explicit human approval before moving on.
- If the target artifact(s) are missing or ambiguous, stop and request them.
- Before proposing any patch that changes behavior materially, stop and confirm risk appetite and ownership.

## Stages

Follow in order:
1. Scope & Boundaries
2. Attack Surface Map
3. Adversarial Test Pack
4. Patch Plan

See each stage file for exact constraints and outputs.
