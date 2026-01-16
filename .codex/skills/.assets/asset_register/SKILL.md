---
name: asset-register
description: Formally register a completed Asset into the asset system. Takes completed asset drafts from personal-company/20_drafts/, assigns Asset ID (A-XXX), moves to personal-company/10_assets/, and updates asset_index.md. Use when user confirms asset is ready for registration.
---

# Asset Register

## Purpose

Formally register a completed Asset into the asset system. This skill performs bookkeeping only—it does NOT modify asset content, rules, or assumptions.

## Inputs

Required:
- Completed asset draft: `personal-company/20_drafts/<asset-name>.md`
  - Must have `Status: draft` or be explicitly confirmed by user as ready

Required:
- Asset index file: `personal-company/10_assets/asset_index.md`

## Outputs

- Registered asset file: `personal-company/10_assets/A-XXX-<asset-name>.md`
  - File renamed with assigned Asset ID
  - Content unchanged (except Status field update if needed)
- Updated index: `personal-company/10_assets/asset_index.md`
  - New entry appended with: Asset ID, Asset name, "Used by:" placeholder

## ID Assignment Rules

1. **Read existing index**: Read `personal-company/10_assets/asset_index.md`
2. **Find highest ID**: Identify the highest A-XXX number currently in use
3. **Assign next ID**: Use A-XXX where XXX is the next sequential number (zero-padded to 3 digits)
   - Example: If highest is A-003, assign A-004
   - If no assets exist, start with A-001
4. **Verify uniqueness**: Ensure the assigned ID doesn't conflict with existing assets

## Workflow

1. **Read draft file**: Read the asset draft from `personal-company/20_drafts/`
2. **Read asset index**: Read `personal-company/10_assets/asset_index.md` to find next available ID
3. **Assign Asset ID**: Determine next sequential A-XXX ID
4. **Update asset file**:
   - Extract asset name from draft (first heading or filename)
   - Rename file to `A-XXX-<asset-name>.md` (sanitize name for filename)
   - Update `Status:` field from `draft` to `v0.1` (or keep if already versioned)
   - Update heading to include Asset ID: `# A-XXX Asset Name`
5. **Move file**: Move from `personal-company/20_drafts/` to `personal-company/10_assets/`
6. **Update index**: Append new line to `asset_index.md`:
   ```
   A-XXX Asset Name
   Used by: [to be filled]
   ```
   - Follow existing format in the index file
7. **Report**: Confirm registration with assigned ID and file location

## Index Format

The index file format (from existing `asset_index.md`):

```markdown
# Asset Index

A-001 Asset Name
Used by: skill1, skill2

A-002 Another Asset
Used by: skill3
```

New entries must follow this exact format.

## Constraints

### Allowed Actions
- Assign Asset ID
- Rename file with ID prefix
- Move file to assets directory
- Update index file with new entry
- Update Status field (draft → version)
- Update heading to include Asset ID

### Forbidden Actions
- Modifying asset content (rules, models, boundaries, assumptions)
- Changing Core Rule / Model
- Editing Boundaries or Failure Cases
- Creating or modifying assumption content
- Changing any substantive content beyond metadata

## Critical Principle

**You are a registry assistant, not a content editor.**

Your job is bookkeeping, not thinking.

Do NOT change the asset content.

Only perform:
- ID assignment
- File organization
- Index updates
- Metadata updates (Status, heading)
