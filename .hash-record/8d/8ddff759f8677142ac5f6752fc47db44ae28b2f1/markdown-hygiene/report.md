---
operation_kind: markdown-hygiene
result: fail
file_path: markdown-hygiene/markdown-hygiene-lint/spec.md
---

# Result

lint: `findings: .hash-record/8d/8ddff759f8677142ac5f6752fc47db44ae28b2f1/markdown-hygiene/lint.md`
analysis: `pass: .hash-record/8d/8ddff759f8677142ac5f6752fc47db44ae28b2f1/markdown-hygiene/analysis.md`

## Advisory Dispositions

- SA009 line 22: multi-sentence list item (4 sentences) — Skipped: procedure steps in spec documents conventionally pack multiple instructions per item; restructuring to sub-sections would harm scanability without benefit.
- SA009 line 23: multi-sentence list item (3 sentences + sub-list) — Skipped: same rationale as SA009 line 22.
- SA009 line 26: multi-sentence list item (3 sentences) — Skipped: same rationale as SA009 line 22.
- SA009 line 27: multi-sentence list item (3 sentences) — Skipped: same rationale as SA009 line 22.
- SA028 line 21: repeated phrase "co-located in this sub-skill folder" — Skipped: the phrase appears in distinct procedure steps and a separate section; indirect cross-references would harm readability.
- SA028 line 48: repeated phrase "blank lines before AND after" — Skipped: the phrase appears in independent rule rows of a reference table; consolidation would require indirect references that obscure per-rule meaning.
- SA037 line 105: Constraints list mixes imperative and descriptive items — Skipped: the three items are intentionally heterogeneous (prohibition, access constraint, capability bound); adding visual signals would add noise without clarifying structure.
