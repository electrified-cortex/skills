---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-comments/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA013 [WARN] line 3: `## Purpose` heading introduces only a single sentence.
  Note: The body under this heading is one sentence; inlining as `**Purpose:**` prose would avoid a heading for a single line.

- SA013 [WARN] line 36: `## Precedence Rules` heading introduces only a single sentence.
  Note: The body under this heading is one sentence ("N/A — …"); inlining as `**Precedence Rules:**` prose would avoid a heading for a single line.

- SA014 [SUGGEST] line 31: "Do not" directive is unemphasized.
  Note: The sentence "Do not use `gh pr view --comments` for this purpose" contains a strong directive keyword that is not bolded or otherwise emphasized in this instruction document.

- SA028 [WARN] lines 49–51: Phrase "Operator approval required before execution" (5 words) appears verbatim 3 times in the Safety Classification table.
  Note: The repeated identical note text in each Destructive row could be collapsed into a table caption or footer note rather than repeated per row.

- SA032 [WARN]: Skill name is inconsistent across the document.
  Note: The document title (line 1) and the cross-reference on line 9 use the plural form `gh-cli-prs-comments` / `gh-cli-prs-review`, while the folder path convention for this skill family uses the singular form `gh-cli-pr-comments` / `gh-cli-pr-review`. The document may be referencing sibling skills by incorrect names.
