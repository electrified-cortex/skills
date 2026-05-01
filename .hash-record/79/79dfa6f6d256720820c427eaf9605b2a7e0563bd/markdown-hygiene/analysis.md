---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-create/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 52: Shell commands `gh pr create` and `gh pr ready` appear in the Safety Classification table Command column without backtick formatting.
  Note: These are shell commands rendered as plain text in a table cell; applying code formatting would align with the backtick usage throughout the rest of the document.

- SA028 [WARN] line 53–54: The phrase "Operator approval required before execution" (5 words) appears verbatim in both table rows.
  Note: The phrase is duplicated across two consecutive table rows; a table-level note or column default might reduce the repetition.

- SA032 [WARN] document-level: The concept of required operator consent is referred to as both "Operator approval" (table, line 53–54) and "operator authorization" (bold sentence, line 56).
  Note: Using two distinct terms for what appears to be the same requirement could cause ambiguity; aligning on one term throughout would improve consistency.
