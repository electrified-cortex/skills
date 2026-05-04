---
file_path: spec-auditing/instructions.uncompressed.md
operation_kind: markdown-hygiene-lint
result: fail
---

# Result

FINDINGS

- MD031 line 37: fenced code block not preceded by a blank line
  Fix: add a blank line before the opening fence at line 37
- MD031 line 43: fenced code block not preceded by a blank line
  Fix: add a blank line before the closing/opening fence transition at line 43
- MD040 line 43: fenced code block missing language identifier
  Fix: add a language tag to the opening fence (e.g. `text` for the cache path template)
- MD029 lines 55, 64, 65, 66, 67, 68: ordered list item prefixes out of sequence (items 3-8 instead of 1-6 in the Gates section)
  Fix: renumber list items starting from 1 in each distinct ordered list; the Gates section items are sub-gates that appear to continue a parent list — restructure or use separate lists with sequential numbering
- MD029 lines 110, 111: ordered list item prefixes 12-13 instead of 1-2
  Fix: renumber to start from 1
- MD029 line 189: ordered list item prefix 4 instead of 1
  Fix: renumber to start from 1
