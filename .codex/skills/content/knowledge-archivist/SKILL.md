---
name: knowledge-archivist
description: Persist raw and distilled knowledge artifacts in a reversible, structured, and indexable format for long-term reuse, auditability, and evolution.
allowed-tools: Write
---

# Knowledge Archivist

This skill is responsible for **making knowledge durable**.

It stores raw and distilled artifacts in a structured, reversible way so that future reinterpretation and reprocessing remain possible.

---

## When to Use This Skill

Activate when:
- Both raw and distilled versions of content exist
- The content is worth long-term retention
- The artifact may be revisited, updated, or re-distilled in the future

---

## Core Responsibility

- Persist knowledge artifacts with clear version boundaries
- Preserve reversibility between raw and processed forms
- Enable future skills to reuse, re-index, or re-distill content

---

## Input Contract

- Raw article (from article-extractor)
- Distilled article (from core-distiller)
- Optional metadata (source, date, topic)

---

## Output Contract

Produces a **structured knowledge unit**, not just files.

Recommended structure:

```
knowledge/
articles/
distributed-systems/
raft-consensus/
raw.md
core.md
meta.yaml
```

---

## Archival Principles

- Raw content is never modified
- Distilled content may evolve
- Both versions always coexist
- Structure should reflect conceptual domain, not source website

---

## Explicit Non-Goals

This skill MUST NOT:
- Rewrite content
- Judge content quality
- Summarize or distill
- Merge unrelated knowledge units

---

## Success Criteria

- Any distilled insight can be traced back to raw text
- Knowledge artifacts remain understandable years later
- Future reprocessing is possible without loss of context

---

## Directory Structure

Organize knowledge by **conceptual domain**, not source:

### Recommended Structure

```
knowledge/
articles/
  {domain}/
    {topic}/
      raw.md          # Original extracted article
      core.md         # Distilled version
      meta.yaml       # Metadata
```

### Domain Examples

- `distributed-systems/` - Consensus, replication, coordination
- `databases/` - Storage, query optimization, transactions
- `networking/` - Protocols, routing, performance
- `algorithms/` - Data structures, complexity, optimization
- `architecture/` - System design, patterns, trade-offs
- `security/` - Cryptography, authentication, vulnerabilities
- `programming/` - Languages, paradigms, best practices

### Topic Naming

Use descriptive, searchable names:
- ✅ `raft-consensus/`
- ✅ `postgres-query-optimization/`
- ✅ `tcp-congestion-control/`
- ❌ `article-1/`
- ❌ `blog-post-2024/`

---

## Metadata Schema

Create `meta.yaml` with:

```yaml
source:
  url: "https://example.com/article"
  title: "Original Article Title"
  author: "Author Name"  # if available
  date: "2024-01-15"     # publication or extraction date

domain: "distributed-systems"
topic: "raft-consensus"

extraction:
  date: "2024-01-20"
  tool: "reader"  # or trafilatura, fallback

distillation:
  date: "2024-01-20"
  version: "1.0"

tags:
  - "consensus"
  - "distributed-systems"
  - "raft"
  - "replication"
```

---

## Workflow

### Step 1: Determine Domain and Topic

Analyze the article content to determine:
- **Domain**: High-level category (e.g., "distributed-systems")
- **Topic**: Specific subject (e.g., "raft-consensus")

If uncertain, use broader domain and descriptive topic name.

### Step 2: Create Directory Structure

```bash
# Example
mkdir -p knowledge/articles/distributed-systems/raft-consensus
```

### Step 3: Copy Raw Article

```bash
# Copy raw article to raw.md
cp article-title.txt knowledge/articles/distributed-systems/raft-consensus/raw.md
```

### Step 4: Copy Distilled Article

```bash
# Copy distilled article to core.md
cp article-title-core.md knowledge/articles/distributed-systems/raft-consensus/core.md
```

### Step 5: Create Metadata

Create `meta.yaml` with source information, domain, topic, and tags.

### Step 6: Verify Structure

Ensure all files are in place:
- `raw.md` - Original article
- `core.md` - Distilled version
- `meta.yaml` - Metadata

---

## Complete Example

### Input Files

- `raft-consensus-article.txt` (from article-extractor)
- `raft-consensus-article-core.md` (from core-distiller)

### Archive Command

```bash
# Create directory
mkdir -p knowledge/articles/distributed-systems/raft-consensus

# Copy files
cp raft-consensus-article.txt knowledge/articles/distributed-systems/raft-consensus/raw.md
cp raft-consensus-article-core.md knowledge/articles/distributed-systems/raft-consensus/core.md

# Create metadata
cat > knowledge/articles/distributed-systems/raft-consensus/meta.yaml <<EOF
source:
  url: "https://raft.github.io/raft.pdf"
  title: "In Search of an Understandable Consensus Algorithm"
  author: "Diego Ongaro, John Ousterhout"
  date: "2014-05-20"

domain: "distributed-systems"
topic: "raft-consensus"

extraction:
  date: "2024-01-20"
  tool: "reader"

distillation:
  date: "2024-01-20"
  version: "1.0"

tags:
  - "consensus"
  - "distributed-systems"
  - "raft"
  - "replication"
  - "leader-election"
EOF
```

### Resulting Structure

```
knowledge/
articles/
distributed-systems/
raft-consensus/
├── raw.md
├── core.md
└── meta.yaml
```

---

## Metadata Guidelines

### Source Information

- **url**: Original article URL (required)
- **title**: Article title (required)
- **author**: Author name (if available)
- **date**: Publication or extraction date (ISO format: YYYY-MM-DD)

### Classification

- **domain**: High-level category (required)
- **topic**: Specific subject within domain (required)

### Processing Information

- **extraction.date**: When article was extracted
- **extraction.tool**: Tool used (reader, trafilatura, fallback)
- **distillation.date**: When article was distilled
- **distillation.version**: Version of distilled content (start at "1.0")

### Tags

- Use lowercase, hyphenated tags
- Include domain, topic, and key concepts
- 3-8 tags typically sufficient

---

## File Naming Conventions

### Directory Names

- Use lowercase
- Use hyphens for word separation
- Be descriptive and searchable
- Avoid dates or source-specific names

Examples:
- ✅ `raft-consensus/`
- ✅ `postgres-query-optimization/`
- ✅ `tcp-congestion-control/`
- ❌ `article-1/`
- ❌ `blog-2024/`

### File Names

Always use:
- `raw.md` - Original extracted article
- `core.md` - Distilled version
- `meta.yaml` - Metadata

---

## Reversibility

The archive structure ensures:

1. **Raw content is preserved** - Original article never modified
2. **Distilled content can evolve** - New versions can be added
3. **Traceability** - Metadata links both versions to source
4. **Reprocessing** - Future skills can re-distill from raw

### Future Evolution

If re-distilling:
- Keep `raw.md` unchanged
- Update `core.md` with new version
- Update `meta.yaml` with new distillation date and version

Or create versioned files:
```
core-v1.md
core-v2.md
```

---

## Integration with Other Skills

This skill completes the knowledge pipeline:

1. **article-extractor** → Produces `raw.md`
2. **core-distiller** → Produces `core.md`
3. **knowledge-archivist** → Organizes both into structured archive (this skill)

When archiving, reference the source files and create the complete structure.

---

## Quality Checks

Before finalizing archive, verify:

- [ ] `raw.md` exists and contains original article
- [ ] `core.md` exists and contains distilled version
- [ ] `meta.yaml` exists with complete metadata
- [ ] Directory structure reflects conceptual domain
- [ ] Topic name is descriptive and searchable
- [ ] All source information is captured
- [ ] Tags are relevant and useful

---

## Common Pitfalls to Avoid

**❌ Don't organize by source website**
- Use conceptual domains, not "articles-from-medium/"

**❌ Don't skip metadata**
- Future reprocessing needs source information

**❌ Don't modify raw content**
- Raw is immutable, only distilled can evolve

**❌ Don't use vague topic names**
- "article-1" is not searchable or meaningful

**❌ Don't merge unrelated content**
- Each knowledge unit should be self-contained

---

## Success Indicators

A successful archive:

- Has clear directory structure by domain/topic
- Contains both raw and distilled versions
- Has complete metadata with source information
- Uses descriptive, searchable names
- Can be found and understood years later
- Enables future reprocessing without loss

---

## Maintenance

Over time, you may want to:

- **Re-distill** - Create new versions of `core.md` as understanding evolves
- **Re-index** - Update tags or domain classification
- **Reorganize** - Move topics to better domains (but preserve history)
- **Archive old versions** - Keep `core-v1.md` when creating `core-v2.md`

The structure supports all of these operations while maintaining reversibility.
