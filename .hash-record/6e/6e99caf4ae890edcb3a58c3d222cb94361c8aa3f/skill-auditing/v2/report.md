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

---

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — no `instructions.txt` or dispatch instruction file present; full procedure in SKILL.md |
| Inline/dispatch consistency | PASS | File-system evidence and SKILL.md content agree: inline skill with full step sequence |
| Structure | PASS | Frontmatter present; direct instructions; self-contained |
| Input/output double-specification (A-IS-1) | PASS | No double-spec of output via sub-skill |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skill input surfaces that accept sibling output artifacts |
| Frontmatter | PASS | `name` and `description` present in SKILL.md |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm/` in both SKILL.md and uncompressed.md |
| Valid frontmatter fields (A-FM-4) | PASS | SKILL.md frontmatter contains only `name` and `description` |
| Trigger phrases (A-FM-11) | PASS | Description contains `Triggers -` with comma-separated trigger phrases |
| uncompressed.md frontmatter mirror (A-FM-12) | PASS | `name` and `description` match SKILL.md exactly (case-sensitive) |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; `uncompressed.md` has `# swarm — Uncompressed Reference` at column 0 |
| No duplication | PASS | No duplicate existing capability identified |
| Orphan files (A-FS-1) | PASS | `reviewers/devils-advocate.md` and `reviewers/security-auditor.md` referenced explicitly by filename example in SKILL.md; `reviewers/index.yaml` referenced by name in SKILL.md registry-loading section |
| Missing referenced files (A-FS-2) | PASS | All `specs/*.md` sub-specs exist in `swarm/specs/`; reviewer body files present |

---

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | All requirements, step sequences, constraints, behaviors, defaults, error handling, and precedence rules faithfully represented in both; rolling-window-of-3 concurrency consistent across both |
| instructions.txt ↔ instructions.uncompressed.md | N/A | No instructions files present |

---

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements section uses must/required/shall throughout |
| Internal consistency | FAIL | `gpt-class` defined as a valid model class term in Definitions section; Requirement 12 enumerates "only model class terms (`haiku-class`, `sonnet-class`, `opus-class`) may be used" — creates normative contradiction; see F1 |
| Spec completeness | PASS | Terms defined; behavior explicitly stated; edge cases addressed |
| Coverage | PASS | All 16 normative requirements represented in SKILL.md |
| No contradictions (SKILL.md vs spec) | PASS | SKILL.md aligns with spec Requirement 12; inconsistency is internal to spec |
| No unauthorized additions | PASS | `local-llm` (reserved, v1 out of scope) noted in SKILL.md/uncompressed.md but is documentary, not normative |
| Conciseness | PASS | SKILL.md is dense and agent-skimmable; no rationale prose detected in SKILL.md |
| Completeness | PASS | All runtime instructions present; defaults stated; edge cases addressed |
| Breadcrumbs | PASS | `dispatch` and `compression` referenced by canonical name; `specs/*.md` files all exist on disk |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` present |
| No spec breadcrumbs | PASS | SKILL.md does not reference companion `spec.md`; `specs/*.md` are sub-specs (own sub-files, exempt) |
| Eval log (informational) | ABSENT | No `eval.md` present — does not affect verdict |
| Description not restated (A-FM-2) | PASS | Body prose does not duplicate frontmatter description |
| No exposition in runtime (A-FM-5) | FAIL | Two rationale blocks found in `uncompressed.md`; see H1, H2 |
| No non-helpful tags (A-FM-6) | PASS | No non-operational descriptor lines found |
| No empty sections (A-FM-7) | PASS | No leaf headings with empty bodies |
| Iteration-safety placement (A-FM-8) | N/A | No instructions files |
| Iteration-safety pointer form (A-FM-9a) | N/A | No instructions files |
| No verbatim Rule A/B restatement (A-FM-9b) | N/A | No instructions files |
| Cross-reference anti-pattern (A-XR-1) | PASS | `dispatch` and `compression` referenced by canonical name; `specs/*.md` are own sub-files (exempt) |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill (A-FM-11 covers trigger phrase for all skills) |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

---

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter required | PASS | YAML block present with `name` and `description` |
| `SKILL.md` | No abs-path leaks | PASS | No Windows or Unix root-anchored paths |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter required | PASS | YAML block present, mirrors SKILL.md |
| `uncompressed.md` | No abs-path leaks | PASS | No Windows or Unix root-anchored paths |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md — not required |
| `spec.md` | No abs-path leaks | PASS | No Windows or Unix root-anchored paths |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | Frontmatter | N/A | Not SKILL.md or agent.md — per-file check does not require it |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | Frontmatter | N/A | Not SKILL.md or agent.md — per-file check does not require it |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |

---

### Issues

**F1 — Spec internal consistency — FAIL**
Rule: Step 3 / Internal consistency — "No contradictions between sections."

`spec.md` Definitions section defines `gpt-class` as a normative model class term:
> `gpt-class` (alias for GPT-family models of roughly sonnet-class capability)

`spec.md` Requirement 12 enumerates the complete permitted set as:
> only model class terms (`haiku-class`, `sonnet-class`, `opus-class`) may be used

The word "only" plus explicit three-item enumeration in Requirement 12 creates a normative contradiction with the Definitions section, which defines `gpt-class` as a valid model class term. Consequence: the index.yaml uses `gpt-class` in Devil's Advocate's `suggested_models` — which is correct per Definitions but violates Requirement 12 as written. Agents reading C6/Requirement 12 literally would flag `gpt-class` as an invalid term.

Fix: Amend Requirement 12 to include `gpt-class` in the enumerated list, or remove `gpt-class` from Definitions and index.yaml.

---

**H1 — A-FM-5: Rationale in uncompressed.md Step 2 — HIGH**
Rule: A-FM-5 — "Scan `uncompressed.md` for rationale, 'why this exists,' root-cause narrative, historical notes, or background prose. Any found → HIGH. Rationale belongs exclusively in spec.md."

`uncompressed.md` Step 2 contains the following rationale block:
> "A separate dispatch for personality selection is not used. Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries."

This is design rationale explaining why inline selection is used. It is already present in `spec.md` Step 2. It must not also appear in `uncompressed.md`.

Fix: Remove the rationale sentence ("Rationale: the token cost...revisited if registry grows beyond approximately 20 entries.") from `uncompressed.md` Step 2. Keep the normative instruction only: "Selection logic must be inline within the skill. A separate dispatch for personality selection is not used."

---

**H2 — A-FM-5: Rationale in uncompressed.md Step 4 — HIGH**
Rule: A-FM-5 — same as H1.

`uncompressed.md` Step 4 contains the following rationale block:
> "Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading. Dynamic data loading at dispatch time keeps the skill's base context minimal. This is a normative decision; implementors must not revert to inline prompts."

This is design rationale explaining the sub-skill file architecture decision. It is already present in `spec.md` Step 4. It must not also appear in `uncompressed.md`.

Fix: Remove the entire rationale paragraph from `uncompressed.md` Step 4 (starting "Rationale for sub-skill files..."). Keep the normative instruction: "Only after the swarm is finalized (post-gating) does the skill load the prompt for each surviving personality."
