# Requirement Analysis Skill

## Purpose

This skill is designed to analyze **ambiguous, incomplete, or evolving requirements**
before any solution or implementation is considered.

The goal is NOT to:
- design a solution
- optimize an approach
- make product decisions

The goal IS to:
- surface hidden assumptions
- separate problem space from solution space
- reduce wasted implementation effort on unclear or invalid requirements

This skill is intentionally **human-led, AI-assisted**.

A successful run may result in:
- clarified questions
- identified constraints
- explicit uncertainty

Even if no implementation follows.

---

## Core Rules

- Do NOT propose solutions early
- Do NOT fill missing information with assumptions
- Do NOT optimize or refactor
- Do NOT judge business value

Uncertainty is a valid and expected output.

---

## Output Contract

Each stage produces:
- structured markdown
- explicit reasoning
- clear boundaries

No stage may skip or merge with another.

## Stages

Follow in order:
1. Denoise — Understand what is explicitly stated
2. Problem Space — Classify the nature of the problem
3. Constraints — Surface and distinguish real vs assumed constraints
4. Solution Space — Explore solution patterns without commitment

See each stage file for exact constraints and outputs:
- `stages/01_denoise.md`
- `stages/02_problem_space.md`
- `stages/03_constraints.md`
- `stages/04_solution_space.md`
