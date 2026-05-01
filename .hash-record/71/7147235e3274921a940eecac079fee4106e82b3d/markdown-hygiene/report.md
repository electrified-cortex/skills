---
operation_kind: markdown-hygiene
result: fail
file_path: gh-cli/gh-cli-projects/spec.md
---

# Result

lint: `findings: .hash-record/71/7147235e3274921a940eecac079fee4106e82b3d/markdown-hygiene/lint.md`
analysis: `pass: .hash-record/71/7147235e3274921a940eecac079fee4106e82b3d/markdown-hygiene/analysis.md`

## Advisories

- SA010 line 36: Applied — wrapped `owner/repo/number` in backticks.
- SA010 line 62: Applied — wrapped all command names in the Safety Classification table in backticks.
- SA018 line 34: Applied — rewrote passive-voice clause to active form ("the skill must include commands for resolving…").
- SA028 lines 35, 41: Skipped: The duplicate phrasing appears in distinct sections (Requirements vs. Behavior) serving different purposes; repetition is intentional for section-level clarity.
