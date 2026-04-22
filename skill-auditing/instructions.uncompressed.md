# Skill Auditing Instructions

## Dispatch Parameters

- `skill_path` (required): Absolute path to SKILL.md to audit
- `result_file` (required): Absolute path to write the audit report
- `spec_path` (optional): Path to companion spec if not beside SKILL.md
- `--fix` (optional flag): Enable single-pass fix mode against the skill's
  authoritative source files (`uncompressed.md` and `instructions.uncompressed.md`,
  siblings of `skill_path`). Runs only on a NEEDS_REVISION verdict. Refused on
  any candidate with pending git changes (untracked, unstaged, staged, or
  merge-conflicted) and on any path that escapes the skill directory. The
  companion `spec.md`, the `README.md`, and the compiled runtime files
  (`SKILL.md`, `instructions.txt`) are never modified.

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
7. If `--fix` is active **and** the verdict is exactly NEEDS_REVISION, enter the
   Fix Mode procedure below. PASS → nothing to fix; FAIL → fix mode is skipped
   and defects are reported for author action. Fix mode is single-pass; the
   auditor does not re-audit or recompress.

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

File presence is definitive for type: any allowed dispatch instruction file
present (`instructions.txt` or `<name>.md` in the skill directory, or the
instruction file explicitly referenced by SKILL.md) → skill is **dispatch**;
no such file found → skill is **inline**. If Check #1 (Classification) and
this check disagree, flag the conflict as a finding but do NOT double-fail —
note the conflict and let the auditor decide.

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

**Stop gates in routing card** (dispatch only): if SKILL.md contains refusal
conditions, eligibility guards, git-clean checks, or path-escape rules, flag
as NEEDS_REVISION. Finding text: `stop gates belong in instructions.txt, not
the routing card`. Routing card = invocation signature + output format.

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

Named finding patterns to flag:

- **"Too much why"**: prose explaining *why* a rule exists instead of stating
  what to do. "Why" belongs in `spec.md`. Finding text: `too much why —
  move rationale to spec.md`.
- **"Essay not reference card"**: skill reads as continuous prose rather than
  decision trees, tables, or bullet instructions. Finding text: `exposition
  where a decision tree would serve`.
- **"Prose conditionals"**: if/else logic written as prose paragraphs instead
  of a decision tree or table. Finding text: `replace prose conditionals with
  decision tree or table`.

A skill passes conciseness only if an agent can skim it in one pass and know
exactly what to do — no hunting through paragraphs for the operative rule.

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

Report no errors on every `.md` file in the skill.

### 9. No dispatch references in instructions

`instructions.txt` must not tell the agent to dispatch other skills.
Subagents can't dispatch — only the host agent can. References to other
skills as "Related" context are OK. "Run this skill" or "dispatch this" →
FAIL. Remediation: move dispatch steps to SKILL.md.

### 10. No spec breadcrumbs in runtime

SKILL.md and `instructions.txt` must not reference the skill's own
companion `spec.md` — not as a pointer, breadcrumb, or "see spec.md"
hint. The compressed runtime is self-contained; nudging the agent toward
the spec inflates context and defeats compression. Exception: skills
whose operation takes a spec as input (`spec-auditing`, `skill-auditing`)
may reference the `spec.md` under audit — never their own companion
spec. Remediation: delete the reference; if the information is genuinely
needed at runtime, inline it.

## Verdict Rules

- **PASS**: All three phases pass.
- **NEEDS_REVISION**: Phase 1 and 2 pass, Phase 3 has 1-2 non-critical
  issues. List fixes.
- **FAIL**: Any phase fails, or Phase 3 has critical issues.

## Fix Mode (`--fix`, single-pass, source-first)

Fix mode targets the skill's authoritative source files — not the compiled
runtime. The compiled runtime (`SKILL.md`, `instructions.txt`) is regenerated
by the caller via the `compression` skill after the auditor exits. This
preserves the repo's source-of-truth chain (`spec.md` → `uncompressed.md` →
`SKILL.md`).

1. **Eligibility gate.** Enter fix mode only when verdict == NEEDS_REVISION.
   PASS → nothing to fix. FAIL (any phase) → fix mode is skipped; defects are
   reported for author action.
2. **Preflight `result_file` writability.** If unwritable, STOP fix mode and
   exit without modifying anything.
3. **Identify writable candidates.** Only `uncompressed.md` and
   `instructions.uncompressed.md` co-located with `skill_path` are eligible.
   - Reject any candidate path that resolves outside the skill directory
     → STOP `refusing to fix: <path> escapes skill directory`.
   - If neither candidate exists, STOP `no writable source files; fix mode
     unavailable`.
   - Never modify `spec.md`, `README.md`, `SKILL.md`, or `instructions.txt`.
4. **Git-clean check.** For each candidate, verify git status:
   - Untracked, unstaged, staged-but-uncommitted, or merge-conflicted on
     any candidate → STOP `refusing to fix: <path> has pending git changes`.
   - Skill not under git control → STOP `refusing to fix: skill is not under
     git control`.
   - The read-only audit report is still written in either case.
5. **Write the read-only audit report** to `result_file` first; this is the
   commit point. Any fix-pass failure after this leaves the report intact.
6. **Apply fixes** to writable source files only, in severity order:
   1. Critical Phase 3 issues: coverage, contradictions, unauthorized
      additions.
   2. Non-critical Phase 3 issues: conciseness, breadcrumbs, cost analysis,
      dispatch refs, spec breadcrumbs.
   3. Hygiene fixes scoped to the writable candidates only. Hygiene defects
      in `spec.md`, `README.md`, or compiled artifacts are surfaced as
      findings, not auto-fixed.
7. **Never auto-fix:** Phase 1 (spec) defects, defects whose root cause is in
   `spec.md` or `README.md` or a compiled artifact, defects requiring author
   judgment. Surface them as findings.
8. **Append a Fix Mode Addendum** to `result_file`:
   - `Files Modified` — absolute paths of every file the auditor wrote.
   - `Fixes Applied` — per file, what changed and which finding it resolves.
   - `Not Auto-Fixed` — defects deferred to the author.
   - `Next Steps` — instruct the caller to recompress via the `compression`
     skill (`uncompressed.md` → `SKILL.md`, `instructions.uncompressed.md` →
     `instructions.txt`) and re-run the auditor for verification.
9. **Single-pass only.** The auditor does not re-audit and does not invoke
   compression. Multi-pass convergence is the caller's responsibility
   (fix → recompress → re-audit).

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
| No spec breadcrumbs | PASS/FAIL | |

### Issues

- <issue and fix>

### Recommendation

<one line>
```

## Rules

- Read-only by default. Never modify any file unless `--fix` is active and the
  verdict is exactly NEEDS_REVISION.
- With `--fix`: modify only `uncompressed.md` and `instructions.uncompressed.md`
  co-located with `skill_path`. Never `spec.md`, `README.md`, `SKILL.md`, or
  `instructions.txt`. Never any file with pending git changes. Never paths
  outside the skill directory.
- Single-pass only — no in-process re-audit, no recompression. Caller drives
  the next cycle.
- One skill per dispatch.
- Evidence-based verdicts.
- When in doubt, NEEDS_REVISION over PASS.
