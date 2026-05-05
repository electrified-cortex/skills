---
file_path: tool-auditing/result.spec.md
operation_kind: markdown-hygiene
model: sonnet-class
result: fail
---

# Result

FINDINGS

lint: 7 MD060/table-column-style violations
analysis: table pipe alignment issues in three tables

## Violations

| Line | Rule | Description |
| --- | --- | --- |
| 11 | MD060 | Table pipe has extra space to the left for style "compact" |
| 60 | MD060 | Table pipe does not align with header for style "aligned" |
| 61 | MD060 | Table pipe does not align with header for style "aligned" (3 occurrences) |
| 62 | MD060 | Table pipe does not align with header for style "aligned" |
| 64 | MD060 | Table pipe does not align with header for style "aligned" |

## Fix

Reformat table pipe characters to align columns. The `## Parameters` table (line 11)
and the `## Output contract` table (lines 60-64) have misaligned pipes.
