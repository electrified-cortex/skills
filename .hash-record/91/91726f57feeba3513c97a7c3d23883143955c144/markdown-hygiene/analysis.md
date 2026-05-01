---
file_path: gh-cli/gh-cli-api/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA007 [WARN] line 89: Two-item list in Token Safety section.
  Note: The two items ("Use `gh auth login`..." and "Set `GH_TOKEN`...") could be expressed as a compound sentence rather than a list.

- SA010 [WARN] line 100: Shell command values in the Safety Classification table Command column are not wrapped in backticks.
  Note: Entries like `gh api GET`, `gh api POST`, etc. appear as plain text in the table; they are shell commands and would conventionally be code-formatted.

- SA012 [WARN] line 6: `# GH CLI API` is immediately followed by `## When to Use` with no prose between them.
  Note: No introductory sentence or body text separates the document title from the first section heading.

- SA014 [SUGGEST] line 87: "Never" in the directive "Never pass tokens as command-line arguments..." is unemphasized.
  Note: The prohibition keyword appears as plain prose in an instruction document; emphasis (bold or other) would signal its importance more clearly.

- SA018 [WARN] line 101: "Operator approval required before execution" in table Notes cells uses passive construction.
  Note: The phrase omits a subject and uses a past-participial form; "Requires operator approval before execution" would make the subject explicit.

- SA028 [WARN] line 101: The phrase "Operator approval required before execution" appears verbatim four times in the table.
  Note: The repetition across every Destructive row is redundant; a column-level note or footnote referencing a single statement could replace per-row duplication.

- SA032 [WARN]: The same concept is referred to as "domain-specific skills" (line 10) and "domain skills" (line 94).
  Note: Two distinct names are used for what appears to be the same class of skills; consistent terminology would remove ambiguity.
