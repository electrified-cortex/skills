---
file_path: gh-cli/gh-cli-issues/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 61: Shell commands in the Safety Classification table Command column are not wrapped in backticks.
  Note: `gh issue list`, `gh issue view`, `gh issue create`, and the remaining six command entries appear as plain text; wrapping each in backticks would signal they are shell commands consistent with their treatment elsewhere in the document.

- SA018 [WARN] line 40: Passive voice used in a directive sentence in the Behavior section.
  Note: "Structured output is obtained with `--json` and `--jq`" reads as passive; the active form ("Use `--json` and `--jq` to obtain structured output") would align with the directive register of the surrounding sentences.

- SA028 [WARN] line 63: The phrase "Operator approval required before execution" appears verbatim seven times across the table Notes column.
  Note: Repetition may be intentional for row-level scanning, but the repeated phrase could be consolidated into a table caption or a note beneath the table to reduce redundancy.

- SA032 [WARN]: The concept of required operator permission is expressed using two distinct terms — "operator approval" (table Notes, lines 63–69) and "operator authorization" (line 71).
  Note: Whether intentional or not, using different labels for the same gate condition may cause readers to wonder if they refer to distinct requirements.

- SA036 [WARN] line 40: The opening sentence of the Behavior section chains multiple items through three or more coordinating conjunctions in a single clause.
  Note: "…viewing details and comments, editing metadata without losing existing values, closing or reopening with an optional comment, commenting, transferring, and bulk operations" contains `and`, `or`, and `and` as coordinating conjunctions across the chain; the Intent section already lists these as bullets and the sentence largely duplicates that list.
