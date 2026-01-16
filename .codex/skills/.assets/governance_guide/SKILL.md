---
name: governance-guide
description: Guide the user through the cognition → asset pipeline with minimal friction. Orchestrates inbox-triage, asset-intake, and asset-register skills. Use when user initiates asset creation workflow (e.g. "process inbox", "turn this into an asset", "register this asset").
---

# Governance Guide

## Purpose

Guide the user through the cognition → asset pipeline with minimal friction. This skill is a process orchestrator and conversational guide—it routes to appropriate lower-level skills and manages workflow state.

## Role

Process orchestrator and conversational guide. The guide NEVER generates judgments or rules—it only routes, asks questions, and stops when human judgment is required.

## Inputs

User intent (conversational):
- "Process my inbox"
- "Review inbox items"
- "Turn this into an asset"
- "Register this asset"
- Or explicit stage indication

## Outputs

- Orchestrated workflow execution
- State transitions between stages
- Human decision points (stops)
- Summary of actions taken

## Workflow States

The pipeline has these states:

1. **inbox** → Raw thoughts in `personal-company/00_inbox/`
2. **triage** → Classified items in `personal-company/10_triage/`
3. **intake** → Draft assets in `personal-company/20_drafts/`
4. **register** → Registered assets in `personal-company/10_assets/`

## Interaction Protocol

### 1. Determine User Stage

Ask the user what stage they are in:
- "Reviewing inbox" → Route to `inbox-triage`
- "Turning a thought into an asset" → Route to `asset-intake`
- "Registering an asset" → Route to `asset-register`

Or if user explicitly states a file or action, infer the stage.

### 2. Route to Appropriate Skill

Based on the answer, invoke ONE of:
- `inbox-triage`: For inbox review and classification
- `asset-intake`: For creating asset drafts
- `asset-register`: For registering completed drafts

### 3. After Each Step

- **Summarize**: What happened in this step
- **Ask exactly ONE question**: "Proceed / revise / stop?"
- **Wait for user confirmation** before continuing

### 4. Human Decision Points

If a field requires judgment (marked `[HUMAN REQUIRED]`):
- **Stop immediately**
- **Explicitly say**: "Human decision required."
- **Show what needs to be filled**
- **Wait for user to complete the field**

## Workflow Examples

### Example 1: Full Pipeline

1. User: "Process my inbox"
2. Guide: Routes to `inbox-triage`
3. Triage completes → Shows classification results
4. Guide: "Found X items. Proceed to asset intake for item Y? (proceed / revise / stop)"
5. If proceed → Routes to `asset-intake` for selected item
6. Intake completes → Shows draft
7. Guide: "Draft created. Fill [HUMAN REQUIRED] fields, then proceed to register? (proceed / revise / stop)"
8. User fills fields
9. Guide: Routes to `asset-register`
10. Registration completes → Shows registered asset

### Example 2: Direct Asset Creation

1. User: "Turn this file into an asset" (points to inbox file)
2. Guide: Routes directly to `asset-intake` (bypasses triage)
3. Intake completes → Shows draft
4. Guide: "Draft created. Fill [HUMAN REQUIRED] fields, then proceed to register? (proceed / revise / stop)"

### Example 3: Registration Only

1. User: "Register this draft" (points to draft file)
2. Guide: Routes to `asset-register`
3. Registration completes → Shows registered asset with ID

## Constraints

### Allowed Actions
- Route to `inbox-triage`
- Route to `asset-intake`
- Route to `asset-register`
- Ask yes/no or clarifying questions
- Summarize workflow state
- Stop at human decision points

### Forbidden Actions
- Creating core rules or judgments
- Filling judgment fields (Core Rule / Model, Boundaries, Failure Cases)
- Continuing without user confirmation
- Proposing rules or assumptions
- Modifying asset content

## Critical Rules

1. **Never generate judgments**: The guide NEVER fills `[HUMAN REQUIRED]` fields
2. **One question at a time**: After each step, ask exactly ONE question
3. **Explicit stops**: When human judgment is required, stop and explicitly state what's needed
4. **User confirmation required**: Never proceed to next stage without explicit user approval
5. **State awareness**: Track which stage the user is in and route accordingly

## Error Handling

- If user provides invalid file path: Ask for clarification
- If required fields are missing: Stop and ask user to provide
- If skill execution fails: Report error and ask if user wants to retry or stop
- If user wants to go back: Allow returning to previous stage
