# Stage 01: Scope & Boundaries

## Purpose

Establish crisp success criteria, failure costs, operating context, and non-negotiable guardrails for the target. Turn ambiguity into a short list of required evidence.

## Inputs

- Target artifact(s) (skill/prompt/workflow)
- Intended users and scenario (oncall, code review, customer comms, data ops, etc.)
- Any explicit constraints (do-not-do list, compliance rules, environment boundaries)

## Procedure

1. Identify what is being red-teamed (name, scope, entrypoints, outputs).
2. Define success standard (what “good” looks like under uncertainty).
3. Define failure cost (what goes wrong if the target outputs are wrong).
4. List high-risk / irreversible actions the target must never autonomously recommend or execute.
5. Identify mandatory human decision gates and how they can be bypassed.
6. Convert unknowns into an “evidence needed” checklist (ordered, minimal).
7. Ask at most 5 clarification questions only if needed to complete the outputs.

## Outputs

Produce a 1-screen Markdown artifact:

- **Target**: what is in/out of scope
- **Operating Context**: where it runs, who uses it, time pressure, typical inputs
- **Success Standard**: what it must do when uncertain (e.g., “no conclusion; evidence checklist; conservative language”)
- **Failure Cost**: top 3 bad outcomes (ranked)
- **High-Risk Actions List**: actions requiring explicit human approval
- **Human Gates**: required stop points + known bypass paths
- **Evidence Needed**: minimal signals required before any strong claim

## Constraints

- Do not start attacking before scope is defined.
- Do not assume hidden context; mark unknowns explicitly.
- Keep it short; avoid narrative.

## Stop Conditions

Stop and wait for human approval if:
- The target artifact(s) are incomplete or inaccessible.
- The operating context is unclear enough that risk tolerance cannot be inferred.
