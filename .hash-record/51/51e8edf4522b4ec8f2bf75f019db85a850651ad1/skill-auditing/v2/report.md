---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline: no instructions.txt, no dispatch wiring; SKILL.md contains full procedure; host-executed explicitly stated |
| Inline/dispatch consistency | PASS | File-system evidence (no instructions.txt) matches inline classification |
| Structure | PASS | Frontmatter present; full step sequence inline; self-contained |
| Input/output double-spec (A-IS-1) | PASS | N/A — no sub-skill output path duplication |
| Sub-skill input isolation (A-IS-2) | N/A | Inline skill; no sub-skill dispatches in skill surface |
| Frontmatter | PASS | `name` and `description` present in both SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm/` in both SKILL.md and uncompressed.md |
| H1 per artifact (A-FM-3) | PASS | SKILL.md: no H1 (correct); uncompressed.md: H1 present (correct) |
| No duplication | PASS | No equivalent skill found |
| Orphan files (A-FS-1) | PASS | All files in swarm/ referenced: `reviewers/index.yaml` referenced in SKILL.md and uncompressed.md; `reviewers/*.md` referenced generically in Step 4; `specs/*.md` referenced in SKILL.md Related section and spec.md Sub-specifications section |
| Missing referenced files (A-FS-2) | PASS | All files referenced by name exist: `specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`, `reviewers/index.yaml`, `reviewers/devils-advocate.md`, `reviewers/security-auditor.md` all present |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | SKILL.md Related section contains 5 entries absent from uncompressed.md: `specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`. Compiled artifact has MORE content than its source. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Inline skill; no instructions.txt |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` present co-located with skill |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall throughout |
| Internal consistency | PASS | No contradictions between sections |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | PASS | All 16 spec requirements represented in SKILL.md |
| No contradictions | PASS | SKILL.md aligns with spec; no normative conflicts |
| No unauthorized additions | PASS | Scope Boundaries section in SKILL.md mirrors spec Scope; no new normative requirements introduced |
| Conciseness | PASS | SKILL.md is dense reference-card format; steps and rules scannable |
| Completeness | PASS | All runtime instructions present; error handling, precedence, defaults, behavior rules all covered |
| Breadcrumbs | PASS | Related section valid; `dispatch` and `compression` canonical names present; own sub-files referenced by path (permitted) |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | Inline skill; no instructions.txt |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own `spec.md`; sub-spec paths (`specs/arbitrator.md` etc.) are own sub-files, not the companion spec |
| Eval log (informational) | ABSENT | No `eval.md` present — does not affect verdict |
| Description not restated (A-FM-2) | PASS | Body prose does not restate the description frontmatter value |
| No exposition in runtime (A-FM-5) | PASS | No rationale or "why" prose in SKILL.md or uncompressed.md |
| No non-helpful tags (A-FM-6) | FAIL | "This skill is host-executed. The host agent reads and follows these steps directly." in both SKILL.md and uncompressed.md is a descriptor label; "Never dispatch this skill as a sub-agent" is the actionable constraint and should stand alone |
| No empty sections (A-FM-7) | PASS | All sections have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference |
| Cross-reference anti-pattern (A-XR-1) | PASS | Cross-skill references use canonical names (`dispatch`, `compression`); own sub-file paths within swarm/ are exempt |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill; A-FM-11 applies instead |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter (required) | PASS | YAML block at line 1 with `name` and `description` only (A-FM-4 PASS) |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter (required) | PASS | YAML block at line 1; name and description match SKILL.md exactly (A-FM-12 PASS) |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | Frontmatter | N/A | Reviewer body file; frontmatter is optional per specs/personality-file.md |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | Frontmatter | N/A | Reviewer body file |
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

- **[HIGH — Parity failure, Step 2]** SKILL.md Related section contains five sub-spec path references (`specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`) not present in `uncompressed.md`. The compiled artifact has MORE content than its uncompressed source, indicating `uncompressed.md` was not updated before recompression. Fix: edit `uncompressed.md` to add a Related section that includes these five sub-spec pointers (plus the existing `dispatch` and `compression` entries), then recompress to `SKILL.md`.

- **[LOW — A-FM-6, Step 3]** "This skill is host-executed. The host agent reads and follows these steps directly." in both SKILL.md and uncompressed.md is a descriptor label with no operational effect — the agent reads and follows any SKILL.md it is given. The actionable constraint ("Never dispatch this skill as a sub-agent — it cannot orchestrate further dispatches from a leaf position") should stand alone. Fix: remove the descriptor sentence; retain only the constraint.

### Recommendation

Add missing sub-spec Related entries to `uncompressed.md` and recompress; remove non-helpful descriptor sentence from both artifacts.
