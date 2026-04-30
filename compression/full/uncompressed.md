# Full Compression Rules

This document describes the rules for Full-tier compression in full prose. It is the uncompressed source that `full/rules.txt` is derived from. When you apply Full compression to this file, you get `rules.txt`. This file is never itself compressed.

Full-tier compression sits between Lite (human-readable, articles preserved) and Ultra (telegraphic, maximum density). A reader with domain knowledge should find Full-compressed text clear and scannable. Full drops articles and strips filler aggressively, but keeps full punctuation and sentence structure where they aid clarity. Unlike Ultra, it does not use abbreviations, arrow notation, or telegraphic fragments.

## What to Remove

Full compression removes content from the following categories:

**Articles:** Remove all articles — "a", "an", and "the" — throughout the document.

**Filler words:** Remove filler words that add length without meaning: just, really, basically.

**Hedging language:** Remove hedging phrases that soften statements: "might be worth," "could consider."

**Pleasantries:** Remove conversational pleasantries: "sure," "certainly," "happy to."

**Verbose phrasing:** Replace verbose multi-word constructions with concise equivalents. Example: "in order to" becomes "to."

**Connective fluff:** Remove transitional phrases that do not carry logical meaning.

**Non-structural markdown:** Remove markdown formatting that serves decorative or tonal purposes only — decorative bold, italics, emphasis, and blockquotes. Exception: when bold is applied to a constraint or imperative term (for example, **never**, **must**, or **do not**), convert it to ALL CAPS (NEVER, MUST, DO NOT) rather than stripping it entirely. This preserves the emphasis signal in plain-text output where markdown is not rendered. This exception applies to inline emphasis on individual terms only, not to label-style bold.

## What to Transform

**Synonyms:** Replace longer words with shorter equivalents where meaning is fully preserved. Examples: "utilize" becomes "use"; "demonstrate" becomes "show."

**Fragments:** Sentence fragments are acceptable when meaning is unambiguous. Unlike Ultra, do not use telegraphic `[thing] [action] [reason]` patterns; preserve enough sentence structure for clarity.

**Merge bullets:** When multiple bullet points cover the same idea, merge them into a single bullet.

## What to Keep

Full compression preserves what Ultra removes:

- **Full punctuation** — periods, commas, colons, and semicolons are kept where they aid clarity.
- **Structural markdown** — headings, lists, tables, code fences, and frontmatter are all preserved.
- **Sentence structure** — logical relationships between clauses are preserved when connectives carry meaning (but, because, unless, however).

## What to Preserve

The following content must never be altered under any circumstances:

- Code blocks and inline code
- URLs, file paths, and shell commands
- Technical terms and proper nouns
- Dates and version numbers
- Environment variable names
- Logic and modality words: not, never, only, unless, must, may
- Actors and their permissions — who does what, who may not do what
- Ordered steps, counts, and thresholds — sequence and numbers must be exact
- Exact-match strings: labels, branch names, configuration keys, frontmatter values

## Ambiguity Stop

If compressing any phrase would introduce ambiguity or change the meaning of the content, keep the original unchanged. Compression never takes priority over accuracy.

## Pass Order

Apply compression in the following sequence:

1. Preserve scan — identify all protected content and mark it as untouchable before making any changes.
2. Remove — strip articles, filler, hedging, pleasantries, verbose phrasing, connective fluff, and non-structural markdown (with the ALL CAPS exception applied).
3. Transform — apply synonym replacements, introduce fragments where safe, and merge redundant bullets.
4. Ambiguity check — review every compressed phrase; restore any that introduced ambiguity or changed meaning.

## Contractions

Convert multi-word negations to contractions: "do not" becomes "don't"; "must not" becomes "mustn't"; "will not" becomes "won't." Prefer "cannot" over "can't" — "cannot" is a stronger imperative and is typically a single token in common BPE tokenizers.
