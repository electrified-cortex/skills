---
hash: f7c6696f874b27968e5eef24e95ccbdb922d02ae
file_paths:
  - hash-record/hash-record-manifest/instructions.uncompressed.md
  - hash-record/hash-record-manifest/spec.md
  - hash-record/hash-record-manifest/uncompressed.md
operation_kind: skill-auditing
model: claude-sonnet-4-6
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: hash-record-manifest

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** .worktrees/15-810/hash-record/hash-record-manifest/SKILL.md
**Failed phase:** 3

Phase 1 — Spec Gate:
| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall throughout |
| Internal consistency | PASS | No contradictions or duplicate rules found |
| Completeness | PASS | All terms defined; behavior fully specified |

Phase 2 — Skill Smoke Check:
| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch: zero-context executor with defined inputs, correct classification |
| Inline/dispatch consistency | PASS | instructions.txt present; SKILL.md is short routing card |
| Structure | PASS | SKILL.md is minimal dispatch card; instructions.txt has full procedure |
| Input/output double-spec (A-IS-1) | PASS | No double-spec; return contract defined once in SKILL.md |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: hash-record-manifest matches folder hash-record-manifest |
| H1 per artifact (A-FM-3) | PASS | SKILL.md no H1 (correct); uncompressed.md has H1; instructions.uncompressed.md has H1; instructions.txt no H1 (correct) |
| No duplication | PASS | No existing skill provides this capability |

Phase 3 — Spec Compliance:
| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec requirements covered in instructions.txt (Steps 1-6, constraints, error table) |
| No contradictions | PASS | instructions.txt faithful to spec; no contradictions |
| No unauthorized additions | PASS | No normative additions beyond spec |
| Conciseness | PASS | instructions.txt is dense reference; no rationale or prose padding |
| Completeness | PASS | All edge cases addressed (duplicate paths, symlinks, empty list, missing files) |
| Breadcrumbs | FAIL | SKILL.md does not end with a Related skills section. Sibling `hash-record` parent and single-file inline `git hash-object` usage are not referenced. |
| Cost analysis | PASS | Dispatch agent, file <500 lines, sub-skills by pointer only, single-turn execution |
| Markdown hygiene | PASS | All .md files CLEAN (MD013 project-suppressed; MD041 sanctioned for SKILL.md per R-FM-3) |
| No dispatch refs | PASS | instructions.txt contains no dispatch instructions |
| No spec breadcrumbs | PASS | Neither SKILL.md nor instructions.txt references spec.md |
| Description not restated (A-FM-2) | PASS | Description only in frontmatter; not restated in body prose |
| Lint wins (A-FM-4) | PASS | SKILL.md CLEAN with --ignore MD041 |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background in SKILL.md or instructions.txt |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor lines found |
| No empty sections (A-FM-7) | PASS | All sections in instructions.txt have body content |
| Iteration-safety placement (A-FM-8) | PASS | No iteration-safety blurb in instructions.txt or instructions.uncompressed.md |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety pointer in runtime (skill delegates caching to caller; no self-caching) |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim iteration-safety rules present |
| Cross-reference anti-pattern (A-XR-1) | PASS | No path-based pointers to other skills' uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | PASS | uncompressed.md contains only: frontmatter, H1, dispatch invocation + input signature, return contract |

Issues:
- **Phase 3, Check 6 — Breadcrumbs missing**: SKILL.md does not end with a `Related:` section. For a sub-skill of `hash-record`, the related skills section should reference `hash-record` (parent) and note that single-file consumers use `git hash-object` inline (not a skill reference, but useful context). Fix: add `Related: hash-record` (or equivalent breadcrumb line) to the end of SKILL.md before recompiling.

Recommendation:
Add a Related breadcrumbs line to uncompressed.md and recompile; one non-critical issue only.

References:
