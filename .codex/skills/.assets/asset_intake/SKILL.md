---
name: asset-intake
description: Convert a selected thought into a structured Asset draft WITHOUT creating judgment. Takes input from triage results or raw inbox files, outputs draft assets to personal-company/20_drafts/. Use when user confirms a thought is worth assetization.
---

# Asset Intake

## Purpose

Convert a selected thought into a structured Asset draft WITHOUT creating judgment. This skill structures information only—it does NOT fill judgment fields or invent boundaries.

## Inputs

Required (one of):
- Triage result file: `personal-company/10_triage/<filename>.yaml`
- Raw inbox file: `personal-company/00_inbox/**/*.md` (if user bypasses triage)

Optional:
- Asset template: `personal-company/_templates/asset.md` (if different from default)

## Outputs

- Asset draft file: `personal-company/20_drafts/<asset-name>.md`
  - Format: Markdown following asset template structure
  - Status field must be set to `draft`
  - Fields requiring human judgment must be marked `[HUMAN REQUIRED]`

## Asset Template Structure

The output must follow this structure (based on `personal-company/_templates/asset.md`):

```markdown
# Asset Draft (TEMP)

Problem:
What decision was the user trying to make? (Extract from input)

Core Rule / Model:
[HUMAN REQUIRED]

Context:
Where might this decision apply? (Extract only from text, do not invent)

Boundaries:
List questions the user must answer to define boundaries. (Do not invent boundaries)

Failure Cases:
Ask whether a failure or counterexample exists. (Do not invent failure cases)

Related Assumptions:
Suggest possible assumption placeholders (AS-XXX), do not invent content.

Status:
draft

Last Reviewed:
[leave empty]
```

## Workflow

1. **Read input**: 
   - If triage file: Read YAML and locate source file from `source_file` field
   - If raw inbox file: Read directly
2. **Extract context**: Extract only information present in the source text
3. **Generate draft structure**: Create asset draft following template
4. **Mark human-required fields**: 
   - `Core Rule / Model` must always be `[HUMAN REQUIRED]`
   - `Boundaries` should list questions, not answers
   - `Failure Cases` should ask questions, not provide answers
5. **Write draft**: Save to `personal-company/20_drafts/<asset-name>.md`
   - Create `20_drafts/` directory if it doesn't exist
   - Use descriptive filename based on problem or topic
6. **Report**: Summarize what was extracted and what requires human input

## Rules

### Extraction Rules

- **Problem**: Extract the decision question or problem statement from the text
- **Context**: Extract only where/when this applies, as mentioned in the text
- **Boundaries**: Generate questions the user must answer, do NOT invent boundaries
- **Failure Cases**: Ask whether failures exist, do NOT invent them
- **Related Assumptions**: Suggest placeholder IDs (AS-XXX) if assumptions are mentioned, do NOT create assumption content

### Human-Required Fields

These fields MUST be marked `[HUMAN REQUIRED]` and never filled:
- `Core Rule / Model`: The actual decision rule or model
- `Boundaries`: The actual boundary definitions (only questions allowed)
- `Failure Cases`: The actual failure cases (only questions allowed)

## Constraints

### Allowed Actions
- Extract context from source text
- Generate questions for boundaries and failure cases
- Create empty structure following template
- Suggest assumption placeholders

### Forbidden Actions
- Writing final rules or models
- Declaring validity or correctness
- Inventing boundaries or failure cases
- Creating assumption content
- Filling judgment fields

## Critical Principle

**You are an intake assistant, not a thinking assistant.**

You do NOT think or decide.
You ONLY structure.

If a field requires human judgment, write: `[HUMAN REQUIRED]`.
