---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-merge/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 78: shell commands in the `Command` column of the Safety Classification table appear without backticks (`gh pr merge`, `gh pr update-branch`, `gh pr revert`, `gh pr close` on lines 78–81).
  Note: Each command cell reads as plain text rather than inline code; the same commands are backtick-wrapped consistently in prose sections above.

- SA028 [WARN] line 78: the five-word phrase "Operator approval required before execution" appears verbatim four times (once per table row, lines 78–81).
  Note: The repetition is structural (one row per command) but the note text is identical across all four rows; a shared table caption or footnote could consolidate it.

- SA032 [WARN]: the same authorization concept is referred to as "operator approval" (table Notes column) and "operator authorization" (closing prose sentence).
  Note: Using one consistent term across both locations would remove the ambiguity about whether the two phrases mean the same thing.
