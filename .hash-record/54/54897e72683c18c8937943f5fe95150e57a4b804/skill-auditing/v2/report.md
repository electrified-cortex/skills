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
| Classification | PASS | Inline confirmed by file-system evidence (no `instructions.txt` or dispatch name file present). Complex orchestrator but procedure is self-contained in SKILL.md — inline is correct. |
| Inline/dispatch consistency | PASS | No instructions.txt; SKILL.md contains full 8-step procedure. |
| Structure | PASS | Frontmatter present; full procedure, constraints, behavior, defaults, error handling, precedence, related — all present. |
| Input/output double-spec (A-IS-1) | PASS | Inputs (`problem`, `personality_filter`, `model_overrides`) don't duplicate sub-skill output paths. |
| Sub-skill input isolation (A-IS-2) | PASS | No sub-skill input surface accepting sibling sub-skill output artifacts. |
| Frontmatter | PASS | `name` and `description` present in SKILL.md. |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm/` in both SKILL.md and uncompressed.md. |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1 (section labels are plain text, not `^# `). uncompressed.md has `# swarm — Uncompressed Reference`. |
| No duplication | PASS | No overlap with existing skills; delegates launch primitive to `dispatch` skill. |
| Orphan files (A-FS-1) | PASS | All files in skill dir are referenced: reviewers/*.md and index.yaml by pattern in Step 4/registry sections; specs/*.md in Related section. |
| Missing referenced files (A-FS-2) | PASS | All explicitly named files exist: `reviewers/index.yaml`, `reviewers/devils-advocate.md`, `reviewers/security-auditor.md`, `specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`. |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | (1) Description mismatch: SKILL.md uses `Triggers -` (hyphen), uncompressed.md uses `Triggers —` (em dash) — A-FM-12 FAIL. (2) KNOWN/INTENTIONAL: SKILL.md Step 5 / D3 implement rolling window of 3; uncompressed.md Step 5 / D3 state single parallel batch. Operator-approved concurrency fix; spec update pending. Mark as KNOWN/INTENTIONAL, not a parity fault. |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instructions.txt; inline skill. |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` co-located with skill dir. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements (1–16), Constraints — all present. |
| Normative language | PASS | Requirements use must/shall/required/must not throughout. |
| Internal consistency | PASS | No contradictions within spec. D3 and Req 7 both say single parallel batch consistently inside the spec. |
| Spec completeness | PASS | All 16 requirements, B1–B8, C1–C8, D1–D6, E1–E5, P1–P5, DN1–DN12 defined. All terms defined. |
| Coverage | PASS | All 16 spec requirements represented in SKILL.md. (Rolling window / Req 7 deviation is KNOWN/INTENTIONAL per operator approval.) |
| No contradictions | PASS | SKILL.md does not contradict spec except the KNOWN/INTENTIONAL rolling-window deviation. |
| No unauthorized additions | PASS | SKILL.md introduces no normative requirements absent from spec. |
| Conciseness | PASS | SKILL.md is telegraphic; section labels are plain text; content is decision-tree and table style. |
| Completeness | PASS | All runtime instructions present; defaults stated; edge cases addressed or explicitly excluded. |
| Breadcrumbs | PASS | Related section points to `dispatch`, `compression`, and all five sub-specs. All targets exist in skill dir or as named skills. |
| Cost analysis | N/A | Inline skill. |
| No dispatch refs | N/A | No instructions.txt. |
| No spec breadcrumbs | PASS | SKILL.md Related section references sub-specs within the skill dir, not the skill's own `spec.md`. |
| Eval log (informational) | ABSENT | No `eval.md` / `eval.txt` found. Does not affect verdict. |
| Description not restated (A-FM-2) | PASS | No body prose duplicates the description frontmatter verbatim in SKILL.md or uncompressed.md. |
| No exposition in runtime (A-FM-5) | FAIL | uncompressed.md contains two rationale blocks in the executor body — see Issues. |
| No non-helpful tags (A-FM-6) | PASS | No bare type labels or descriptor lines without operational value found. |
| No empty sections (A-FM-7) | PASS | All sections contain body content. |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety blurb present in any artifact. |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety references. |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety references. |
| Cross-reference anti-pattern (A-XR-1) | PASS | Cross-skill refs (`dispatch`, `compression`) carry canonical names. Sub-spec refs are own-folder files — exempt. |
| Launch-script form (A-FM-10) | N/A | Inline skill. |
| Return shape declared (DS-1) | N/A | Inline skill. |
| Host card minimalism (DS-2) | N/A | Inline skill. |
| Description trigger phrases (DS-3) | N/A | Dispatch-only check. A-FM-11 covers trigger presence for all skills — see Step 1 frontmatter row. |
| Inline dispatch guard (DS-4) | N/A | Inline skill. |
| No substrate duplication (DS-5) | N/A | Inline skill. |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill. |

**Additional check — A-FM-11 (trigger phrases, all skills):** PASS. SKILL.md description contains `Triggers -` with comma-separated trigger phrases. uncompressed.md uses `Triggers —` (em dash) — fails A-FM-11 substring match, but this is already captured by the A-FM-12 FAIL.

**Additional check — A-FM-4 (valid frontmatter fields, SKILL.md):** PASS. SKILL.md frontmatter contains only `name` and `description`.

**Additional check — A-FM-12 (uncompressed.md frontmatter mirror):** FAIL. See Issues #1.

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter (required) | PASS | `name` and `description` present. |
| `SKILL.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md/agent.md. |
| `spec.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter (required) | PASS | `name` and `description` present. |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | Frontmatter | N/A | Not SKILL.md/agent.md. |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | Frontmatter | N/A | Not SKILL.md/agent.md. |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | All checks | PASS | Non-empty; no abs-path leaks. |
| `specs/dispatch-integration.md` | All checks | PASS | Non-empty; no abs-path leaks. |
| `specs/glossary.md` | All checks | PASS | Non-empty; no abs-path leaks. |
| `specs/personality-file.md` | All checks | PASS | Non-empty; no abs-path leaks. |
| `specs/registry-format.md` | All checks | PASS | Non-empty; no abs-path leaks. |

### Issues

**#1 — A-FM-12 [FAIL]: uncompressed.md description does not match SKILL.md (hyphen vs em dash)**

`uncompressed.md` frontmatter `description` ends with `Triggers — swarm review, ...` (em dash U+2014). `SKILL.md` frontmatter `description` ends with `Triggers - swarm review, ...` (hyphen U+002D). A-FM-12 requires an exact case-sensitive match. These do not match.

Fix: change `uncompressed.md` description to use `Triggers -` (hyphen) to match `SKILL.md` exactly, then recompress `SKILL.md` from the corrected `uncompressed.md`.

**#2 — A-FM-5 [HIGH]: uncompressed.md Step 2 contains rationale prose**

`uncompressed.md` body, Step 2 — Select personalities, includes:

> "Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries."

Rationale belongs exclusively in `spec.md`. It is already present there (Step 2 section). Remove from `uncompressed.md`.

Fix: delete the Rationale paragraph from `uncompressed.md` Step 2; verify `spec.md` already contains it (confirmed).

**#3 — A-FM-5 [HIGH]: uncompressed.md Step 4 contains rationale prose**

`uncompressed.md` body, Step 4 — Load reviewer prompts, includes:

> "Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading. Dynamic data loading at dispatch time keeps the skill's base context minimal. This is a normative decision; implementors must not revert to inline prompts."

Rationale belongs exclusively in `spec.md`. Remove from `uncompressed.md`.

Fix: delete the Rationale paragraph from `uncompressed.md` Step 4; move to `spec.md` if not already captured there.

---

**KNOWN/INTENTIONAL (not a finding): rolling window of 3 vs single parallel batch**

`SKILL.md` Step 5 and D3 implement a rolling window of maximum 3 concurrent dispatches. `uncompressed.md` Step 5 / D3 and `spec.md` Requirement 7 state "single parallel batch." This is an operator-approved concurrency fix (prevents runaway sub-agent spawning). Spec update is pending. Not scored as a parity failure or coverage failure.
