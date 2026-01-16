---
name: core-distiller
description: Rewrite a cleaned technical article into a high-density, minimal-yet-complete version by removing non-essential explanations while preserving core concepts, logic, and constraints. Produces a readable, long-term knowledge artifact.
allowed-tools: Write
---

# Core Distiller

This skill transforms a **clean, canonical article** into a **high-density distilled version** suitable for long-term knowledge retention.

It operates at the **editorial level**, not the extraction or summarization level.

---

## When to Use This Skill

Activate when:
- A cleaned article already exists (from article-extractor)
- The goal is long-term understanding, not beginner onboarding
- You want to preserve insight while reducing cognitive load
- The document will be stored as a knowledge asset

---

## Core Mission

Rewrite the input article into a version that:

- Is fully readable as a standalone article
- Preserves all essential concepts, mechanisms, and boundaries
- Removes or compresses non-essential explanations
- Maximizes information density without breaking logic

---

## Input Contract

Input MUST:
- Be a full, cleaned article
- Preserve original author intent and ordering
- Contain no UI clutter

Assumed reader:
- Technically competent
- Interested in understanding, not tutorials
- Future version of the author or peer engineer

---

## Editorial Rules

Each retained paragraph must contain at least one of:

1. **Irreplaceable concept definition**
2. **Non-compressible mechanism or causal explanation**
3. **Critical boundary, constraint, or condition**

Handling rules:
- If removable without ambiguity → remove
- If removal causes ambiguity → compress
- If repetitive → merge

---

## Explicit Non-Goals

This skill MUST NOT:
- Output bullet points or outlines
- Produce summaries or abstracts
- Introduce new interpretations or opinions
- Change the author's conclusions
- Explain for beginners

---

## Output Contract

Output MUST:
- Be continuous prose
- Be readable from start to finish
- Preserve logical progression
- Feel like a "second edition" written under space constraints

Output MUST NOT:
- Look like notes
- Look like a summary
- Contain meta-commentary about the text

---

## Success Criteria

- A knowledgeable reader can reconstruct the original argument
- No conceptual gaps exist
- Information density is significantly higher than the source
- The text is suitable for long-term archival and rereading

---

## How It Works

### Processing Steps

1. **Read the cleaned article** (from article-extractor output)
2. **Identify core concepts** - What must be understood?
3. **Identify mechanisms** - How do things work?
4. **Identify boundaries** - What are the constraints and limits?
5. **Remove non-essential explanations** - Tutorial-style hand-holding
6. **Compress repetitive content** - Merge similar points
7. **Preserve logical flow** - Maintain argument structure
8. **Write distilled version** - High-density, readable prose

---

## Editorial Guidelines

### What to Remove

- **Tutorial scaffolding**: "First, let's understand...", "Now we'll see..."
- **Redundant examples**: Multiple examples of the same concept
- **Beginner explanations**: "As you might know...", "In case you're not familiar..."
- **Meta-commentary**: "This is important because...", "Let me explain..."
- **Repetitive transitions**: "As we saw earlier...", "Remember that..."

### What to Preserve

- **Core definitions**: Essential terminology and concepts
- **Causal mechanisms**: How X causes Y, why Z happens
- **Constraints and boundaries**: Limits, edge cases, failure modes
- **Logical structure**: Argument flow, dependencies, prerequisites
- **Critical examples**: Unique or non-obvious illustrations
- **Author's conclusions**: Final insights and takeaways

### What to Compress

- **Multiple similar examples** → One representative example
- **Verbose explanations** → Tighter phrasing
- **Repetitive concepts** → Single clear statement
- **Long transitions** → Brief connections

---

## Example Transformation

### Before (Original Article Excerpt)

> "Let's start by understanding what distributed consensus means. In a distributed system, you have multiple nodes that need to agree on something. This is harder than it sounds because nodes can fail, networks can partition, and messages can be delayed. The consensus problem is fundamental to many distributed systems. For example, if you're building a distributed database, you need all nodes to agree on what data is stored where. Or if you're building a distributed lock service, you need all nodes to agree on who holds the lock."

### After (Distilled Version)

> "Distributed consensus requires multiple nodes to agree despite failures, network partitions, and message delays. It's fundamental to distributed databases (data placement) and lock services (lock ownership)."

**What changed:**
- Removed tutorial scaffolding ("Let's start by understanding...")
- Removed redundant explanation ("This is harder than it sounds...")
- Compressed examples into parenthetical notes
- Preserved core concept and applications

---

## Workflow

1. **Load the cleaned article** (from article-extractor)
2. **Analyze structure** - Identify sections, concepts, examples
3. **Apply editorial rules** - Remove, compress, preserve
4. **Write distilled version** - Continuous prose, high density
5. **Verify completeness** - Ensure no conceptual gaps
6. **Save output** - Use descriptive filename (e.g., `article-title-core.md`)

---

## Output Naming

Save distilled articles with a clear naming convention:

```bash
# If input is: article-title.txt
# Output should be: article-title-core.md
```

Or if saving to knowledge archive:
```bash
# Save to: knowledge/articles/topic/article-name/core.md
```

---

## Quality Checks

Before finalizing, verify:

- [ ] All core concepts are present
- [ ] Logical flow is maintained
- [ ] No conceptual gaps exist
- [ ] Text is readable as standalone prose
- [ ] Information density is higher than source
- [ ] No bullet points or outline format
- [ ] No meta-commentary about the text

---

## Integration with Other Skills

This skill works in sequence with:

1. **article-extractor** → Produces clean input
2. **core-distiller** → Produces distilled output (this skill)
3. **knowledge-archivist** → Persists both versions

When both raw and distilled versions exist, suggest archiving with knowledge-archivist.

---

## Common Pitfalls to Avoid

**❌ Don't create summaries**
- Output should be a complete article, not a summary

**❌ Don't use bullet points**
- Maintain prose format throughout

**❌ Don't add your own interpretations**
- Preserve author's intent and conclusions

**❌ Don't remove too much**
- If removal creates ambiguity, compress instead

**❌ Don't change the structure**
- Maintain original argument flow

---

## Success Indicators

A successful distillation:

- Reads like a technical article, not notes
- Contains all essential information
- Is 30-50% shorter than original
- Maintains logical coherence
- Can be understood without the original
- Preserves author's insights and conclusions
