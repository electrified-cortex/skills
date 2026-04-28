---
hash: 393b623f6461475feaf258f4ac9f80a6586cded0
file_paths:
  - gh-cli/gh-cli-issues/spec.md
  - gh-cli/gh-cli-issues/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: pass
---

# Result

PASS

Skill Audit: gh-cli-issues

Verdict: PASS
Type: dispatch
Path: gh-cli/gh-cli-issues
Failed phase: none

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use enforceable terms (must, shall) |
| Internal consistency | PASS | No contradictions; Error Handling and Precedence Rules align |
| Completeness | PASS | All terms defined; behavior explicit |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch skill (instructions.txt present) |
| Inline/dispatch consistency | PASS | Consistent dispatch pattern |
| Structure | PASS | Dispatch structure correct; params N/A for reference |
| Input/output double-spec (A-IS-1) | PASS | N/A (reference skill) |
| Frontmatter | PASS | name, description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: gh-cli-issues matches folder |
| H1 per artifact (A-FM-3) | PASS | uncompressed.md has H1; SKILL.md has none |
| No duplication | PASS | Unique skill in family |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec requirements covered: JSON output, bulk pipelining, @me assignee, state listing |
| No contradictions | PASS | Skill examples align with spec error handling and behavior |
| No unauthorized additions | PASS | REST API comment edit pattern extends logically; justified by gh limitation |
| Conciseness | PASS | Agent-facing density; no rationale prose; decision-tree structure |
| Completeness | PASS | All operations covered; edge cases addressed (comment edit/delete via REST) |
| Breadcrumbs | PASS | Related skills listed (gh-cli-projects, gh-cli-prs-create); all valid |
| Cost analysis | PASS | Instructions 60 lines; no sub-skill dispatches; single-turn execution |
| Markdown hygiene | PASS | CLEAN (Phase 0): all files pass |
| No dispatch refs | PASS | No "dispatch skill" or "run this skill" language in instructions |
| No spec breadcrumbs | PASS | No references to own spec.md in runtime |
| Description not restated (A-FM-2) | PASS | Paraphrased, not verbatim duplication |
| Lint wins (A-FM-4) | PASS | SKILL.md correctly has no H1; no suppressed violations |
| No exposition in runtime (A-FM-5) | PASS | Operational limitation notes justified; no rationale prose |
| No non-helpful tags (A-FM-6) | PASS | All descriptors carry operational value |
| No empty sections (A-FM-7) | PASS | All headings have body |
| Iteration-safety placement (A-FM-8) | PASS | N/A (reference skill) |
| Iteration-safety pointer form (A-FM-9a) | PASS | N/A |
| No verbatim Rule A/B (A-FM-9b) | PASS | N/A |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-file pointers; skill name references acceptable |
| Launch-script form (A-FM-10) | PASS | N/A |

## Issues

None identified.

## Recommendation

Skill ready for use. No revisions needed.

## References

(all CLEAN — no findings)
