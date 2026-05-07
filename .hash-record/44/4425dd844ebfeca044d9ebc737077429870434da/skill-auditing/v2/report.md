---
operation_kind: skill-auditing/v2
result: fail
skill: swarm
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
---

# Result

**Verdict: FAIL**

Two FAIL-level findings: spec normative requirements missing from compiled SKILL.md, and built-in personality body files lack required YAML frontmatter, breaking the metadata-validation gate at runtime.

---

## Per-file Findings

### SKILL.md

- Not empty ✓
- Frontmatter present (`name`, `description` only) ✓
- A-FM-1: `name: swarm` matches folder name ✓
- A-FM-4: Valid frontmatter fields only ✓
- A-FM-11: Trigger phrases present in description ✓
- A-FM-3: No real H1 in SKILL.md ✓
- A-FM-12: uncompressed.md frontmatter name and description match exactly ✓
- No absolute-path leaks ✓

### uncompressed.md

- Not empty ✓
- Frontmatter present, matches SKILL.md ✓
- A-FM-3: Real H1 present (`# swarm — Uncompressed Reference`) ✓
- No absolute-path leaks ✓
- **[HIGH — A-FM-5]** Step 2 contains explicit rationale paragraph: begins "Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries." Rationale belongs exclusively in spec.md.
- **[HIGH — A-FM-5]** Step 4 contains explicit rationale paragraph: begins "Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading..." Rationale belongs exclusively in spec.md.

### spec.md

- Not empty ✓
- Required spec sections present: Purpose ✓, Scope ✓, Definitions ✓, Requirements (R1–R16) ✓, Constraints ✓
- Normative language (must/shall/required) used throughout ✓
- No absolute-path leaks ✓

### reviewers/devils-advocate.md

- Not empty ✓
- No absolute-path leaks ✓
- Frontmatter: basic checks require frontmatter only for SKILL.md and agent.md — not flagged here. Flagged under Step 3 (spec violation; see F2).

### reviewers/security-auditor.md

- Not empty ✓
- No absolute-path leaks ✓
- Same frontmatter note as above (see F2).

---

## Step 1 — Compiled Artifacts

**Skill type**: Inline. No `instructions.txt`, `swarm.md`, or dispatch-target file present. SKILL.md contains a full 8-step procedure. File-system evidence confirms inline classification. Classification consistent with content.

**A-FS-1 — Orphan files**: All non-well-known files in the skill directory are referenced by name or relative path in SKILL.md, uncompressed.md, or spec.md:
- `reviewers/devils-advocate.md` — referenced (Step 4 filename example) ✓
- `reviewers/security-auditor.md` — referenced (Step 4 filename example) ✓
- `reviewers/index.yaml` — referenced ("ordered manifest") ✓
- `specs/arbitrator.md` — referenced ✓
- `specs/dispatch-integration.md` — referenced ✓
- `specs/glossary.md` — referenced ✓
- `specs/personality-file.md` — referenced ✓
- `specs/registry-format.md` — referenced ✓

No orphan files. ✓

**A-FS-2 — Missing referenced files**: All explicitly named sibling files exist on disk. ✓

---

## Step 2 — Parity Check

`uncompressed.md` present; parity check performed.

**[HIGH — Parity Failure — F1 overlap]** SKILL.md omits the following normative sections present in uncompressed.md:

- **Behavior (B1–B8)**: error return conditions for empty problem (B1) and empty swarm (B2); single-personality swarm handling (B3); non-contributing personality treatment (B4); all-no-findings synthesis (B5); Devil's Advocate dispatch guarantee (B6); custom menu trigger evaluation (B7); cross-vendor diversity best-effort (B8).
- **Defaults (D1–D6)**: default personality_filter (D1); default model class (D2); dispatch default (D3, which also carries the known deviation note); default model_overrides (D4); custom-menu model fallback (D5); confidence rating calibration with worked examples (D6).
- **Error Handling (E1–E5)**: probe failure handling (E1); empty swarm error (E2); individual dispatch failure treatment (E3); packet assembly failure (E4); synthesis word-budget truncation order (E5).
- **Precedence Rules (P1–P5)**: personality_filter override of triggers (P1); model_overrides override of registry (P2); availability gate override of selection (P3); read-only constraint override of personality prompts (P4); word-budget override of completeness (P5).

An agent executing from SKILL.md alone lacks all behavioral rules for edge cases, error conditions, and precedence. `Fix: edit uncompressed.md to confirm these sections are current, then recompress to SKILL.md.`

**Other parity notes (passing)**:
- Key Terms content aligns between documents (gpt-class absent from both — see L1; otherwise consistent). ✓
- Step sequence (Steps 1–8) aligns with appropriate compression in SKILL.md. ✓
- Constraints C1, C2, C4–C6 present in both. C3 intentionally absent from both — C3 is a known-limitation note (prompt enforcement caveat); belongs in spec. ✓
- Known deviation K1 in place: rolling window of 3 (both documents) vs spec's single-batch requirement. Operator-approved; spec update pending. ✓

---

## Step 3 — Spec Alignment

**Required spec sections**: Purpose ✓, Scope ✓, Definitions ✓, Requirements ✓, Constraints ✓. All present and substantive.

**Normative language**: enforceable language (must/shall/required) used throughout. ✓

**[FAIL — F1] Coverage: normative Behavior/Defaults/Error Handling/Precedence sections absent from SKILL.md**

Spec.md contains normative Behavior (B1–B8), Defaults (D1–D6), Error Handling (E1–E5), and Precedence (P1–P5) sections with numbered rules. None are represented in SKILL.md. Per auditing rules: every normative spec requirement must appear in the compiled artifact. Missing → FAIL.

**[FAIL — F2] Personality file frontmatter absent**

Spec Personality Metadata Schema states: "Each `reviewers/<name>.md` MUST begin with YAML frontmatter block" with required fields `name`, `trigger`, `required`, `suggested_models`, `suggested_backends`, `scope`. Both `reviewers/devils-advocate.md` and `reviewers/security-auditor.md` begin with an H1 heading followed by body prompt content — no YAML frontmatter block is present in either file.

Per the metadata-validation gate definition in SKILL.md: "File failing validation silently skipped." Both files fail the gate and would be silently dropped at runtime, leaving the built-in personality registry empty (Custom Specialist, which has no body file, is the only remaining entry). This breaks core swarm functionality.

Note: all metadata for both personalities IS present in `reviewers/index.yaml`. The design appears to have split metadata (index.yaml) from body content (.md files), but the spec was not updated to reflect this. See also H4 (metadata source ambiguity).

**[HIGH — H4] Metadata source ambiguity (internal inconsistency)**

SKILL.md states metadata-validation gate checks each `.md` file in `reviewers/` for required frontmatter fields. SKILL.md simultaneously states `reviewers/index.yaml` is the "ordered manifest — provides metadata and ordering for personalities discovered during crawl." These two metadata sources are not reconciled in SKILL.md, uncompressed.md, or spec.md:

- If index.yaml is authoritative, per-file frontmatter is unnecessary — but spec requires it.
- If per-file frontmatter is authoritative, index.yaml is redundant — but both body files lack frontmatter.
- Current state: index.yaml has all metadata; body files have none; spec requires body-file frontmatter.

The spec is silent on index.yaml entirely (see H5). Resolution requires either: (a) removing frontmatter requirement from spec and designating index.yaml as the metadata source, or (b) adding frontmatter to body files and clarifying index.yaml's role as an ordering hint only.

**[HIGH — H5] Unauthorized addition: index.yaml as ordered manifest**

SKILL.md and uncompressed.md introduce `reviewers/index.yaml` as an "ordered manifest — provides metadata and ordering for personalities discovered during crawl." This concept is entirely absent from spec.md. Spec describes the registry only as "the `reviewers/` directory, crawled at invocation time" with no mention of an index file.

Designating a specific file as the authoritative metadata and ordering source is a normative behavioral requirement — it affects crawl output order and is the de facto metadata source given body files lack frontmatter. This requires a spec amendment before it can appear in SKILL.md.

**[KNOWN/INTENTIONAL — K1] Rolling window of 3 vs single parallel batch**

SKILL.md Step 5 and D3, and uncompressed.md Step 5, specify: "Maximum concurrency: rolling window of 3. Dispatch up to 3 personalities in parallel; as each completes, dispatch the next until all personalities have run."

Spec R7: "All swarm personalities must be dispatched in a single parallel batch; sequential dispatch is not permitted."
Spec D3: "Default for parallel vs sequential dispatch: parallel (all at once, single batch)."

This deviation is operator-approved; spec update is pending. Not a FAIL — marked KNOWN/INTENTIONAL only.

**No other contradictions**: SKILL.md is subordinate to spec and does not introduce conflicting normative rules beyond K1. ✓

**Breadcrumbs**: uncompressed.md ends with a comprehensive Related section referencing the `dispatch` skill, `compression` skill, and all five sub-specs. SKILL.md has no Related section — cross-skill navigation is absent from the compiled artifact. See L2.

**[LOW — L1] gpt-class undefined in runtime documents**

Spec Definitions includes `gpt-class` as a model class alias ("alias for GPT-family models of roughly sonnet-class capability"). Neither SKILL.md nor uncompressed.md Key Terms defines `gpt-class`. The term appears in `reviewers/index.yaml` under `suggested_models` for Devil's Advocate (`[sonnet-class, gpt-class]`). An agent reading SKILL.md would encounter an undefined model class term via the registry.

**[LOW — L2] SKILL.md missing Related breadcrumbs**

SKILL.md ends at the Constraints section with no Related or breadcrumb section. uncompressed.md provides a full Related section. Cross-skill navigation (dispatch, compression, sub-specs) is absent from the compiled artifact an agent will use at runtime.

---

## Summary of Findings

| ID | Step / Check | Severity | Description |
| --- | --- | --- | --- |
| F1 | Step 2 Parity + Step 3 Coverage | **FAIL** | SKILL.md missing normative B1–B8, D1–D6, E1–E5, P1–P5 sections from spec and uncompressed.md |
| F2 | Step 3 Coverage | **FAIL** | reviewers/devils-advocate.md and reviewers/security-auditor.md lack required YAML frontmatter; both silently skipped by metadata-validation gate at runtime |
| H1 | Per-file / A-FM-5 | HIGH | uncompressed.md Step 2: explicit "Rationale:" paragraph; belongs in spec.md only |
| H2 | Per-file / A-FM-5 | HIGH | uncompressed.md Step 4: "Rationale for sub-skill files" paragraph; belongs in spec.md only |
| H3 | Step 2 Parity | HIGH | SKILL.md missing all Behavior, Defaults, Error Handling, Precedence sections present in uncompressed.md (detailed in F1 above; cited separately as parity failure) |
| H4 | Step 3 Internal consistency | HIGH | Metadata source ambiguity: per-file frontmatter validation gate vs index.yaml as manifest — not reconciled in SKILL.md, uncompressed.md, or spec.md |
| H5 | Step 3 Unauthorized addition | HIGH | index.yaml as "ordered manifest" introduced in SKILL.md and uncompressed.md; absent from spec.md; normative change requires spec amendment |
| K1 | Step 3 R7 + D3 | KNOWN/INTENTIONAL | Rolling window of 3 (SKILL.md/uncompressed.md) vs spec "single parallel batch"; operator-approved, spec update pending |
| L1 | Step 3 Coverage | LOW | gpt-class defined in spec Definitions; omitted from SKILL.md and uncompressed.md Key Terms; used in index.yaml without a runtime definition |
| L2 | Step 3 Breadcrumbs | LOW | SKILL.md has no Related section; cross-skill navigation absent from compiled artifact |

---

## Verdict

**FAIL**

Primary blockers:

- **F1** — SKILL.md is missing all normative Behavior (B1–B8), Defaults (D1–D6), Error Handling (E1–E5), and Precedence (P1–P5) sections. Every normative spec requirement must appear in the compiled artifact.
- **F2** — Both built-in personality body files (`reviewers/devils-advocate.md`, `reviewers/security-auditor.md`) lack required YAML frontmatter. Per the metadata-validation gate, both would be silently skipped at runtime, leaving no loadable built-in reviewers.
