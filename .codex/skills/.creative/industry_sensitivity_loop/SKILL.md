---
name: industry_sensitivity_loop
description: Maintain long-term industry sensitivity (行业敏感度) by running a loop to form, adversarially validate, and update a single falsifiable industry-direction judgment (one active hypothesis at a time).
metadata:
  short-description: Industry sensitivity loop / 行业判断
---

# Industry Sensitivity Loop

## Purpose

- Maintain long-term industry sensitivity by forming, testing, and updating high-level judgments.
- This skill prioritizes judgment quality over information coverage.

## Non-goals

- News aggregation
- Trend summarization
- Knowledge base construction

## Core Output

- A falsifiable judgment about industry direction.

## Operating Mode

- Event-driven
- One active hypothesis at a time
- Validation is adversarial, not confirmatory

## Files (the contract)

- `state/active_hypothesis.md`: The only persistent state; must contain exactly one active hypothesis.
- `stages/01_direction.md`: Slow input; create a falsifiable judgment without sources.
- `stages/02_validation.md`: Adversarial validation; question-driven research only.
- `stages/03_fast_input.md`: Fast input; collect only what answers validation and updates signals.
- `run/quick_start.md`: Minimal loop to run in 10–30 minutes.

## Hard Rules

- Do not create multiple hypotheses in parallel; replace or weaken the active one.
- If there are no validation questions, do not open Twitter / HN / Bloomberg / feeds.
- Always map any input back to: (a) the judgment, (b) validation questions, (c) next expected signal.
