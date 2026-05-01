---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-comments/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 57: `never` is unemphasized in an instruction document.
  Note: "never for exhaustive comment checks" — the directive word "never" appears in plain prose without bold or other emphasis.

- SA018 [WARN] lines 76–78: Table notes use passive voice for a directive.
  Note: "Operator approval required before execution" omits an actor and verb — the active form would be "Obtain operator approval before execution."

- SA028 [WARN] lines 20, 33: "Use the REST API directly" appears verbatim in both the Editing and Deleting sections.
  Note: The identical phrase is repeated across two sections that could share a single note or cross-reference.

- SA028 [WARN] lines 76–78: "Operator approval required before execution" appears verbatim in three consecutive table rows.
  Note: The repetition is structurally consistent but the identical five-word phrase is duplicated.

- SA032 [WARN]: The concept of issue-level PR comments is referred to as "general comments" (line 8) and "general PR (issue) comments" (line 51).
  Note: The parenthetical clarifies the API category but introduces two distinct names for the same concept within the document.

- SA038 [FAIL]: Lines 20 and 33 explicitly state that `gh pr comment` has no `--edit` or `--delete` flags, yet lines 77–78 list "gh pr comment --edit" and "gh pr comment --delete" as named commands in the Safety Classification table.
  Note: The table implies these are valid command invocations, directly contradicting the prose that states the flags do not exist.
