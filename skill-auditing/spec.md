# Skill Auditing Specification

## Purpose

Define the rules and procedures for auditing skills. The skill auditor is
the source of truth for skill quality. Skill writers conform to the
auditor's rules. The auditor can verify its own skill for compliance
(dogfooding).

## Finding Priority Ordering — Big Rough First

When iterating toward a seal, fix in this order:

1. **Structural/architectural** — wrong classification, cross-pollination between
   sub-skills, missing required files, broken dispatch pattern. No polish until
   structure is settled.
2. **Correctness** — spec deviation, parity failures between compressed and
   uncompressed artifacts, logic errors in result determination.
3. **Minimalism/style** — exposition in runtime artifacts, host card verbosity,
   non-normative language in specs, cosmetic naming.

Do not re-audit the same finding category after it has passed. Move to the next
tier. Rehashing settled tiers wastes audit cycles.

**Sealing gate:** the skill is ready to seal when tiers 1 and 2 are fully clear.
Tier 3 findings are polishing passes — they do not block a seal.

## Scope

Applies when auditing an existing skill for quality, compliance, or
optimization. Covers classification verification, structural checks,
cost analysis, and breadcrumb validation.

This is a **dispatch skill** — the audit procedure is context-independent
and should run in an isolated agent via the Dispatch agent pattern.

## Version

2

Bump this when the audit semantics, output schema, or check codes change in a way that invalidates prior records. The version is reflected in the `op_kind` used by the result tool (`skill-auditing/v2`).

## Definitions

- **Audit**: Systematic verification of a skill against the skill-writing
  spec and this auditing spec's quality rules.
- **Verdict**: The outcome of an audit — CLEAN, PASS, NEEDS_REVISION, or FAIL.
- **Classification error**: A skill using the wrong execution pattern
  (inline when it should dispatch, or vice versa).
- **Context overhead**: The cost of loading unnecessary context (system
  prompt, conversation history) into a dispatched agent's turns.
- **Routing depth**: How many sub-skills a skill references. Deeper =
  more modular but harder to trace.
- **Simple inline skill**: An inline skill with no configurable
  parameters, no conditional branching, and no multi-step decision
  procedure. These may omit a companion `spec.md`.
- **Complex inline skill**: An inline skill that is not simple — it
  has configurable parameters, conditional branching, or multi-step
  decision logic. A companion `spec.md` is required.
- **SKILL.md-only skill**: a skill (dispatch or inline) with no
  `uncompressed.md` companion. Valid when `SKILL.md` is already
  concise and precise. Absence of `uncompressed.md` is not a finding.
  When `SKILL.md` exceeds 60 lines and no `uncompressed.md` exists,
  the auditor should raise a LOW advisory suggesting the pair — this
  does not affect verdict severity.
- **semantic-content whitelist**: the explicit ordered list of artifact files used for manifest hashing: `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md` (whichever exist in the skill directory).
- **Repo-relative path**: A filesystem path relative to the root of the git repository containing the audited skill, stripped of absolute prefixes (e.g., `C:\`, `/home/`). Computed via `git rev-parse --show-toplevel` or fallback to the skill directory if no `.git/` is found.
- **Iteration-safety**: Design pattern enabling an agent to safely audit a skill multiple times without re-computing unchanged work. Implemented via hash-record caching and idempotent procedure execution. See the `iteration-safety` skill (`../iteration-safety/SKILL.md`) for full pattern details.
- MISS: return token emitted when no cache record exists for the manifest hash; the full audit must run.
- HIT: return token emitted when a cache record is found; verdict not re-computed.

The verdict vocabulary above (`CLEAN`, `PASS`, `NEEDS_REVISION`, `FAIL`)
intentionally does NOT include a "skipped" verdict. Cache-hit and cache-miss
are implementation concerns of the result tool — on a hit, the host re-emits
the cached verdict (one of the four canonical ones); on a miss, the executor
runs the full audit and writes a fresh verdict. The audit's verdict surface
stays four-state — what the audit FOUND, not what the runtime decided about
re-running it.

If a 3-iteration off-ramp is needed (caller accepts a NEEDS_REVISION result
as good-enough after 3 fix passes), the verdict on the audit record stays as
the actual finding (e.g. `PASS` if findings are non-blocking; `NEEDS_REVISION`
if they remain). Caller acceptance is a separate caller-side decision; it does
not become a new auditor verdict.

## Requirements

1. The auditor **must** execute the audit as a single sweep in order: compiled artifacts → parity check → spec alignment.
2. All findings **must** be collected across the full sweep before assigning a verdict; the sweep does not stop on the first finding.
3. The spec **must** contain Purpose, Scope, Definitions, Requirements, and Constraints sections; absence of any → spec alignment FAIL.
4. Requirements in the spec **must** use enforceable language (must, shall, required); vague normative language → FAIL.
5. `SKILL.md` **must** represent every normative requirement in the spec; missing coverage → FAIL.
6. `SKILL.md` **must** not contradict the spec; spec is authoritative.
7. `SKILL.md` **must** not introduce normative requirements absent from the spec.
8. Every line in `SKILL.md` **must** affect runtime behavior; design rationale belongs in spec.
9. `instructions.txt` **must** not direct the agent to dispatch other skills; only host agents can dispatch.
10. The auditor **must** compute a manifest hash from the skill's source files, check the hash-record cache, and — on a cache miss — write the verdict and full report to the hash-record path before performing any other side effect. On a cache hit, the auditor **must** return the cached verdict and stop. The return token **must** appear as the final line of stdout, starting at column 0 with no indentation, no quoting, and no list-marker prefix. No output may follow it. The caller parses the last line of stdout to extract the return token. Valid return tokens: `CLEAN: <abs-path>` | `PASS: <abs-path>` | `NEEDS_REVISION: <abs-path>` | `FAIL: <abs-path>` on verdict; `MISS: <abs-path>` on cache miss (triggers full audit run).
11. The auditor **must** be read-only; the companion `spec.md` and all compiled runtime files (`SKILL.md`, `instructions.txt`) are immutable — the compiled runtime is regenerated by the caller via the `compression` skill, not by the auditor.
12. Verdict **must** be justified with evidence from the skill files — no unsupported assertions.
13. The auditor **must** check parity between each compiled artifact and its uncompressed counterpart (`SKILL.md` ↔ `uncompressed.md`; `instructions.txt` ↔ `instructions.uncompressed.md`). The compiled version **must** faithfully represent the uncompressed source with no loss of intent. Parity failures **must** be reported with the remediation path: fix the uncompressed source, then recompress. `uncompressed.md` is optional; its absence is not a finding — parity for that pair is N/A.
14. Tool files (`.sh`, `.ps1`) and tool-spec files (`*.spec.md` other than the skill's own `spec.md`) **must** be skipped — they are out of scope for skill-auditing AND excluded from the manifest `file_paths`. Tool quality is covered by `tool-auditing` independently; the skill manifest and tool manifest are intentionally separate. The skill manifest covers only the skill bundle: `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md` (whichever exist).
15. If no companion spec exists and the skill is dispatch or complex
    inline, the auditor **must** record a FAIL finding for the spec alignment step and continue collecting findings from compiled artifacts and parity.
16. After all verdict-bearing Step 3 checks, the auditor **must** perform
    the eval-presence check via the co-located `eval.txt` sub-instructions.
    This requirement specifies that the check exists, not its full procedure.
    Absence of `eval.txt` **must not** affect the verdict.
17. The auditor **must** check all skill artifacts for cross-reference
    anti-patterns (A-XR-1): per R-FM-11, every cross-skill reference MUST
    identify the target by canonical `name`; a relative path may follow as
    an optional pointer. References that supply ONLY a path with no canonical
    name **must** be flagged HIGH. Bare-name references and name-with-path
    references are permitted. Subject-matter mentions in skill-auditing's
    own files are exempt.
18. For dispatch skills, `uncompressed.md` **must** be a launch-script: frontmatter,
    optional H1, dispatch invocation + input signature, return contract, optional
    2-line iteration-safety pointer, optional inline result check protocol (pre-dispatch
    cache check + post-execute result routing via a co-located result tool). Anything
    else (executor procedure, Modes tables, examples, rationale, Related breadcrumbs,
    Behavior sections, Output format descriptions, model-class guidance) belongs in
    `instructions.uncompressed.md` or `spec.md`. Violation → HIGH. (A-FM-10)

## Constraints

- **One skill per invocation**: each invocation audits exactly one
  skill; multi-skill audits are separate runs.
- **Compiled artifacts immutable**: `SKILL.md`, `instructions.txt`,
  `spec.md`, and `README.md` must never be modified by the auditor
  in any mode.
- **No absolute paths in record body**: The record body MUST NOT contain
  absolute filesystem paths. The `Path:` line and any other path mentioned
  in the body MUST be repo-relative to the resolved repo root (e.g.,
  `Path: skill-auditing`, not a Windows drive-letter prefixed path or a
  Unix absolute path under `/Users/`, `/home/`, etc.). Before writing the record, the
  executor MUST replace any leaked absolute path in the rendered body with
  its repo-relative form — the same path that goes into `file_paths:`
  frontmatter.

Fix iteration is caller-driven; the executor is single-pass read-only. Callers dispatch fix agents independently.

## Behavior

The audit executes as a single sweep in three ordered steps. All findings are collected before a verdict is assigned — the sweep does not stop on the first finding.

On entry, the host (via `result.sh` / `result.ps1`) computes a manifest hash from the semantic-content whitelist in `skill_dir` (top-level only, in this exact order: `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md` — files that exist are included; missing files are skipped; order is part of the hash key) using the hash-record manifest procedure, and checks the cache at `.hash-record/<manifest_hash[0:2]>/<manifest_hash>/skill-auditing/v2/report.md`. On a cache hit, the host re-emits the cached verdict token and stops — the executor is not dispatched. On a miss, the host dispatches the executor with `--report-path <abs-path>` and the executor runs the full audit.

The auditor reads `SKILL.md`, determines skill type (inline or dispatch) by file-system evidence, collects all non-tool files referenced from `SKILL.md` within `skill_dir`, and proceeds through the three steps:

1. **Compiled artifacts** — audit `SKILL.md` and any referenced non-tool files (structural checks, classification, frontmatter, quality checks).
2. **Parity** — compare each compiled artifact against its uncompressed counterpart (`SKILL.md` ↔ `uncompressed.md`; `instructions.txt` ↔ `instructions.uncompressed.md`). Verify no loss of intent in compression. Parity failures surface with remediation: fix the uncompressed source, then recompress.
3. **Spec alignment** — read `spec.md` and verify coverage, consistency, and normative compliance against the compiled artifacts.

### Output / Return Contract

After all narrative or report-related output, the auditor **must** emit exactly one final line of stdout. That line **must** be the last line of stdout — nothing may follow it. The line **must** start at column 0 with no indentation, no quoting, and no list-marker prefix.

```text
Right:  CLEAN: <abs-path> | PASS: <abs-path> | NEEDS_REVISION: <abs-path> | FAIL: <abs-path>
Wrong:  Verdict: PASS. Wrote record to: PATH: <abs-prefix>/...
```

The caller parses only the last line of stdout; mixed narrative breaks the parse contract.

On completion, the auditor assigns one of four verdicts (CLEAN, PASS, NEEDS_REVISION, or FAIL) and writes the full structured report to `.hash-record/<manifest_hash[0:2]>/<manifest_hash>/skill-auditing/v2/report.md`. The record frontmatter uses a `file_paths` list (repo-relative paths for every file in the manifest, sorted lexically), `operation_kind: skill-auditing/v2`, `model` set to the executing agent's model class, and `result` mapped as: CLEAN → `clean`; PASS → `pass`; NEEDS_REVISION → `findings`; FAIL → `fail`. Errors are never persisted as records; runtime/argument failures of the tool emit `ERROR: <reason>` and exit 1. The record body opens with `# Result`, states the verdict, and lists findings. The auditor emits the appropriate verdict token from R10 (`CLEAN`, `PASS`, `NEEDS_REVISION`, or `FAIL` with the abs-path to the record) as the final line of stdout and exits. `ERROR: <reason>` is reserved for runtime/argument failures of the tool itself; errors are NEVER persisted as records — they are transient runtime conditions reported to the caller.

## Defaults and Assumptions

- **Read-only**: the auditor never modifies any file in the skill folder. Fixes are the caller's responsibility: edit the uncompressed source, then recompress.
- **One skill per dispatch**: each auditor invocation audits exactly one skill.
- **Auditor disposition**: skeptical and evidence-based; findings must cite file content; creative interpretation of intent is not permitted.
- **Spec location**: companion spec is `spec.md` co-located with `skill_dir`.
- **Simple inline exemption**: simple inline skills (see Definitions) may omit `spec.md`; the spec alignment step is skipped for these.
- **Sweep covers all artifacts**: the auditor always evaluates both compiled artifacts and their uncompressed counterparts in a single pass. There is no mode selection.
- **Fix path**: any parity finding instructs the caller to fix the uncompressed source (`uncompressed.md` or `instructions.uncompressed.md`) and recompress via the `compression` skill. The auditor never performs recompression.

## Audit Steps

The audit executes three steps in order. All findings are collected before a verdict is assigned.

### Step 1 — Compiled Artifacts

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
   direct instructions, self-contained. For dispatch: SKILL.md should be
   minimal lines of routing content, an allowed dispatch instruction file exists
   and is reachable, parameters typed with required/optional/defaults, output
   format specified, uses Dispatch agent (isolated).
   - **(A-IS-1) Input/output double-specification.** If a skill takes an INPUT
     parameter that duplicates an OUTPUT already determined by a referenced
     sub-skill (e.g. passing `result_file` when the sub-skill dictates the output
     path via its own hash-record write), flag as HIGH. The input surface must not
     override conventions dictated by referenced sub-skills.
   - **(A-IS-2) Sub-skill input isolation.** If a sub-skill's input surface
     includes a parameter that accepts the output path, result token, or computed
     artifact of a sibling sub-skill (e.g. a `<lint_path>` parameter consuming a
     sibling lint sub-skill's output), flag as HIGH. Sub-skills must be independently
     executable from the primary input only; the parent orchestrator owns cross-sub-skill
     data flow. See `skill-writing` spec R-SS-1.
   - **Stop gates** (dispatch only): routing cards must contain no refusal conditions, eligibility guards, git-clean checks, or path-escape rules.
4. **Frontmatter** — `name` and `description` present and accurate.
   Additionally:
   - (A-FM-1) `name` field MUST equal the skill's folder name exactly. Check
     both `uncompressed.md` and `SKILL.md`; mismatch in either → FAIL.
   - (A-FM-3) H1 presence — applies ONLY to `.md` files (markdown). `.txt`
     files (e.g. `instructions.txt`) are NOT markdown and the H1 rule does
     NOT apply to them; never flag a `.txt` file under A-FM-3 regardless of
     content. For `.md` files: a "real H1" is a line that **starts at
     column 0** and matches `^# ` literally. References to H1 markers
     INSIDE fenced code blocks (```...```), inline code (`# ...`), or quoted
     prose are TEMPLATE / EXAMPLE content — NEVER count them as H1s. To
     detect: regex on `^# ` in the file, then verify the line is NOT inside
     a fence by tracking ``` toggles. Rule: `SKILL.md` MUST NOT contain a
     real H1. If `uncompressed.md` is present, it MUST contain a real H1.
     `instructions.uncompressed.md` (if present) MUST contain a real H1.
     Violation in `SKILL.md` → HIGH. Absence of `uncompressed.md` is not a
     finding. Missing H1 in `uncompressed.md` or `instructions.uncompressed.md`
     is out of skill-auditing's scope; markdown-hygiene covers H1 enforcement.
5. **No duplication** — skill does not duplicate an existing capability.
   If similar skill exists, recommend merge or distinguish clearly.
6. **(A-FS-1) Orphan files** — scan all files in the skill directory
   and sub-directories. Any file that is not referenced directly or
   indirectly from `SKILL.md`, `uncompressed.md`, `spec.md`, or
   `instructions.uncompressed.md` (by filename or relative path) and
   has no well-known role (e.g. `spec.md`, `README.md`, `result.sh`,
   `result.ps1`, `verify.sh`, `verify.ps1`, `eval.txt`,
   `eval.uncompressed.md`) → flag LOW. An `instructions.txt` in a
   skill that shows no evidence of being a dispatch skill (no
   `instructions.txt` reference in `SKILL.md` or the
   uncompressed source) is a HIGH example of this pattern.
7. **(A-FS-2) Missing referenced files** — scan `SKILL.md`,
   `uncompressed.md`, `spec.md`, and `instructions.uncompressed.md` for any
   file-path pointer (explicit `instructions.txt` reference,
   `result.sh`, `result.ps1`, `verify.sh`, `verify.ps1`, or any other
   path literal). Each referenced file MUST exist on disk. Missing file
   → HIGH.

### Per-file Basic Checks

Run against all `.md` and `*.spec.md` files in `skill_dir` (recursively; skip dot-prefixed directories and `optimize-log.md`). Tool files (`.sh`, `.ps1`) are out of scope. Findings accumulate into a separate Per-file section of the report; they do NOT block Steps 1–3.

**`.md` files:**

- **Not empty** — file must contain non-whitespace content. Empty → HIGH.
- **Frontmatter where required** — `SKILL.md` and `agent.md` MUST have YAML frontmatter (`---` block at line 1). Missing → HIGH.
- **No absolute-path leaks** — body must not contain Windows-style (`<letter>:\` or `<letter>:/`) or Unix root-anchored paths (`/Users/`, `/home/`, `/d/`). Any found → HIGH.

**`*.spec.md` files (name ends in `.spec.md`):**

- **Purpose section present** — must contain `## Purpose` or `# Purpose`. Missing → HIGH.
- **Parameters section present** — must contain `## Parameters` or `# Parameters`. Missing → HIGH.
- **Output section present** — must contain `## Output` or `# Output`. Missing → HIGH.

### Step 2 — Parity Check

Verify each compiled artifact faithfully represents its uncompressed counterpart with no loss of intent. Minor wording compression is acceptable; omitted requirements, contradictions, or changed behavior are not.

| Compiled | Uncompressed counterpart |
| --- | --- |
| `SKILL.md` | `uncompressed.md` |
| `instructions.txt` | `instructions.uncompressed.md` |

For each pair where both files exist: read both, compare intent. If the compiled version diverges — finding text: `Parity failure: <description>. Fix: edit <uncompressed-file>, then recompress to <compiled-file>.`

If a counterpart does not exist, skip parity for that pair.

### Step 3 — Spec Alignment

Verify the companion spec is structurally sound, then verify the compiled artifacts faithfully represent it.

**Spec structure** (skip if simple inline skill with no spec):

1. **Spec exists** — `spec.md` must exist co-located with `skill_dir`. If not found and skill is dispatch or complex inline → FAIL finding; continue collecting findings from Steps 1–2.
2. **Required sections** — spec must contain: Purpose, Scope, Definitions, Requirements, Constraints. Missing → FAIL.
3. **Normative language** — requirements must use enforceable language (must, shall, required). Vague terms → FAIL.
4. **Internal consistency** — no contradictions between sections, no duplicate rules.
5. **Completeness** — all terms defined, all behavior explicitly stated.

**Spec compliance:**

6. **Coverage** — every normative requirement in the spec must be
   represented in the `SKILL.md`. Missing requirements → FAIL.
7. **No contradictions** — `SKILL.md` must not contradict the spec.
   Spec is authoritative; `SKILL.md` is subordinate.
8. **No unauthorized additions** — `SKILL.md` must not introduce
   normative requirements not present in the spec.
9. **Conciseness** — every line in `SKILL.md` must affect runtime
   behavior. No design rationale (belongs in spec). No redundant
   explanations. Agent-facing density, not human-facing readability.
   The auditor must also check for consolidation opportunities: sections
   that could be merged, rules that repeat content already stated, and
   length that exceeds the complexity of what is described. Flag as
   Informational; escalate to Low if duplication creates drift risk.
10. **Completeness** — all runtime instructions present. No implicit
    assumptions. Edge cases addressed or explicitly excluded. Defaults
    stated, not assumed.
11. **Breadcrumbs** — ends with related skills or help topics.
    References are valid (pointed-to resources exist). No stale
    references.
12. **Cost analysis** (dispatch skills only) — uses Dispatch agent
    (zero-context isolation). Instruction file is right-sized (< 500
    lines). Sub-skills referenced by pointer, not inlined. Single
    dispatch turn when possible.
13. **No dispatch refs in instructions** — `instructions.txt` must not
    tell the agent to dispatch other skills. Subagents cannot dispatch;
    only the host agent can. "Related" context references are OK;
    "run this skill" or "dispatch this" → FAIL.
14. **No spec breadcrumbs in runtime** — the runtime surface (`SKILL.md`
    and `instructions.txt`) must not reference the skill's own companion
    `spec.md`, not as a pointer, breadcrumb, or "see spec.md" hint. The
    compressed runtime is self-contained; pointing the agent at the spec
    invites context inflation and defeats compression. Exception: skills
    whose operation takes a spec as input (e.g. `spec-auditing`,
    `skill-auditing`) may reference `spec.md` files that are the subject
    of the operation — never the skill's own companion spec.
15. **Eval log presence (informational)** — perform the eval-presence
    check by reading the co-located `eval.txt` sub-instructions. Full
    procedure (four-option suggestion, honest-state principle,
    verdict-gate rule) lives in `eval.txt` / `eval.uncompressed.md`.
    Absence of `eval.txt` MUST NOT affect the verdict.
16. **(A-FM-2) Description not restated** — search every artifact
    (`uncompressed.md`, `SKILL.md`, `instructions.uncompressed.md`,
    `instructions.txt`) for body prose that duplicates the `description`
    frontmatter value. Any restatement → LOW (escalate to HIGH if
    verbatim duplication).
17. **(A-FM-5) No exposition in runtime artifacts** — scan `SKILL.md`,
    `uncompressed.md`, `instructions.uncompressed.md`, and
    `instructions.txt` for rationale, "why this exists," root-cause
    narrative, historical notes, or background prose. Any found → HIGH.
    Rationale belongs exclusively in `spec.md`.
18. **(A-FM-6) No non-helpful tags** — check all artifacts for descriptor
    lines that carry no operational value (e.g., "inline apply directly no
    dispatch," "dispatch skill," bare type labels not used as actionable
    instructions). Any found → LOW.
19. **(A-FM-7) No empty leaves** — empty section = leaf heading with no
    body AND no subheadings before the next heading at the same level or
    higher (or EOF) → HIGH. Headings with subsections are never empty.
20. **(A-FM-8) Iteration-safety placement** — verify the Iteration Safety
    blurb is absent from `instructions.uncompressed.md` and
    `instructions.txt`. Presence in either → HIGH. Additionally, if the
    guard appears in both `SKILL.md` and `instructions.*`, flag as
    probable duplication → HIGH.
21. **(A-FM-9a) Iteration-safety pointer form** — if a caller skill
    references iteration-safety, verify it uses the exact 2-line pointer
    block form (`Do not re-audit unchanged files.` + `See
    \``<path>`/iteration-safety/SKILL.md\`.`) and that the relative path
    matches the caller's actual folder depth. Any deviation → HIGH.
22. **(A-FM-9b) No verbatim Rule A/B restatement** — scan all artifacts
    for verbatim restatement of iteration-safety Rules A or B beyond the
    sanctioned 2-line pointer block. Any found → HIGH.
23. **(A-XR-1) Cross-reference anti-pattern** — scan `SKILL.md`,
    `instructions.txt`, any sub-instructions (e.g. `eval.txt`),
    `instructions.uncompressed.md`, `uncompressed.md`, and `spec.md` for
    cross-skill references that supply ONLY a path with no canonical skill
    name. Per R-FM-11, every cross-skill reference MUST identify the target
    by its `name` (the value of `name:` in that skill's SKILL.md frontmatter);
    a relative path MAY follow the name as an optional "see this file"
    pointer for direct (non-plugin) reading.

    **Violations (any other cross-file pointer with NO canonical name → HIGH):**

    - `See ../compression/uncompressed.md for details.` (path, no name)
    - `Consult ../spec-writing/spec.md for the format.` (path, no name)
    - Inline links to `.uncompressed.md` / `.spec.md` of another skill with no
      name reference.

    **Permitted (do NOT flag):**

    - Sibling skill by name only: ``the `compression` skill``
    - Name + folder pointer: ``the `compression` skill (`../compression`)``
    - Name + specific-file pointer: ``the `compression` skill's tier rules
      (`../compression/<tier>/rules.txt`)``
    - References to OWN sub-files within the same skill folder.
    - Subject-matter mentions of these file types within skill-auditing
      itself (which audits these files as targets).

    Note: pointers to a sibling's `uncompressed.md` or `spec.md` are still
    load invitations even when a name is present; prefer pointing at the
    skill folder or a more specific sub-file (e.g., `tier/rules.txt`,
    embedded examples). This is preference, not a violation.

## Dispatch Skill Audit Criteria

Applies to dispatch skills only. Auditor runs these checks against `uncompressed.md`
(the host-facing card). Each check is a gate: violation → flag at the severity stated.

1. **Return shape declared (DS-1)** — the host card MUST declare the return shape
   explicitly. Canonical shapes: `PATH: <abs-path-to-artifact>` on success,
   `ERROR: <reason>` on pre-write failure. A card that returns content (multi-line
   reports, structured findings, inline results) instead of a path — for a skill that
   produces an artifact — MUST be flagged HIGH. The artifact lives at the path;
   consumers read it from disk only when they need it.

2. **Host card minimalism (DS-2)** — The host card (`uncompressed.md` when present;
   or `SKILL.md` for `SKILL.md`-only dispatch skills) MUST NOT contain any of the
   following; each present → HIGH:
   - Internal cache mechanism descriptions (e.g., "iteration-safe via hash-record",
     "hash blob check") — caching is implementation detail invisible to the host.
     **Exception:** A-FM-10 inline result check protocol sections (pre-dispatch cache
     check + post-execute result routing via a co-located result tool) are explicitly
     allowed host behavior — auditors MUST NOT flag these as DS-2 violations.
   - Adaptive/conditional rules invisible to the host (e.g., "MD041 auto-suppressed
     when frontmatter present") — those belong in `instructions.uncompressed.md`.
   - Tool-fallback hints (e.g., "use the CLI if available") — those belong in
     instructions where the dispatched agent decides.
   - Subjective qualifiers (e.g., "Sonnet-class equivalent or diminishing returns")
     — replace with the operative model class in the dispatch line.
   - Prose describing what the skill does or how it works internally — that belongs
     in `spec.md`. The card answers: how to dispatch, what params, what return shape,
     what modes. Nothing else.

3. **Description trigger phrases (DS-3)** — the frontmatter `description` MUST follow
   the pattern: `<one-line action>. Triggers - <phrase1>, <phrase2>, ..., <phraseN>.`
   with comma-separated trigger phrases. **Trigger phrases must be present.** Violations:
   - **No trigger phrases at all** — description is prose without any `Triggers -` block.
     The skill is undiscoverable. → HIGH.
   - **Trigger phrases stuffed with implementation notes** (e.g., "Dispatch skill",
     "Iteration-safe via hash-record", "Zero errors gate") — these waste trigger-phrase
     budget and must be removed. → HIGH.
   - Phrase count is not policed (any count is acceptable; the upper bound is
     practical not normative).

4. **Inline dispatch guard (DS-4)** — dispatch skills MUST use the canonical
   prompt-only dispatch pattern. See `dispatch/dispatch-pattern.md` for context.

   Required elements in `uncompressed.md`:
   - `<instructions>` binding MUST include a `NEVER READ` guard (e.g. `NEVER READ THIS FILE` or `NEVER READ`) on the same line.
   - `<prompt>` binding MUST use the `Read and follow <instructions-abspath>` form.
   - MUST delegate via `Follow dispatch skill. See <path>/dispatch/SKILL.md`.

   Violations:
   - Missing `NEVER READ` guard on the `<instructions>` binding → HIGH.
   - Missing `<prompt>` binding or not using the `Read and follow` form → HIGH.
   - Missing `Follow dispatch skill. See ...` delegation line → HIGH.
   - Stale standalone opener (`Without reading... yourself, spawn...`) or closer (`NEVER READ OR INTERPRET...`) outside the variable block → MEDIUM (stale pattern; remove).

5. **No substrate duplication in consumers (DS-5)** — consumer skills that produce
   records (audit reports, hygiene reports, review reports) MUST NOT inline the
   hash-record path schema, frontmatter shape, or shard layout from a referenced
   substrate skill (e.g., `hash-record`). They MUST reference the substrate by name
   only. Duplication of path math, frontmatter schema, or shard layout → HIGH.

6. **No overbuilt sub-skill dispatches for trivial work (DS-6)** — a sub-skill folder
   whose entire procedure could be expressed as 2–3 inline steps in the consumer's
   instructions is an anti-pattern. Two extra lines of inline procedure in a
   haiku-dispatched consumer are cheaper than spawning another haiku for those two
   lines. Auditor flags any sub-skill whose procedure fits entirely within 2–3 steps
   that a consuming agent could execute directly → LOW (escalate to HIGH if the
   sub-skill adds no logic beyond a filesystem operation plus a write).

7. **(A-FM-10) Launch-script form on dispatch skills** — `uncompressed.md` is
   optional for dispatch skills; absence is not a finding (see SKILL.md-only skill
   in Definitions). IF `uncompressed.md` is present for a dispatch skill, it MUST
   contain only: frontmatter, optional H1, dispatch invocation + input signature,
   return contract, optional 2-line iteration-safety pointer, optional inline result
   check protocol (pre-dispatch cache check + post-execute result routing via a
   co-located result tool). Any content beyond these elements (executor procedure,
   Modes tables, examples, rationale, Related breadcrumbs, Behavior sections, Output
   format descriptions, model-class guidance, false-positive guard lists) → HIGH.
   Content belongs in `instructions.uncompressed.md` or `spec.md`.

8. **(DS-7) Tool integration alignment** — for skills that ship a co-located tool
   trio (`<stem>.sh` + `<stem>.ps1` + `<stem>.spec.md`), the auditor MUST check
   integration without auditing the tool itself (that is `tool-auditing`'s job):
   - **Orphan tool** — every tool present in `skill_dir` MUST be referenced by
     `SKILL.md` or `spec.md` (by stem name or relative path). Unreferenced tool
     present → HIGH.
   - **Missing tool** — every tool referenced by `SKILL.md` or `spec.md` MUST
     exist in `skill_dir` as a complete trio. Referenced tool absent or
     incomplete trio → FAIL.
   - **Tool-spec alignment** — IF a referenced tool has a `*.spec.md`, its
     declared behavior (`Purpose`, `Output`, return contract) MUST be consistent
     with how `SKILL.md` / `spec.md` describes the tool's role. Contradiction
     (main spec says "moves A to B"; tool spec says "deletes") → FAIL.
   The auditor reads tool-spec text for this check; tool files (`.sh`, `.ps1`,
   `*.spec.md`) remain excluded from the manifest hash per Step 1.

9. **(DS-8) Canonical trigger phrase** — for dispatch skills, the `description:`
   field in `SKILL.md` MUST contain the canonical action phrase for the skill.
   The canonical phrase is derived by replacing hyphens with spaces in the skill
   directory name (e.g., `spec-auditing` → "spec audit", `tool-auditing` →
   "tool audit", `markdown-hygiene` → "markdown hygiene").

   A multi-word trigger of the form `<verb> <root>` or `<root>` (root alone,
   hyphenated or space-separated) MUST appear verbatim (case-insensitive) in
   the description triggers list.

   Finding: if the canonical phrase (or its hyphenated equivalent) does not
   appear in `description:`, emit HIGH: "Canonical trigger phrase `<phrase>`
   missing from description triggers."

These checks extend Step 3. Violations are recorded in the Step 3 findings table
under a "Dispatch Skill Checks" group and accumulate into the main Verdict Rules tally.
A single HIGH dispatch finding moves verdict to NEEDS_REVISION; 3+ HIGH findings from
any combination of Step 1, Step 3, and Dispatch Skill Audit checks trigger FAIL.
LOW dispatch findings count toward the two-or-more-LOW threshold for NEEDS_REVISION.

## Banned Terminology

The executor MUST NOT use the term **"non-goals"** in any finding text, recommendation, or output. The term is ambiguous. Use **"Out of Scope"** instead.

When auditing skill content, the executor MUST flag any occurrence of "non-goals" in `SKILL.md`, `uncompressed.md`, `instructions*.md`, or `spec.md` as a HIGH terminology finding under Step 1 (Compiled Artifacts) or Step 3 (Spec Alignment) as appropriate, and recommend renaming the section or term to "Out of Scope".

## Verdict Rules

- CLEAN: All steps pass with zero findings (no HIGH, no LOW, no informational). Audit produced nothing to report.
- PASS: All steps pass with no HIGH findings. Non-blocking findings (LOW, informational) may be present. Safe to seal.
- NEEDS_REVISION: No FAIL findings, but (1) any HIGH finding, or (2) two or more LOW findings. Skill works but has quality gaps. List specific fixes and do a fix pass before sealing.
- FAIL: Any FAIL finding, or 3+ HIGH findings. Skill cannot be used reliably. Do not seal until fixed.

## Audit Report Format

Record frontmatter (written to hash-record path):

```yaml
---
file_paths:
  - skill-auditing/instructions.uncompressed.md
  - skill-auditing/SKILL.md
  - skill-auditing/spec.md
  - skill-auditing/uncompressed.md
operation_kind: skill-auditing/v2
model: <executing-model-class>
result: clean | pass | findings | fail
---
```

**No `hash:` field in frontmatter.** The record's directory path already encodes the manifest hash (`.hash-record/<aa>/<full-hash>/...`). Putting the same hash in the body creates a duplicate source of truth that drifts on hand-edit and complicates rekeying. Path is authoritative; body MUST NOT restate it. This rule applies fleet-wide — auditing skills writing hash-record artifacts MUST NOT include a `hash:` field when the path already encodes the hash.

`file_paths` MUST be a YAML list of repo-relative path strings — one entry per source
file consumed in the manifest hash, sorted lexically. The repo root MUST be resolved
from the skill's location, not from CWD:

```bash
target_dir=$(dirname "<skill_path>")
repo_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
# Fallback: no .git/ found → place .hash-record/ adjacent to the skill directory
[ -z "$repo_root" ] && repo_root="$target_dir"
```

Compute each repo-relative path via `git ls-files --full-name <file>` from inside the
file's repo, or strip `<repo-root>/` from each absolute path.

```yaml
# Correct:
file_paths:
  - skill-auditing/instructions.uncompressed.md
  - skill-auditing/SKILL.md
  - skill-auditing/spec.md
  - skill-auditing/uncompressed.md

# Correct (minimal manifest for a SKILL.md-only dispatch skill):
file_paths:
  - skill-auditing/SKILL.md
  - skill-auditing/spec.md

# WRONG (directory only, no filenames):
file_path: skill-auditing/

# WRONG (absolute paths):
file_paths:
  - /abs/path/to/skill-auditing/SKILL.md

# WRONG (singular file_path in a multi-file context):
file_path: skill-auditing/SKILL.md
```

**Mandatory examples in instructions** — auditor instruction artifacts (`instructions.txt` and `instructions.uncompressed.md`) MUST embed the same Correct + WRONG `file_paths` example block alongside the report-write step. This is a common error class (agents emit `file_path: <dir>/`, absolute paths, or singular keys in multi-file contexts); explicit examples at the point of writing are protective and load-bearing. Removing the examples from instructions is a regression — flag any pass that strips them.

Record body:

```markdown
# Result

CLEAN | PASS | NEEDS_REVISION | FAIL

## Skill Audit: <skill-name>

**Verdict:** CLEAN | PASS | NEEDS_REVISION | FAIL
**Type:** inline | dispatch
**Path:** <repo-relative path>

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
| Return shape declared (DS-1) | PASS/FAIL/N/A | |
| Host card minimalism (DS-2) | PASS/FAIL/N/A | |
| Description trigger phrases (DS-3) | PASS/FAIL/N/A | |
| Inline dispatch guard (DS-4) | PASS/FAIL/N/A | |
| No substrate duplication (DS-5) | PASS/FAIL/N/A | |
| No overbuilt sub-skill dispatch (DS-6) | PASS/FAIL/N/A | |
| Launch-script form (A-FM-10) | PASS/FAIL/N/A | |

### Issues
- <specific issue and fix>

### Recommendation
<one-line summary>

```

## Dispatch Parameters (for the auditor agent)

The host composes a `<prompt>` containing the inputs below and follows the `dispatch` skill (see `dispatch/SKILL.md`). The host does NOT pass a `--filename` flag — the record filename is hardcoded as `report.md` by the executor.

- `skill_dir` (string, required): Absolute path to the skill folder being audited.
- `--report-path <abs-path>` (string, required): Absolute path to write the report.

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

1. **Iterate tier** — a fast-cheap model class (Haiku-class, or any
   equivalent inexpensive tier the host has available).
   Use for iterative audit-fix cycles: when the auditor returns
   NEEDS_REVISION, fix and re-run at this tier. Repeat until PASS.
2. **Sign-off tier** — a standard model class (or any equivalent
   default tier the host has available). Run one final audit at this
   tier after the iterate tier returns PASS. Only a sign-off-tier PASS
   is production-ready.

Rationale: the iterate tier catches structural and obvious issues
cheaply; the sign-off tier catches subtle compliance gaps. Running
the sign-off tier on every iteration wastes tokens on issues the
iterate tier already found.

The terms fast-cheap and standard are model-agnostic. Hosts running
Anthropic models map these to Haiku-class and Sonnet-class respectively;
other model families should map to their own inexpensive/default tiers.

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Auditing Constraints

- Auditor is read-only. The companion `spec.md` and all compiled runtime files (`SKILL.md`, `instructions.txt`) are immutable.
- One skill per dispatch — don't batch audit multiple skills in one run.
- Verdict must be justified with evidence from the skill files.
- When in doubt, NEEDS_REVISION over PASS — be adversarial.

## Error Handling

- **Target not found** (`skill_dir` does not resolve): return `ERROR: skill_dir not found: <path>`. Do not write a partial report.
- **Spec not found** (no co-located `spec.md`): if skill is dispatch or complex inline, record FAIL finding for spec alignment and continue the sweep. If simple inline (no configurable parameters, no conditional branching, no multi-step decision procedure), skip spec alignment.
- **Inline/dispatch mismatch** (`instructions.txt` absent when SKILL.md indicates dispatch, or present when inline): record FAIL finding under compiled artifacts step.
- **Report path not writable**: return `ERROR: <reason>` and exit without altering any skill file.

## Precedence Rules

1. `spec.md` is authoritative over `uncompressed.md` and SKILL.md in all content disputes.
2. `uncompressed.md` takes precedence over SKILL.md for procedure detail.
3. `skill-writing/spec.md` governs what constitutes a valid skill structure; this auditing
   spec governs the audit procedure itself.
4. Iterate-tier findings are preliminary; a sign-off-tier PASS is required for
   production-ready status. An iterate-tier PASS alone does not equal production-ready.

## Don'ts

- Do not modify any file in `skill_dir` — auditor is read-only.
- Do not modify `spec.md`, `README.md`, `SKILL.md`, or `instructions.txt` — spec is authoritative; README is human-facing; compiled runtime files are regenerated by `compression`, not the auditor.
- Do not batch-audit multiple skills in a single dispatch invocation.
- Do not infer intent — verdicts must be grounded in explicit file content.
- Do not run steps out of order.
- Do not produce a PASS verdict when evidence is ambiguous — use NEEDS_REVISION.
- Do not include dispatch instructions (e.g., "run this skill") in instructions.txt.
- Do not reference skills by inlining their content — use pointers only.
- Do not pass A-XR-1 if any skill artifact (other than skill-auditing's own files as subject-matter context) contains a cross-skill reference that supplies ONLY a path with no canonical name. Bare-name and name-with-path-pointer references pass.
- Do not pass A-FM-8 if the Iteration Safety blurb appears in `instructions.uncompressed.md` or `instructions.txt`, even if it is also present in `SKILL.md`.
- Do not rate A-FM-9a/9b as N/A unless the skill contains no iteration-safety reference at all; if any reference is present, check pointer form and verbatim restatement.

## Appendix — Design Goal: Haiku Wins the Eval Game

(Rationale; non-normative.)

Sonnet-class is the baseline — table stakes. A working skill must run
correctly under sonnet. Haiku-class is the **winning bar**: a skill that
also runs reliably under haiku has won the eval game. Cheap, deterministic,
predictable across runs.

The audit's job is to push every skill toward the haiku bar. A
haiku-executable skill is one a haiku-class agent can run almost like
reading a program — small, concise, unambiguous instructions, explicit
decision branches, minimal prose, and zero interpretive slack.

When a skill needs sonnet to "make sense of" the instructions, the fix
is rarely "use a stronger model." It's almost always tighten the
instructions: replace prose conditionals with decision trees, replace
ambiguous directives with explicit step lists, replace implied behavior
with normative statements. Audit findings that close interpretive slack
take priority — they're the moves that get a skill from "works on
sonnet" to "wins on haiku."

Token cost compounds across calls. A skill invoked 100 times saves real
money when its haiku runs hold up. Verdicts are weighted toward findings
that move a skill closer to reliable haiku execution.
