# Compiled Prompt

## Header

Mode: Analysis

---

## Problem Statement

Organize and structure a collection of informal thoughts and messy notes to:
1. Extract and clarify the core ideas the user intends to express
2. Identify gaps and ambiguities in the original content
3. Propose expanded topics and related themes that could enhance understanding
4. Maintain clear attribution distinguishing original user content from AI-generated extensions

---

## Context

**Domain**: Personal knowledge management, note organization, idea refinement

**Input Source**: User's scattered thoughts and unstructured notes
- Format: unknown (text, markdown, mixed media)
- Content type: personal reflections, ideas, observations
- Language: Mixed (Chinese primary, may contain other languages)

**Audience**: The user themselves (for personal understanding and development)

**Operating Environment**: AI-assisted content organization and synthesis

---

## Assumptions

- The original notes contain valuable core ideas that can be extracted and clarified
- The user's intent is recoverable from the scattered notes, though it may be implicit
- Expansion and related topic suggestions can add value without distorting original meaning
- Clear attribution (original vs. expanded) is both feasible and necessary
- The user wants a structured output that preserves their core thoughts while enhancing clarity

**Not addressed**:
- Whether the notes should be entirely rewritten (preservation of original form is assumed)
- The ultimate purpose of the organized notes (may be personal reference, publication, etc.)
- Specific output format or delivery method preference

---

## Constraints

**Hard Boundaries**:
1. **No fabrication**: Do not invent ideas that are not inferable from the original content
2. **No guessing intent**: When core ideas are unclear, identify ambiguities rather than assume meaning
3. **Clear attribution required**: Every element must be tagged as either:
   - Original (from user's notes)
   - Clarified/Inferred (reformulated from original, marked with uncertainty indicators)
   - Expanded (AI-generated extensions, clearly labeled)
4. **Preserve original voice**: Original content should retain its authentic phrasing and structure where possible
5. **Scope limits**: Expansions should be directly related to identified themes, not introduce tangential topics

**Prohibited Actions**:
- Rewriting original content without marking it as clarified
- Adding unrelated topics that cannot be traced to original notes
- Removing or censoring original ideas
- Making definitive claims about user intent when evidence is insufficient

---

## Task Instructions

### Phase 1: Content Audit
1. Receive and examine all provided notes and thoughts
2. Identify distinct ideas, themes, or topics present in the original content
3. List ambiguities, contradictions, or incomplete thoughts
4. Map relationships between different ideas in the notes

### Phase 2: Core Idea Extraction
1. Synthesize the primary intent or message the user appears to be expressing
2. Present core ideas in a clear, structured format
3. Flag areas where intent is unclear or requires user clarification
4. Maintain direct quotes from original notes where they express ideas clearly

### Phase 3: Expansion and Enhancement
1. For each identified core idea, propose:
   - Related topics or themes that naturally extend the idea
   - Potential questions or implications worth exploring
   - Connections to broader contexts or disciplines
2. Ensure all expansions are clearly linked back to original content
3. Explain the rationale for each expansion (why it's relevant)

### Phase 4: Structured Output with Attribution
1. Organize the output into sections:
   - Core Ideas (original + clarified)
   - Expanded Topics (clearly marked as extensions)
   - Related Themes (marked as AI-suggested)
   - Ambiguities and Open Questions (flagged for user review)
2. Use explicit markers throughout:
   - `[Original]` or `[User's notes]` for source content
   - `[Clarified]` for reformulated but inferred content
   - `[Expanded]` or `[AI-suggested]` for new additions
   - `[Uncertain]` for areas requiring clarification

---

## Output Requirements

**Format**:
- Structured document with clear section headers
- Bulleted or numbered lists for ideas and topics
- Attribution tags inline or as prefixes for each element
- Visual hierarchy distinguishing original from expanded content

**Structure**:
1. Executive summary of identified core themes
2. Detailed breakdown of each theme with attribution
3. Expanded topics section (clearly marked)
4. Related themes section (clearly marked)
5. Questions for clarification (if any)

**Length**: Comprehensive but not exhaustive; focus on clarity over volume

**Tone**: Neutral, analytical, respectful of original content; clear and professional

---

## Quality Bar

**Must Include**:
- At least one clear statement of what the user appears to be trying to express
- Explicit attribution for every piece of content
- Identification of any major ambiguities or contradictions
- At least 2-3 meaningful expansions per core theme
- Clear visual distinction between original and expanded content

**Must Avoid**:
- Over-interpretation of unclear notes
- Adding content that cannot be logically connected to original notes
- Obscuring the user's original ideas with expansions
- Creating false clarity where ambiguity exists
- Mixing original and expanded content without clear separation

**Failure Conditions**:
- Output would mislead the user about what was in their original notes
- Attribution is unclear or inconsistent
- Core ideas are obscured by expansions
- Ambiguities are resolved by guessing rather than flagging

---

## Notes

- This prompt assumes the user will provide their notes as input to this compiled prompt
- The AI executing this prompt should ask for the notes if not provided in the initial request
- When in doubt about attribution, err on the side of marking as uncertain or expanded
- The goal is to help the user understand their own thoughts better, not to impose structure that doesn't fit