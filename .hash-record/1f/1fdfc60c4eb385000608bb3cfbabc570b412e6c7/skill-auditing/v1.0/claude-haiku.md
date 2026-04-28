---
hash: 1fdfc60c4eb385000608bb3cfbabc570b412e6c7
file_paths:
  - session-logging/instructions.uncompressed.md
  - session-logging/spec.md
  - session-logging/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: session-logging

Verdict: NEEDS_REVISION
Type: dispatch
Path: session-logging

Failed phase: 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
|-------|--------|-------|
| Spec exists | PASS | spec.md found |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints present |
| Normative language | PASS | Requirements use enforceable terms |
| Internal consistency | PASS | No contradictions |
| Completeness | PASS | All terms defined |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
|-------|--------|-------|
| Classification | PASS | Dispatch (instructions.txt present) |
| Inline/dispatch consistency | PASS | Consistent |
| Structure | PASS | Proper structure |
| Input/output double-spec (A-IS-1) | PASS | No input/output conflicts |
| Frontmatter | PASS | name and description present |
| Name matches folder (A-FM-1) | PASS | session-logging matches |
| H1 per artifact (A-FM-3) | FAIL | SKILL.md contains H1, should not |
| No duplication | PASS | Unique capability |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
|-------|--------|-------|
| Coverage | PASS | All spec requirements covered |
| No contradictions | PASS | No contradictions |
| No unauthorized additions | PASS | No unauthorized additions |
| Conciseness | NEEDS_REVISION | Some exposition present (check A-FM-5) |
| Completeness | PASS | Runtime instructions complete |
| Breadcrumbs | PASS | Related skills referenced |
| Cost analysis | PASS | Dispatch agent, <500 lines |
| Markdown hygiene | FINDINGS | See References |
| No dispatch refs | PASS | No dispatch references in instructions |
| No spec breadcrumbs | PASS | No self-referential spec breadcrumbs |
| Description not restated (A-FM-2) | PASS | Description not duplicated |
| Lint wins (A-FM-4) | PASS | Markdown hygiene OK |
| No exposition in runtime (A-FM-5) | FAIL | Rationale/why prose present in SKILL.md |
| No non-helpful tags (A-FM-6) | PASS | No non-helpful descriptor lines |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | PASS | Iteration-safety blurb placement correct |
| Iteration-safety pointer form (A-FM-9a) | PASS | Pointer form correct (if present) |
| No verbatim Rule A/B (A-FM-9b) | PASS | No verbatim iteration-safety rules |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-file pointers to uncompressed/spec |
| Launch-script form (A-FM-10) | PASS | Launch-script form correct for dispatch |

## Issues

1. **(A-FM-3) H1 in SKILL.md**: SKILL.md contains an H1 heading. Per spec, SKILL.md must NOT have H1. This is a High severity issue. Fix: Remove H1 from SKILL.md or move to uncompressed.md.

2. **(A-FM-5) Exposition in runtime**: SKILL.md contains rationale/explanatory prose that belongs in spec.md. Agent instructions should be concise, decision-tree focused, not essay-like. Fix: Move rationale to spec.md; keep SKILL.md as a dense reference card.

## Recommendation

Remove H1 from SKILL.md, relocate exposition/rationale prose to spec.md. Re-audit with `--uncompressed` mode to validate source files before recompressing.

## References

- `markdown-hygiene` phase 0: CLEAN (no issues)
