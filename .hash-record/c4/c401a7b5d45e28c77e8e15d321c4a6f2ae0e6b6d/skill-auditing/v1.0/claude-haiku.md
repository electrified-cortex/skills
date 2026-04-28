---
hash: c401a7b5d45e28c77e8e15d321c4a6f2ae0e6b6d
file_paths:
  - gh-cli/gh-cli-prs/gh-cli-prs-comments/spec.md
  - gh-cli/gh-cli-prs/gh-cli-prs-comments/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

FAIL

## Skill Audit: gh-cli-prs-comments

**Verdict:** FAIL  
**Mode:** default (compressed runtime)  
**Type:** inline  
**Path:** gh-cli\gh-cli-prs\gh-cli-prs-comments  
**Failed phase:** 2

## Phase 1 — Spec Gate

| Check | Result | Notes |
|-------|--------|-------|
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Behavior, Error Handling, Precedence Rules, Constraints all present |
| Normative language | PASS | Uses "must", "shall", "required" appropriately |
| Internal consistency | PASS | No contradictions detected |
| Completeness | PASS | All terms defined, behavior explicit |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
|-------|--------|-------|
| Classification | PASS | Correctly identified as inline skill (reference/how-to format) |
| Inline/dispatch consistency | PASS | SKILL.md is self-contained inline format |
| Structure | FAIL | See A-FM-3 violation |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `gh-cli-prs-comments` matches folder name |
| H1 per artifact (A-FM-3) | FAIL | SKILL.md MUST NOT have H1; file contains `# gh-cli-prs-comments` |
| No duplication | PASS | Capability unique to this skill |

## Issues

**HIGH Severity — A-FM-3 (H1 per artifact)**
- SKILL.md contains `# gh-cli-prs-comments` H1 immediately after frontmatter
- Per spec, SKILL.md must NOT have H1
- uncompressed.md correctly has H1 `# GH CLI PR Comments`
- instructions.txt correctly has no H1
- Fix: Remove H1 from SKILL.md (second line after frontmatter)

## Recommendation

Remove the H1 from SKILL.md line 5 (`# gh-cli-prs-comments`). After fix, re-audit. Phase 2 will then proceed to Phase 3.

## References

None (no markdown-hygiene violations aside from H1 issue handled in A-FM-3).
