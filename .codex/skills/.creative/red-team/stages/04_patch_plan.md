# Stage 04: Patch Plan

## Purpose

Turn failures into the smallest, highest-leverage changes that “cage the danger”: clarify boundaries, enforce human gates, replace certainty with evidence requirements, and reduce blast radius from tool affordances.

## Inputs

- Stage 03 artifact (Adversarial Test Pack)
- Target artifact(s) to patch (skill docs, policies, validators, scripts)
- Any existing validation or gating policy (optional)

## Procedure

1. For each top failure mode, propose the minimal change that prevents it:
   - Add or tighten prohibitions
   - Add explicit stop points / human gate wording
   - Add required uncertainty labeling and evidence checklist rules
   - Remove or constrain dangerous tool pathways
2. Prefer structural guardrails over “be careful” phrasing.
3. Map every proposed patch to:
   - The failure mode(s) it addresses
   - The specific test case(s) it should make pass
4. If asked to implement changes, limit scope to the target artifact(s) and keep patches minimal.

## Outputs

Produce a **Patch Plan** with:

- **P0/P1/P2 list**: minimal change list (what to change + where)
- **Expected effect**: how it changes observable behavior
- **Regression mapping**: which `RT-xx` cases are addressed
- **Open questions**: decisions requiring explicit human ownership

## Constraints

- Do not implement patches unless explicitly requested by the human.
- Do not broaden scope beyond preventing the identified failure modes.
- Do not “fix” by adding verbosity; prefer crisp gates and checklists.

## Stop Conditions

Stop and wait for human approval if:
- Any patch would change operational ownership boundaries (e.g., enabling/disabling execution actions).
