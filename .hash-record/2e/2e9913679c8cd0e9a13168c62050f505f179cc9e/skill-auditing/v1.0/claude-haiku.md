---
hash: 2e9913679c8cd0e9a13168c62050f505f179cc9e
file_paths:
  - gh-cli/gh-cli-api/spec.md
  - gh-cli/gh-cli-api/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: gh-cli-api

Verdict: NEEDS_REVISION
Mode: (default)
Type: inline
gh-cli\gh-cli-api
Failed phase: none

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present and well-formed |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Uses must/shall throughout requirements section |
| Internal consistency | PASS | No contradictions or duplicate rules |
| Completeness | PASS | All terms defined, all behavior explicit |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Correctly identified as inline skill |
| Inline/dispatch consistency | PASS | Source artifacts present (spec.md, uncompressed.md); compiled artifacts (SKILL.md, instructions.txt) match expected pattern |
| Structure | PASS | Inline: frontmatter (name, description), direct instructions, self-contained |
| Frontmatter | PASS | name and description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: gh-cli-api matches folder name; verified in both uncompressed.md and SKILL.md |
| H1 per artifact (A-FM-3) | PASS | uncompressed.md has H1 ("# GH CLI API"); SKILL.md has no H1; instructions.txt has no H1 |
| No duplication | PASS | Skill does not duplicate existing gh-* subcommand skills |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All normative requirements represented: escape hatch guidance, --jq examples, GraphQL examples, token safety, pagination behavior |
| No contradictions | PASS | SKILL.md and uncompressed.md consistent with spec |
| No unauthorized additions | PASS | No new normative requirements introduced |
| Conciseness | PASS | Agent-facing density; terse, example-driven; no long prose explanations |
| Completeness | PASS | All runtime instructions present; edge cases addressed; defaults stated |
| Breadcrumbs | LOW | Missing references to related skills (gh-issue, gh-pr, gh-release, etc.). Recommend adding "See also" section |
| Markdown hygiene | PASS | No violations detected |
| No spec breadcrumbs | PASS | No references to spec.md in SKILL.md or instructions.txt |
| Description not restated (A-FM-2) | LOW | Frontmatter description: "Make authenticated REST and GraphQL calls to the GitHub API via the CLI. Use when no dedicated gh subcommand covers the operation." This is restated in both uncompressed.md and SKILL.md opening paragraphs. Description should appear only in frontmatter. |
| Lint (A-FM-4) | PASS | markdown-hygiene compliant (with --ignore MD041 for no-H1 rule) |
| No exposition in runtime (A-FM-5) | PASS | No rationale, "why exists," or background prose in runtime artifacts |
| No non-helpful tags (A-FM-6) | PASS | No descriptor lines lacking operational value |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Cross-reference anti-pattern (A-XR-1) | PASS | No links to other skills' uncompressed.md or spec.md |

## Issues

1. **A-FM-2 (LOW)** — Description restatement in body: Frontmatter description is repeated in opening line of uncompressed.md and SKILL.md. Remove this line; frontmatter description is sufficient. Description should appear only in frontmatter, not duplicated in body.

2. **Breadcrumbs (LOW)** — Missing related skills: Skill ends with "Scope Boundaries" but no reference to related gh-* subcommand skills (gh-issue, gh-pr, gh-release, etc.) or next logical steps. Add "## See also" section pointing to companion skills.

## Recommendation

Fix A-FM-2 by removing description restatement from body prose in uncompressed.md and SKILL.md. Add breadcrumbs referencing related gh-* subcommand skills. Re-audit after fix.

## References

None (all checks passed or identified as non-critical findings)
