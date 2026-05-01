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
| Spec exists | PASS | `swarm/spec.md` found |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use "must", "shall", "required" throughout |
| Internal consistency | PASS | No contradictions or duplicate rules detected |
| Completeness | PASS | All terms defined; behaviors explicitly stated |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Multi-step orchestration requiring runtime decision logic — inline is appropriate |
| Inline/dispatch consistency | PASS | No `instructions.txt`; SKILL.md contains full procedure; consistent with inline type |
| Structure | PASS | SKILL.md contains full inline procedure with step sequence, behaviors, precedence, constraints |
| Input/output double-spec (A-IS-1) | N/A | Inline skill |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; `uncompressed.md` has H1; no `instructions.txt` present |
| No duplication | PASS | No existing skill duplicates this capability |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All normative requirements from spec are represented in SKILL.md |
| No contradictions | PASS | SKILL.md does not contradict spec |
| No unauthorized additions | PASS | No normative rules added beyond spec |
| Conciseness | FAIL | Footguns section in SKILL.md is rationale prose; S2 inline rationale note; see A-FM-5 |
| Completeness | PASS | All runtime instructions present; edge cases addressed in Behaviors |
| Breadcrumbs | FAIL | No Related section at end of SKILL.md; no related skills or topics listed |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` |
| No spec breadcrumbs | PASS | Neither SKILL.md nor `uncompressed.md` reference companion `spec.md` |
| Description not restated (A-FM-2) | PASS | No verbatim description duplication in body |
| No exposition in runtime (A-FM-5) | FAIL | Footguns section and S2 rationale note in SKILL.md; Rationale paragraphs in `uncompressed.md` Steps 2 and 4 |
| No non-helpful tags (A-FM-6) | FAIL | `uncompressed.md` opens with meta-architectural descriptor "`swarm` is infrastructure only" |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference |
| Cross-reference anti-pattern (A-XR-1) | PASS | No pointers to another skill's `uncompressed.md` or `spec.md` in SKILL.md or `uncompressed.md` |
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
| `SKILL.md` | Frontmatter | PASS | `---` block at line 1 with `name` and `description` |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
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

### Orphan Files (A-FS-1)

| File | Result | Notes |
| --- | --- | --- |
| `specs/arbitrator.md` | LOW | Not referenced in SKILL.md or `uncompressed.md`; referenced only from other `specs/` files |
| `specs/dispatch-integration.md` | LOW | Not referenced in SKILL.md or `uncompressed.md` |
| `specs/glossary.md` | LOW | Not referenced in SKILL.md or `uncompressed.md` |
| `specs/personality-file.md` | LOW | Not referenced in SKILL.md or `uncompressed.md` |
| `specs/registry-format.md` | LOW | Not referenced in SKILL.md or `uncompressed.md` |

### Issues

- **[HIGH, A-FM-5, Phase 3] Exposition in SKILL.md — Footguns section**: The `## Footguns` section (F1–F8) in `SKILL.md` contains rationale narrative explaining why footguns occur and how to avoid them. This is design rationale, not runtime instructions. Remove the entire Footguns section from `SKILL.md`; it belongs in `spec.md` (where a Footguns section already exists).

- **[HIGH, A-FM-5, Phase 3] Exposition in SKILL.md — S2 rationale note**: Step S2 ends with "Selection is inline — no separate dispatch. Revisit if registry exceeds ~20 entries." This is a design rationale comment, not an operative instruction. Remove this note from `SKILL.md`; the rationale already lives in `spec.md` Step 2.

- **[HIGH, A-FM-5, Phase 3] Exposition in `uncompressed.md` — Rationale paragraphs**: Step 2 contains a "Rationale:" paragraph explaining the token cost of selection dispatch. Step 4 contains a "Rationale:" paragraph explaining why inline prompts bloat context. Both are design rationale that belongs in `spec.md` only. Remove these paragraphs from `uncompressed.md`.

- **[LOW, A-FM-6, Phase 3] Non-helpful meta-architectural descriptor in `uncompressed.md`**: The opening lines "`swarm` is infrastructure only. Consumer skills (e.g., `code-review`) call into it. The two have a strict consumer-service relationship; swarm must not merge with or replace any consumer skill." describe the skill's role rather than instructing the agent what to do. Remove or replace with a direct operative constraint if the boundary needs enforcement.

- **[FAIL, Breadcrumbs, Phase 3] No Related section**: `SKILL.md` does not end with a Related section linking to related skills or topics. Add a `## Related` section referencing at minimum the `dispatch` skill.

- **[LOW, A-FS-1, Phase 2] Orphan `specs/` sub-files**: Five sub-spec files (`specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`) are not referenced from `SKILL.md` or `uncompressed.md`. Either add references in the appropriate artifacts or acknowledge these as companion spec annexes (and note them in `spec.md` as such).

### Recommendation

Remove the Footguns section and inline rationale notes from `SKILL.md`, strip the Rationale paragraphs from `uncompressed.md`, and add a Related breadcrumb section to `SKILL.md`.
