---
name: skill-auditing
description: >-
  Specification for auditing skills — the quality rules, compliance checks,
  and cost analysis that govern skill quality in the workspace.
type: spec
---

# Skill Auditing Specification

## Purpose

Define the rules and procedures for auditing skills. The skill auditor is
the source of truth for skill quality. Skill writers conform to the
auditor's rules. The auditor can verify its own skill for compliance
(dogfooding).

## Scope

Applies when auditing an existing skill for quality, compliance, or
optimization. Covers classification verification, structural checks,
cost analysis, and breadcrumb validation.

This is a **dispatch skill** — the audit procedure is context-independent
and should run in an isolated agent via the Dispatch agent pattern.

## Definitions

- **Audit**: Systematic verification of a skill against the skill-writing
  spec and this auditing spec's quality rules.
- **Verdict**: The outcome of an audit — PASS, NEEDS_REVISION, or FAIL.
- **Classification error**: A skill using the wrong execution pattern
  (inline when it should dispatch, or vice versa).
- **Context overhead**: The cost of loading unnecessary context (system
  prompt, conversation history) into a dispatched agent's turns.
- **Routing depth**: How many sub-skills a skill references. Deeper =
  more modular but harder to trace.

## Requirements

1. The auditor **must** execute phases in order: Phase 1 → Phase 2 → Phase 3.
2. Failure at any phase **must** stop the audit — subsequent phases must not execute.
3. The spec **must** contain Purpose, Scope, Definitions, Requirements, and Constraints sections; absence of any → Phase 1 FAIL.
4. Requirements in the spec **must** use enforceable language (must, shall, required); vague normative language → Phase 1 FAIL.
5. SKILL.md **must** represent every normative requirement in the spec; missing coverage → Phase 3 FAIL.
6. SKILL.md **must** not contradict the spec; spec is authoritative.
7. SKILL.md **must** not introduce normative requirements absent from the spec.
8. Every line in SKILL.md **must** affect runtime behavior; design rationale belongs in spec.
9. `instructions.txt` **must** not direct the agent to dispatch other skills; only host agents can dispatch.
10. The auditor **must** write the verdict and full report to `result_file`.
11. The auditor **must** be read-only; it must never modify the skill being audited.
12. Verdict **must** be justified with evidence from the skill files — no unsupported assertions.

## Behavior

The audit executes as a three-phase gate flow. Each phase is a hard gate: failure at any phase
stops all further evaluation and produces a FAIL verdict. Phases do not run in parallel.

On entry, the auditor reads the skill at `skill_path`, determines type (inline or dispatch) by
file-system evidence, then locates the companion spec. If no spec is found and the skill is
dispatch or complex inline, the auditor fails immediately without entering Phase 1.

Phase 1 (Spec Gate) validates the companion spec's structure and normative quality. Phase 2
(Skill Smoke Check) validates SKILL.md structure, classification, and frontmatter. Phase 3
(Spec Compliance Audit) performs deep cross-verification between spec and SKILL.md, including
cost analysis for dispatch skills, markdown hygiene, and instruction file constraints.

On completion, the auditor assigns one of three verdicts (PASS, NEEDS_REVISION, FAIL), writes
the full structured report to `result_file`, and exits without modifying any skill file.

## Defaults and Assumptions

- **Read-only default**: the auditor never modifies any file in the skill folder.
- **One skill per dispatch**: each auditor invocation audits exactly one skill.
- **Auditor disposition**: skeptical and evidence-based; findings must cite file content;
  creative interpretation of intent is not permitted.
- **Spec location default**: companion spec is assumed to be `spec.md` co-located with
  `skill_path`; `spec_path` overrides this.
- **Simple inline exemption**: skills under ~30 lines with no design decisions may omit
  spec.md; these skip Phase 1 entirely.
- **Markdown hygiene scope**: every `.md` file in the skill must report no errors.

## Audit Phases

The audit executes three phases in order. Failure at any phase stops
the audit — subsequent phases do not execute.

### Phase 1 — Spec Gate

Verify the companion spec exists and is structurally sound. This phase
must pass before any skill-level checks.

1. **Spec exists** — `spec.md` must exist in the skill folder (or at
   `spec_path` if provided). Exception: simple inline skills under ~30
   lines with no design decisions may omit the spec — in that case,
   skip to Phase 2.
2. **Required sections** — the spec must contain these sections:
   Purpose, Scope, Definitions, Requirements, Constraints. Missing
   sections → FAIL.
3. **Normative language** — requirements must use enforceable language
   (must, shall, required). Vague terms in normative sections → FAIL.
4. **Internal consistency** — no contradictions between sections. No
   duplicate rules. No normative content in descriptive sections.
5. **Completeness** — all terms used are defined. All behavior is
   explicitly stated, not implied.

If the spec fails any of these checks, the verdict is FAIL with
detail identifying which spec check failed. Do not proceed to Phase 2.

### Phase 2 — Skill Smoke Check

Quick structural verification of the SKILL.md.

1. **Classification** — apply the decision tree from the skill-writing
   spec: "Could someone with no context do this from just the inputs?"
   Yes → should be dispatch. No → should be inline. Flag misclassification.
2. **Inline/dispatch file consistency** — file-system evidence determines
   type: any allowed dispatch instruction file present (`instructions.txt`,
   `<name>.md` in the skill directory, or the instruction file explicitly
   referenced by SKILL.md) → dispatch; no such file found → inline. If
   Check #1 and this check disagree, flag the conflict as a finding but do
   NOT double-fail — note the conflict. If dispatch: verify SKILL.md is a
   short routing card. If inline: verify SKILL.md contains the full
   procedure. Mismatch between file-system evidence and SKILL.md structure
   → FAIL.
3. **Structure** — for inline: has frontmatter (`name`, `description`),
   direct instructions, self-contained. For dispatch: SKILL.md ≤15 lines
   of routing content, an allowed dispatch instruction file exists and is
   reachable, parameters typed with required/optional/defaults, output
   format specified, uses Dispatch agent (isolated).
4. **Frontmatter** — `name` and `description` present and accurate.
5. **No duplication** — skill does not duplicate an existing capability.
   If similar skill exists, recommend merge or distinguish clearly.

If any smoke check fails, the verdict is FAIL. Do not proceed to
Phase 3.

### Phase 3 — Spec Compliance Audit

Deep verification that the SKILL.md faithfully represents the spec.
This is the final quality gate.

1. **Coverage** — every normative requirement in the spec must be
   represented in the SKILL.md. Missing requirements → FAIL.
2. **No contradictions** — SKILL.md must not contradict the spec.
   Spec is authoritative; SKILL.md is subordinate.
3. **No unauthorized additions** — SKILL.md must not introduce
   normative requirements not present in the spec.
4. **Conciseness** — every line in SKILL.md must affect runtime
   behavior. No design rationale (belongs in spec). No redundant
   explanations. Agent-facing density, not human-facing readability.
5. **Completeness** — all runtime instructions present. No implicit
   assumptions. Edge cases addressed or explicitly excluded. Defaults
   stated, not assumed.
6. **Breadcrumbs** — ends with related skills or help topics.
   References are valid (pointed-to resources exist). No stale
   references.
7. **Cost analysis** (dispatch skills only) — uses Dispatch agent
   (zero-context isolation). Instruction file is right-sized (<500
   lines). Sub-skills referenced by pointer, not inlined. Single
   dispatch turn when possible.
8. **Markdown hygiene** — run the `markdown-hygiene` skill; it must
   report no errors on every `.md` file in the skill.
9. **No dispatch refs in instructions** — `instructions.txt` must not
   tell the agent to dispatch other skills. Subagents cannot dispatch;
   only the host agent can. "Related" context references are OK;
   "run this skill" or "dispatch this" → FAIL.
10. **No spec breadcrumbs in runtime** — the runtime surface (SKILL.md
    and `instructions.txt`) must not reference the skill's own companion
    `spec.md`, not as a pointer, breadcrumb, or "see spec.md" hint. The
    compressed runtime is self-contained; pointing the agent at the spec
    invites context inflation and defeats compression. Exception: skills
    whose operation takes a spec as input (e.g. `spec-auditing`,
    `skill-auditing`) may reference `spec.md` files that are the subject
    of the operation — never the skill's own companion spec.

## Verdict Rules

- **PASS**: All three phases pass. Skill is production-ready.
- **NEEDS_REVISION**: Phase 1 and 2 pass, Phase 3 has 1-2 non-critical
  issues. Skill works but has quality gaps. List specific fixes.
- **FAIL**: Any phase fails, or Phase 3 has critical issues
  (classification error, missing instruction file, spec contradiction,
  or structural breakdown). Skill cannot be used reliably until fixed.

## Audit Report Format

```markdown
## Skill Audit: <skill-name>

**Verdict:** PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <path-to-skill>
**Failed phase:** <1 | 2 | 3 | none>

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS/FAIL/SKIP | |
| Required sections | PASS/FAIL | |
| Normative language | PASS/FAIL | |
| Internal consistency | PASS/FAIL | |
| Completeness | PASS/FAIL | |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS/FAIL | |
| Inline/dispatch consistency | PASS/FAIL | |
| Structure | PASS/FAIL | |
| Frontmatter | PASS/FAIL | |
| No duplication | PASS/FAIL | |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS/FAIL | |
| No contradictions | PASS/FAIL | |
| No unauthorized additions | PASS/FAIL | |
| Conciseness | PASS/FAIL | |
| Completeness | PASS/FAIL | |
| Breadcrumbs | PASS/FAIL | |
| Cost analysis | PASS/FAIL/N/A | |
| Markdown hygiene | PASS/FAIL | |
| No dispatch refs | PASS/FAIL/N/A | |
| No spec breadcrumbs | PASS/FAIL | |

### Issues
- <specific issue and fix>

### Recommendation
<one-line summary>
```

## Dispatch Parameters (for the auditor agent)

- `skill_path` (string, required): Absolute path to the SKILL.md to audit
- `result_file` (string, required): Absolute path to write the audit report
- `spec_path` (string, optional): Path to companion spec if not co-located

## Self-Audit

This skill can and should be audited by its own agent. The skill-auditor
dispatch instruction file reads the skill-writing spec as its rule set
and applies this auditing spec's checklist to any skill — including
itself. If the auditor fails its own audit, fix it before auditing others.

## Relationship to Other Skills

- **skill-writing** — the spec this auditor enforces
- **spec-auditing** — audits companion specs (complementary, not overlapping)
- **compression** — exemplar dispatch pattern to compare against

## Tiered Model Strategy

Audits MAY use a tiered model approach to optimize cost. The auditor
skill is model-agnostic — the orchestrating agent chooses the tier per
dispatch.

1. **Iterate tier** — a cheap, fast model class (a "haiku-class"
   model, or any equivalent inexpensive tier the host has available).
   Use for iterative audit-fix cycles: when the auditor returns
   NEEDS_REVISION, fix and re-run at this tier. Repeat until PASS.
2. **Sign-off tier** — a higher-capability default model class (a
   "sonnet-class" model, or any equivalent default tier the host has
   available). Run one final audit at this tier after the iterate tier
   returns PASS. Only a sign-off-tier PASS is production-ready.

Rationale: the iterate tier catches structural and obvious issues
cheaply; the sign-off tier catches subtle compliance gaps. Running
the sign-off tier on every iteration wastes tokens on issues the
iterate tier already found.

Class names (haiku/sonnet/opus) are Anthropic-specific labels used
as a convenient shorthand. Hosts running other model families should
map these to their own inexpensive/default/premium tiers.

## Constraints

- Auditor is read-only — never modifies the skill being audited
- One skill per dispatch — don't batch audit multiple skills
  in one run
- Verdict must be justified with evidence from the skill file
- When in doubt, NEEDS_REVISION over PASS — be adversarial

## Error Handling

- **Target not found** (`skill_path` does not resolve): abort immediately, report FAIL with
  message "skill_path not found: \<path\>". Do not write a partial report.
- **Spec not found** (no `spec_path`, no co-located `spec.md`): if skill is dispatch or
  complex inline, verdict is FAIL with Phase 1 stop. If simple inline (<30 lines), skip
  Phase 1 and proceed to Phase 2.
- **Compression check fails** (instructions.txt missing or empty when SKILL.md indicates
  dispatch): record as Phase 2 FAIL under "Inline/dispatch file consistency".
- **Phase gate fails**: stop evaluation, assign FAIL, include a "Failed phase" field in the
  report, and list all failing checks found within that phase.
- **result_file not writable**: report the error to stdout and exit without altering any
  skill file.

## Precedence Rules

1. `spec.md` is authoritative over `uncompressed.md` and SKILL.md in all content disputes.
2. `uncompressed.md` takes precedence over SKILL.md for procedure detail.
3. `skill-writing/spec.md` governs what constitutes a valid skill structure; this auditing
   spec governs the audit procedure itself.
4. Iterate-tier findings are preliminary; a sign-off-tier PASS is required for
   production-ready status. An iterate-tier PASS alone does not equal production-ready.

## Don'ts

- Do not modify any file in the skill folder — auditor is strictly read-only.
- Do not batch-audit multiple skills in a single dispatch invocation.
- Do not infer intent — verdicts must be grounded in explicit file content.
- Do not skip phases or run them out of order.
- Do not produce a PASS verdict when evidence is ambiguous — use NEEDS_REVISION.
- Do not include dispatch instructions (e.g., "run this skill") in instructions.txt.
- Do not reference skills by inlining their content — use pointers only.
