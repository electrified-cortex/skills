---
file_path: gh-cli/gh-cli-projects/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 129: Shell commands in Safety Classification table cells appear without backtick formatting.
  Note: Entries like `gh project list`, `gh project view`, `gh project create`, and others in the Command column are unquoted shell commands in plain table cells; wrapping them in backticks would be consistent with how commands are treated elsewhere in the document.

- SA028 [WARN] line 131: The phrase "Operator approval required before execution" appears verbatim 12 times across table rows (lines 131–142).
  Note: The repeated phrase is structural in a table context, but could be consolidated into a table caption or section note to reduce repetition.
