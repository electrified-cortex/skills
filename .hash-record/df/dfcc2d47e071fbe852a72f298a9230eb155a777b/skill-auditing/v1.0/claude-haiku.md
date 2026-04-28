---
hash: dfcc2d47e071fbe852a72f298a9230eb155a777b
file_paths:
  - gh-cli/gh-cli-prs/spec.md
  - gh-cli/gh-cli-prs/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

PASS_WITH_FINDINGS

Skill Audit: gh-cli-prs

Verdict: PASS_WITH_FINDINGS
Type: inline
gh-cli\gh-cli-prs\
Failed phase: none

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and well-formed |
| Required sections | PASS | All sections present: Purpose, Scope, Definitions, Requirements, Intent, Behavior, Error Handling, Constraints |
| Normative language | PASS | Requirements use normative terms: "must", "must not" |
| Internal consistency | PASS | No contradictions detected |
| Completeness | PASS | All terms defined; behavior fully specified |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly classified as inline skill (<30 lines) |
| Inline/dispatch consistency | PASS | No instructions.uncompressed.md; skill is inline |
| Structure | PASS | Proper frontmatter, content structure |
| Input/output double-spec (A-IS-1) | PASS | No input parameters; output is sub-skill routing guidance |
| Frontmatter | PASS | name and description present, accurate |
| Name matches folder (A-FM-1) | PASS | "gh-cli-prs" matches directory name |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1 ✓; uncompressed.md has H1 ✓ |
| No duplication | PASS | No significant duplication detected |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec requirements covered: inspection commands, sub-skill routing, scope boundaries |
| No contradictions | PASS | SKILL.md/uncompressed.md align with spec |
| No unauthorized additions | PASS | No extra normative requirements introduced |
| Conciseness | FINDINGS | Minor exposition could be tightened (see below) |
| Completeness | PASS | All instructions present for agent use |
| Breadcrumbs | FINDINGS | No related-skills or next-step pointers; sub-skills referenced but not linked |
| Cost analysis | N/A | Inline skill; cost not applicable |
| Markdown hygiene | PASS | No hard tabs, trailing spaces, or inline HTML detected |
| No dispatch refs | N/A | Not a dispatch skill |
| No spec breadcrumbs | PASS | No references to spec.md in runtime files |
| Description not restated (A-FM-2) | FINDINGS | Description appears in frontmatter AND as opening line of uncompressed.md body—minor duplication |
| Lint wins (A-FM-4) | PASS | No markdown violations |
| No exposition in runtime (A-FM-5) | PASS | Focused on instructions; no rationale/background |
| No non-helpful tags (A-FM-6) | PASS | All descriptors are operational |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | Not an iteration-safety candidate |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-file pointers to uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | N/A | Not dispatch; N/A |

## Issues

1. **Breadcrumbs missing (Phase 3 Check 6):** uncompressed.md and SKILL.md do not include "Related Skills" or "Next Steps" sections linking to the four sub-skills (gh-cli-prs-create, gh-cli-prs-review, gh-cli-prs-comments, gh-cli-prs-merge). The sub-skills are named in the table but not linked or contextualized. This reduces discoverability and leaves the agent without navigation hints.

   - **Severity:** LOW  
   - **Fix:** Add a "Related Skills" section at end of uncompressed.md with pointers to: `gh-cli-prs-create`, `gh-cli-prs-review`, `gh-cli-prs-comments`, `gh-cli-prs-merge`.

2. **Description restatement (Phase 3 Check A-FM-2):** The description "Entry point for pull request management via the GitHub CLI. Handles common PR inspection and routes write operations to sub-skills." appears verbatim in frontmatter and again in uncompressed.md's opening sentence. This is minor—boilerplate pattern—but violates A-FM-2's "description not restated" rule.

   - **Severity:** LOW  
   - **Fix:** Remove or rephrase the opening line of uncompressed.md body to avoid verbatim match to frontmatter description.

## Recommendation

PASS_WITH_FINDINGS. Skill is functional and compliant. Two LOW-severity findings: add breadcrumbs to sub-skills and avoid duplicating description in body. No blocking issues.
