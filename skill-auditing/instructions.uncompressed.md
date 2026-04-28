# Skill Auditing Instructions

## Dispatch Parameters

- `skill_path` (required): Absolute path to SKILL.md to audit
- `--filename <name>` (required): exact filename string for the record file and frontmatter `model:` field; lowercase-hyphenated vendor-class only (e.g. `claude-sonnet`, `claude-opus`); use VERBATIM, no inference, no sub-version. Missing -> `ERROR: --filename required`, stop.
- `spec_path` (optional): Path to companion spec if not beside SKILL.md
- `--fix` (optional flag): Enable single-pass fix mode against the skill's
  authoritative source files (`uncompressed.md` and `instructions.uncompressed.md`,
  siblings of `skill_path`). Runs only on a NEEDS_REVISION verdict. Refused on
  any candidate with pending git changes (untracked, unstaged, staged, or
  merge-conflicted) and on any path that escapes the skill directory. The
  companion `spec.md`, the `README.md`, and the compiled runtime files
  (`SKILL.md`, `instructions.txt`) are never modified.
- `--uncompressed` (optional flag): Audit the uncompressed source files
  (`uncompressed.md`, `instructions.uncompressed.md`) instead of the compiled
  runtime (`SKILL.md`, `instructions.txt`).

## Procedure

0. **Guard:** If `--filename` was not passed, output `ERROR: --filename required` and stop immediately.
1. **Read** the target skill directory listing (Glob or ls on the skill dir containing `skill_path`).
2. **Identify source files** — typically `spec.md`, `uncompressed.md`, `instructions.uncompressed.md` if present. Skip `SKILL.md` and `instructions.txt` — those are compressed artifacts derived from the source.
3. **Run** `git hash-object <file>` on each source file. Collect `(filename, blob-hash)` pairs.
4. **Build manifest:** sort pairs lexically by filename. Write one `<filename> <hash>` line per pair to a temp string. Run `git hash-object --stdin` on that text. Save the 40-char result as `<manifest_hash>`.
4a. **Resolve repo root** from `skill_path` (use the Bash tool):

    ```bash
    target_dir=$(dirname "<skill_path>")
    repo_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
    # Fallback: no .git/ found → place .hash-record/ adjacent to the skill directory
    [ -z "$repo_root" ] && repo_root="$target_dir"
    ```

    Save `<repo_root>` for all subsequent cache path construction.
5a. **Compute the cache filename.** The leaf is `<filename>.md` where `<filename>` is the value from `--filename`, used VERBATIM. Lowercase-hyphenated, vendor-class only (e.g. `claude-haiku`, `claude-sonnet`, `claude-opus`). Do NOT include: caller skill name, timestamp/date, sub-version qualifiers. See `../hash-record/filenames.md` for canonical values.

5b. **Compute the cache path.** Path shape:

   ```text
   <repo-root>/.hash-record/<manifest_hash[0:2]>/<manifest_hash>/skill-auditing/v1.1/<filename>.md
   ```

   The `v1.1` segment is mandatory for skill-auditing records. The version is declared in `spec.md` and MUST match the version embedded in this instructions file. If they ever drift, that's a defect — surface and stop.

   ```text
   Correct:   .hash-record/<sh>/<hash>/skill-auditing/v1.1/claude-sonnet.md
   Incorrect: .hash-record/<sh>/<hash>/skill-auditing/skill-auditing-sonnet-claude-sonnet.md
   Incorrect: .hash-record/<sh>/<hash>/skill-auditing/claude-sonnet-2026-04-27T19-17-52Z.md
   ```

5c. **Probe the cache.** Run `test -f <path-from-5b>` (use the Bash tool).

- **HIT** (file exists): output `PATH: <abs-path-to-that-file>` and stop. Do not re-run the audit.
- **MISS** (file does not exist): save `<repo-root>/.hash-record/<manifest_hash[0:2]>/<manifest_hash>/skill-auditing/v1.1/` as `<audit_cache_dir>` and continue.

6. **Read the skill** at `skill_path`. Determine type: inline or dispatch. Locate companion spec — check `spec_path` if provided, otherwise `spec.md` co-located with `skill_path`. If not found: simple inline skills (<30 lines) may skip Phase 1; dispatch or complex inline → record an error verdict, write the record, output `PATH:`, and stop.
8. **Run Phase 1 → Phase 2 → Phase 3** (stop on first failure). Assign verdict. Map to `result` field: PASS → `pass`; PASS_WITH_FINDINGS / NEEDS_REVISION / FAIL → `findings`; error → `error`.
9. **Scrub absolute paths from record body.** Before writing, scan the rendered body for any absolute filesystem path (Windows drive-letter prefix `<letter>:\...` or `<letter>:/...`, or Unix root-anchored paths under `/Users/`, `/home/`, `/d/`, etc.). For each hit, replace it with its repo-relative form — the same relative path used in `file_paths:` frontmatter (e.g., body should read `skill-auditing`, never the full absolute form). The body MUST NOT contain absolute paths.
10. **Write audit record** at `<audit_cache_dir><filename>.md` — filename is the `--filename` value verbatim (e.g. `claude-sonnet.md`), no skill-name prefix, no timestamp, no extra qualifiers. `mkdir -p <audit_cache_dir>` first. Frontmatter: `hash: <manifest_hash>`, `file_paths: <YAML list of repo-relative paths>` (one entry per source file from step 3, sorted lexically; each path is relative to `<repo-root>` resolved from `skill_path` — compute via `git ls-files --full-name <file>` or strip `<repo-root>/` from each absolute path), `operation_kind: skill-auditing` (verbatim from `--filename`), `result: <mapped value>`.

   ```yaml
   # Correct:
   file_paths:
     - skill-auditing/instructions.uncompressed.md
     - skill-auditing/SKILL.md
     - skill-auditing/spec.md
     - skill-auditing/uncompressed.md

   # WRONG (directory only):
   file_path: skill-auditing/

   # WRONG (absolute paths):
   file_paths:
     - /abs/path/to/skill-auditing/SKILL.md

   # WRONG (singular file_path in multi-file context):
   file_path: skill-auditing/SKILL.md
   ```

   Body: open with `# Result` H1, state verdict, list findings (with phase and check references).
11. **Output** `PATH: <audit_cache_dir><filename>.md` and stop.
12. If `--fix` is active **and** the verdict is exactly NEEDS_REVISION, enter the Fix Mode procedure below. PASS → nothing to fix; FAIL → fix mode is skipped and defects are reported for author action. Fix mode is single-pass; the auditor does not re-audit or recompress.

## When to audit which artifact

**Default — audit the compressed runtime (`SKILL.md`, `instructions.txt`)
against `spec.md`.** This is the regression / smoke check: does the shipped
artifact match the spec? The compressed runtime is what actually runs.

**Build / iteration mode — pass `--uncompressed`.** Audits the source
artifacts (`uncompressed.md`, `instructions.uncompressed.md`) instead. Apply
fixes to the source. Iterate until the source passes cleanly. Only then
recompile and run a final default-mode pass on the compressed result.

Pick the mode by intent: regression check → default. Building or revising →
`--uncompressed` until source converges, then default for the final pass. The
host agent chooses the mode based on what it is doing.

## Phase 1 — Spec Gate

Verify the companion spec is structurally sound. Must pass before any skill-level checks.

### Spec exists

`spec.md` must exist (or `spec_path` must resolve). Exception: simple inline
skills under ~30 lines may skip this phase entirely — proceed to Phase 2.

### Required sections

The spec must contain: Purpose, Scope, Definitions, Requirements,
Constraints. Missing sections → FAIL.

### Normative language

Requirements must use enforceable language (must, shall, required). Vague
terms in normative sections → FAIL.

### Internal consistency

No contradictions between sections. No duplicate rules. No normative content
in descriptive sections.

### Spec completeness

All terms used are defined. All behavior explicitly stated, not implied.

If any Phase 1 check fails → verdict FAIL, report which spec check failed,
do not proceed to Phase 2.

## Phase 2 — Skill Smoke Check

Quick structural verification of the SKILL.md.

### Classification

Apply: "Could someone with no context do this from just the inputs?" Yes →
should be dispatch. No → should be inline. Flag misclassification.

### Inline/dispatch file consistency

File presence is definitive for type: any allowed dispatch instruction file
present (`instructions.txt` or `<name>.md` in the skill directory, or the
instruction file explicitly referenced by SKILL.md) → skill is **dispatch**;
no such file found → skill is **inline**. If Check #1 (Classification) and
this check disagree, flag the conflict as a finding but do NOT double-fail —
note the conflict and let the auditor decide.

If dispatch: verify SKILL.md is a short routing card (structural details
in Check #3). If inline: verify SKILL.md contains the full procedure.
Mismatch between file-system evidence and SKILL.md structure → FAIL.

### Structure

**Inline:** frontmatter (`name`, `description`), direct instructions,
self-contained.
**Dispatch:** Instruction file exists and is reachable. Params typed with
required/optional/defaults. Output format specified. Uses Dispatch agent
(isolated), not background agent with host context. SKILL.md is minimal
routing content.

**Stop gates in routing card** (dispatch only): if SKILL.md contains refusal
conditions, eligibility guards, git-clean checks, or path-escape rules, flag
as NEEDS_REVISION. Finding text: `stop gates belong in instructions.txt, not
the routing card`. Routing card = invocation signature + output format.

**(A-IS-1) Input/output double-specification** — if the skill takes an INPUT
parameter that duplicates an OUTPUT already determined by a referenced sub-skill
(e.g. passing `result_file` when the sub-skill dictates the output path via its
own hash-record write), flag as HIGH. The input surface must not override
conventions dictated by referenced sub-skills.

### Frontmatter

`name` and `description` present and accurate.

**(A-FM-1) Name matches folder** — `name` field MUST equal the skill's
folder name exactly. Check both `uncompressed.md` and `SKILL.md`;
mismatch in either → FAIL.

**(A-FM-3) H1 per artifact** — `SKILL.md` MUST NOT contain an H1
(`# ...` line). `uncompressed.md` MUST contain an H1.
`instructions.uncompressed.md` (if present) MUST contain an H1.
`instructions.txt` (if present) MUST NOT contain an H1. Violation in
`SKILL.md` or `instructions.txt` → HIGH. Missing H1 in `uncompressed.md`
or `instructions.uncompressed.md` → FAIL. MD041 findings on `SKILL.md` are
expected and not a violation (R-FM-3 sanctioned no-H1).

### No duplication

Not duplicating existing capability. If similar exists, recommend merge or
distinguish.

If any Phase 2 check fails → verdict FAIL, do not proceed to Phase 3.

## Phase 3 — Spec Compliance Audit

Deep verification that the SKILL.md faithfully represents the spec.

### Coverage

Every normative requirement in the spec must be represented in the SKILL.md.
Missing requirements → FAIL.

### No contradictions

SKILL.md must not contradict the spec. Spec is authoritative; SKILL.md is
subordinate.

### No unauthorized additions

SKILL.md must not introduce normative requirements not present in the
spec.

### Conciseness

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
- **"Meta-architectural label"**: any line describing the skill's own execution
  pattern rather than instructing the agent what to do. Meta-architectural
  labels are design rationale and must be flagged. Examples: "this is an inline
  skill", "must not dispatch", "Worker runs directly". The agent follows
  instructions as written — it does not need to know its classification or be
  told what not to do. Finding text: `meta-architectural label — remove, this is
  design rationale`.

A skill passes conciseness only if an agent can skim it in one pass and know
exactly what to do — no hunting through paragraphs for the operative rule.

### Skill completeness

All runtime instructions present. No implicit assumptions. Edge cases
addressed or excluded. Defaults stated.

### Breadcrumbs

Ends with related skills/topics. References are valid (targets exist). No
stale references.

### Cost analysis (dispatch only)

**`--uncompressed` mode: SKIP.**

Uses Dispatch agent (zero-context isolation). Instruction file right-sized
(<500 lines). Sub-skills referenced by pointer, not inlined. Single dispatch
turn when possible.

### No dispatch references in instructions

`instructions.txt` must not tell the agent to dispatch other skills.
Subagents can't dispatch — only the host agent can. References to other
skills as "Related" context are OK. "Run this skill" or "dispatch this" →
FAIL. Remediation: move dispatch steps to SKILL.md.

### No spec breadcrumbs in runtime

SKILL.md and `instructions.txt` must not reference the skill's own
companion `spec.md` — not as a pointer, breadcrumb, or "see spec.md"
hint. The compressed runtime is self-contained; nudging the agent toward
the spec inflates context and defeats compression. Exception: skills
whose operation takes a spec as input (`spec-auditing`, `skill-auditing`)
may reference the `spec.md` under audit — never their own companion
spec. Remediation: delete the reference; if the information is genuinely
needed at runtime, inline it.

### (A-FM-2) Description not restated

Search every artifact (`uncompressed.md`, `SKILL.md`,
`instructions.uncompressed.md`, `instructions.txt`) for body prose that
duplicates the `description` frontmatter value. Any restatement → LOW
(escalate to HIGH if verbatim duplication).

### (A-FM-5) No exposition in runtime artifacts

Scan `SKILL.md`, `uncompressed.md`, `instructions.uncompressed.md`, and
`instructions.txt` for rationale, "why this exists," root-cause narrative,
historical notes, or background prose. Any found → HIGH. Rationale belongs
exclusively in `spec.md`.

### (A-FM-6) No non-helpful tags

Check all artifacts for descriptor lines that carry no operational value
(e.g., "inline apply directly no dispatch," "dispatch skill," bare type
labels not used as actionable instructions). Any found → LOW.

### (A-FM-7) No empty sections

Verify every heading in every artifact has body content before the next
heading or end of file. An empty section → HIGH.

### (A-FM-8) Iteration-safety placement

Verify the Iteration Safety blurb is absent from
`instructions.uncompressed.md` and `instructions.txt`. Presence in
either → HIGH. Additionally, if the guard appears in both `SKILL.md` and
`instructions.*`, flag as probable duplication → HIGH.

### (A-FM-9a) Iteration-safety pointer form

If a caller skill references iteration-safety, verify it uses the exact
2-line pointer block form (`Do not re-audit unchanged files. See <path>/iteration-safety/SKILL.md`.`) and that the relative path
matches the caller's actual folder depth. Any deviation → HIGH.

### (A-FM-9b) No verbatim Rule A/B restatement

Scan all artifacts for verbatim restatement of iteration-safety Rules A
or B beyond the sanctioned 2-line pointer block. Any found → HIGH.

### (A-XR-1) Cross-reference anti-pattern

Scan `SKILL.md`, `instructions.txt`, any sub-instructions (e.g. `eval.txt`),
and `uncompressed.md` for any pointer — by file path or inline link — to
ANOTHER skill's `uncompressed.md` or `spec.md`. Violations:

- "See uncompressed.md for full version"
- "See spec.md for requirements"
- "Reference: `<some-skill>/uncompressed.md`"
- Any href or inline link whose target ends in `.uncompressed.md` or `.spec.md`

NOT violations:

- Referencing a skill by SKILL NAME only (e.g. "see the `compression` skill")
- Subject-matter mentions of these file types in skill-auditing's own artifacts
  (this skill audits these files as targets, so it must name them)

Any cross-file path pointer → HIGH.

### (A-FM-10) Launch-script form on dispatch skills

Applies to dispatch skills only (N/A for inline skills).

Verify `uncompressed.md` contains ONLY:

- Frontmatter (`name`, `description`)
- Optional H1
- Dispatch invocation + input signature (parameter list)
- Return contract (`Returns:` line)
- Optional 2-line iteration-safety pointer

Any of the following → HIGH:

- Executor procedure steps or phase descriptions
- Modes tables or "When to audit which artifact" tables
- Examples or sample invocations beyond the input signature
- Rationale, "why this exists," or background prose
- Related breadcrumbs or "Related:" sections
- Behavior sections or Output format descriptions
- Model-class guidance (e.g., "Haiku-class handles most audits")
- False-positive guard lists

Content must go in `instructions.uncompressed.md` (executor procedure) or `spec.md` (rationale/behavior).

### Dispatch Skill Checks (DS-1..DS-6)

Applies to dispatch skills only (N/A for inline skills). Run against `uncompressed.md` (the host-facing card).

### (DS-1) Return shape declared

The host card MUST explicitly declare the return shape. Canonical shapes: `PATH: <abs-path-to-artifact>` on success, `ERROR: <reason>` on pre-write failure. A card returning content (multi-line reports, structured findings, inline results) instead of a path — for a skill that produces an artifact — MUST be flagged. Missing return shape declaration → HIGH.

### (DS-2) Host card minimalism

`uncompressed.md` MUST NOT contain any of the following; each present → HIGH:

- Internal cache mechanism descriptions (e.g., "iteration-safe via hash-record", "hash blob check") — caching is implementation detail invisible to the host.
- Adaptive/conditional rules invisible to the host (e.g., "MD041 auto-suppressed when frontmatter present") — belong in `instructions.uncompressed.md`.
- Tool-fallback hints (e.g., "use the CLI if available") — belong in instructions where the dispatched agent decides.
- Subjective qualifiers (e.g., "Sonnet-class equivalent or diminishing returns") — replace with the operative model class in the dispatch line.
- Prose describing what the skill does or how it works internally — belongs in `spec.md`. The card answers: how to dispatch, what params, what return shape, what modes. Nothing else.

### (DS-3) Description trigger phrases

The frontmatter `description` MUST follow the pattern: `<one-line action>. Triggers — <phrase1>, <phrase2>, ..., <phraseN>.` with 3–6 comma-separated trigger phrases. Violations → LOW:

- Description written as prose without trigger phrases.
- Description stuffed with implementation notes (e.g., "Dispatch skill", "Iteration-safe via hash-record", "Zero errors gate") — these waste trigger-phrase budget and must be removed.

### (DS-4) Inline dispatch guard

The dispatch instruction MUST follow the canonical cross-platform dispatch pattern:

```text
Without reading `<instructions-file>` yourself, spawn a zero-context, haiku-class sub-agent in the background:

**Claude Code:** `Agent` tool. Pass: `"Read and follow <instructions-file> here. Input: <args>"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow <instructions-file> in <skill_dir>. Input: <args>")`

Don't read `<instructions-file>` yourself.

Returns: `<return contract>`

NEVER READ OR INTERPRET `<instructions-file>` YOURSELF. Let the sub-agent do the work.
```

Three reinforcements required:

- **Opening prefix:** `Without reading <instructions-file> yourself, spawn...` — primes the agent before reading the bullets.
- **Mid-block warning:** `Don't read <instructions-file> yourself.` — repeated after the cross-platform bullets.
- **Closing reinforcement:** `NEVER READ OR INTERPRET <instructions-file> YOURSELF. Let the sub-agent do the work.` — uppercase at end of body. Empirically, the closing uppercase form makes VS Code Copilot reliably dispatch instead of inlining.

Violations:

- Standalone bold warnings (`**Do not execute this skill inline.**`) separated from the dispatch line → HIGH (fold into pattern, don't keep as banner).
- Missing the opening "Without reading" prefix → HIGH.
- Missing the closing uppercase reinforcement → MEDIUM.
- Cross-platform bullets reduced to a single platform → HIGH (dual Claude Code / VS Code form is the cross-platform contract).
- VS Code line missing `model: "Claude Haiku 4.5"` literal → HIGH.

### (DS-5) No substrate duplication

Consumer skills that produce records (audit reports, hygiene reports, review reports) MUST NOT inline the hash-record path schema, frontmatter shape, or shard layout from a referenced substrate skill (e.g., `hash-record`). Must reference the substrate by name only. Duplication of path math, frontmatter schema, or shard layout → HIGH.

### (DS-6) No overbuilt sub-skill dispatches for trivial work

A sub-skill folder whose entire procedure fits within 2–3 inline steps in the consumer's instructions is an anti-pattern. Two extra inline steps are cheaper than spawning another agent for those two steps. Flag any sub-skill whose procedure a consuming agent could execute directly in 2–3 steps → LOW (escalate to HIGH if the sub-skill adds no logic beyond a filesystem operation plus a write).

These checks extend Phase 3. Violations recorded in the Phase 3 findings table under a "Dispatch Skill Checks" group. HIGH violations contribute to NEEDS_REVISION or FAIL depending on count; LOW violations contribute to NEEDS_REVISION.

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
2. **Preflight report path writability.** Compute report path via the hash-record manifest path (`<audit_cache_dir><filename>.md`). If unwritable, STOP fix mode and exit without modifying anything.
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
5. **Write the read-only audit report** to the computed path first; this is the
   commit point. Any fix-pass failure after this leaves the report intact.
6. **Apply fixes** to writable source files only, in severity order:
   1. Critical Phase 3 issues: coverage, contradictions, unauthorized
      additions.
   2. Non-critical Phase 3 issues: conciseness, breadcrumbs, cost analysis,
      dispatch refs, spec breadcrumbs.
7. **Never auto-fix:** Phase 1 (spec) defects, defects whose root cause is in
   `spec.md` or `README.md` or a compiled artifact, defects requiring author
   judgment. Surface them as findings.
8. **Append a Fix Mode Addendum** to the report:
   - `Files Modified` — absolute paths of every file the auditor wrote.
   - `Fixes Applied` — per file, what changed and which finding it resolves.
   - `Not Auto-Fixed` — defects deferred to the author.
   - `Next Steps` — re-audit until PASS.
9. **Single-pass only.** The auditor does not re-audit and does not invoke
   compression. Multi-pass convergence is the caller's responsibility
   (fix → recompress → re-audit).

## Report Format

Frontmatter (required):

```yaml
---
hash: <manifest-hash>
file_paths:
  - <repo-relative path to first source file>
  - <repo-relative path to second source file>
  ...
operation_kind: skill-auditing
model: <filename>
result: pass | findings | error | skipped
---
```

`file_paths` MUST be a YAML list of repo-relative path strings — one per source file from the manifest, sorted lexically. Repo-relative = relative to the git root containing `.hash-record/`. NOT absolute paths, NOT a directory-only string, NOT a singular `file_path` key.

Body (required):

```markdown
# Result

PASS | PASS_WITH_FINDINGS | NEEDS_REVISION | FAIL

## Skill Audit: <skill-name>

**Verdict:** PASS | NEEDS_REVISION | FAIL
**Mode:** uncompressed  ← include only when --uncompressed is active; omit in standard mode
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
| Input/output double-spec (A-IS-1) | PASS/FAIL | |
| Frontmatter | PASS/FAIL | |
| Name matches folder (A-FM-1) | PASS/FAIL | |
| H1 per artifact (A-FM-3) | PASS/FAIL | |
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
| No dispatch refs | PASS/FAIL/N/A | |
| No spec breadcrumbs | PASS/FAIL | |
| Description not restated (A-FM-2) | PASS/FAIL | |
| No exposition in runtime (A-FM-5) | PASS/FAIL | |
| No non-helpful tags (A-FM-6) | PASS/FAIL | |
| No empty sections (A-FM-7) | PASS/FAIL | |
| Iteration-safety placement (A-FM-8) | PASS/FAIL/N/A | |
| Iteration-safety pointer form (A-FM-9a) | PASS/FAIL/N/A | |
| No verbatim Rule A/B (A-FM-9b) | PASS/FAIL/N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS/FAIL | |
| Launch-script form (A-FM-10) | PASS/FAIL/N/A | |
| Return shape declared (DS-1) | PASS/FAIL/N/A | |
| Host card minimalism (DS-2) | PASS/FAIL/N/A | |
| Description trigger phrases (DS-3) | PASS/FAIL/N/A | |
| Inline dispatch guard (DS-4) | PASS/FAIL/N/A | |
| No substrate duplication (DS-5) | PASS/FAIL/N/A | |
| No overbuilt sub-skill dispatch (DS-6) | PASS/FAIL/N/A | |

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
