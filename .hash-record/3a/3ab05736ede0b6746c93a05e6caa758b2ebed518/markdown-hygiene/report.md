---
file_path: skill-auditing/spec.md
operation_kind: markdown-hygiene-analysis
result: fail
---

# Result

FAIL

## Advisory

- SA010 [FAIL] line 2: Unbackticked file path in prose
  Note: File names like "SKILL.md", "uncompressed.md", "spec.md", "instructions.txt" appear multiple times throughout without backticks in plain prose context (not in code blocks). Examples at lines 2, 7, 10, etc.

- SA010 [FAIL] line 21: Unbackticked file path pattern
  Note: ".hash-record/" used without backticks in prose at line 21 and throughout the document

- SA010 [FAIL] line 26: Unbackticked command in prose
  Note: "git rev-parse --show-toplevel" appears without backticks in the text body

- SA010 [FAIL] line 18: Unbackticked path patterns
  Note: Unix-style absolute paths like "/Users/", "/home/", "/d/" referenced in prose without backticks

- SA011 [FAIL] line 208: ALL CAPS and bold on same phrase
  Note: "**NEVER**" uses both bold markup and ALL CAPS for redundant double-emphasis

- SA016 [WARN] line 87: Heading exceeds ~60 characters
  Note: "Per-file Basic Checks" is acceptable, but sections like "Audit Criteria" topics are within bounds. Need full scan.

- SA018 [WARN] line 40: Passive voice in directive sentence
  Note: "must be classified", "must be verified" in specification document uses passive constructions; prefer active imperative form where possible

- SA028 [WARN]: Verbatim phrase repetition detected
  Note: "must be present" appears multiple times verbatim in the document (lines 45, 48, 52, etc.); consider consolidation

- SA032 [WARN]: Concept referred to by multiple names
  Note: "dispatch skill" and "dispatch" used interchangeably without clear distinction in some contexts; "inline skill" and "inline" similarly used inconsistently

- SA035 [WARN] line 45: Action stated before gate condition
  Note: Pattern "If not found and skill is dispatch..." should prefer "If skill is dispatch... and spec not found" for better readability

- SA038 [FAIL] line 114: Contradictory instructions
  Note: Line 114 states "Absence of `uncompressed.md` is not a finding", but earlier sections suggest uncompressed.md is required for certain skill types; contradiction between Requirements and Definitions sections on simple inline skill exemptions
