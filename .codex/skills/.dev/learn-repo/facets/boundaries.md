# Facet 4: System Boundaries

## Purpose

Analyze the system boundaries of this repository.

Answer what the system takes responsibility for and what it delegates.

## Focus Areas

- What does this system explicitly or implicitly take responsibility for?
- What does it delegate to external systems or users?
- Where does it draw the line and say "not my problem"?

## Output Structure

### Responsibilities

This system takes responsibility for:

- ...

### Delegated Responsibilities

This system delegates to external systems or users:

- ...

### External Dependencies and Assumptions

- ...

### Operational Expectations

- ...

### Boundary Uncertainties

If boundaries are unclear, state what is uncertain:

- ...

## Constraints

Do NOT:
- Repeat dependency lists mechanically
- Explain how integrations are implemented

If boundaries are unclear, state what is uncertain.

**Important**: If this facet is difficult to write, it may indicate incomplete understanding of the repository.

## Prompt Template

```
You are analyzing a source code repository.

Your goal is NOT to explain code line-by-line,
and NOT to produce a tutorial.

Your goal is to model the repository from a specific analytical lens,
produce a structured, falsifiable understanding,
and explicitly mark uncertainty where appropriate.

Prefer abstraction over implementation details.
Prefer stable concepts over transient code structure.

---

Analyze the system boundaries of this repository.

Answer:
- What does this system explicitly or implicitly take responsibility for?
- What does it delegate to external systems or users?
- Where does it draw the line and say "not my problem"?

Focus on:
- External dependencies and assumptions
- Responsibilities pushed outward
- Operational or environmental expectations

Do NOT:
- Repeat dependency lists mechanically
- Explain how integrations are implemented

If boundaries are unclear, state what is uncertain.
```
