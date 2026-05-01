---
file_paths:
  - swarm/SKILL.md
operation_kind: skill-auditing
model: sonnet-class
result: findings
---

# Result

FAIL

## Skill Audit: swarm

**Verdict:** FAIL
**Type:** inline
**Path:** swarm/
**Failed phase:** 1

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` present |
| Required sections | FAIL | `## Requirements` heading absent; normative content is distributed across Step Sequence, Constraints, Behavior, etc. but no section named "Requirements" |
| Normative language | PASS | Enforceable language (must, shall, required) used throughout normative sections |
| Internal consistency | PASS | No contradictions detected between sections |
| Completeness | PASS | Terms defined; behavior explicitly stated |

Phase 1 failed on Required sections. Phase 2 and Phase 3 not evaluated.

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | N/A | Phase 1 failed |
| Inline/dispatch consistency | N/A | Phase 1 failed |
| Structure | N/A | Phase 1 failed |
| Input/output double-spec (A-IS-1) | N/A | Phase 1 failed |
| Frontmatter | N/A | Phase 1 failed |
| Name matches folder (A-FM-1) | N/A | Phase 1 failed |
| H1 per artifact (A-FM-3) | N/A | Phase 1 failed |
| No duplication | N/A | Phase 1 failed |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | N/A | Phase 1 failed |
| No contradictions | N/A | Phase 1 failed |
| No unauthorized additions | N/A | Phase 1 failed |
| Conciseness | N/A | Phase 1 failed |
| Completeness | N/A | Phase 1 failed |
| Breadcrumbs | N/A | Phase 1 failed |
| Cost analysis | N/A | Phase 1 failed |
| No dispatch refs | N/A | Phase 1 failed |
| No spec breadcrumbs | N/A | Phase 1 failed |
| Description not restated (A-FM-2) | N/A | Phase 1 failed |
| No exposition in runtime (A-FM-5) | N/A | Phase 1 failed |
| No non-helpful tags (A-FM-6) | N/A | Phase 1 failed |
| No empty sections (A-FM-7) | N/A | Phase 1 failed |
| Iteration-safety placement (A-FM-8) | N/A | Phase 1 failed |
| Iteration-safety pointer form (A-FM-9a) | N/A | Phase 1 failed |
| No verbatim Rule A/B (A-FM-9b) | N/A | Phase 1 failed |
| Cross-reference anti-pattern (A-XR-1) | N/A | Phase 1 failed |
| Launch-script form (A-FM-10) | N/A | inline skill |
| Return shape declared (DS-1) | N/A | inline skill |
| Host card minimalism (DS-2) | N/A | inline skill |
| Description trigger phrases (DS-3) | N/A | inline skill |
| No substrate duplication (DS-5) | N/A | inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | YAML frontmatter present at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Orphan (A-FS-1) | LOW | Filename `index.md` not referenced by name in `SKILL.md` or `uncompressed.md`; only the parent directory `reviewers/` is referenced |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Not empty | PASS | |
| `specs/arbitrator.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Orphan (A-FS-1) | LOW | Not referenced by name in `SKILL.md` or `uncompressed.md` |
| `specs/dispatch-integration.md` | Not empty | PASS | |
| `specs/dispatch-integration.md` | No abs-path leaks | PASS | |
| `specs/dispatch-integration.md` | Orphan (A-FS-1) | LOW | Not referenced by name in `SKILL.md` or `uncompressed.md` |
| `specs/glossary.md` | Not empty | PASS | |
| `specs/glossary.md` | No abs-path leaks | PASS | |
| `specs/glossary.md` | Orphan (A-FS-1) | LOW | Not referenced by name in `SKILL.md` or `uncompressed.md` |
| `specs/personality-file.md` | Not empty | PASS | |
| `specs/personality-file.md` | No abs-path leaks | PASS | |
| `specs/personality-file.md` | Orphan (A-FS-1) | LOW | Not referenced by name in `SKILL.md` or `uncompressed.md` |
| `specs/registry-format.md` | Not empty | PASS | |
| `specs/registry-format.md` | No abs-path leaks | PASS | |
| `specs/registry-format.md` | Orphan (A-FS-1) | LOW | Not referenced by name in `SKILL.md` or `uncompressed.md` |

### Issues

- **[Phase 1 — Required sections — FAIL]** `swarm/spec.md` is missing a `## Requirements` section. The spec's normative content is distributed across `## Step Sequence`, `## Constraints`, `## Behavior`, `## Inputs`, `## Defaults and Assumptions`, `## Error Handling`, `## Precedence Rules`, and `## Don'ts`, but none of these carry the required heading name. Fix: add a `## Requirements` section (can be a summary or index into the normative sections, or rename/consolidate the existing normative content under that heading).
- **[Per-file — A-FS-1 — LOW]** `reviewers/index.md` filename is not referenced by name in `SKILL.md` or `uncompressed.md`. The files reference `reviewers/` as a directory to crawl, but the specific index file name is only named in sub-spec files (`specs/glossary.md`, `specs/registry-format.md`). Consider adding an explicit reference to `reviewers/index.md` in `uncompressed.md`.
- **[Per-file — A-FS-1 — LOW]** Five files under `specs/` (`arbitrator.md`, `dispatch-integration.md`, `glossary.md`, `personality-file.md`, `registry-format.md`) are not referenced by name in `SKILL.md` or `uncompressed.md`. These are sub-specs referenced internally from `spec.md` but are invisible to the compiled skill artifacts. They are not well-known role files. Consider whether `uncompressed.md` should reference them or whether they are purely spec-side concerns (in which case they may be acceptable as unreferenced from the runtime artifacts).

### Recommendation

Add `## Requirements` section to `swarm/spec.md` to satisfy the Phase 1 Required sections gate, then re-audit.
