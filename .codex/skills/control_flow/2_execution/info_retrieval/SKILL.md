---
name: info-retrieval
description: Retrieve raw information and store it as evidence, based on a declared executable action. No interpretation.
---

# Info Retrieval

## Purpose

Retrieve raw information and store it as evidence.

## Inputs (read-only)

- `openspec/changes/<change-name>/actions/action-XXX-exec.md`

## Outputs (write-only)

- Write only:
  - `openspec/changes/<change-name>/evidence/<source>/<artifact>.md`
- Do not write anywhere else.

## Evidence Rules

Every evidence file MUST include:

- Source
- Retrieval method
- Time window
- Raw excerpt

No interpretation.

## Forbidden

- Summaries
- Conclusions
- Filtering to fit hypotheses
- Writing or modifying state
- Writing decision outputs

