# Assets Skills

This directory contains skills for managing the personal cognition asset pipeline: inbox → triage → intake → register.

## Skills

### 1. inbox-triage
Classifies raw inbox thoughts and assesses whether they are candidates for asset creation.

- **Input**: `personal-company/00_inbox/**/*.md`
- **Output**: `personal-company/10_triage/<filename>.yaml`
- **Purpose**: Classification only, no judgment creation

### 2. asset-intake
Converts selected thoughts into structured Asset drafts without creating judgment.

- **Input**: Triage results or raw inbox files
- **Output**: `personal-company/20_drafts/<asset-name>.md`
- **Purpose**: Structure information, mark `[HUMAN REQUIRED]` fields

### 3. asset-register
Formally registers completed Assets into the asset system.

- **Input**: Completed asset drafts from `personal-company/20_drafts/`
- **Output**: Registered assets in `personal-company/10_assets/A-XXX-<name>.md`
- **Purpose**: Bookkeeping only, assigns IDs and updates index

### 4. governance-guide
Orchestrates the full pipeline and guides users through the workflow.

- **Input**: User intent (conversational)
- **Output**: Orchestrated workflow execution
- **Purpose**: Process orchestration, routes to other skills

## Directory Structure

The skills expect these directories (created automatically on first use):

```
personal-company/
├── 00_inbox/          # Raw thoughts (existing)
├── 10_triage/         # Classification results (auto-created)
├── 20_drafts/         # Asset drafts (auto-created)
└── 10_assets/         # Registered assets (existing)
    └── asset_index.md # Asset registry (existing)
```

## Workflow

1. **Inbox** → Raw thoughts collected
2. **Triage** → Classify and assess asset potential
3. **Intake** → Create structured draft (with `[HUMAN REQUIRED]` fields)
4. **Register** → Assign ID and move to assets directory

## Key Principles

- **No judgment creation**: Skills structure and classify, but never create rules or judgments
- **Human decision points**: Fields requiring judgment are marked `[HUMAN REQUIRED]`
- **Fixed execution logic**: Each skill has clear, repeatable steps
- **Explicit file paths**: All inputs and outputs use concrete file paths
