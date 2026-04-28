# Ultra Compression — Uncompressed Reference

Companion reference for `ultra/rules.txt`. This file is for auditors comparing the runtime rules against the spec. Agents load `rules.txt` only.

## Purpose

Ultra-tier compression is for agent-facing files, agent thinking, and any context where token density is critical. Maximum compression: telegraphic, dense, no articles, abbreviations allowed, arrow notation permitted. A knowledgeable reader can parse it; a non-specialist cannot be expected to.

## Key Distinction

- Unlike Lite and Full: removes articles, hedging, filler, pleasantries, connective fluff, imperative softeners, redundant phrasing, unnecessary punctuation, non-structural markdown, excess heading depth.
- Unique to Ultra: abbreviation discipline, arrow notation (`X -> Y`), fragment-first style, `[thing] [action] [reason]` pattern template.
- Scope: agent files, agent thinking, skill content, context injections.

## What the rules.txt Must Include

### Remove List (all 11 categories)

1. Articles: `a`, `an`, `the`
2. Filler phrases: `in order to`, `it is worth noting`, `please note`
3. Pleasantries: `feel free to`, `don't hesitate to`, `of course`, `certainly`
4. Hedging: `arguably`, `somewhat`, `in some cases`, `it could be said`
5. Connective fluff: `additionally`, `furthermore`, `as a result`, `in conclusion`
6. Imperative softeners: `please`, `kindly`, `if possible`, `as needed`
7. Redundant phrasing: `in order to` -> `to`; `due to the fact that` -> `because`
8. Unnecessary punctuation: trailing commas in lists, double spaces
9. Non-structural markdown: decorative bold/italic, unnecessary emphasis
10. Excess heading depth: collapse `####` and deeper where content is minimal
11. Judgment-based markdown: remove formatting that conveys no structural meaning

### Transform List

- Synonyms: `utilize` -> `use`, `demonstrate` -> `show`, `implement` -> `add`
- Abbreviations: one abbreviation per concept per file; standard terms or introduce once in full
- Fragments: acceptable; prefer `[thing] [action] [reason]` pattern
- Arrow notation: `X -> Y` for transformations, flows, replacements
- Merge redundant bullets covering the same point into one
- One example per pattern (not multiple illustrative examples)
- Scope directive: Ultra applies to agent files, agent thinking, not operator-facing prose

### Preserve List (Never Modify)

- Code blocks and inline code
- URLs, file paths, commands
- Technical terms and proper nouns
- Dates and version numbers
- Environment variable names
- Logic/modality words: `not`, `never`, `only`, `unless`, `must`, `may`
- Actors + permissions (who does what, who may not)
- Ordered steps, counts, thresholds (sequence and numbers must be exact)
- Exact-match strings: labels, branch names, config keys, frontmatter values
- Structural markdown: headings, lists, tables, code fences, frontmatter, definition lists

### Structural vs Non-Structural Markdown

Structural markdown must be kept: headings that organize content, lists that enumerate items, tables, code fences, frontmatter fields, definition lists.

Non-structural markdown must be removed: decorative bold/italic with no semantic purpose, emphasis that reflects tone rather than importance.

### Ambiguity Stop

If compression of any phrase would introduce ambiguity or change meaning, keep the original unchanged.

### Pass Order

Compression must follow this sequence:

1. Preserve scan — identify all protected content; mark as untouchable
2. Remove — strip all 11 remove categories
3. Transform — apply synonyms, fragments, arrows, abbreviations, merge bullets
4. Ambiguity check — verify no compressed phrase is ambiguous; restore originals where needed

### Abbreviation Discipline

One abbreviation per concept per file. Use standard abbreviations without introduction. Introduce non-standard abbreviations once in full form, then abbreviate consistently. Never introduce multiple abbreviations for the same concept.

### Self-Referential Meta-Statement

The `rules.txt` should include a statement that it is itself an example of Ultra compression. This is acceptable and encouraged as a dog-fooding signal.

## Format

The `rules.txt` uses `label:` format — sections are labeled lines, not `##` hash headers. This is unique to Ultra and must be preserved.

## Size Target

Under 50 lines of content in the `rules.txt` (excluding frontmatter). Each section covers one category. No overlap between sections.

## Self-Containment Requirement

An agent loading only `rules.txt` must have everything needed to apply Ultra compression. No dependency on other tiers, the parent compression rules.txt, or this uncompressed.md.

## Dog-Fooding

The `rules.txt` itself must be Ultra-compressed. This spec file (`uncompressed.md`) is never compressed.

## Gold Standard

`ultra/rules.txt` is the benchmark for how agent-facing files should be structured. All agent files, skills, and instructions should aspire to this density and format.

## Audit Checklist

Verifying rules.txt against spec:

- [ ] Self-contained — agent needs only rules.txt to apply Ultra
- [ ] Remove section covers all 11 categories: articles, filler, pleasantries, hedging, connective fluff, imperative softeners, redundant phrasing, unnecessary punctuation, non-structural markdown, excess heading depth, judgment-based markdown removal
- [ ] Transform section covers: synonyms, fragments, arrows, abbreviations list, merge redundant bullets, one example per pattern, `[thing] [action] [reason]` pattern template, scope directive (agent thinking)
- [ ] Preserve section complete: code blocks, inline code, URLs, paths, commands, terms, proper nouns, dates, versions, env vars; logic words (not/never/only/unless/must/may); actors + permissions; ordered steps/counts/thresholds; exact-match strings; structural markdown sub-list
- [ ] Structural vs non-structural markdown distinction clear
- [ ] Scope/usage directive present
- [ ] Ambiguity stop rule present
- [ ] Pass order defined (preserve scan -> remove -> transform -> ambiguity check)
- [ ] Abbreviation discipline present
- [ ] Self-referential meta-statement present
- [ ] No overlap with Lite or Full tier content
- [ ] Size under 50 lines of content
- [ ] rules.txt uses `label:` format (no `##` headers)
- [ ] rules.txt is itself Ultra-compressed
