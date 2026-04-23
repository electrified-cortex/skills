# Lite Compression — rules.txt Spec

> Companion spec for `lite/rules.txt` in `skills/electrified-cortex/compression/`.
> Agents read the main file only. Reviewers and auditors read both.

## Purpose

Self-contained Lite-tier compression instructions. An agent loading only this
file has everything needed to apply Lite compression to human-facing content.
No dependencies on the parent compression rules.txt or other tiers.

## Content Requirements

### Must Include

- **Remove list:** Filler, hedging, pleasantries, verbose phrasing
- **Keep list:** What Lite preserves that Ultra doesn't (articles, full sentences, grammar)
- **Formatting guidance:** Vertical structure, bullets, readability over density
- **Preserve list:** Content that must never be modified — includes technical content, logic words, actors + permissions, ordered steps/counts/thresholds, exact-match strings, security warnings, irreversible confirmations
- **Ambiguity stop:** Explicit instruction to keep original when compression adds ambiguity
- **Pass order:** Defined sequence for compression passes (preserve scan, remove, transform, ambiguity check)

### Must NOT Include

- Other tier rules (Full, Ultra) — each tier is self-contained
- Examples or before/after — reference parent for those
- Rationale for why Lite exists — belongs in parent rules.txt or this spec

### Key Distinction from Ultra

Lite keeps articles, full sentences, and professional grammar. The output
should read like well-edited professional prose, not telegraphic shorthand.
A non-technical human should be able to read Lite-compressed text comfortably.

## Size Target

Under 40 lines of content (excluding frontmatter). Lite has fewer rules than Ultra.

## Compression

This file (the spec) is NEVER compressed.
The rules.txt itself should be Lite-compressed (dog-food the rules it describes).

## Audit Checklist

- [ ] Self-contained — agent needs only this file to apply Lite
- [ ] Remove section covers filler, hedging, pleasantries, verbose phrasing
- [ ] Keep section explicitly preserves articles, sentences, grammar, connectives
- [ ] Formatting section addresses vertical structure and readability
- [ ] Preserve section complete (code, paths, URLs, commands, terms, proper nouns, dates, versions, logic words, actors + permissions, ordered steps/counts/thresholds, exact-match strings, security warnings, irreversible confirmations)
- [ ] Ambiguity stop present
- [ ] Pass order defined (preserve scan, remove, transform, ambiguity check)
- [ ] No overlap with Full or Ultra tier content
- [ ] Size under 40 lines of content
- [ ] rules.txt is itself Lite-compressed (dog-fooding)

Created: 2026-04-12
