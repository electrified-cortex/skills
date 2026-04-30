# Lite Compression Rules

This document describes the rules for Lite-tier compression in full prose. It is the uncompressed source that `lite/rules.txt` is derived from. When you apply Lite compression to this file, you get `rules.txt`. This file is never itself compressed.

Lite-tier compression is intended for human-facing content where readability is paramount. A non-technical human should be able to read Lite-compressed text comfortably. The output should read like well-edited professional prose — complete sentences, proper grammar, and clear structure. Unlike Full and Ultra, Lite keeps articles and does not use abbreviations, arrow notation, or telegraphic fragments.

## What to Remove

Lite compression removes content from the following categories:

**Filler words and phrases:** Remove words and phrases that add length without adding meaning: "just," "really," "basically," "actually," "simply," "in order to" (replace with "to"), "it is worth noting," "please note," "as mentioned."

**Hedging language:** Remove phrases that soften statements without providing information: "arguably," "somewhat," "in some cases," "it could be said," "might possibly."

**Pleasantries:** Remove conversational pleasantries and social softeners: "feel free to," "don't hesitate to," "of course," "certainly," "we hope that."

**Qualifiers:** Remove personal hedges that reduce confidence unnecessarily: "I think," "I believe."

**Verbose phrasing:** Replace multi-word constructions with concise equivalents where no meaning is lost.

## What to Keep

Lite compression explicitly preserves what Ultra and Full remove:

- **Articles** — "a," "an," and "the" are always kept.
- **Full sentences and professional grammar** — do not fragment sentences into telegraphic shorthand.
- **Connectives** — words that carry logical relationships are kept: "and," "but," "because," "so," "however," "therefore."
- **Sentence-level punctuation** — periods, commas, colons, and semicolons are kept wherever they aid clarity.
- **Meaningful markdown** — all markdown formatting that aids readability is preserved. Bold, italics, headings, lists, and tables are all kept when they serve a structural or emphasis purpose.

## Formatting Guidance

Prefer vertical structure over dense paragraphs. Use bullets and numbered lists where they aid comprehension. Use headings to aid navigation in longer content. Prioritize readability over density — do not sacrifice clarity in pursuit of compactness.

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
- Security warnings and language describing irreversible actions

## Ambiguity Stop

If compressing any phrase would introduce ambiguity or change the meaning of the content, keep the original unchanged. Compression never takes priority over accuracy.

## Pass Order

Apply compression in the following sequence:

1. Preserve scan — identify all protected content and mark it as untouchable before making any changes.
2. Remove — strip filler, hedging, pleasantries, qualifiers, and verbose phrasing.
3. Transform — apply readability improvements; introduce vertical structure where it helps comprehension.
4. Ambiguity check — review every compressed phrase; restore any that introduced ambiguity or changed meaning.

## Contractions

Convert multi-word negations to contractions: "do not" becomes "don't"; "must not" becomes "mustn't"; "will not" becomes "won't." Prefer "cannot" over "can't" — "cannot" is a stronger imperative and is typically a single token in common BPE tokenizers.
