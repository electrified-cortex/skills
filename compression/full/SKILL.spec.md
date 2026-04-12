# Full Compression — SKILL.md Spec

> Companion spec for `full/SKILL.md` in `skills/electrified-cortex/compression/`.
> Agents read the main file only. Reviewers and auditors read both.

## Purpose

Self-contained Full-tier compression instructions. Positioned between Lite
(human-readable) and Ultra (telegraphic). An agent loading only this file
has everything needed to apply Full compression. No dependencies on other tiers.

## Content Requirements

### Must Include

- **Remove list:** Articles, filler, hedging, pleasantries, verbose phrasing
- **Transform list:** Synonyms, fragments, merging bullets
- **Keep list:** What Full preserves that Ultra doesn't (punctuation, formatting when structural)
- **Preserve list:** Content that must never be modified — includes technical content, logic words, actors + permissions, ordered steps/counts/thresholds, exact-match strings
- **Ambiguity stop:** Explicit instruction to keep original when compression adds ambiguity
- **Pass order:** Defined sequence for compression passes (preserve scan, remove, transform, ambiguity check)

### Must NOT Include

- Other tier rules (Lite, Ultra) — each tier is self-contained
- Abbreviation rules (that's Ultra territory)
- Arrow notation (that's Ultra territory)
- Examples or before/after — reference parent for those

### Key Distinction

Full drops articles (like Ultra) but keeps full punctuation and sentence structure
where it aids clarity (like Lite). No abbreviations, no arrows, no telegraphic
fragments. A knowledgeable reader should find Full text clear and scannable.

## Size Target

Under 40 lines of content (excluding frontmatter). Full has moderate rule set.

## Compression

This file (the spec) is NEVER compressed.
The SKILL.md itself should be Full-compressed (dog-food the rules it describes).

## Audit Checklist

- [ ] Self-contained — agent needs only this file to apply Full
- [ ] Remove section covers articles, filler, hedging, pleasantries, verbose phrasing
- [ ] Transform section covers synonyms, fragments, bullet merging
- [ ] Keep section preserves punctuation and structural formatting
- [ ] Preserve section complete (code, paths, URLs, commands, terms, proper nouns, dates, versions, env vars, logic words, actors + permissions, ordered steps/counts/thresholds, exact-match strings, frontmatter values)
- [ ] Ambiguity stop present
- [ ] Pass order defined (preserve scan, remove, transform, ambiguity check)
- [ ] No abbreviation rules (Ultra only)
- [ ] No arrow notation (Ultra only)
- [ ] No overlap with Lite or Ultra tier content
- [ ] Size under 40 lines of content
- [ ] SKILL.md is itself Full-compressed (dog-fooding)

Created: 2026-04-12
