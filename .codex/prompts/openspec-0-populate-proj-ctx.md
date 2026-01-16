---
description: Populate and refine openspec/project.md with concrete, verifiable project context.
argument-hint: optional high-level project description or constraints
---

$ARGUMENTS

<!-- OPENSPEC:START -->
**Objective**
You are helping to make `openspec/project.md` a clear, accurate, and human-readable source of truth
for understanding this project’s purpose, scope, technical foundations, and working conventions.

This is NOT a design or implementation task.
Your goal is to clarify and surface existing reality, not invent new decisions.

**Guardrails**
- Only edit `openspec/project.md`.
- Prefer completing missing sections or refining unclear ones over rewriting existing content.
- Do NOT invent architecture, tooling, or conventions that are not evidenced in the repo.
- If required information cannot be confidently inferred, stop and ask explicit follow-up questions.
- Avoid aspirational language; describe what *is*, not what *might be*.

**Sources of Truth**
Use the following, in priority order:
1. Existing content in `openspec/project.md`
2. Repository structure (`ls`, folder names, config files)
3. Readable signals in the codebase (imports, frameworks, build tools)
4. Any user-provided arguments or context

Do not rely on generic best practices unless they are already implied by the project.

**What to Fill**
Ensure the document clearly answers:
- What problem this project is trying to solve (in one or two concrete sentences)
- What is explicitly in scope vs out of scope
- The primary tech stack (language, runtime, major frameworks, infra assumptions)
- How this project is expected to be worked on (conventions, workflows, constraints)

**Output Expectations**
- Produce a clean, coherent `openspec/project.md` that a new engineer could read in 5 minutes
  and correctly explain what this project is and how it is approached.
- If you encounter ambiguity that affects correctness, ask questions instead of guessing.

**Non-Goals**
- Do not propose new features, refactors, or specs.
- Do not modify or reference other files.
- Do not validate or optimize the tech stack.

<!-- OPENSPEC:END -->
