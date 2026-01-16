# Stage 03 — Fast Input (快输入 / evidence only)

Collect the minimum information needed to answer Stage 02’s questions and update signals.

## Inputs

- The judgment in `../state/active_hypothesis.md`
- The validation questions from Stage 02

## Process (time-boxed)

1. Pick 1–3 questions that matter most (highest falsification power).
2. For each, gather 1–3 concrete pieces of evidence (numbers, customer examples, pricing, timelines, constraints).
3. Update the judgment status: `active`, `weakened`, or `invalidated`.
4. Write the next expected signal (what you’ll look for next, and by when).

## Output

- A short evidence list mapped to each selected question (not a summary feed).
- A state update in `../state/active_hypothesis.md`:
  - `Status`, `Last Updated`, `Next Expected Signal`

## Rules

- Minimum viable sources only; stop when questions are answered.
- No “industry overview”; no “everything I learned”.
- If evidence doesn’t move the judgment, shrink scope or rewrite the judgment.

