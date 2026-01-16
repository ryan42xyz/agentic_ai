---
name: inbox-triage
description: Classify raw inbox thoughts from personal-company/00_inbox/ and assess whether they are candidates for asset creation. Outputs structured YAML classification. Use when reviewing inbox items or when user explicitly requests triage.
---

# Inbox Triage

## Purpose

Classify raw inbox thoughts and assess whether they are candidates for asset creation. This skill performs classification only—it does NOT generate new ideas, evaluate correctness, or create judgments.

## Inputs

Required:
- Raw inbox file from `personal-company/00_inbox/**/*.md`

Optional:
- Existing triage results from `personal-company/10_triage/` (if re-triaging)

## Outputs

- Classification file: `personal-company/10_triage/<source-filename>.yaml`
  - Format: YAML with required fields (see Classification Schema below)
  - If source file is in subdirectory (e.g., `00_inbox/acknowledge/note1.md`), preserve relative path structure

## Classification Schema

Output YAML must contain these fields:

```yaml
candidate_type: judgment | observation | information | emotional | noise
decision_involved: yes | no
reusability: high | medium | low
signals_of_asset:
  repeated_pattern: yes | no | unknown
  explicit_decision: yes | no | unknown
  mentions_boundary: yes | no | unknown
  mentions_failure: yes | no | unknown
suggested_next_step: asset_intake | archive | discard
source_file: <relative path from personal-company/>
```

## Workflow

1. **Read input file**: Read the specified markdown file from `personal-company/00_inbox/`
2. **Classify content**: Apply classification rules (see Rules below)
3. **Generate YAML**: Create structured YAML output following the schema
4. **Write output**: Save to `personal-company/10_triage/<source-filename>.yaml`
   - Create `10_triage/` directory if it doesn't exist
   - Preserve subdirectory structure if source is in a subdirectory
5. **Report result**: Summarize classification to user

## Rules

### Classification Rules

- **candidate_type**:
  - `judgment`: Contains a decision rule, principle, or judgment call
  - `observation`: Describes a pattern or phenomenon
  - `information`: Factual data or reference material
  - `emotional`: Personal feelings or reactions
  - `noise`: Not actionable or relevant

- **decision_involved**: Does the content involve a decision the user made or needs to make?

- **reusability**: How likely is this to be useful in future contexts?
  - `high`: Clear pattern, explicit decision framework, mentions boundaries/failures
  - `medium`: Some structure but needs refinement
  - `low`: One-off, context-specific, or incomplete

- **signals_of_asset**: Look for indicators that this could become an asset:
  - `repeated_pattern`: Mentions patterns, "always", "usually", "often"
  - `explicit_decision`: Contains decision criteria, "when X, do Y"
  - `mentions_boundary`: Discusses limits, "not when", "except if"
  - `mentions_failure`: Describes failures, edge cases, counterexamples

- **suggested_next_step**:
  - `asset_intake`: If reusability is high AND signals_of_asset are present
  - `archive`: If useful but not asset-worthy
  - `discard`: If noise or low value

## Constraints

### Allowed Actions
- Label and classify content
- Summarize findings
- Ask clarification questions if input is ambiguous

### Forbidden Actions
- Proposing core rules or judgments
- Rewriting content into assets
- Evaluating correctness or truth
- Generating new ideas
- Filling in missing information

## Critical Principle

**You are a classification assistant, not a thinking assistant.**

Your job is NOT to think for the user.
Your job is to classify the input so the user can decide.

Classify ONLY. Do not add opinions.
