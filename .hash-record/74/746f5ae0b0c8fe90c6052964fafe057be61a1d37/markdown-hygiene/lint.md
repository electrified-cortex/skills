---
file_path: spec-auditing/instructions.uncompressed.md
operation_kind: markdown-hygiene-lint
result: fail
---

# Result

FINDINGS

- MD041 line 1: first non-blank line is not an H1 heading — line reads `?# Spec Auditing Instructions` (stray `?` before `#`)
  Fix: remove the leading `?` character so the first line becomes `# Spec Auditing Instructions`
- MD031 line 37: fenced code block not preceded by a blank line
  Fix: add a blank line before the opening ` ``` ` fence at line 37
- MD031 line 43: fenced code block not preceded or followed by a blank line
  Fix: add blank lines around the closing fence and subsequent fence at line 43
- MD040 line 43: fenced code block missing language identifier
  Fix: add a language tag to the opening ` ``` ` fence (e.g. `text` for the cache path template)
- MD029 lines 55, 64, 65, 66, 67, 68: ordered list item prefixes do not follow sequential style (items numbered 3-8 instead of 1-6 in the Gates section)
  Fix: renumber list items sequentially starting from 1; this is a continuation list that should use separate numbering or be restructured
- MD029 lines 110, 111: ordered list item prefixes 12-13 instead of 1-2 in the Audit section
  Fix: renumber list items to start from 1 in this sub-list
- MD029 line 189: ordered list item prefix 4 instead of 1 in the Output section
  Fix: renumber list items to start from 1
