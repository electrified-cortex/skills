# Skill Auditor

Read the target skill, evaluate in three phases, write verdict. Failure at any
phase stops the audit.

## Dispatch Parameters

- `skill_path` (required): Absolute path to SKILL.md to audit
- `result_file` (required): Absolute path to write the audit report
- `spec_path` (optional): Path to companion spec if not beside SKILL.md

## Procedure

1. Read the skill at `skill_path`
2. Determine type: inline or dispatch
3. Locate companion spec — check in order:
   a. `spec_path` if provided
   b. `spec.md` in the same directory as `skill_path`
   If not found: simple inline skills (<30 lines) may skip Phase 1; dispatch
   or complex inline → FAIL immediately.
4. Run Phase 1 → Phase 2 → Phase 3 (stop on first failure)
5. Assign verdict
6. Write report to `result_file`

## Phase 1 — Spec Gate

Verify the companion spec is structurally sound. Must pass before any skill-level checks.

### 1. Spec exists

`spec.md` must exist (or `spec_path` must resolve). Exception: simple inline
skills under ~30 lines may skip this phase entirely — proceed to Phase 2.

### 2. Required sections

The spec must contain: Purpose, Scope, Definitions, Requirements,
Constraints. Missing sections → FAIL.

### 3. Normative language

Requirements must use enforceable language (must, shall, required). Vague
terms in normative sections → FAIL.

### 4. Internal consistency

No contradictions between sections. No duplicate rules. No normative content
in descriptive sections.

### 5. Spec completeness

All terms used are defined. All behavior explicitly stated, not implied.

If any Phase 1 check fails → verdict FAIL, report which spec check failed,
do not proceed to Phase 2.

## Phase 2 — Skill Smoke Check

Quick structural verification of the SKILL.md.

### 1. Classification

Apply: "Could someone with no context do this from just the inputs?" Yes →
should be dispatch. No → should be inline. Flag misclassification.

### 2. Inline/dispatch file consistency

File presence is definitive for type: `instructions.txt` present → skill
is **dispatch**; absent → skill is **inline**. If Check #1 (Classification)
and this check disagree (e.g., task seems inline but `instructions.txt`
exists), flag the conflict as a finding but do NOT double-fail — note the
conflict and let the auditor decide.

If dispatch: verify SKILL.md is a short routing card (structural details
in Check #3). If inline: verify SKILL.md contains the full procedure.
Mismatch between file-system evidence and SKILL.md structure → FAIL.

### 3. Structure

**Inline:** frontmatter (`name`, `description`), direct instructions,
self-contained.
**Dispatch:** SKILL.md ≤15 lines routing content. Instruction file exists
and is reachable. Params typed with required/optional/defaults. Output
format specified. Uses Dispatch agent (isolated), not background agent with
host context.

### 4. Frontmatter

`name` and `description` present and accurate.

### 5. No duplication

Not duplicating existing capability. If similar exists, recommend merge or
distinguish.

If any Phase 2 check fails → verdict FAIL, do not proceed to Phase 3.

## Phase 3 — Spec Compliance Audit

Deep verification that the SKILL.md faithfully represents the spec.

### 1. Coverage

Every normative requirement in the spec must be represented in the SKILL.md.
Missing requirements → FAIL.

### 2. No contradictions

SKILL.md must not contradict the spec. Spec is authoritative; SKILL.md is
subordinate.

### 3. No unauthorized additions

SKILL.md must not introduce normative requirements not present in the
spec.

### 4. Conciseness

Every line affects runtime behavior. No rationale in SKILL.md (belongs in
spec). No redundant explanations. Agent-facing density.

### 5. Skill completeness

All runtime instructions present. No implicit assumptions. Edge cases
addressed or excluded. Defaults stated.

### 6. Breadcrumbs

Ends with related skills/topics. References are valid (targets exist). No
stale references.

### 7. Cost analysis (dispatch only)

Uses Dispatch agent (zero-context isolation). Instruction file right-sized
(<500 lines). Sub-skills referenced by pointer, not inlined. Single dispatch
turn when possible.

### 8. Markdown hygiene

All `.md` files in the skill folder should pass `npx markdownlint-cli2`.
Zero errors on uncompressed.md, spec.md, instructions.uncompressed.md.
Compressed files (SKILL.md, instructions.txt) are exempt.

### 9. No dispatch references in instructions

`instructions.txt` must not tell the agent to dispatch other skills.
Subagents can't dispatch — only the host agent can. References to other
skills as "Related" context are OK. "Run this skill" or "dispatch this" →
FAIL. Remediation: move dispatch steps to SKILL.md.

## Verdict Rules

- **PASS**: All three phases pass.
- **NEEDS_REVISION**: Phase 1 and 2 pass, Phase 3 has 1-2 non-critical
  issues. List fixes.
- **FAIL**: Any phase fails, or Phase 3 has critical issues.

## Report Format

```markdown
## Skill Audit: <skill-name>

**Verdict:** PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <path>
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

- <issue and fix>

### Recommendation

<one line>
```

## Rules

- Read-only. Never modify the skill.
- One skill per dispatch.
- Evidence-based verdicts.
- When in doubt, NEEDS_REVISION over PASS.
