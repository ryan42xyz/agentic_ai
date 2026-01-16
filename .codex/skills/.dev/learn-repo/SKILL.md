---
name: learn-repo
description: Analyze a source code repository from multiple independent perspectives (facets) and convert it into a structured, long-lived knowledge object. Use when you need to understand a repository's intent, problem space, core concepts, boundaries, structure, dynamics, constraints, tradeoffs, comparisons, and open questions. This skill is NOT for line-by-line code reading or producing tutorials, but for compressing a repository into a reusable mental model that surfaces core abstractions, constraints, and assumptions while explicitly recording uncertainty.
---

# Learn Repo Skill (Facet-based)

## Purpose

This skill is designed to analyze a source code repository from multiple
independent perspectives (facets) and convert it into a structured,
long-lived knowledge object.

It is NOT intended to:
- fully read or understand every line of code
- produce a tutorial or usage guide
- guarantee correctness or completeness

It IS intended to:
- compress a repository into a reusable mental model
- surface core abstractions, constraints, and assumptions
- explicitly record uncertainty and knowledge gaps
- support incremental refinement over time

## Inputs

Required:
- Repository path or URL
- Intended usage context (read / modify / extend / evaluate)
- Depth budget (quick scan / normal / deep)

Optional:
- Prior domain knowledge
- Code reading allowance (none / selective / full)

## Outputs

A structured knowledge directory representing the repository,
organized by facets rather than workflow stages.

The output is designed to be:
- human-readable
- diff-friendly
- incrementally updatable
- reusable across similar repositories

## Method

The repository is analyzed once, but modeled through multiple facets.
Each facet represents an independent lens on the system and may be
incomplete or partially speculative.

Uncertainty is considered a first-class output.

## Facets

This skill uses a facet-based approach rather than linear stages.
Each facet represents an independent analytical lens on the repository.

### Core Facets (Minimum Set)

1. **intent.md** - Why this repository exists
2. **problem-space.md** - How the problem is conceptualized
3. **concepts.md** - Core conceptual model and language
4. **boundaries.md** - System boundaries and responsibilities
5. **structure.md** - Structural skeleton (not directory tree)
6. **dynamics.md** - How the system behaves over time

### Extended Facets (Optional)

7. **constraints.md** - Real-world constraints shaping the code
8. **tradeoffs.md** - Design choices and what was sacrificed
9. **comparisons.md** - Positioning relative to similar systems
10. **open-questions.md** - Uncertainty and knowledge gaps

## Usage

For each facet you need to analyze:

1. Read the corresponding facet prompt in `facets/<facet-name>.md`
2. Apply the prompt to the repository
3. Produce structured markdown output following the facet's contract
4. Explicitly mark uncertainty where appropriate

Start with the core facets (1-6) for a complete analysis.
Add extended facets (7-10) when deeper understanding is needed.

## Global Conventions

All facet prompts share these conventions:

- You are analyzing a source code repository
- Your goal is NOT to explain code line-by-line, and NOT to produce a tutorial
- Your goal is to model the repository from a specific analytical lens
- Produce structured, falsifiable understanding
- Explicitly mark uncertainty where appropriate
- Prefer abstraction over implementation details
- Prefer stable concepts over transient code structure

See individual facet files in `facets/` for specific prompts and contracts.
