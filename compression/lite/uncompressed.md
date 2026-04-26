# Lite Compression — Uncompressed Reference

Companion reference for `lite/rules.txt`. This file is for auditors comparing the runtime rules against the spec. Agents load `rules.txt` only.

## Purpose

Lite-tier compression is for human-facing content where readability is paramount. A non-technical human should be able to read Lite-compressed text comfortably. Lite keeps articles, full sentences, and professional grammar. The output reads like well-edited professional prose.

## Key Distinction

- Unlike Ultra and Full: articles (`a`, `an`, `the`) are kept.
- Unlike Ultra: no abbreviations, no arrow notation, no fragments, no telegraphic shorthand.
- Lite removes filler, hedging, and pleasantries, but preserves sentence structure and grammar.
- Vertical structure (bullets, lists) preferred over dense paragraphs for readability.

## What the rules.txt Must Include

### Remove List

All of the following must be explicitly covered:
- Filler phrases: `in order to`, `it is worth noting`, `it should be noted`, `please note`, `as mentioned above`
- Hedging: `arguably`, `somewhat`, `in some cases`, `it could be said`, `might possibly`
- Pleasantries: `feel free to`, `don't hesitate to`, `of course`, `certainly`, `we hope that`
- Verbose phrasing that adds length without adding meaning

### Keep List

Lite explicitly preserves what Ultra removes:
- Articles: `a`, `an`, `the`
- Full sentences and professional grammar
- Connectives: `and`, `but`, `because`, `so`, `however`, `therefore`
- Sentence-level punctuation (periods, commas, colons, semicolons)

### Formatting Guidance

- Prefer vertical structure: bullets and numbered lists over dense paragraphs
- Readability over density — do not sacrifice clarity for compactness
- Use headings to aid navigation in longer content

### Preserve List (Never Modify)

The following must never be altered:
- Code blocks and inline code
- URLs, file paths, commands
- Technical terms and proper nouns
- Dates and version numbers
- Environment variable names
- Logic/modality words: `not`, `never`, `only`, `unless`, `must`, `may`
- Actors + permissions (who does what)
- Ordered steps, counts, thresholds (sequence and numbers must be exact)
- Exact-match strings: labels, branch names, config keys, frontmatter values
- Security warnings and irreversible confirmation language

### Ambiguity Stop

If compression of any phrase would introduce ambiguity or change meaning, keep the original unchanged.

### Pass Order

Compression must follow this sequence:
1. Preserve scan — identify all protected content; mark as untouchable
2. Remove — strip filler, hedging, pleasantries, verbose phrasing
3. Transform — apply readability improvements; add vertical structure where helpful
4. Ambiguity check — verify no compressed phrase is ambiguous; restore originals where needed

## Size Target

Under 40 lines of content in the rules.txt (excluding frontmatter). Lite has fewer rules than Ultra.

## Self-Containment Requirement

An agent loading only `rules.txt` must have everything needed to apply Lite compression. No dependency on other tiers, the parent compression rules.txt, or this uncompressed.md.

## Dog-Fooding

The `rules.txt` itself must be Lite-compressed (applying the rules it describes). This spec file (`uncompressed.md`) is never compressed.

## Audit Checklist

Verifying rules.txt against spec:
- [ ] Self-contained — agent needs only rules.txt to apply Lite
- [ ] Remove section covers filler, hedging, pleasantries, verbose phrasing
- [ ] Keep section explicitly preserves articles, sentences, grammar, connectives
- [ ] Formatting section addresses vertical structure and readability
- [ ] Preserve section complete (code, paths, URLs, commands, terms, proper nouns, dates, versions, logic words, actors + permissions, ordered steps/counts/thresholds, exact-match strings, security warnings, irreversible confirmations)
- [ ] Ambiguity stop present
- [ ] Pass order defined (preserve scan, remove, transform, ambiguity check)
- [ ] No overlap with Full or Ultra tier content
- [ ] Size under 40 lines of content
- [ ] rules.txt is itself Lite-compressed
