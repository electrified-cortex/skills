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
8. **Markdown hygiene** — all `.md` files in skill folder pass
   markdownlint. Compressed files (SKILL.md, instructions.txt) exempt.
9. **No dispatch refs in instructions** — `instructions.txt` must not
   tell the agent to dispatch other skills. Subagents cannot dispatch;
   only the host agent can. "Related" context references are OK;
   "run this skill" or "dispatch this" → FAIL.

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

Audits CAN use a tiered model approach to optimize cost:

1. **Haiku passes** — use Haiku (cheapest model) for iterative
   audit-fix cycles. When the auditor returns NEEDS_REVISION,
   fix the issues and re-run with Haiku. Repeat until Haiku
   returns PASS.
2. **Sonnet final** — after Haiku passes, run one final audit
   with Sonnet (higher-capability model) as the sign-off pass.
   Only Sonnet PASS is production-ready.

Rationale: Haiku catches structural and obvious issues cheaply.
Sonnet catches subtle compliance gaps. Running Sonnet on every
iteration wastes tokens on issues Haiku already found.

The orchestrating agent (not the auditor itself) controls which
model is used per dispatch. The auditor skill is model-agnostic.

## Constraints

- Auditor is read-only — never modifies the skill being audited
- One skill per dispatch — don't batch audit multiple skills
  in one run
- Verdict must be justified with evidence from the skill file
- When in doubt, NEEDS_REVISION over PASS — be adversarial
