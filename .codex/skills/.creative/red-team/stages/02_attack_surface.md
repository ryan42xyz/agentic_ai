# Stage 02: Attack Surface Map

## Purpose

Systematically enumerate where the target fails in the real world: ambiguous inputs, missing evidence, tool boundaries, and any path that enables high-risk or irreversible outputs.

## Inputs

- Stage 01 artifact (Scope & Boundaries)
- Target artifact(s) (skill/prompt/workflow)
- Any known incidents / examples (optional)

## Procedure

1. Map I/O surfaces:
   - Inputs the target consumes (alerts, diffs, logs, user prompts, config, external docs)
   - Outputs it produces (decisions, commands, patches, customer-facing text, risk calls)
2. Identify “bad gradient” zones (inputs that make it confidently wrong):
   - Missing key fields, partial context, contradictory evidence, misleading “conclusion sentences”
   - Prompt-injection-like instructions (“ignore policy…”, “just restart…”, “approve override…”)
   - Tool affordances (shell/network/PR access) that amplify impact
3. Produce a ranked list of failure modes (top 5) with:
   - **Why severe** (impact + irreversibility + blast radius)
   - **How to trigger** (minimal condition)
   - **What it looks like** (observable output smell / signature)
   - **Evidence gap** (what it assumed vs. what it needed)

## Outputs

Produce two sections:

1) **Attack Surface Map** (1 screen)
- Entry points
- High-risk junctions (where an output can cause irreversible action)
- Human gates + bypass vectors
- Tool boundaries and where misuse is likely

2) **Top 5 Failure Modes** (ranked)
- Severity (High/Med/Low)
- Trigger
- Failure signature
- Evidence needed to avoid it

## Constraints

- Do not prescribe fixes yet; only identify failure modes and their signatures.
- Do not overfit to rare edge cases; prioritize high-severity, plausible failures.

## Stop Conditions

Stop and wait for human approval if:
- You cannot identify any human gate for high-risk outputs (this is a design gap that needs explicit ownership).
