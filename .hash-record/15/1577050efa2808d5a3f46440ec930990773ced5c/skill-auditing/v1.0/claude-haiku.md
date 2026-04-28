---
hash: 1577050efa2808d5a3f46440ec930990773ced5c
file_paths:
  - gh-cli/gh-cli-actions/spec.md
  - gh-cli/gh-cli-actions/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

Skill Audit: gh-cli-actions

Verdict: NEEDS_REVISION
Type: inline
gh-cli\gh-cli-actions\SKILL.md
Failed phase: 3

## Phase 1 — Spec Gate

| Check | Result | Notes |
|-------|--------|-------|
| Spec exists | PASS | spec.md present, well-formed |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints, Behavior, Error Handling, Precedence Rules |
| Normative language | PASS | Uses "must", "must enable", "must not", "must distinguish", "must surface", "must always" |
| Internal consistency | PASS | No contradictions between sections |
| Completeness | PASS | All terms defined (Workflow, Run ID, repository-level, environment-level, etc.) |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
|-------|--------|-------|
| Classification | PASS | Inline classification correct — self-contained reference material |
| Inline/dispatch consistency | PASS | SKILL.md and instructions.txt present; no instructions.uncompressed.md (appropriate for inline) |
| Structure | PASS | Frontmatter (name, description) + body; inline format correct |
| Input/output double-spec (A-IS-1) | PASS | No redundant input/output specifications |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | gh-cli-actions in folder, uncompressed.md, and SKILL.md match |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has NO H1 (correct); uncompressed.md has H1 (correct); instructions.txt has NO H1 (correct) |
| No duplication | PASS | Unique capability; no similar skills detected |

## Phase 3 — Spec Compliance Audit

| Check | Result | Notes |
|-------|--------|-------|
| Coverage | FAIL | Spec requires "show how to interpret `--json statusCheckRollup` output to determine overall run health" — SKILL.md omits this example |
| No contradictions | PASS | SKILL.md aligns with all spec assertions |
| No unauthorized additions | PASS | SKILL.md contains only spec-defined scope |
| Conciseness | PASS | Reference-card density; every line affects runtime |
| Completeness | FAIL | Incomplete due to missing statusCheckRollup guidance |
| Breadcrumbs | FAIL | No "Related skills", "Next steps", or skill references |
| Cost analysis | N/A | Inline skill |
| Markdown hygiene | PASS | No formatting violations |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own spec.md |
| Description not restated (A-FM-2) | PASS | Body does not duplicate frontmatter description |
| Lint wins (A-FM-4) | PASS | No markdown violations detected |
| No exposition in runtime (A-FM-5) | PASS | SKILL.md is command-dense; rationale in uncompressed.md (correct placement) |
| No non-helpful tags (A-FM-6) | PASS | No descriptor lines without operational value |
| No empty sections (A-FM-7) | PASS | All sections have content |
| Iteration-safety placement (A-FM-8) | N/A | Not a dispatch skill; iteration-safety not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-references to other skills' source/spec files |

## Issues

1. **CRITICAL — Missing statusCheckRollup example (Coverage)**
   - Spec requires: "The skill must show how to interpret `--json statusCheckRollup` output to determine overall run health."
   - Current SKILL.md shows: `--json databaseId,status,conclusion` but NOT `--json statusCheckRollup`
   - Example missing that guides agent how to parse health rollup
   - Fix: Add example showing statusCheckRollup query and output interpretation

2. **NON-CRITICAL — No breadcrumbs (Breadcrumbs)**
   - SKILL.md lacks "Related skills" section or references to related workflows
   - Cost: Agent doesn't discover related workflow patterns
   - Fix: Add brief "Related" section pointing to relevant GitHub APIs or similar skills

## Recommendation

NEEDS_REVISION. Add statusCheckRollup example to meet spec Coverage requirement. Optional: add breadcrumbs section.

## References

None — markdown hygiene CLEAN.
