# Prompt Compiler Output Schema

All compiled prompts MUST follow this structure.
No sections may be omitted.

---

## Header

Mode: <Execution | Analysis | Reframing>

---

## Problem Statement

A clear, rewritten statement of the problem or task,
normalized from the original input.

- No conversational language
- No ambiguity
- One primary objective only

---

## Context

Minimum necessary background information required
to correctly understand the problem.

- Domain
- Audience
- Constraints
- Operating environment

---

## Assumptions

Explicit list of assumptions the prompt relies on.

- What is assumed to be true
- What is intentionally not addressed

No hidden assumptions allowed.

---

## Constraints

Hard boundaries the responder MUST respect.

Examples:
- Scope limits
- Time / cost / risk constraints
- Prohibited actions

---

## Task Instructions

Clear instructions aligned with the selected mode.

- Execution: steps to perform
- Analysis: dimensions to analyze
- Reframing: questions to challenge and reformulate

---

## Output Requirements

Exact expectations for the response:

- Format (bullets, table, JSON, etc.)
- Length or depth
- Tone (if applicable)

---

## Quality Bar

Definition of what constitutes a good answer.

- Must include
- Must avoid
- Failure conditions

---

## Notes (Optional)

Clarifications, reminders, or meta-guidance
that do not affect scope or authority.
