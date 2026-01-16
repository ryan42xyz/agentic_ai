---
name: blogs
description: Write high-quality blog posts through a structured, human-led, stage-gated process. Use when a user wants to create a blog post from raw thoughts, ideas, or notes, ensuring conservative extraction, locked outlines, careful drafting, red-team review, knowledge distillation, and finalization.
---

# Blogs

This skill assists with writing high-quality blog posts through a structured, multi-stage process.

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
- Add new ideas, conclusions, or frameworks beyond what the author provided
- Modify the locked outline after it's been approved
- Skip stages or merge stages without human approval
- Introduce new claims or arguments during finalization
- "Sound like an AI" - maintain natural, human language

## Inputs

Required:
- Raw personal thoughts, ideas, or notes from the author
- Author's intent and boundaries for the article

Optional:
- Reference materials or context
- Existing drafts or partial content

## Outputs

Stage outputs are defined in the stage files:
- `stages/01_extract.md` - Extracted structure (beliefs, questions, boundaries)
- `stages/02_outline_lock.md` - Locked outline with title candidates
- `stages/03_draft.md` - Initial draft following the outline
- `stages/04_redteam.md` - Critical review and critique
- `stages/05_distill.md` - Reusable cognitive assets (checklists, rules, diagrams, cards)
- `stages/06_final.md` - Finalized article ready for publication

## Mandatory stop points

- After each stage, wait for explicit human approval before moving on.
- If the raw input is unclear or insufficient, stop.
- If the outline needs significant changes, stop and re-lock it.
- If red-team critique reveals fundamental issues, stop.

## Stages

Follow in order:
1. Extract - Extract structure from raw personal thoughts
2. Outline Lock - Compile and lock the outline
3. Draft - Write the article following the locked outline
4. Red Team - Critically review the draft
5. Distill - Convert to reusable cognitive assets
6. Final - Produce the final, accountable version

See each stage file for exact constraints and outputs.
