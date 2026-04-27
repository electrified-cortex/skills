---
hash: 3582b3c2197027955a34e61d0ecc107ba050477d
file_path: janitor/
operation_kind: skill-auditing
model: claude-sonnet-4-6
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: janitor

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** .worktrees/20-758/janitor/SKILL.md
**Failed phase:** none

Phase 1 — Spec Gate:

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements present; Constraints content present as `### Safety Constraints` subsection under Requirements and `## Don'ts` top-level section — normatively complete even without a bare `## Constraints` heading |
| Normative language | PASS | Requirements use must/shall/required throughout |
| Internal consistency | PASS | No contradictions or duplicate rules found |
| Completeness | PASS | All terms defined; behavior explicit; edge cases (git-history gate, fail-fast) stated |

Phase 2 — Skill Smoke Check:

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Dispatch — executor procedure is non-trivial multi-step pruning logic; requires `instructions.txt` |
| Inline/dispatch consistency | PASS | `instructions.txt` present; SKILL.md is a short routing card |
| Structure | PASS | SKILL.md is minimal routing card; instructions.txt has full procedure |
| Input/output double-spec (A-IS-1) | PASS | No sub-skill output path overridden |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: janitor` matches folder `janitor/` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; uncompressed.md has `# Janitor` H1; instructions.uncompressed.md has `# Janitor — Dispatch Instructions` H1; instructions.txt has no H1 |
| No duplication | PASS | No equivalent skill found in skill index |

Phase 3 — Spec Compliance:

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All normative requirements represented in instructions.txt |
| No contradictions | PASS | instructions.txt faithful to spec |
| No unauthorized additions | PASS | No normative content added beyond spec |
| Conciseness | PASS | instructions.txt is dense reference; no rationale prose |
| Completeness | PASS | All edge cases (git-history gate, fail-fast, dry-run default) addressed |
| Breadcrumbs | PASS | `iteration-safety`, `audit-reporting`, `session-logging` all exist and are valid |
| Cost analysis | PASS | Dispatch file well under 500 lines; no sub-skills inlined |
| Markdown hygiene | PASS | All .md files CLEAN under project .markdownlint.json (MD013/MD029/MD038 disabled) |
| No dispatch refs | PASS | instructions.txt contains no dispatch invocations |
| No spec breadcrumbs | PASS | Neither SKILL.md nor instructions.txt references own spec.md |
| Description not restated (A-FM-2) | PASS | Description appears only in frontmatter; not restated in body prose |
| Lint wins (A-FM-4) | PASS | SKILL.md CLEAN with `--ignore MD041` and project config |
| No exposition in runtime (A-FM-5) | PASS | No rationale, history, or "why" narrative in runtime artifacts |
| No non-helpful tags (A-FM-6) | PASS | No bare type-label lines found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | PASS | No iteration-safety blurb in instructions.uncompressed.md or instructions.txt |
| Iteration-safety pointer form (A-FM-9a) | N/A | Skill does not invoke iteration-safety; Related list is name-only breadcrumb |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety pointer present |
| Cross-reference anti-pattern (A-XR-1) | PASS | No path-based pointers to another skill's uncompressed.md or spec.md |
| Launch-script form (A-FM-10) | FINDINGS | uncompressed.md contains `Related:` breadcrumbs line — explicitly forbidden in launch-script form (A-FM-10: "Related breadcrumbs" listed as prohibited content) |

Issues:

- **[A-FM-10] HIGH — uncompressed.md: `Related:` breadcrumbs forbidden in launch-script form.** Line 22 of `uncompressed.md` reads `Related: /`iteration-safety/`, /`audit-reporting/`, /`session-logging/``. Per A-FM-10, `uncompressed.md` (the launch script) must contain ONLY: frontmatter, optional H1, dispatch invocation + input signature, return contract, and an optional 2-line iteration-safety pointer. "Related breadcrumbs" are explicitly listed as prohibited. Fix: remove the `Related:` line from `uncompressed.md`. The `Related:` line in `SKILL.md` (compiled runtime) is correct and should be kept.

Recommendation:
Remove the `Related:` breadcrumbs line from `uncompressed.md` (line 22), then regenerate `SKILL.md` via the compression skill.

References:
