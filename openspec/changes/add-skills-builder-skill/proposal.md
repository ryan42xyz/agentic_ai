# Proposal: Add skills_builder skill

## Goal

Add a new skill `skills_builder` under `.ai/skills/` that helps users build new skills. This skill will guide the creation of skill definitions, optional policy files, and optional specification directories following the established skill structure patterns in this repository.

## Scope

- Create a new skill under `.ai/skills/.dev/skills_builder/` with:
  - `SKILL.md` - Main skill definition with YAML frontmatter
  - Optional `policy.md` - Policy/constraints document (if needed)
  - Optional `spec/` directory - For skill specifications and templates (if needed)
- The skill should guide users through creating:
  - `SKILL.md` (or `skill.md`) - Main skill definition
  - `policy.md` (optional) - Policy and constraints
  - `spec/` directory (optional) - Specifications and templates
- Follow the established skill structure patterns:
  - YAML frontmatter with `name` and `description`
  - Clear purpose and when to use
  - Inputs, outputs, and constraints
  - Stage-gated workflow if applicable
- The skill should be meta-level: it helps build other skills

## Out of Scope

- Any application code changes
- Any changes to existing skills (except documentation references)
- Any OpenSpec CLI scripts or tooling changes
- Any changes outside `.ai/skills/.dev/skills_builder/`

## Deliverables

- `.ai/skills/.dev/skills_builder/SKILL.md` - Main skill definition
- `.ai/skills/.dev/skills_builder/policy.md` (optional) - Policy document if needed
- `.ai/skills/.dev/skills_builder/spec/` (optional) - Specification templates if needed

## Skill Requirements

The `skills_builder` skill should:

1. **Guide skill creation**:
   - Help identify skill purpose and scope
   - Determine if skill needs stages, policy, or spec directory
   - Generate appropriate skill structure based on patterns

2. **Follow established patterns**:
   - Reference existing skills (openspec_change_apply, requirement_analysis, verification) as examples
   - Support both simple skills and stage-gated workflows
   - Support optional policy.md and spec/ directory structures

3. **Output structure**:
   - Generate `SKILL.md` with proper YAML frontmatter
   - Generate `policy.md` if constraints/policies are needed
   - Generate `spec/` directory structure if specifications are needed
   - Ensure all outputs follow repository conventions

4. **Constraints**:
   - Must not modify existing skills
   - Must follow OpenSpec workflow (proposal → review → apply → archive)
   - Must produce versionable, markdown-based outputs
   - Must be tool-agnostic (work across Cursor, CLI, etc.)

## Open Questions

1. Should this skill be stage-gated like `openspec_change_apply`, or should it be a simpler single-step skill?
2. Should it include templates for common skill patterns (simple skill, stage-gated skill, skill with policy)?
3. Should it validate the generated skill structure against existing patterns?
4. Should it be placed in `.ai/skills/.dev/` (development tools) or directly in `.ai/skills/`?

## Rationale

Creating skills is a common task in this repository, and having a dedicated skill to help build skills will:
- Ensure consistency across skill definitions
- Reduce errors in skill structure
- Provide guidance on when to use policy.md and spec/ directories
- Accelerate skill creation workflow
- Maintain alignment with established patterns
