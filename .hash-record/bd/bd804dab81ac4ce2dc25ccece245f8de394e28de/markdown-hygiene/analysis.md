---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-merge/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 55: Shell commands in table cells without backticks (`gh pr merge`, `gh pr update-branch`, `gh pr revert`, `gh pr close`).
  Note: The Safety Classification table lists CLI commands in plain cell text; the commands are indistinguishable from prose without backtick formatting applied to each cell value.

- SA013 [WARN] line 8: `## Purpose` heading introduces only a single sentence.
  Note: The entire section body is one sentence; a bold inline label in the surrounding prose may serve better than a standalone heading.

- SA014 [SUGGEST] line 40: `always` in directive is unemphasized.
  Note: "the agent must always pass an explicit strategy flag" — the constraint word is unformatted in an instruction sentence.

- SA014 [SUGGEST] line 40: `must not` in directive is unemphasized.
  Note: "it must not force-update" — the prohibition appears without emphasis.

- SA014 [SUGGEST] line 44: `must not` in directive is unemphasized.
  Note: "the agent must not delete the source branch unless the caller explicitly requests it" — the prohibition appears without emphasis.

- SA018 [WARN] line 44: Passive voice on directive sentence.
  Note: "Merge strategy must be explicitly specified" places the actor implicit; "The agent must explicitly specify a merge strategy" would express the same directive in active voice.

- SA028 [WARN] line 55: Phrase "Operator approval required before execution" appears verbatim four times in the table.
  Note: The phrase fills all four Notes cells identically; extracting it to a prefatory sentence or table caption would eliminate the repetition.

- SA032 [WARN]: "source branch" and "PR branch" used interchangeably for the same concept.
  Note: "source branch" appears in Requirements (line 29), Behavior (line 36), and Precedence Rules (line 44); "PR branch" appears in Definitions (line 21), Requirements (line 30), and Behavior (line 36) — both appear to refer to the branch being merged.
