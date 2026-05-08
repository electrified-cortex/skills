# ACTIVATION-DISCIPLINE — 2026-05-08

## Findings

### Missing "Not For" Guardrails — HIGH

**Finding:** Trigger keywords (security, correctness, code-quality, change-review, architectural-risk) are broad and could activate on non-code content (specs, docs, lockfiles) better handled by spec-auditing or markdown-hygiene.

**Action taken:** Added "Not for: specs, docs, config-only changes, lockfiles (use spec-auditing or markdown-hygiene)" to frontmatter description in SKILL.md, uncompressed.md, and instructions.txt.

## Clean (reviewed)

- Tier selection guidance: covered by Orchestration section (two-pass policy) and new Anti-patterns section
- Model selection: covered by MODEL-SELECTION optimization (tier justifications + model override guidance)
