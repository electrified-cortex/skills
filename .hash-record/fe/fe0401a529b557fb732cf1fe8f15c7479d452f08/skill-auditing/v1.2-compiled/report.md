---
file_paths:
  - swarm/SKILL.md
operation_kind: skill-auditing
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/
**Failed phase:** none

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `spec.md` present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall throughout |
| Internal consistency | PASS | No contradictions detected within primary spec |
| Completeness | PASS | Terms defined; behavior explicitly stated |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline: procedure requires context-sensitive judgment; agent executes directly |
| Inline/dispatch consistency | PASS | No `instructions.txt` present; SKILL.md contains full procedure |
| Structure | PASS | Frontmatter present; full step sequence in body; self-contained |
| Input/output double-spec (A-IS-1) | PASS | No output double-specification found |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder name `swarm/` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1 (correct); no instructions.txt present |
| No duplication | PASS | No duplicate capability found |
| Orphan files (A-FS-1) | FINDINGS | See Issues |
| Missing referenced files (A-FS-2) | PASS | No specific filenames referenced that are missing |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | FINDINGS | Arbitrator step (S6) in SKILL.md lacks backing in primary spec step sequence |
| No contradictions | FINDINGS | SKILL.md S2 crawl-at-runtime contradicts `specs/registry-format.md` single-index-read policy |
| No unauthorized additions | FINDINGS | B8 (diversity rule) present in SKILL.md but absent from primary spec Behavior section; S6 Arbitrator step not in spec step sequence |
| Conciseness | PASS | Terse, action-oriented; no rationale prose; no meta-architectural labels detected |
| Completeness | PASS | All runtime instructions present; edge cases covered |
| Breadcrumbs | PASS | Related section present; `dispatch`, `compression`, `skill-index` are valid targets |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No instructions.txt |
| No spec breadcrumbs | PASS | No reference to companion spec.md in SKILL.md |
| Description not restated (A-FM-2) | PASS | Description only in frontmatter; body does not restate it |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose found in SKILL.md |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety content present |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill's uncompressed.md or spec.md found |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | `name` and `description` present |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Not empty | PASS | |
| `specs/arbitrator.md` | No abs-path leaks | PASS | |
| `specs/dispatch-integration.md` | Not empty | PASS | |
| `specs/dispatch-integration.md` | No abs-path leaks | PASS | |
| `specs/glossary.md` | Not empty | PASS | |
| `specs/glossary.md` | No abs-path leaks | PASS | |
| `specs/personality-file.md` | Not empty | PASS | |
| `specs/personality-file.md` | No abs-path leaks | PASS | |
| `specs/registry-format.md` | Not empty | PASS | |
| `specs/registry-format.md` | No abs-path leaks | PASS | |

### Issues

- **[Phase 3 / Orphan files — A-FS-1 — LOW]** Files in `swarm/specs/` (`arbitrator.md`, `dispatch-integration.md`, `glossary.md`, `personality-file.md`, `registry-format.md`) are not referenced by filename in `SKILL.md` or `uncompressed.md`. They self-identify as sub-specs of `spec.md` but the primary `spec.md` does not reference them by path or name. `reviewers/index.md` is similarly unreferenced by filename (S2/S4 reference the `reviewers/` directory via a pattern, which covers body files but not the index file explicitly). Fix: either reference each sub-spec by name from `spec.md` or add a `## Sub-specifications` section in `spec.md` listing them; for `reviewers/index.md`, add an explicit reference in the spec or SKILL.md loading description.

- **[Phase 3 / No unauthorized additions — MEDIUM]** `SKILL.md` declares `B8` (cross-vendor diversity rule) in its Behaviors section, but the primary `spec.md` Behavior section only defines B1–B7. The diversity rule exists in `specs/dispatch-integration.md` but that sub-spec is not referenced by the primary spec, and the primary spec's normative behavior list does not include it. Fix: add B8 to the primary `spec.md` Behavior section, or confirm the sub-specs are authoritative additions and reference them explicitly from `spec.md`.

- **[Phase 3 / Coverage + No unauthorized additions — MEDIUM]** The primary `spec.md` step sequence has 7 steps (Steps 1–7); the Arbitrator consolidation sub-agent does not appear in the spec's step sequence. `SKILL.md` introduces a separate arbitrator dispatch step (S6) between dispatch and aggregation, with `specs/arbitrator.md` defining its role — but neither document is cross-referenced from the primary `spec.md`. As a result, the primary spec's Step 6 ("Aggregate findings from all dispatched personalities") contradicts SKILL.md's Step 7 ("Aggregate from arbitrator's action list only"). Fix: amend primary `spec.md` to add an explicit arbitrator step between Steps 5 and 6, reference `specs/arbitrator.md`, and update Step 6 to reflect that aggregation draws from the arbitrator's action list.

- **[Phase 3 / No contradictions — LOW]** `SKILL.md` S2 instructs the agent to "Crawl `reviewers/` at runtime," consistent with the primary spec's Definitions ("crawling the `reviewers/` directory"). However, `specs/registry-format.md` specifies a single-index-read loading policy from `reviewers/index.md` and explicitly states "No directory crawl is performed." These are contradictory loading models. The primary spec and SKILL.md agree on the crawl model; the sub-spec diverges. Fix: align `specs/registry-format.md` loading policy with the primary spec's crawl definition, or update the primary spec to adopt the index-read model and propagate to SKILL.md.

### Recommendation

Amend `spec.md` to include the arbitrator step in the step sequence, add B8 to the Behavior section, cross-reference the `specs/` sub-specifications, and resolve the crawl-vs-index-read contradiction in `specs/registry-format.md`; then resubmit for audit.
