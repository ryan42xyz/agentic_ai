# Facet 3: Core Concepts

## Purpose

Extract the core conceptual model of this repository.

Identify the first-class concepts and their relationships.

## Focus Areas

- First-class concepts (stable nouns)
- Their responsibilities and roles
- Relationships between concepts (composition, orchestration, layering)

## Output Structure

### Core Concepts

- **Concept A**
  - Meaning:
  - Role:
  - Relations:

- **Concept B**
  - Meaning:
  - Role:
  - Relations:

## Constraints

Avoid:
- File-by-file explanations
- Variable-level or function-level details

Prefer a small set of stable concepts over exhaustive listing.
If concepts appear overloaded or ambiguous, note it.

Describe concepts independently of file or directory structure.

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

Extract the core conceptual model of this repository.

Identify:
- First-class concepts (stable nouns)
- Their responsibilities and roles
- Relationships between concepts (composition, orchestration, layering)

Describe concepts independently of file or directory structure.

Avoid:
- File-by-file explanations
- Variable-level or function-level details

Prefer a small set of stable concepts over exhaustive listing.
If concepts appear overloaded or ambiguous, note it.
```
