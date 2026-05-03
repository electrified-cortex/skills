---
file_path: markdown-hygiene/markdown-hygiene-lint/lint.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA020 [WARN]: Requirements R1–R3 are numbered without sequence dependency — the three requirements are independent constraints, not ordered steps.
  Note: Bullet points would convey that these are parallel obligations rather than a sequence to follow in order.

- SA031 [WARN]: H2 sibling headings mix Title Case and Sentence case — "Purpose", "Scope", "Interface", "Behavior", "Requirements" are Title Case while "Output encoding" and "Exit codes" use Sentence case.
  Note: Picking one convention and applying it to all H2 siblings in this file would eliminate the inconsistency.

- SA034 [WARN] line 38: "These fixes are unconditional — if you don't want them, don't run the tool." — the qualifier "unconditional" is weakened by an implicit exception (caller discretion about running the tool at all).
  Note: The sentence accurately describes the tool's behavior but the phrase "don't want them" introduces a vague discretionary condition; removing it and stating only the behavioral fact would tighten the directive.
