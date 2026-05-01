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
| Spec exists | PASS | `swarm/spec.md` present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | must/shall throughout Requirements and Constraints |
| Internal consistency | PASS | Primary `spec.md` is internally consistent; terminology inconsistency (`additional_personalities` vs `custom menu`) and undefined `B10` reference are confined to sub-specs, not primary spec |
| Completeness | PASS | All terms used in primary spec are defined; behavior explicitly stated |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Complex multi-step orchestration; spec explicitly mandates inline selection (Step 2 rationale); inline appropriate |
| Inline/dispatch consistency | PASS | No `instructions.txt`; SKILL.md contains full procedure; inline confirmed |
| Structure | PASS | Full step sequence, behavior rules, precedence, constraints present |
| Input/output double-spec (A-IS-1) | PASS | N/A — inline skill; no double-specification of outputs |
| Frontmatter | PASS | `name` and `description` present |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; `uncompressed.md` has H1 on line 1 |
| No duplication | PASS | No equivalent capability found |
| Orphan files (A-FS-1) | LOW | `.gitignore`, `reviewers/index.md`, `specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md` not referenced by filename in SKILL.md or `uncompressed.md`; sub-specs are referenced in `spec.md` (reducing practical concern), but `.gitignore` and `reviewers/index.md` have no such anchor |
| Missing referenced files (A-FS-2) | PASS | `reviewers/<kebab-name>.md` pattern referenced; `devils-advocate.md` and `security-auditor.md` present; no specific missing file |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | NEEDS_REVISION | Spec Definitions section defines `gpt-class` as a valid model class; `gpt-class` is absent from SKILL.md entirely while `reviewers/index.md` uses it; implementors following SKILL.md cannot know `gpt-class` is a valid term |
| No contradictions | PASS | SKILL.md does not contradict primary spec |
| No unauthorized additions | PASS | No normative additions beyond spec |
| Conciseness | PASS | Arrow notation, bullet steps; no prose paragraphs for conditionals; agent-facing density |
| Completeness | PASS | All runtime instructions present; edge cases addressed |
| Breadcrumbs | PASS | `dispatch`, `compression`, `skill-index` listed; all exist |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own `spec.md` |
| Description not restated (A-FM-2) | LOW | `uncompressed.md` line 2 restates the description in expanded form: "Multi-personality review and analysis infrastructure skill. Given any artifact, select applicable reviewer personalities from a runtime-crawled registry, gate each on availability, dispatch surviving set in parallel…" — near-verbatim restatement of frontmatter description |
| No exposition in runtime (A-FM-5) | HIGH | `uncompressed.md` Footguns section (lines 262–280) contains root-cause narratives and background prose ("Why: the naive implementation reads…", "Why: default coding pattern loops…") — rationale belongs in `spec.md`, which already carries an equivalent Footguns section; also line 29 contains rationale tail "This ensures new personalities are available immediately" |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or non-operational descriptor lines found |
| No empty sections (A-FM-7) | PASS | All headings in SKILL.md and `uncompressed.md` have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present in any artifact |
| Iteration-safety pointer form (A-FM-9a) | N/A | Not applicable |
| No verbatim Rule A/B (A-FM-9b) | N/A | Not applicable |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill's `uncompressed.md` or `spec.md` found |
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
| `SKILL.md` | Frontmatter required | PASS | YAML frontmatter present at line 1 |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter required | N/A | Not SKILL.md or agent.md |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
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

- **[Phase 3 — Coverage — MEDIUM]** `gpt-class` is defined in `spec.md` Definitions and used in `reviewers/index.md` (`suggested_models: [sonnet-class, gpt-class]` for Devil's Advocate), but SKILL.md nowhere names `gpt-class` as a valid model class term. An implementor relying only on SKILL.md would not know `gpt-class` is permitted. Fix: add `gpt-class` to the model class enumeration in SKILL.md's Personality Metadata Schema section alongside the existing three classes.

- **[Phase 3 — A-FM-5 — HIGH]** `uncompressed.md` Footguns section (lines 262–280) contains root-cause rationale prose ("Why: the naive implementation…", "Why: error propagation defaults…", "Why: constraint lives only in this spec…", etc.) and background narrative. `spec.md` already carries an equivalent Footguns section. Rationale belongs exclusively in `spec.md`. Fix: remove the Footguns section from `uncompressed.md`; it is redundant with `spec.md` and violates the no-exposition rule for runtime artifacts. Also remove the rationale tail on the Registry loading note ("This ensures new personalities are available immediately").

- **[Phase 3 — A-FM-2 — LOW]** `uncompressed.md` line 2 restates the description frontmatter in near-verbatim expanded form. Fix: replace the opening prose with a brief orientation sentence that does not echo the description, or remove it entirely if the H1 and Key Terms section are sufficient orientation.

- **[Phase 2 — A-FS-1 — LOW]** `reviewers/index.md` is not referenced by filename in SKILL.md or `uncompressed.md`. The file is operationally significant (it IS the personality registry index, referenced by sub-specs), but its filename does not appear in the runtime-facing artifacts. Fix: add a reference to `reviewers/index.md` in the Personality Registry section of `uncompressed.md`.

- **[Phase 2 — A-FS-1 — LOW]** `.gitignore` has no reference in any skill artifact. Standard hygiene file; low concern. No fix required unless team convention mandates suppression.

- **[Sub-spec consistency note — informational]** `reviewers/index.md` references `swarm B10` in the Custom Specialist scope field, but no behavior B10 exists in `spec.md` (behaviors end at B8). `specs/registry-format.md` uses `additional_personalities` as a parameter name in several places, conflicting with the primary spec's `custom menu` terminology. These are sub-spec maintenance issues; fix by aligning sub-spec terminology and adding B10 to `spec.md` or removing the stale reference.

### Recommendation

Remove the Footguns section from `uncompressed.md`, add `gpt-class` to SKILL.md's model class enumeration, and patch the `B10` stale reference and `additional_personalities` terminology inconsistency in the sub-specs.
