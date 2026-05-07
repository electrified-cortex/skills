---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: swarm

**Verdict:** FAIL
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — no `instructions.txt` or dispatch instruction file present in skill dir. SKILL.md contains full Step 1–8 procedure. |
| Inline/dispatch consistency | PASS | Full procedure in SKILL.md; appropriate for inline classification. |
| Structure | PASS | Frontmatter present; direct instructions; self-contained. |
| Input/output double-spec (A-IS-1) | N/A | |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | PASS | `name` and `description` present; no extra fields (A-FM-4 pass). |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder in both SKILL.md and uncompressed.md. |
| H1 per artifact (A-FM-3) | FAIL | **HIGH** — SKILL.md contains a real H1 (`# swarm`) at column 0 after frontmatter. SKILL.md MUST NOT contain a real H1. uncompressed.md correctly has H1 (required). |
| No duplication | PASS | No existing skill with equivalent multi-personality swarm review capability identified. |
| Orphan files (A-FS-1) | FAIL | **LOW** — `reviewers/index.yaml` is present in the skill dir but is not referenced by its actual filename in SKILL.md, uncompressed.md, or spec.md. (Correlated with A-FS-2 finding.) |
| Missing referenced files (A-FS-2) | FAIL | **HIGH** — Both SKILL.md and uncompressed.md reference `reviewers/index.md` as the ordered personality manifest. This file does not exist in the skill dir. Actual file present: `reviewers/index.yaml`. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Both consistently describe rolling window of 3 in Step 5 and Default D3. No parity divergence between compiled and uncompressed. Root issue is spec contradiction, not parity. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file exists. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` present and co-located. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present. |
| Normative language | PASS | Requirements use `must` throughout. |
| Internal consistency | PASS | No contradictions detected within spec itself. |
| Spec completeness | PASS | All terms defined; behavior explicitly stated. |
| Coverage | FAIL | Spec Requirement 7 ("single parallel batch; sequential dispatch not permitted") is contradicted rather than faithfully represented. |
| No contradictions | FAIL | **FAIL** — SKILL.md Step 5 and Default D3 state "rolling window of 3" (max 3 in flight; dispatch next as each completes). Spec Step 5, Requirement 7, Default D3, and DN6 all mandate "single parallel batch — all at once; must not issue sequentially." Direct contradiction; spec is authoritative. Same contradiction present in uncompressed.md (not a parity failure — both source and compiled agree with each other, but both contradict spec). |
| No unauthorized additions | FAIL | **FAIL** — Rolling window concurrency limit (max 3 simultaneous) is normative in SKILL.md and uncompressed.md but absent from spec. Spec mandates single-batch all-at-once dispatch; no rolling window concept exists in spec. Constitutes an unauthorized normative addition. |
| Conciseness | FAIL | Caller Tier rationale present (see A-FM-5). |
| Completeness | PASS | All runtime instructions present for covered requirements. |
| Breadcrumbs | PASS | Related section present. External skill refs use bare canonical names (`dispatch`, `compression`). Sub-file refs (`specs/*.md`) are own-folder, exempt from A-XR-1. All referenced `specs/*.md` files confirmed present. |
| Cost analysis | N/A | Inline skill. |
| No dispatch refs | N/A | No instructions.txt. |
| No spec breadcrumbs | PASS | SKILL.md does not reference its own companion `spec.md`. |
| Eval log (informational) | ABSENT | No `eval.md` found; does not affect verdict. |
| Description not restated (A-FM-2) | PASS | No verbatim description restatement in body of any artifact. |
| No exposition in runtime (A-FM-5) | FAIL | **HIGH ×2** — Caller Tier section in both SKILL.md and uncompressed.md contains rationale explaining WHY haiku-class is insufficient: "Orchestration requires judgment-intensive work: constructing self-contained review packet from arbitrary input, evaluating trigger conditions inline against inferred problem traits, synthesizing arbitrator output into host-voice with a confidence rating." This is rationale; it belongs in spec.md exclusively. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels without operational context. |
| No empty sections (A-FM-7) | PASS | No empty leaf headings detected. |
| Iteration-safety placement (A-FM-8) | N/A | No instructions.txt or instructions.uncompressed.md. |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | External skill refs use bare canonical names only. Own sub-file refs exempt. |
| Launch-script form (A-FM-10) | N/A | Inline skill. |
| Return shape declared (DS-1) | N/A | Inline skill. |
| Host card minimalism (DS-2) | N/A | Inline skill. |
| Description trigger phrases (DS-3) | N/A | Inline skill. (A-FM-11 covers trigger phrase for all skills — PASS: description contains `Triggers —`.) |
| Inline dispatch guard (DS-4) | N/A | Inline skill. |
| No substrate duplication (DS-5) | N/A | Inline skill. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill. |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | YAML frontmatter present; `name` and `description` only (A-FM-4 pass). |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | All checks | PASS | Not empty; frontmatter not required; no abs-path leaks; filename does not end in `.spec.md` so spec-section checks N/A. |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | N/A | Not SKILL.md or agent.md; A-FM-12 (Step 1) confirmed: frontmatter present, `name` and `description` mirror SKILL.md exactly. |
| `uncompressed.md` | No abs-path leaks | PASS | |

### Issues

1. **FAIL — No contradictions / No unauthorized additions** (`swarm/SKILL.md`, `swarm/uncompressed.md`): Step 5 and Default D3 in both files describe a rolling window of 3 (dispatch up to 3 at once; as each completes, dispatch the next). Spec mandates a single parallel batch — all personalities issued simultaneously; rolling and sequential dispatch are explicitly forbidden (spec Requirement 7, Step 5, D3, DN6). Rolling window limit is also an unauthorized normative addition absent from spec. Fix: edit `swarm/uncompressed.md` Step 5 and Default D3 to align with spec (single parallel batch, all-at-once), then recompress to `swarm/SKILL.md`.

2. **HIGH — A-FM-3** (`swarm/SKILL.md`): SKILL.md contains a real H1 (`# swarm`) at column 0 after frontmatter. SKILL.md MUST NOT contain a real H1. Fix: recompress `swarm/uncompressed.md` to `swarm/SKILL.md` with H1 stripped.

3. **HIGH — A-FS-2** (`swarm/SKILL.md`, `swarm/uncompressed.md`): Both files reference `reviewers/index.md` as the ordered personality manifest. File does not exist; actual file present is `reviewers/index.yaml`. Fix: rename `reviewers/index.yaml` to `reviewers/index.md` (if YAML format is acceptable as `.md`), or update references in `swarm/uncompressed.md` (and recompress SKILL.md) to `reviewers/index.yaml`.

4. **HIGH — A-FM-5** (`swarm/SKILL.md`): Caller Tier section contains rationale prose explaining why haiku-class is insufficient ("Orchestration requires judgment-intensive work: constructing self-contained review packet from arbitrary input, evaluating trigger conditions inline against inferred problem traits, synthesizing arbitrator output into host-voice with a confidence rating."). Rationale must not appear in runtime artifacts. Fix: edit `swarm/uncompressed.md` Caller Tier to retain only normative statements, then recompress to `swarm/SKILL.md`.

5. **HIGH — A-FM-5** (`swarm/uncompressed.md`): Same rationale prose present in uncompressed.md Caller Tier (source of issue 4). Fix: remove rationale sentence from `swarm/uncompressed.md` Caller Tier section directly.

6. **LOW — A-FS-1** (`swarm/reviewers/index.yaml`): File present in `reviewers/` but not referenced by its actual filename in any source file. Resolved by fix for issue 3.

### Recommendation

Align dispatch batching model with spec (single batch, drop rolling window), resolve `reviewers/index.md` vs `reviewers/index.yaml` name mismatch, strip Caller Tier rationale from both runtime artifacts, and recompress SKILL.md to remove the H1.

FAIL
