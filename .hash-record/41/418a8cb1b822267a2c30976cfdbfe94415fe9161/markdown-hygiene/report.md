---
file_path: electrified-cortex/skills/skill-auditing/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisories

- SA012 [WARN] line 17: Heading "Inspect:" immediately followed by heading "Variables:" with no content between.
  Note: Two adjacent headings without intervening content signal possible structural issue. Consider adding introductory text to "Inspect:" or merging sections.

- SA013 [WARN] line 6: Heading "Input:" introduces only a single item definition.
  Note: Single-item sections may benefit from being written as prose with a label instead of a section heading (e.g., `**Input:** ...`).

- SA014 [WARN] line 10: Directive "DON'T READ script source" not emphasized (not bold).
  Note: Instruction documents use emphasis on directives to highlight procedural imperatives. Consider `**DON'T READ** script source` to reinforce this critical guidance.
