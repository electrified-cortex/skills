---
file_path: spec-auditing/spec.md
operation_kind: markdown-hygiene-lint
result: fail
---

# Result

FINDINGS

- MD032 line 507: list not surrounded by blank lines
  Fix: add a blank line before the bullet list starting at line 507 (the return token values list after the code block ends)
- MD040 line 583: fenced code block missing language identifier
  Fix: add a language tag to the opening fence (e.g. `text` for the path template block)
- MD040 line 625: fenced code block missing language identifier
  Fix: add a language tag to the opening fence (e.g. `text` for the return token examples block)
