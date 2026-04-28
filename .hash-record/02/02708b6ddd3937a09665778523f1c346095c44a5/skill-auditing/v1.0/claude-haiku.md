---
hash: 02708b6ddd3937a09665778523f1c346095c44a5
file_paths:
  - gh-cli/gh-cli-repos/spec.md
  - gh-cli/gh-cli-repos/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: pass
---

# Result

PASS

Skill Audit: gh-cli-repos

Verdict: PASS
Type: inline
Path: gh-cli/gh-cli-repos
Failed phase: none

## Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present |
| Required sections | PASS | Purpose, Scope, Definitions, Intent, Requirements, Behavior present |
| Normative language | PASS | Must used consistently |
| Internal consistency | PASS | No contradictions |
| Completeness | PASS | All terms defined |

## Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — no instructions.txt present |
| Inline/dispatch consistency | PASS | SKILL.md is full procedure; no instruction file present |
| Structure | PASS | Frontmatter + full inline procedure |
| Input/output double-spec (A-IS-1) | PASS | No duplicate specs |
| Frontmatter | PASS | name and description present |
| Name matches folder (A-FM-1) | PASS | gh-cli-repos matches folder |
| H1 per artifact (A-FM-3) | PASS | SKILL.md no H1; uncompressed.md has H1 |
| No duplication | PASS | Unique sub-skill |

## Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | Create (personal/org), clone, fork with upstream-remote, sync --force warning, edit metadata, rename/archive/delete, list, set-default all covered |
| No contradictions | PASS | Aligns with spec |
| No unauthorized additions | PASS | All additions spec-traceable |
| Conciseness | PASS | Reference-card density |
| Completeness | PASS | Always-explicit-visibility requirement; --remote-name upstream guidance present |
| Breadcrumbs | PASS | Related section added |
| Cost analysis | N/A | Inline skill |
| Markdown hygiene | PASS | Clean |
| No dispatch refs | N/A | Inline skill |
| No spec breadcrumbs | PASS | No own spec.md reference |
| Description not restated (A-FM-2) | PASS | No verbatim restatement |
| Lint wins (A-FM-4) | PASS | Clean |
| No exposition in runtime (A-FM-5) | PASS | No rationale prose |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor lines |
| No empty sections (A-FM-7) | PASS | All sections populated |
| Iteration-safety placement (A-FM-8) | N/A | Not a self-auditing skill |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | No cross-references to other skills' source files |
| Launch-script form (A-FM-10) | N/A | Inline skill |

## Recommendation

No action required.
