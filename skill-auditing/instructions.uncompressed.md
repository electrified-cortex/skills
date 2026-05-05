# Skill Auditing Instructions

## Inputs

`skill_dir` (positional, required) — absolute path to the skill folder being audited.
`--report-path <abs-path>` (required) — absolute path to write the report. Missing → `ERROR: --report-path required`, stop. Existing file at `<report_path>` is overwritten.

**Hard prohibition:** do NOT author scripts (`.ps1`, `.sh`, `.py`, etc.), helper files, or any file other than `<report_path>`. Source files in `skill_dir` are read-only. Use Read/Bash/Grep only for inspection.

**Check invention prohibition:** only evaluate checks that are explicitly named and defined in this document. Do not invent, infer, or apply checks not present here — even if a pattern looks suspicious. If a concern does not match a named check, do not report it.

## Procedure

1. **Enumerate files.** Collect all files in `skill_dir` recursively, skipping dot-prefixed directories and `optimize-log.md`. Tool files (`.sh`, `.ps1`) and tool-spec files (`*.spec.md` other than the skill's own `spec.md` co-located with `SKILL.md`) are out of scope for Steps 1–3 AND excluded from the manifest `file_paths` — they belong to the tool manifest, audited independently by `tool-auditing`. The skill manifest covers only the skill bundle: `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md` (whichever exist). Tool files and tool-spec files are included in A-FS-1 enumeration only.
2. **Read `SKILL.md`.** Determine skill type (inline or dispatch) by file-system evidence: any allowed dispatch instruction file present (`instructions.txt`, `<name>.md`, or the file explicitly referenced by `SKILL.md`) → dispatch; no such file → inline. Locate companion spec `spec.md` co-located with `skill_dir`.
3. **Run Per-file basic checks** (always run; findings accumulate into a separate Per-file section; do NOT block Steps 1–3).
4. **Run Step 1 → Step 2 → Step 3.** Collect ALL findings before assigning a verdict. Do not stop on the first finding.
5. **Assign verdict** per Verdict Rules.
6. **Scrub absolute paths from the entire report** — frontmatter `file_paths`, Notes columns, Findings, ALL prose. Forbidden tokens: any Windows drive-letter path (`<letter>:[/\\]`), any POSIX root-anchored path (`/Users/`, `/home/`, `/d/`, `/c/`, `/mnt/`, `/tmp/`, `/var/`). When citing evidence containing such a path, describe abstractly ("hardcoded drive-letter path on line N") rather than quoting the literal path. Use repo-relative paths for any path in Findings.
7. **Write report** at `<report_path>` (overwrite if present). Use Bash tool to create the directory first: `mkdir -p $(dirname <report_path>)`. Then use Write tool to write the report. Write report frontmatter per the `hash-record` skill contract (operation_kind: `skill-auditing/v2`, result: `clean | pass | findings | fail`). Result mapping: CLEAN → `clean`; PASS → `pass`; NEEDS_REVISION → `findings`; FAIL → `fail`. Errors are never persisted — runtime/argument failures emit `ERROR: <reason>` and exit 1 (no path).

   **"Repo-relative":** resolve via `git -C <dir-containing-target-files> rev-parse --show-toplevel` and strip that prefix. The same repo root governs the cache directory layout (`<repo-root>/.hash-record/...`).

   **Skill-auditing-specific `file_paths` guidance** (multi-file context — auditors commonly miss this):

   ```yaml
   # Correct — list of repo-relative paths, one per non-tool source file from step 1, sorted lexically:
   file_paths:
     - skill-auditing/instructions.uncompressed.md
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

   Body: open with `# Result` H1, state verdict, list findings (with step and check references).

8. **Verify report on disk.** Before returning a verdict, run `ls -la <report_path>` (or equivalent) and confirm the file exists with non-zero size at the EXACT path supplied via `--report-path`. If missing, empty, or written to a different location → return `ERROR: report not at <report_path>` and stop. Do NOT return `CLEAN`, `PASS`, `NEEDS_REVISION`, or `FAIL` without a verified file. The host post-execute cache check is the second line of defense; this self-check is the first.

9. **Return** the verdict token as the final line of stdout, starting at column 0 with no indentation, no quoting, no list-marker prefix. Nothing may follow it.
   - `CLEAN: <report_path>`
   - `PASS: <report_path>`
   - `NEEDS_REVISION: <report_path>`
   - `FAIL: <report_path>`
   - `ERROR: <reason>`

## Per-file Basic Checks

Run against all `.md` and `*.spec.md` files in `skill_dir` (recursively; skip dot-prefixed directories and `optimize-log.md`). Tool files (`.sh`, `.ps1`) are out of scope — do not run per-file checks on them.

Findings accumulate into the Per-file section of the report and do NOT block Steps 1–3.

### `.md` files

- **Not empty** — file must contain non-whitespace content. Empty → HIGH.
- **Frontmatter where required** — `SKILL.md` and `agent.md` MUST have YAML frontmatter (`---` block at line 1). Missing frontmatter on these files → HIGH.
- **No absolute-path leaks** — body must not contain Windows-style (`<letter>:\` or `<letter>:/`) or Unix root-anchored paths (`/Users/`, `/home/`, `/d/`). Any found → HIGH.
- **Canonical trigger phrase (dispatch skills only)** — For dispatch skills (frontmatter `type: dispatch`), the `description:` field MUST include the canonical action phrase: `<verb> <skill-root>` where skill-root = directory name with hyphens replaced by spaces (e.g., `spec-auditing` -> "spec audit"). Check case-insensitively. Missing phrase -> HIGH (DS-8). Applies only to `SKILL.md`, not sub-skill files.

### `*.spec.md` files (files whose name ends in `.spec.md`)

- **Purpose section present** — must contain a `## Purpose` or `# Purpose` heading. Missing → HIGH.
- **Parameters section present** — must contain a `## Parameters` or `# Parameters` heading. Missing → HIGH.
- **Output section present** — must contain a `## Output` or `# Output` heading. Missing → HIGH.

## Step 1 — Compiled Artifacts

Quick structural verification of `SKILL.md` and any non-tool files it references.

### Classification

Apply: "Could someone with no context do this from just the inputs?" Yes → should be dispatch. No → should be inline. Flag misclassification.

### Inline/dispatch file consistency

File presence is definitive for type: any allowed dispatch instruction file present (`instructions.txt` or `<name>.md` in the skill directory, or the instruction file explicitly referenced by SKILL.md) → skill is **dispatch**; no such file found → skill is **inline**. If Check #1 (Classification) and this check disagree, flag the conflict as a finding but do NOT double-fail — note the conflict and let the auditor decide.

If dispatch: verify SKILL.md is a short routing card. If inline: verify SKILL.md contains the full procedure. Mismatch between file-system evidence and SKILL.md structure → FAIL.

### Structure

**Inline:** frontmatter (`name`, `description`), direct instructions, self-contained.
**Dispatch:** Instruction file exists and is reachable. Params typed with required/optional/defaults. Output format specified. Uses Dispatch agent (isolated), not background agent with host context. SKILL.md is minimal routing content.

**Stop gates in routing card** (dispatch only): if SKILL.md contains refusal conditions, eligibility guards, git-clean checks, or path-escape rules, flag as NEEDS_REVISION. Finding text: `stop gates belong in instructions.txt, not the routing card`. Routing card = invocation signature + output format.

**(A-IS-1) Input/output double-specification** — if the skill takes an INPUT parameter that duplicates an OUTPUT already determined by a referenced sub-skill (e.g. passing `result_file` when the sub-skill dictates the output path via its own hash-record write), flag as HIGH. The input surface must not override conventions dictated by referenced sub-skills.

**(A-IS-2) Sub-skill input isolation** — if a sub-skill's input surface includes a parameter that accepts the output path, result token, or computed artifact of a sibling sub-skill (e.g. a `<lint_path>` parameter consuming a sibling lint sub-skill's output), flag as HIGH. Sub-skills must be independently executable from the primary input only; the parent orchestrator owns cross-sub-skill data flow. See `skill-writing` spec R-SS-1.

### Frontmatter

`name` and `description` present and accurate.

**(A-FM-1) Name matches folder** — `name` field MUST equal the skill's folder name exactly. Check both `uncompressed.md` and `SKILL.md`; mismatch in either → FAIL.

**(A-FM-3) H1 per artifact** — applies ONLY to `.md` files (markdown). `.txt` files (e.g. `instructions.txt`) are NOT markdown; the H1 rule does NOT apply to them — never flag a `.txt` file under A-FM-3 regardless of content.

For `.md` files, a "real H1" is a line that:

- Starts at column 0 (no leading whitespace).
- Matches `^# ` literally — the line begins with `#` followed by a space.
- Is NOT inside a fenced code block (```...```), inline code (`` `# ...` ``), or quoted prose.

H1 markers inside fenced markdown blocks are TEMPLATE / EXAMPLE content showing what the executor should write to a generated artifact — they are NOT the file's own H1 and MUST never be counted as a real H1. To detect: scan for `^# ` AND verify the line is not inside a ``` fence by tracking fence open/close toggles as you walk the file.

Rule: `SKILL.md` MUST NOT contain a real H1. `uncompressed.md` (if present) MUST contain a real H1. `instructions.uncompressed.md` (if present) MUST contain a real H1. Violation in `SKILL.md` → HIGH. Absence of `uncompressed.md` is not a finding — it is optional. Missing H1 in `uncompressed.md` or `instructions.uncompressed.md` is out of scope — markdown-hygiene covers H1 enforcement.

### No duplication

Not duplicating existing capability. If similar exists, recommend merge or distinguish.

### (A-FS-1) Orphan files

Scan all files in `<skill_dir>` recursively. Skip dot-prefixed directories.
For each file that is NOT a well-known role file (`spec.md`, `*.sh`, `*.ps1`, `*.spec.md`, `eval.txt`, `*.uncompressed.md`, `SKILL.md`, `uncompressed.md`, `instructions.txt`, `optimize-log.md`):

- Check whether the file is referenced by name or relative path in any of: `SKILL.md`, `uncompressed.md`, `spec.md`, `instructions.uncompressed.md`.
- If not referenced → flag LOW.

Special case: `instructions.txt` present in a skill where file-system evidence shows it is NOT dispatch (no dispatch invocation in `SKILL.md` or `uncompressed.md`) → flag HIGH. Instructions file with no dispatch wiring is an orphan.

### (A-FS-2) Missing referenced files

Scan `SKILL.md`, `uncompressed.md`, `spec.md`, and `instructions.uncompressed.md` for any explicit file-path pointer: `instructions.txt`, `result.sh`, `result.ps1`, `verify.sh`, `verify.ps1`, and any other filename literal that denotes a sibling file. For each found path, verify the file exists in `<skill_dir>`. If it does not exist on disk → flag HIGH.

## Step 2 — Parity Check

Verify each compiled artifact faithfully represents its uncompressed counterpart with no loss of intent. Minor wording compression is acceptable; omitted requirements, contradictions, or changed behavior are not.

`uncompressed.md` is optional. Its absence is not a finding. When absent, the SKILL.md ↔ uncompressed.md parity row is N/A.

| Compiled | Uncompressed counterpart |
| --- | --- |
| `SKILL.md` | `uncompressed.md` (optional) |
| `instructions.txt` | `instructions.uncompressed.md` |

For each pair where both files exist: read both, compare intent. If the compiled version diverges — finding text: `Parity failure: <description>. Fix: edit <uncompressed-file>, then recompress to <compiled-file>.`

If a counterpart does not exist, skip parity for that pair (N/A).

Advisory (LOW, non-blocking): if `uncompressed.md` is absent and `SKILL.md` is >60 lines → suggest maintaining an uncompressed source for readability and safe editing. Do not count toward verdict severity.

## Step 3 — Spec Alignment

Verify the companion spec is structurally sound, then verify compiled artifacts faithfully represent it.

### Spec exists

`spec.md` must exist co-located with `skill_dir`. Exception: simple inline skills (<30 lines) may skip this step entirely.

If not found and skill is dispatch or complex inline → FAIL finding; continue collecting findings from Steps 1–2.

### Required sections

The spec must contain: Purpose, Scope, Definitions, Requirements, Constraints. Missing → FAIL.

### Normative language

Requirements must use enforceable language (must, shall, required). Vague terms → FAIL.

### Internal consistency

No contradictions between sections. No duplicate rules. No normative content in descriptive sections.

### Spec completeness

All terms used are defined. All behavior explicitly stated, not implied.

### Coverage

Every normative requirement in the spec must be represented in the SKILL.md. Missing → FAIL.

### No contradictions

SKILL.md must not contradict the spec. Spec is authoritative; SKILL.md is subordinate.

### No unauthorized additions

SKILL.md must not introduce normative requirements not present in the spec.

### Conciseness

Every line affects runtime behavior. No rationale in SKILL.md (belongs in spec). No redundant explanations. Agent-facing density.

Named finding patterns to flag:

- **"Too much why"**: prose explaining *why* a rule exists. Finding text: `too much why — move rationale to spec.md`.
- **"Essay not reference card"**: skill reads as continuous prose rather than decision trees, tables, or bullet instructions. Finding text: `exposition where a decision tree would serve`.
- **"Prose conditionals"**: if/else logic written as prose paragraphs. Finding text: `replace prose conditionals with decision tree or table`.
- **"Meta-architectural label"**: any line describing the skill's own execution pattern rather than instructing the agent what to do. Finding text: `meta-architectural label — remove, this is design rationale`.

A skill passes conciseness only if an agent can skim it in one pass and know exactly what to do.

### Skill completeness

All runtime instructions present. No implicit assumptions. Edge cases addressed or excluded. Defaults stated.

### Breadcrumbs

Ends with related skills/topics. References valid (targets exist). No stale references.

### Cost analysis (dispatch only)

Uses Dispatch agent (zero-context isolation). Instruction file right-sized (<500 lines). Sub-skills referenced by pointer, not inlined. Single dispatch turn when possible.

### No dispatch references in instructions

`instructions.txt` must not tell the agent to dispatch other skills. Subagents can't dispatch — only the host agent can. References to other skills as "Related" context are OK. "Run this skill" or "dispatch this" → FAIL. Remediation: move dispatch steps to SKILL.md.

### No spec breadcrumbs in runtime

SKILL.md and `instructions.txt` must not reference the skill's own companion `spec.md` — not as a pointer, breadcrumb, or "see spec.md" hint. Exception: skills whose operation takes a spec as input (`spec-auditing`, `skill-auditing`) may reference the `spec.md` under audit — never their own companion spec. Remediation: delete the reference; if the information is genuinely needed at runtime, inline it.

### Eval log presence (informational)

Perform the eval-presence check by reading the co-located `eval.txt` sub-instructions. Full procedure lives in `eval.txt` / `eval.uncompressed.md`. Absence of `eval.md` MUST NOT affect the verdict.

### (A-FM-2) Description not restated

Search every artifact (`uncompressed.md`, `SKILL.md`, `instructions.uncompressed.md`, `instructions.txt`) for body prose that duplicates the `description` frontmatter value. Any restatement → LOW (escalate to HIGH if verbatim duplication).

### (A-FM-5) No exposition in runtime artifacts

Scan `SKILL.md`, `uncompressed.md`, `instructions.uncompressed.md`, and `instructions.txt` for rationale, "why this exists," root-cause narrative, historical notes, or background prose. Any found → HIGH. Rationale belongs exclusively in `spec.md`.

### (A-FM-6) No non-helpful tags

Check all artifacts for descriptor lines that carry no operational value (e.g., "inline apply directly no dispatch," "dispatch skill," bare type labels not used as actionable instructions). Any found → LOW.

### (A-FM-7) No empty leaves

Empty section = leaf heading with no body AND no subheadings before the next heading at the same level or higher (or EOF) → HIGH. Headings with subsections are never empty.

### (A-FM-8) Iteration-safety placement

Verify the Iteration Safety blurb is absent from `instructions.uncompressed.md` and `instructions.txt`. Presence in either → HIGH. Additionally, if the guard appears in both `SKILL.md` and `instructions.*`, flag as probable duplication → HIGH.

### (A-FM-9a) Iteration-safety pointer form

If a caller skill references iteration-safety, verify it uses the exact 2-line pointer block form (`Do not re-audit unchanged files.` + `See <path>/iteration-safety/SKILL.md`.`) and that the relative path matches the caller's actual folder depth. Any deviation → HIGH.

### (A-FM-9b) No verbatim Rule A/B restatement

Scan all artifacts for verbatim restatement of iteration-safety Rules A or B beyond the sanctioned 2-line pointer block. Any found → HIGH.

### (A-XR-1) Cross-reference anti-pattern

Scan `SKILL.md`, `instructions.txt`, any sub-instructions (e.g. `eval.txt`), and `uncompressed.md` for any pointer — by file path or inline link — to ANOTHER skill's `uncompressed.md` or `spec.md`. Violations:

- "See uncompressed.md for full version"
- "See spec.md for requirements"
- "Reference: `<some-skill>/uncompressed.md`"
- Any href or inline link whose target ends in `.uncompressed.md` or `.spec.md`

NOT violations:

- Referencing a skill by SKILL NAME only (e.g. "see the `compression` skill")
- Subject-matter mentions of these file types in skill-auditing's own artifacts (this skill audits these files as targets, so it must name them)

Any cross-file path pointer → HIGH.

### (A-FM-10) Launch-script form on dispatch skills

Applies to dispatch skills only (N/A for inline skills). N/A if `uncompressed.md` is absent (SKILL.md-only is valid).

If `uncompressed.md` is present, verify it contains ONLY:

- Frontmatter (`name`, `description`)
- Optional H1
- Dispatch invocation + input signature (parameter list)
- Return contract (`Returns:` line)
- Optional 2-line iteration-safety pointer
- Optional inline result check protocol (pre-dispatch cache check + post-execute result routing via a co-located result tool)

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

### Dispatch Skill Checks (DS-1..DS-8)

Applies to dispatch skills only (N/A for inline skills). Run against `uncompressed.md` (the host-facing card).

### (DS-1) Return shape declared

The host card MUST explicitly declare the return shape. Canonical shapes: `PATH: <abs-path-to-artifact>` on success, `ERROR: <reason>` on pre-write failure. A card returning content (multi-line reports, structured findings, inline results) instead of a path — for a skill that produces an artifact — MUST be flagged. Missing return shape declaration → HIGH.

### (DS-2) Host card minimalism

The host card — `uncompressed.md` when present, or `SKILL.md` for SKILL.md-only dispatch skills — MUST NOT contain any of the following; each present → HIGH:

- Internal cache mechanism descriptions (e.g., "iteration-safe via hash-record", "hash blob check") — caching is implementation detail invisible to the host. **Exception: A-FM-10 inline result check protocol sections (pre-dispatch cache check + post-execute result routing via a co-located result tool) are explicitly allowed host behavior — do NOT flag these as DS-2 violations.**
- Adaptive/conditional rules invisible to the host (e.g., "MD041 auto-suppressed when frontmatter present") — belong in `instructions.uncompressed.md`.
- Tool-fallback hints (e.g., "use the CLI if available") — belong in instructions where the dispatched agent decides.
- Subjective qualifiers (e.g., "Sonnet-class equivalent or diminishing returns") — replace with the operative model class in the dispatch line.
- Prose describing what the skill does or how it works internally — belongs in `spec.md`. The card answers: how to dispatch, what params, what return shape, what modes. Nothing else.

### (DS-3) Description trigger phrases

The frontmatter `description` MUST follow the pattern: `<one-line action>. Triggers — <phrase1>, <phrase2>, ..., <phraseN>.` with 3–6 comma-separated trigger phrases. Violations → LOW:

- Description written as prose without trigger phrases.
- Description stuffed with implementation notes (e.g., "Dispatch skill", "Iteration-safe via hash-record", "Zero errors gate") — these waste trigger-phrase budget and must be removed.

### (DS-4) Inline dispatch guard

Dispatch skills MUST use the canonical prompt-only dispatch pattern. See `dispatch/dispatch-pattern.md` for context.

Required elements in `uncompressed.md`:

- `<instructions>` binding MUST include a `NEVER READ` guard (e.g. `NEVER READ THIS FILE` or `NEVER READ`) on the same line.
- `<prompt>` binding MUST use the `Read and follow <instructions-abspath>` form.
- MUST delegate via `Follow dispatch skill. See <path>/dispatch/SKILL.md`.

Violations:

- Missing `NEVER READ` guard on the `<instructions>` binding → HIGH.
- Missing `<prompt>` binding or not using the `Read and follow` form → HIGH.
- Missing `Follow dispatch skill. See ...` delegation line → HIGH.
- Stale standalone opener (`Without reading... yourself, spawn...`) or closer (`NEVER READ OR INTERPRET...`) outside the variable block → MEDIUM (stale pattern; remove).

### (DS-5) No substrate duplication

Consumer skills that produce records (audit reports, hygiene reports, review reports) MUST NOT inline the hash-record path schema, frontmatter shape, or shard layout from a referenced substrate skill (e.g., `hash-record`). Must reference the substrate by name only. Duplication of path math, frontmatter schema, or shard layout → HIGH.

### (DS-6) No overbuilt sub-skill dispatches for trivial work

A sub-skill folder whose entire procedure fits within 2–3 inline steps in the consumer's instructions is an anti-pattern. Flag any sub-skill whose procedure a consuming agent could execute directly in 2–3 steps → LOW (escalate to HIGH if the sub-skill adds no logic beyond a filesystem operation plus a write).

### (DS-7) Tool integration alignment

For skills shipping a co-located tool trio (`<stem>.sh` + `<stem>.ps1` + `<stem>.spec.md`), check integration WITHOUT auditing the tool itself (tool-auditing covers that):

- **Orphan tool** — every tool present in `skill_dir` MUST be referenced by `SKILL.md` or `spec.md` (by stem name or relative path). Unreferenced tool present → HIGH.
- **Missing tool** — every tool referenced by `SKILL.md` or `spec.md` MUST exist in `skill_dir` as a complete trio. Referenced tool absent or incomplete trio → FAIL.
- **Tool-spec alignment** — IF a referenced tool has a `*.spec.md`, its declared behavior (Purpose, Output, return contract) MUST be consistent with how `SKILL.md` / `spec.md` describes the tool's role. Contradiction (main spec says "moves A to B"; tool spec says "deletes") → FAIL.

The auditor reads tool-spec text for this check; tool files (`.sh`, `.ps1`, `*.spec.md`) remain excluded from the manifest hash per Step 1.

### (DS-8) Canonical trigger phrase

Applies to dispatch skills only. N/A for inline skills. Applies only to `SKILL.md`, not sub-skill files.

For dispatch skills (frontmatter `type: dispatch`), the `description:` field MUST include the canonical action phrase. The canonical phrase = directory name with hyphens replaced by spaces (e.g., `spec-auditing` → "spec audit", `tool-auditing` → "tool audit", `markdown-hygiene` → "markdown hygiene").

Check case-insensitively. A trigger of the form `<verb> <root>` or `<root>` alone (hyphenated or space-separated) MUST appear verbatim in the description triggers list.

Missing phrase → HIGH (DS-8). Finding text: `Canonical trigger phrase '<phrase>' missing from description triggers.`

These checks extend Step 3. Violations recorded in the Step 3 findings table under a "Dispatch Skill Checks" group. HIGH violations contribute to NEEDS_REVISION or FAIL depending on count; LOW violations contribute to NEEDS_REVISION.

## Verdict Rules

- **CLEAN**: All steps pass with zero findings (no HIGH, no LOW, no informational). Audit produced nothing to report.
- **PASS**: No FAIL findings, no HIGH findings. Non-blocking findings (LOW, informational) may be present. Safe to seal.
- **NEEDS_REVISION**: No FAIL findings, but HIGH or multiple LOW findings present. List specific fixes.
- **FAIL**: Any FAIL finding, or 3+ HIGH findings.

## Report Format

Frontmatter (required):

```yaml
---
file_paths:
  - <repo-relative path to first source file>
  - <repo-relative path to second source file>
  ...
operation_kind: skill-auditing/v2
model: haiku-class  # or sonnet-class or opus-class — NEVER a literal model id
result: clean | pass | findings | fail
---
```

`file_paths` MUST be a YAML list of repo-relative path strings — one per non-tool source file from the manifest, sorted lexically. NOT absolute paths, NOT a directory-only string, NOT a singular `file_path` key.

Body (required):

```markdown
# Result

CLEAN | PASS | NEEDS_REVISION | FAIL

## Skill Audit: <skill-name>

**Verdict:** CLEAN | PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <path>

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS/FAIL | |
| Inline/dispatch consistency | PASS/FAIL | |
| Structure | PASS/FAIL | |
| Input/output double-spec (A-IS-1) | PASS/FAIL | |
| Sub-skill input isolation (A-IS-2) | PASS/FAIL/N/A | |
| Frontmatter | PASS/FAIL | |
| Name matches folder (A-FM-1) | PASS/FAIL | |
| H1 per artifact (A-FM-3) | PASS/FAIL | |
| No duplication | PASS/FAIL | |
| Orphan files (A-FS-1) | PASS/FAIL | |
| Missing referenced files (A-FS-2) | PASS/FAIL | |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS/FAIL/N/A | |
| instructions.txt ↔ instructions.uncompressed.md | PASS/FAIL/N/A | |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS/FAIL/SKIP | |
| Required sections | PASS/FAIL/SKIP | |
| Normative language | PASS/FAIL/SKIP | |
| Internal consistency | PASS/FAIL/SKIP | |
| Spec completeness | PASS/FAIL/SKIP | |
| Coverage | PASS/FAIL | |
| No contradictions | PASS/FAIL | |
| No unauthorized additions | PASS/FAIL | |
| Conciseness | PASS/FAIL | |
| Completeness | PASS/FAIL | |
| Breadcrumbs | PASS/FAIL | |
| Cost analysis | PASS/FAIL/N/A | |
| No dispatch refs | PASS/FAIL/N/A | |
| No spec breadcrumbs | PASS/FAIL | |
| Eval log (informational) | PRESENT/ABSENT | |
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
| Tool integration alignment (DS-7) | PASS/FAIL/N/A | |
| Canonical trigger phrase (DS-8) | PASS/FAIL/N/A | |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `<filename>` | Not empty | PASS/FAIL | |
| `<filename>` | Frontmatter (if required) | PASS/FAIL/N/A | |
| `<filename>` | No abs-path leaks | PASS/FAIL | |
| `<filename>` | Purpose section (.spec.md) | PASS/FAIL/N/A | |
| `<filename>` | Parameters section (.spec.md) | PASS/FAIL/N/A | |
| `<filename>` | Output section (.spec.md) | PASS/FAIL/N/A | |

Omit rows that are N/A for the given file type. Add one row group per file checked. Files with no findings may be collapsed to a single "all checks pass" row.

### Issues

- <issue and fix>

### Recommendation

<one line>

```

## Rules

- Read-only. Never modify any source file in `skill_dir`. Write only `<report_path>`.
- Single-pass only — no in-process re-audit, no recompression. Caller drives the next cycle.
- One skill per dispatch.
- Evidence-based verdicts.
- When in doubt, NEEDS_REVISION over PASS.

## Banned terminology

Do not use the term **"non-goals"** in any finding text, recommendation, or
output. The term is ambiguous and confusing to humans and downstream agents
alike. Use **"Out of Scope"** instead.

When auditing skill content, flag any occurrence of "non-goals" in
`SKILL.md`, `uncompressed.md`, `instructions*.md`, or `spec.md` as a HIGH
terminology finding under Step 1 (Compiled Artifacts) or Step 3 (Spec
Alignment) as appropriate. Recommend renaming the section/heading/term to
"Out of Scope".
