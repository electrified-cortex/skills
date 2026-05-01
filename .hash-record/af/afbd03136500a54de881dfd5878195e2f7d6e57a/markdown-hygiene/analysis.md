---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-review/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 55: shell commands in the Safety Classification table Command column are not wrapped in backticks
  Note: `gh pr review --approve`, `gh pr review --request-changes`, `gh pr review --comment`, and `gh pr review --dismiss` appear as plain table cell text; other shell commands in the document are consistently backtick-formatted.

- SA013 [WARN] line 41: `## Precedence Rules` heading introduces only a single sentence
  Note: The entire section body is one sentence ("N/A — each review operation…"); a bold label inline with surrounding text may be a better fit for single-sentence content.

- SA014 [SUGGEST] line 35: "always" is unemphasized in a directive sentence
  Note: "Requesting changes must always include a body explaining what needs to be fixed" — "always" carries directive weight but is rendered in plain text.

- SA028 [WARN] line 55: "Operator approval required before execution" appears verbatim four times in the Safety Classification table
  Note: All four Notes cells carry identical text; the repetition is structurally expected for a table but could be replaced with a single footnote or caption to reduce noise.

- SA032 [WARN] document-level: the same operation is named "request changes" (unhyphenated) and "request-changes" (hyphenated) in different parts of the document
  Note: Definitions and Requirements use "request changes"; Error Handling and the table use "request-changes". Inconsistent naming for the same concept across sections.
