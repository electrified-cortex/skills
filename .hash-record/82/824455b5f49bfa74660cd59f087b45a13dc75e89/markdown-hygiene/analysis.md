---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-review/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA007 [WARN] line 78: Two-item "Related" list reads naturally as a compound sentence.
  Note: Both entries could be joined — e.g. "`gh-cli-prs-create` for reviewers and PR creation, and `gh-cli-api` for GraphQL thread resolution."

- SA009 [WARN] line 73: Error Paths list items each contain two sentences.
  Note: Multi-sentence entries may be clearer as labeled subsections or definition-style blocks rather than list items.

- SA010 [WARN] line 85: Shell commands in Safety Classification table cells are bare (no backticks).
  Note: All four command cells — `gh pr review --approve`, `--request-changes`, `--comment`, `--dismiss` — contain unformatted shell commands.

- SA018 [WARN] line 20: Directive uses passive voice — "A body is required to explain what needs to be addressed."
  Note: Could be rewritten as "Include a body explaining what needs to be addressed."

- SA018 [WARN] line 36: Directive uses passive voice — "`--review-id` is required."
  Note: Could be rewritten as "Provide `--review-id`; the `gh` CLI will not accept `--dismiss` without it."

- SA028 [WARN] line 85: Phrase "Operator approval required before execution" appears verbatim four times in the Notes column.
  Note: Repeated table-cell text; a note beneath the table could convey this once rather than per row.
