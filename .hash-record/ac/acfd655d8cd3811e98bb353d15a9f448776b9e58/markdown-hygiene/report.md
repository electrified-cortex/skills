---
operation_kind: markdown-hygiene
result: pass
file_path: skill-auditing/SKILL.md
---

# Result

lint: `clean`
analysis: `pass: .hash-record/ac/acfd655d8cd3811e98bb353d15a9f448776b9e58/markdown-hygiene/analysis.md`

## Advisories

- SA010: fixed — wrapped `stdout` in backticks on lines 12, 19, 20, 52.
- SA013: Skipped: `## Input` heading is intentional SKILL.md structural format; collapsing to an inline label would break the pattern used across all skills.
- SA018: fixed — changed "Audit proceeds only when…" to "Proceed only when…".
- SA029: fixed — replaced positional reference with explicit section name.
- SA032: fixed — replaced all `mhygiene` references with `markdown-hygiene`; updated inline error message strings accordingly.
