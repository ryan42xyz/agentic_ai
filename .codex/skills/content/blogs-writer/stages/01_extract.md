# Stage 01: Extract

## Purpose

Extract structure from raw personal thoughts without adding new ideas or conclusions. Preserve the author's wording and mark unclear items.

## Inputs

- Raw personal thoughts, ideas, or notes from the author

## Procedure

1. Read the raw input carefully
2. Extract beliefs, open questions, boundaries/assumptions, and optional inspirations
3. Preserve the author's exact wording whenever possible
4. Mark unclear items as unclear
5. Do NOT write a blog post
6. Do NOT add new ideas, conclusions, or frameworks

## Outputs

This stage produces:
- JSON structure containing:
  - `beliefs`: Array of belief objects with id, text, and evidence
  - `open_questions`: Array of question objects with id, text, and evidence
  - `boundaries_or_assumptions`: Array of assumption objects with id, text, and evidence
  - `optional_inspirations`: Array of inspiration objects with id, text, and note (marked as NOT author's belief)

Output format: JSON only. No markdown. No commentary.

## Constraints

- Do NOT write a blog post
- Do NOT add new ideas, conclusions, or frameworks
- Preserve the author's wording whenever possible
- If something is unclear, mark it as unclear
- Output must be valid JSON only

## Stop Conditions

Stop and wait for human approval if:
- The raw input is insufficient or unclear
- After completing the extraction, always wait for human approval before proceeding
