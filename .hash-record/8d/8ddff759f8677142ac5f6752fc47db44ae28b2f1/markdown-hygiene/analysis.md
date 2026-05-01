---
file_path: markdown-hygiene/markdown-hygiene-lint/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA009 [WARN] line 22: list item is a multi-sentence paragraph (4 sentences)
  Note: Procedure item 2 contains four sentences; the rule suggests converting verbose list items to sub-sections.

- SA009 [WARN] line 23: list item is a multi-sentence paragraph (3 sentences + sub-list)
  Note: Procedure item 3 contains three prose sentences before branching into a sub-list.

- SA009 [WARN] line 26: list item is a multi-sentence paragraph (3 sentences)
  Note: Procedure item 4 contains three sentences.

- SA009 [WARN] line 27: list item is a multi-sentence paragraph (3 sentences)
  Note: Procedure item 5 contains three sentences.

- SA014 [SUGGEST] line 22: "Do not install one if absent." — "do not" unemphasized in instruction document
  Note: Unemphasized negation directive; the rule suggests visual emphasis (bold or caps) on "do not" in instruction context.

- SA014 [SUGGEST] line 26: "do not re-check covered rules" — "do not" unemphasized in instruction document
  Note: Same pattern as line 22; the directive negation is not visually distinguished from surrounding prose.

- SA018 [WARN] line 5: "The target file is always modified by preparation" — passive voice on directive sentence in spec document
  Note: Active rewrite would be "Preparation always modifies the target file."

- SA018 [WARN] line 106: "Target file is read-only by this executor." — passive voice in Constraints section
  Note: Active rewrite would be "This executor must not modify the target file."

- SA028 [WARN] line 21: phrase "co-located in this sub-skill folder" repeated verbatim on lines 21, 26, and 62
  Note: The six-word phrase appears three times; a single cross-reference or consolidation could reduce repetition.

- SA028 [WARN] line 48: phrase "blank lines before AND after" repeated verbatim on lines 48, 49, and 57
  Note: The phrase appears identically in three MD rule table rows (MD031, MD032, MD058); a shared shorthand could reduce duplication.

- SA031 [WARN] line 60: `## verify Scripts` uses lowercase "v" while all sibling `##` headings use Title Case
  Note: Sibling headings (Purpose, Model Tier, Inputs, Procedure, MD Rule Reference, Output Contract, Constraints) are all Title Case; "verify" breaks the pattern.

- SA035 [WARN] line 22: "Do not install one if absent." — action stated before gate condition
  Note: Gate-first preference: "If absent, do not install one."

- SA035 [WARN] line 22: "Ignore MD041 warnings if the target file is a `SKILL.md`." — action stated before gate condition
  Note: Gate-first preference: "If the target file is a `SKILL.md`, ignore MD041 warnings."

- SA035 [WARN] line 29: "overwrite if present" — action stated before gate condition
  Note: Gate-first preference: "if present, overwrite."

- SA037 [WARN] line 105: Constraints list mixes imperative command items and description/observation items without a distinguishing signal
  Note: Item 1 is an imperative command ("do NOT author scripts"), item 2 is a descriptive constraint ("Target file is read-only"), item 3 is mixed (description + command). No visual signal distinguishes command items from descriptive ones.
