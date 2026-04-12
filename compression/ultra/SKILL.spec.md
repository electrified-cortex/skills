# Ultra Compression — SKILL.md Spec

> Companion spec for `ultra/SKILL.md` in `skills/electrified-cortex/compression/`.
> Agents read the main file only. Reviewers and auditors read both.

## Purpose

Self-contained Ultra-tier compression instructions. An agent loading only this
file has everything needed to apply Ultra compression. No dependencies on the
parent compression SKILL.md or other tiers.

## Content Requirements

### Must Include

- **Remove list:** Every category of content to strip — all 11 categories (see Audit Checklist)
- **Transform list:** Synonym rules, abbreviation patterns, fragment handling, pattern template, scope directive
- **Preserve list:** Content that must never be modified — includes technical content (code, URLs, paths, commands, terms, proper nouns, dates, versions, env vars), logic/modality words (not/never/only/unless/must/may), actors + permissions (who does what), ordered steps/counts/thresholds, exact-match strings (labels, branch names, config keys, frontmatter values), and structural markdown sub-list
- **Structural vs non-structural markdown:** Clear distinction between what to keep and strip
- **Scope/usage directive:** Where and when Ultra applies (agent files, agent thinking, etc.)
- **Ambiguity stop rule:** Explicit instruction — if compression adds ambiguity, keep original
- **Pass order:** Defined sequence for compression passes (preserve scan → remove → transform → ambiguity check)
- **Abbreviation discipline:** One abbreviation per concept per file, standard or introduced once in full
- **Self-referential meta-statement:** "This file is an example of ultra compression" — acceptable and encouraged as a dog-fooding signal

### Must NOT Include

- Other tier rules (Lite, Full) — each tier is self-contained
- Rationale for why Ultra exists — belongs in parent SKILL.md or spec
- Tutorial examples or before/after comparisons — keep tight, reference parent. Inline operational rules like `"in order to" → "to"` are permitted (they are rules, not examples)
- Surface map — belongs in parent SKILL.md

## Size Target

Under 50 lines of content (excluding frontmatter). Each section covers one category.
No overlap between sections.

## Compression

This file (the spec) is NEVER compressed — plain English, full clarity.
The SKILL.md itself should be Ultra-compressed (dog-food the rules it describes).
The skill uses `label:` format — sections are labeled lines, not `##` hash headers.

## Audit Checklist

- [ ] Self-contained — agent needs only this file to apply Ultra
- [ ] Remove section covers all 11 categories: articles, filler, pleasantries, hedging, connective fluff, imperative softeners, redundant phrasing, unnecessary punctuation, non-structural markdown, excess heading depth, judgment-based markdown removal
- [ ] Transform section covers: synonyms, fragments, arrows (`X → Y`), abbreviations list, merge redundant bullets, one example per pattern, `[thing] [action] [reason]` pattern template, scope directive (agent thinking)
- [ ] Preserve section complete: code blocks, inline code, URLs, paths, commands, terms, proper nouns, dates, versions, env vars; logic words (not/never/only/unless/must/may); actors + permissions; ordered steps/counts/thresholds; exact-match strings (labels, branch names, config keys, frontmatter values); structural markdown sub-list (headings, lists, tables, code fences, frontmatter, definition lists)
- [ ] Structural vs non-structural markdown distinction clear
- [ ] Scope/usage directive present
- [ ] Ambiguity stop rule present (keep original when compression adds ambiguity)
- [ ] Pass order defined (preserve scan → remove → transform → ambiguity check)
- [ ] Abbreviation discipline present (one per concept per file, standard or introduced once in full)
- [ ] Self-referential meta-statement present ("This file is an example of ultra compression")
- [ ] No overlap with Lite or Full tier content
- [ ] Size under 50 lines of content
- [ ] SKILL.md uses `label:` format (no `##` headers)
- [ ] SKILL.md is itself Ultra-compressed (dog-fooding)

Created: 2026-04-12

## Gold Standard

`ultra/SKILL.md` is the benchmark for how agent-facing files should be structured.
All agent files, skills, and instructions should aspire to this density and format.

## Audit Log

- 2026-04-12: Full audit — ALIGNED (zero findings). Preserve rules expanded (logic words,
  actors, ambiguity stop, pass order, abbreviation discipline). Scope directive added.
  GPT 5.4 external review feedback incorporated. Operator approved.
