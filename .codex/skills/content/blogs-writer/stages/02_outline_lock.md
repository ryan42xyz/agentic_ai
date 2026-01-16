# Stage 02: Outline Lock

## Purpose

Compile a locked outline from the extracted structure. The outline must not be expanded later - it is locked at this stage.

## Inputs

- Extracted structure JSON from Stage 01

## Procedure

1. Use ONLY the provided extracted structure
2. Generate title candidates
3. Create a locked outline with sections, headings, intents, and belief IDs to include
4. List explicit boundaries (what the article does NOT claim)
5. Do NOT introduce new beliefs or arguments
6. Do NOT expand the outline beyond what's in the extracted structure

## Outputs

This stage produces:
- JSON structure containing:
  - `title_candidates`: Array of potential titles
  - `locked_outline`: Array of section objects with:
    - `section`: Section number
    - `heading`: Section heading
    - `intent`: What this section intends to convey
    - `include_belief_ids`: Array of belief IDs to include
    - `exclude_optional_ids`: Array of optional inspiration IDs to exclude
  - `explicit_boundaries`: Array of statements about what the article does NOT claim

Output format: JSON only.

## Constraints

- Use ONLY provided inputs
- Do NOT introduce new beliefs or arguments
- The outline is LOCKED and must not be expanded later
- Output must be valid JSON only

## Stop Conditions

Stop and wait for human approval if:
- The extracted structure is insufficient
- After completing the outline, always wait for human approval before proceeding
- If the outline needs significant changes, stop and re-lock it
