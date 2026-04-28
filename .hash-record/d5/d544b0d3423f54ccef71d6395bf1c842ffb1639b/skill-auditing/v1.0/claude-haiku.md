---
hash: d544b0d3423f54ccef71d6395bf1c842ffb1639b
file_paths:
  - skill-auditing/instructions.uncompressed.md
  - skill-auditing/spec.md
  - skill-auditing/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

FAIL

## Skill Audit: skill-auditing

**Verdict:** FAIL
**Type:** dispatch
**Path:** skill-auditing
**Failed phase:** 2

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use enforc able terms (must, shall, required) |
| Internal consistency | PASS | No contradictions detected |
| Completeness | PASS | All terms defined, behavior explicit |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill by inspection (instructions.txt present) |
| Inline/dispatch consistency | PASS | instructions.txt present confirms dispatch classification |
| Structure | PASS | SKILL.md is routing card, instructions.txt contains full procedure |
| Input/output double-spec (A-IS-1) | PASS | No input/output duplication detected |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: skill-auditing matches folder |
| H1 per artifact (A-FM-3) | FAIL | uncompressed.md MUST contain H1 but does NOT |
| No duplication | PASS | No duplicate capability detected |

### Issues

- **(A-FM-3 FAIL)** — `uncompressed.md` must contain an H1 heading (`# ...` on first line after frontmatter if present), but none was found. SKILL.md spec: "H1 per artifact — `SKILL.md` MUST NOT contain an H1. `uncompressed.md` MUST contain an H1. `instructions.uncompressed.md` (if present) MUST contain an H1. `instructions.txt` (if present) MUST NOT contain an H1."

### Recommendation

Add H1 to `uncompressed.md`. Verify: `uncompressed.md` should open with `# Skill Auditing` or similar heading immediately after any frontmatter.
