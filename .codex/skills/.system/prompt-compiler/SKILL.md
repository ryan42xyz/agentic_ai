---
name: prompt-compiler
type: meta-skill
risk_level: low
description: >
  A meta skill that transforms an informal, ambiguous, or conversational prompt
  into a structured, explicit, and execution-safe prompt.
  This skill DOES NOT answer the prompt.
  It only audits, classifies, and rewrites prompts according to cognitive permission levels.
---

# Prompt Compiler Skill

## Skill Intent

This skill exists to **compile human-intent prompts into governed, structured prompts**.

Its responsibility is to:
- clarify intent
- classify cognitive permission level
- surface assumptions and ambiguities
- produce a reusable, structured prompt artifact

This skill MUST NOT:
- answer the prompt
- solve the problem
- make decisions on behalf of the user
- execute downstream tasks

It only produces a **prompt**, not an outcome.

---

## Input Contract

The input MAY be:
- a single conversational sentence
- a vague idea
- an incomplete or poorly framed question
- a prompt without structure, scope, or output definition

The skill MUST assume:
- the input is ambiguous
- the problem statement may be suboptimal
- clarification may be required

---

## Cognitive Mode Selection (Mandatory)

Before compiling the prompt, the skill MUST confirm
which cognitive permission level to apply.

Available modes:
1. Execution
2. Analysis
3. Reframing (First-Principles)

The skill MUST:
- explicitly ask the user to choose one mode
- refuse to proceed without confirmation
- NOT auto-infer or guess the mode

Mode definitions are specified in `MODES.md`.

---

## Processing Workflow

Once the mode is confirmed, the skill performs:

### Step 1 — Prompt Audit
- Identify ambiguities
- Identify missing constraints
- Identify implicit assumptions
- Detect scope confusion

### Step 2 — Mode-Specific Validation
- Validate the prompt against the selected cognitive mode
- Detect violations (e.g. reframing inside execution mode)

### Step 3 — Prompt Compilation
- Rewrite the prompt into a structured format
- Enforce cognitive boundaries
- Normalize language and scope

---

## Output Contract

The ONLY output of this skill is:
- one structured prompt
- following the schema defined in `OUTPUT_SCHEMA.md`

No answers, no recommendations, no execution.

---

## Failure Policy

If any of the following occurs, the skill MUST stop:
- cognitive mode not confirmed
- conflicting goals detected
- insufficient information to safely compile

In such cases, the skill MUST ask clarification questions
and MUST NOT partially proceed.

---

## Success Criteria

A successful run produces:
- a copy-paste-ready structured prompt
- explicit cognitive mode declaration
- explicit assumptions and constraints
- no ambiguity about scope or intent
