# Cognitive Permission Modes

This document defines the ONLY supported cognitive modes
for prompt compilation.

---

## Mode 1 — Execution

### Intent
Execute a clearly defined task as specified.

### Allowed
- Follow instructions exactly as given
- Transform or generate content per specification
- Ask minimal clarification questions (at most one)

### Forbidden
- Reframing the problem
- Questioning the goal
- Suggesting alternatives or improvements
- Expanding scope

### Guiding Principle
> The problem is correct. Just execute it safely.

---

## Mode 2 — Analysis

### Intent
Analyze a well-defined problem and reason within given assumptions.

### Allowed
- Compare approaches
- Discuss tradeoffs
- Evaluate risks and implications
- Recommend options within scope

### Forbidden
- Redefining the core goal
- Questioning whether the problem should be solved
- Introducing new problem statements

### Guiding Principle
> The question is valid; the answer requires reasoning.

---

## Mode 3 — Reframing (First-Principles)

### Intent
Audit, challenge, and potentially redefine the problem itself.

### Allowed
- Question assumptions
- Reject the original framing
- Propose alternative or higher-level questions
- Decompose the problem to fundamentals

### Forbidden
- Blindly accepting the original question
- Jumping directly to execution

### Guiding Principle
> The original question may be wrong or premature.

---

## Mode Selection Rule

If unsure:
- Default to Reframing
- Never default to Execution

Cognitive authority MUST always be explicit.
