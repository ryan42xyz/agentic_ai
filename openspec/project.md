# Project Specification

## Project Overview

**Status**: ACTIVE

This document describes the current state and architecture of this repository as understood through static analysis and explicit documentation.

## Project Facts (Fill In)

- **Owner / Maintainer**: UNKNOWN
- **Primary users**: UNKNOWN (e.g., just you, your team, OSS users)
- **Primary workflows**: OpenSpec change cycle + skill-driven execution
- **Where it runs**: Local developer machines (CLI + editor integrations); no CI config found at repo root (no `.github/`, etc.)
- **External dependencies**: Docs reference an `openspec` CLI (e.g., `openspec/USAGE.md`, `openspec/QUICK_REFERENCE.md`), but this repo does not include installation instructions or a vendored binary

## What This Project Does

**Purpose**: This repository stores OpenSpec documentation plus reusable “skills” and prompts for running a spec-driven, human-led workflow for AI-assisted work.

**Core Functionality**:
- **OpenSpec Framework**: A specification-driven development system that enforces "spec before code" principles
- **AI Engineering Assets**: Reusable skills, prompts, and workflows stored in `.codex/` directory
- **Change Management**: Structured workflow for proposals, reviews, implementations, and archiving
- **Tool Agnosticism**: Assets designed to work across Cursor, CLI, and other AI agent tools

**Key Components**:
- **Skills System**: Reusable AI workflows under `.codex/skills/` (organized by category: control, decision, execution, cognition, domains, system)
- **Prompts**: Agent bootstrap / workflow prompts under `.codex/prompts/`
- **OpenSpec Workflow**: Proposal → review → apply → archive loop (documented under `openspec/`)
- **Editor Integration**: Cursor slash-commands under `.cursor/commands/` for proposal/apply/archive scaffolding

**Observations**:
- Repository name: `agentic_ai`
- Contains an `openspec/` directory (OpenSpec specification framework)
- Contains a `.codex/` directory (AI engineering assets with skills and prompts)
- Contains a `.cursor/commands/` directory (Cursor command definitions)
- Contains an `opensource/` directory with a vendored third-party repository (`opensource/awesome-claude-skills/`) that includes executable code (e.g., Python scripts) and its own dependency files (e.g., `requirements.txt` under some skills)
- Contains a `dist/` directory with packaged skill files (`.skill` format)
- Contains a `scripts/` directory with utility scripts
- No language runtime or dependency manifests were found at repo root (no `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`)
- Predominantly Markdown-based documentation/specification assets, plus small code/script artifacts under `opensource/`

## Scope

**In scope (what this repo is for)**:
- OpenSpec project context and AI behavior constraints (`openspec/project.md`, `openspec/AGENTS.md`)
- OpenSpec change artifacts under `openspec/changes/` (proposals, reviews, and archives)
- First-party, tool-agnostic AI skills and prompts under `.codex/`
- Editor workflow scaffolding under `.cursor/commands/`
- Vendored third-party skill collections under `opensource/` (as included in this working tree)

**Out of scope / not present as a single cohesive system**:
- A single “application” runtime with a unified build/test/run entrypoint
- A repository-defined installation path for the `openspec` CLI
- A repository-defined CI pipeline (none observed at repo root)

## Primary Tech Stack

**Technology Stack**: Documentation/specification assets + lightweight editor/CLI conventions.

**Core Technologies**:
- **Markdown**: Primary format for all documentation, specifications, and AI assets
- **Git**: Version control for all assets
- **YAML frontmatter**: Skill metadata (`name`, `description`) embedded at top of some skill markdown files
- **OpenSpec file conventions**: `openspec/` directory structure and change lifecycle documents
- **Cursor commands (optional)**: `.cursor/commands/openspec-*.md` definitions
- **OpenSpec CLI (optional/external)**: Documentation references an `openspec` CLI, but this repo does not define how it’s installed (UNKNOWN)

**Observations**:
- No traditional application code dependencies (`package.json`, `requirements.txt`, `pyproject.toml`, `Cargo.toml`, `go.mod`)
- No single repo-wide runtime/language toolchain; code artifacts exist primarily under `opensource/`
- First-party assets (`openspec/`, `.codex/`, `.cursor/`) are Markdown-first for portability and version control

**Stated goals (as documented in repo docs)**:
- Tool-agnostic, versionable assets
- Spec-first workflow (“proposal → review → apply → archive”)
- Human-led gating for high-impact steps

## Operational Conventions

### Standard Commands (Fill In)

Several validators (compile/test/run/api_test) require “the standard project command(s)”. This repo currently does not define them. Fill these in so verification can run without ambiguity:

- **Compile**: UNKNOWN (example: `make build`, `go build ./...`)
- **Unit tests**: UNKNOWN (example: `go test ./...`, `pytest`)
- **Run**: UNKNOWN (example: `make run`, `docker compose up`)
- **API tests**: UNKNOWN (example: `newman run ...`, `curl` smoke checks)

### Skill Conventions

- **Location**: skills live under `.codex/skills/`, organized by category (e.g., `0_control/`, `1_decision/`, `2_execution/`, `cognition/`, `domains/`, `system/`, `.system/`).
- **Metadata**: most skills use YAML frontmatter at the top of `SKILL.md`.
- **Stage-gated workflows**: multi-step skills keep stage documents in `stages/` with numeric prefixes (e.g., `01_review.md`).
- **Evidence-first validation**: validators treat outputs as evidence sources; failures must be reported verbatim; overrides require explicit human acknowledgement.

### OpenSpec Change Conventions

- **Change folders**: `openspec/changes/<change-id>/` typically contains at least `proposal.md`, and may include `review.md` and other artifacts.
- **Archive folder**: `openspec/changes/archive/` exists for archived change snapshots.
- **Language**: OpenSpec docs in this repo include Chinese (`openspec/USAGE.md`, `openspec/QUICK_REFERENCE.md`) and English (skills and prompts).

## Architectural Style

**Repository Pattern**: Documentation + skills repository for a spec-driven (OpenSpec) workflow

**Pattern Characteristics**:
- **Workflow/asset focused**: Contains OpenSpec docs, skills, and editor command scaffolding; it is not a single deployable application
- **Skills-Based Architecture**: Modular, reusable AI workflows organized as skills
- **Specification-Driven**: OpenSpec framework enforces structured development workflows
- **Documentation-Centric**: Markdown-based specifications and documentation as primary artifacts

**Architectural Components**:
1. **OpenSpec Framework** (`openspec/`):
   - `project.md`: Project context and specifications
   - `AGENTS.md`: AI agent role definitions and constraints
   - `changes/`: Change proposals and their lifecycle
   - `specs/`: Stable specifications (when changes are archived)

2. **AI Engineering Assets** (`.codex/`):
   - `skills/`: Reusable AI workflows and procedures
   - `prompts/`: System prompts and templates
   - Skills organized by category (control, decision, execution, cognition, domains, system)

3. **Workflow System**:
   - Four-stage cycle: proposal → review → apply → archive
   - Stage-gated execution with mandatory human approval points
   - Validation and verification at each stage

**Design Principles**:
- **Separation of Concerns**: Skills are domain-specific and reusable
- **Explicit Workflows**: All procedures documented in markdown
- **Human-in-the-Loop**: Mandatory approval points at each stage
- **Version Control**: All assets tracked in git

## Coding and Operational Constraints

### Explicit Constraints (from setup)

1. **AI Engineering Workflow**:
   - OpenSpec-driven workflow is enforced
   - "Spec before code" principle applies
   - Silent code edits are prohibited
   - Proposal → review → apply → archive loop is encouraged

2. **Infrastructure-Level Focus**:
   - Do NOT modify application code without explicit requirements
   - Do NOT invent requirements
   - Prefer generating markdown documents over code
   - All AI assets must be versionable and reusable across tools

3. **Tool Agnosticism**:
   - AI engineering assets in `.codex/` must work across Cursor, CLI, and other agents
   - Skills and prompts are version-controlled and reusable

### Inferred Constraints

**Documentation / format signals**:
- OpenSpec and first-party skills are Markdown
- Some skills use YAML frontmatter for `name`/`description`
- OpenSpec docs include Chinese (`openspec/USAGE.md`, `openspec/QUICK_REFERENCE.md`) alongside English content in skills

**Workflow Constraints**:
- **Stage-Gated Execution**: Must complete stages in order (review → refine → validate → implement → sync knowledge)
- **Human Approval Required**: Stop after each stage for explicit approval
- **No Scope Creep**: Cannot introduce features beyond the change document
- **No Silent Edits**: All changes must be documented in proposals

**File Organization**:
- Skills organized by category in `.codex/skills/` (control, decision, execution, cognition, domains, system)
- Prompts in `.codex/prompts/`

**Testing and Validation**:
- Verification system with compile, run, and test validators
- Change execution skill includes an explicit `03_validate` stage
- Verification outputs a pass/fail/block verdict intended to gate progression

**Deployment**:
- No traditional deployment (infrastructure repository)
- Changes tracked through OpenSpec workflow
- Assets version-controlled in git

## Directory Structure

```
agentic_ai/
├── .codex/                       # AI engineering assets (skills, prompts, configuration)
│   ├── skills/                   # Reusable AI skills
│   │   ├── 0_control/            # Control layer skills (state_validator, state_diff_tracker, execution_state_compiler)
│   │   ├── 1_decision/           # Decision layer skills (action_selector, plan_refiner)
│   │   ├── 2_execution/          # Execution layer skills (change_authoring, execution_runner, info_retrieval)
│   │   ├── cognition/            # Cognitive skills (brainstorming, critical-thinking, first-principles)
│   │   ├── domains/              # Domain-specific skills (infra/oncall-fast-response, infra/oncall_checklister)
│   │   ├── system/               # System-level skills (prompt-engineering, skill-creator, skill-installer)
│   │   └── .system/              # System skills (skill-creator, skill-installer)
│   ├── prompts/                  # System prompts and templates
│   │   ├── openspec-0-populate-proj-ctx.md
│   │   ├── openspec-1-proposal.md
│   │   ├── openspec-2-apply.md
│   │   ├── openspec-100-archive.md
│   │   └── openspec_001.md
│   └── [config files]            # Codex configuration files
├── .cursor/                      # Cursor IDE integration
│   └── commands/                 # Custom Cursor commands
│       ├── openspec-apply.md
│       ├── openspec-archive.md
│       └── openspec-proposal.md
├── openspec/                     # OpenSpec specification files
│   ├── project.md                # This file (project context)
│   ├── AGENTS.md                 # Agent specifications
│   ├── USAGE.md                  # Usage guide (Chinese)
│   ├── QUICK_REFERENCE.md        # Quick reference guide
│   ├── specs/                    # Stable specifications (currently empty)
│   └── changes/                  # Change proposals
│       ├── add-change-execution-skill/
│       ├── add-skills-builder-skill/
│       └── add-verification-skill/
├── opensource/
│   └── awesome-claude-skills/     # Vendored third-party “Awesome Claude Skills” repo (contains scripts, assets, and licenses)
└── AGENTS.md                     # Root-level agent instructions (OpenSpec managed)
```

## Current Skills Inventory

**Control Layer Skills** (`.codex/skills/0_control/`):
- `state_validator/`: Validate execution state for logical, evidential, and structural integrity
- `state_diff_tracker/`: Track meaningful state progression by diffing state snapshots
- `execution_state_compiler/`: Compile execution traces into verifiable execution state

**Decision Layer Skills** (`.codex/skills/1_decision/`):
- `action_selector/`: Translate approved plan actions into executable action declarations
- `plan_refiner/`: Address unresolved uncertainties to refine plans

**Execution Layer Skills** (`.codex/skills/2_execution/`):
- `change_authoring/`: Produce code changes as patch artifacts based on executable actions
- `execution_runner/`: Execute declared commands/tests and capture raw output
- `info_retrieval/`: Retrieve raw information and store as evidence

**Cognition Skills** (`.codex/skills/cognition/`):
- `brainstorming/`: Explore user intent, requirements, and design before implementation
- `critical-thinking/`: Analyze claims with evidence standards and reasoning chains
- `first-principles/`: Reason from first principles, rebuilding explanations from fundamental constraints

**Domain Skills** (`.codex/skills/domains/`):
- `infra/oncall-fast-response/`: Generate fast, safe, auditable responses for first-response oncall situations
- `infra/oncall_checklister/`: Oncall checklist and triage workflow

**System Skills** (`.codex/skills/system/`, `.codex/skills/.system/`):
- `prompt-engineering/`: Guide for writing and optimizing prompts, commands, hooks, and skills
- `skill-creator/`: Guide for creating effective skills
- `skill-installer/`: Install skills from curated lists or GitHub repos

**Prompts** (`.codex/prompts/`):
- `openspec-0-populate-proj-ctx.md`: Populate and refine openspec/project.md
- `openspec-1-proposal.md`: Create OpenSpec change proposals
- `openspec-2-apply.md`: Apply OpenSpec changes
- `openspec-100-archive.md`: Archive OpenSpec changes
- `openspec_001.md`: Prompt notes / starter instructions

## Known Unknowns / Gaps (Need Human Input)

- **Owner / audience**: Who owns this repo and who it is intended for (personal vs team vs OSS)
- **OpenSpec CLI**: Where the `openspec` CLI comes from and how it should be installed/versioned for users of this repo
- **CHANGELOG.md**: `openspec/USAGE.md` and `openspec/QUICK_REFERENCE.md` reference `openspec/CHANGELOG.md`, but it is not present in this working tree
- **Verification “standard commands”**: If the verification skill is intended to be used here, what commands map to compile/test/run/api_test (this repo is not an application with an obvious default)

## Last Updated

- **Date**: 2025-01-11
- **Method**: Repository scan + documentation review
- **Confidence**: High (repository structure verified; UNKNOWNs remain for ownership/audience, OpenSpec CLI installation, and verification command mapping)

---

**Note**: This document should be updated as the project evolves. When context is lost, rebuild this file by scanning the repository and updating sections with actual findings rather than guesses.
