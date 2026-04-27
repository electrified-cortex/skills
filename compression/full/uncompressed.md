# Full Compression — Uncompressed Reference

Companion reference for `full/rules.txt`. This file is for auditors comparing the runtime rules against the spec. Agents load `rules.txt` only.

## Purpose

Full-tier compression sits between Lite (human-readable, articles preserved) and Ultra (telegraphic, maximum density). A reader with domain knowledge should find Full-compressed text clear and scannable. Full drops articles and light filler but keeps full punctuation and sentence structure where it aids clarity.

## Key Distinction

- Unlike Ultra: no abbreviations, no arrow notation (`->`), no telegraphic fragments.
- Unlike Lite: articles (`a`, `an`, `the`) are removed. Filler and hedging stripped aggressively.
- Full output reads like well-edited technical prose without articles.

## What the rules.txt Must Include

### Remove List

All of the following must be explicitly covered:

- Articles: `a`, `an`, `the`
- Filler phrases: `in order to`, `it is worth noting`, `it should be noted`, `please note`, `as mentioned`
- Hedging: `arguably`, `somewhat`, `in some cases`, `it could be said`
- Pleasantries: `feel free to`, `don't hesitate to`, `of course`, `certainly`
- Verbose phrasing that can be compressed to a single word

### Transform List

- Synonyms to shorter equivalents (e.g., `utilize` -> `use`, `demonstrate` -> `show`)
- Fragments acceptable where meaning is unambiguous
- Merge redundant bullets covering the same point

### Keep List

Full preserves where Ultra does not:

- Full punctuation (periods, commas, colons, semicolons) where they aid clarity
- Sentence structure when the logical relationship between clauses would be lost without it
- Connectives that carry logical meaning (`but`, `because`, `unless`, `however`)

### Preserve List Never Modify

The following must never be altered regardless of compression tier:

- Code blocks and inline code
- URLs, file paths, commands
- Technical terms and proper nouns
- Dates and version numbers
- Environment variable names
- Logic/modality words: `not`, `never`, `only`, `unless`, `must`, `may`
- Actors + permissions (who does what)
- Ordered steps, counts, thresholds (sequence and numbers must be exact)
- Exact-match strings: labels, branch names, config keys, frontmatter values

### Ambiguity Stop

If compression of any phrase would introduce ambiguity or change meaning, keep the original unchanged.

### Pass Order

Compression must follow this sequence:

1. Preserve scan — identify all protected content; mark as untouchable
2. Remove — strip articles, filler, hedging, pleasantries, verbose phrasing
3. Transform — apply synonyms, fragment where safe, merge redundant bullets
4. Ambiguity check — verify no compressed phrase is ambiguous; restore originals where needed

## Size Target

Under 40 lines of content in the rules.txt (excluding frontmatter). Full has a moderate rule set.

## Self-Containment Requirement

An agent loading only `rules.txt` must have everything needed to apply Full compression. No dependency on other tiers, the parent compression rules.txt, or this uncompressed.md.

## Dog-Fooding

The `rules.txt` itself must be Full-compressed (applying the rules it describes). This spec file (`uncompressed.md`) is never compressed.

## Audit Checklist

Verifying rules.txt against spec:

- [ ] Self-contained — agent needs only rules.txt to apply Full
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
- [ ] rules.txt is itself Full-compressed
