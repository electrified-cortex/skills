# Ultra Compression Rules

This document describes the rules for Ultra-tier compression in full prose. It is the uncompressed source that `ultra/rules.txt` is derived from. When you apply Ultra compression to this file, you get `rules.txt`. This file is never itself compressed.

## What to Remove

Ultra compression removes content from the following categories:

**Articles:** Remove all articles — "a", "an", and "the" — throughout the document.

**Filler words:** Remove filler words and phrases that add length without meaning: just, really, basically, actually, simply, and essentially.

**Pleasantries:** Remove conversational pleasantries and social softeners such as "feel free to," "don't hesitate to," "of course," and "certainly."

**Hedging language:** Remove hedging phrases that soften statements without adding information: "arguably," "somewhat," "in some cases," "it could be said."

**Connective fluff:** Remove transitional phrases that do not carry logical meaning: "additionally," "furthermore," "as a result," "in conclusion."

**Imperative softeners:** Remove words that soften directives without changing their meaning: "please," "kindly," "if possible," "as needed."

**Redundant phrasing:** Replace verbose constructions with concise equivalents. Example: "in order to" becomes "to."

**Unnecessary punctuation:** Remove punctuation that adds no meaning, such as trailing commas in lists and double spaces.

**Non-structural markdown:** Remove markdown formatting that serves decorative or tonal purposes only — decorative bold, italic, and emphasis. Exception: when bold is applied to a constraint or imperative term (for example, **never**, **must**, or **do not**), convert it to ALL CAPS (NEVER, MUST, DO NOT) rather than stripping it entirely. This preserves the emphasis signal in plain-text output where markdown is not rendered. This exception applies to inline emphasis on individual terms only, not to label-style bold (for example, **Step name:**), which is handled by the structural label transform described below.

**Excess heading depth:** Collapse headings at level four and deeper (`####`) into the surrounding content when the content under those headings is minimal.

**Judgment-based markdown:** Remove any markdown formatting that conveys no structural meaning and exists only for visual decoration.

## What to Transform

**Synonyms:** Replace longer words with shorter equivalents where meaning is fully preserved. Examples: "utilize" becomes "use"; "demonstrate" becomes "show"; "implement" becomes "add."

**Fragments:** Sentence fragments are acceptable in ultra-compressed output. Prefer the pattern `[thing] [action] [reason]` — state the subject, the action, and the reason in that order without connecting words.

**Arrow notation:** Use `X → Y` to represent transformations, replacements, flows, and before/after pairs.

**Abbreviations:** Replace common technical terms with standard abbreviations: DB (database), auth (authentication), config (configuration), req (request), res (response), fn (function), impl (implementation), msg (message), sess (session), conn (connection), dir (directory), env (environment), repo (repository). Use each abbreviation consistently throughout the file. Standard abbreviations need no introduction. Non-standard abbreviations must be introduced once in full form, then abbreviated consistently. Never introduce more than one abbreviation for the same concept.

**Merge bullets:** When multiple bullet points cover the same idea, merge them into a single bullet.

**One example per pattern:** When illustrating a rule or transformation, use one example only. Do not provide multiple illustrative examples for the same pattern.

## Scope

Ultra compression applies to agent files, agent-to-agent messages, and agent thinking. The token savings in these contexts compound over the course of a session.

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
- Structural markdown: headings that organize content, lists that enumerate items, tables, code fences, frontmatter fields, and definition lists

## Structural Format Rules

In ultra-compressed output, the following structural primitives apply:

- Periods end statements.
- Newlines separate distinct concepts.
- Commas join inline items within a single concept.
- Sections are labeled using the `Label:` format rather than markdown headings.

The following markdown transforms apply during compression:

- `## Heading` becomes `Heading:` (a labeled line, not a hash header)
- List items (`- item`) become newline-separated lines or semicolon-joined inline items
- The `#` title header is used only for document identity; all other headers are flattened to `Label:` format
- Tables are kept when their grid structure aids parsing

All markdown syntax markers are stripped during output:

- Heading markers (`#`, `##`, `###`)
- List markers (`- `)
- Blockquote markers (`>`)
- Emphasis markers (`**`, `__`) — with the ALL CAPS exception described above
- Body horizontal rules (`---`) — YAML frontmatter delimiters are never stripped

Numbered lists are kept because ordering conveys meaning. Tables are kept because grid structure aids parsing.

## Ambiguity Stop

If compressing any phrase would introduce ambiguity or change the meaning of the content, keep the original unchanged. Compression never takes priority over accuracy.

## Pass Order

Apply compression in the following sequence:

1. **Preserve scan** — identify all protected content and mark it as untouchable before making any changes.
2. **Remove** — strip all eleven remove categories from the document.
3. **Transform** — apply synonym replacements, introduce fragments, use arrow notation, apply abbreviations, and merge redundant bullets.
4. **Ambiguity check** — review every compressed phrase; restore any that introduced ambiguity or changed meaning.

## Abbreviation Discipline

One abbreviation per concept per file. Use standard abbreviations without introduction. Introduce non-standard abbreviations once in full form, then abbreviate consistently throughout. Never use multiple abbreviations for the same concept in the same file.

## Contractions

Convert multi-word negations to contractions: "do not" becomes "don't"; "must not" becomes "mustn't"; "will not" becomes "won't." Prefer "cannot" over "can't" — "cannot" is typically a single token in common BPE tokenizers and reads as a stronger imperative.

## Self-Reference

This rules file is itself an example of Ultra compression. The rules it describes are applied to the file itself as a dog-fooding signal.
