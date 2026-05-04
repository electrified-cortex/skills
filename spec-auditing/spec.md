# Spec Auditing Specification

## Purpose

Defines authoritative behavior of the spec-auditing dispatch skill.

The spec auditor reviews a target spec and its companion file, determines
alignment, completeness, consistency, and fitness for use.

Source of truth for audit procedure and finding format.

### Adopted Patterns (from SPEC-kit)

- **`[NEEDS CLARIFICATION]`**: embed in specs to flag ambiguity explicitly.
  Auditor should flag any requirement that could reasonably be interpreted
  two ways, rather than choosing one interpretation silently.
- **Constitution constraints**: immutable rules that override all other
  content (e.g., "never modify spec during audit" is constitutional).

---

## Identity

**Name:** Spec Auditing
**Role:** Deterministic specification auditor
**Primary Responsibility:** Audit a spec and its companion file for correctness, consistency, completeness, and clarity
**Disposition:** Strict, skeptical, evidence-based, non-creative during audit mode

The agent must behave as an auditor, not as an author, unless explicitly asked to propose repairs after the audit.

---

## Version

1

Bump this when the audit semantics, output schema, or check codes change in a way that invalidates prior records. The version is reflected in the `operation_kind` used by the result record (`spec-auditing/v1`).

---

## Scope

The auditor operates in one of two modes:

**Pair-audit mode** (default): evaluates a spec file and its companion file together.
**Spec-only mode**: evaluates a single spec file for spec quality alone. This
mode may be requested explicitly via audit context, or entered automatically
when no companion is present (see § Spec-Only Mode).

In pair-audit mode, the auditor evaluates:

1. **Spec File**
   - The normative source describing rules, requirements, expectations, structure, or behavior
   - Usually a markdown file intended to serve as the specification

2. **Target File** (companion)
   - A related file that implements, explains, summarizes, derives from, or operationalizes the spec
   - Examples:
     - an agent file
     - a README
     - an implementation guide
     - an operating policy
     - a prompt/instruction file
     - a usage contract

The auditor must treat the spec as normative unless this file explicitly declares a different precedence rule.

---

## Spec-Only Mode

When the target is a `spec.md` file and the caller explicitly requests
spec-only mode, or when no companion is present (see §Companion Auto-Detect),
the auditor operates in spec-only mode.

### What is audited

In spec-only mode the auditor evaluates the spec file against its own quality
criteria:

- **Completeness** — are all required sections present; are terms defined; are
  procedures complete?
- **Enforceability** — are requirements testable; is language precise; are
  vague/aspirational statements flagged?
- **Structural Integrity** — logical ordering; stable headings; no hidden
  requirements in examples; normative language consistent.
- **Economy** — duplicated rules, unnecessary scaffolding, or prose that can be
  removed without changing the spec's effect.
- **Terminology** — defined terms used consistently; undefined critical terms
  flagged; synonym drift flagged.
- **Internal Consistency** — no contradictions within the spec itself.

### What is not audited

The following checks require a companion file and are skipped:

- Semantic Alignment (spec vs companion)
- Requirement Coverage (companion coverage of spec requirements)
- Contradiction Detection (spec vs companion)
- Unauthorized Additions (companion scope expansion)
- Compression Fidelity (loss/gain/bloat)
- Change Drift Risk (cross-file divergence)

### Fix mode in spec-only

`--fix` modifies the companion file to align it with the spec. In spec-only
mode there is no companion, so there is nothing for `--fix` to act on. Fixing
the spec itself is an authorial act requiring domain judgment and is never
done by the auditor.

If `--fix` is passed in spec-only mode: ignore the flag, report that fix mode
is unavailable in this mode, and run a read-only audit. Any spec defects
surface as findings for the caller to act on.

### Output in spec-only mode

Use the standard output structure. Set Coverage Summary to:
"N/A — spec-only mode, no companion present."

---

## Definitions

- **Spec file**: the normative markdown document describing rules, requirements, expectations, structure, or behavior for a system or artifact.
- **Named file spec**: a spec file named `spec.md` (canonical) or legacy `<name>.spec.md` that governs a directory, skill, or artifact set.
- **Folder spec**: a `spec.md` file that governs a directory, artifact set, primary thing in that directory, or a hierarchy of child specs/folders. It is not interpreted as a same-basename file-targeting spec.
- **Companion file**: a related file that implements, explains, summarizes, derives from, or operationalizes the spec. Also called "target file."
- **Target file**: synonym for companion file in pair-audit mode; the file being evaluated against the spec.
- **Finding**: a numbered, severity-labeled observation of a defect, weakness, or risk in the audited material.
- **Pair-audit mode**: the auditor evaluates a spec file and its companion file together.
- **Spec-only mode**: the auditor evaluates a single spec file for spec quality alone, either because the caller explicitly requested that mode or because no companion is present.
- **Drift**: accidental semantic divergence between the spec and its companion over time, or within the spec itself.
- **Compression fidelity**: the degree to which the companion faithfully preserves the meaning of the spec without loss (dropped requirements) or gain (unauthorized additions).
- **Unauthorized addition**: content in the companion that has no basis in the spec and that the spec does not permit via extension. A defect.
- **Valid extension**: an addition in the companion that fits within an extension point explicitly permitted by the spec.
- **Derived but unstated**: an addition in the companion that is a reasonable inference from the spec but is not explicitly stated. Must be flagged.
- **Meaningful** (as in "meaningful conflict" or "meaningful requirement"): any requirement, prohibition, or constraint that affects observable behavior or that an implementor or auditor would need to act on; excludes phrasing variation with identical effect.
- **Material** (as in "materially incomplete"): a gap or weakness significant enough that a reader cannot reliably interpret or act on the document; excludes minor wording issues or incomplete examples that do not affect the normative content.
- **Sufficient** (as in "sufficient information to audit"): enough normative content exists to evaluate the companion against the spec without guessing at intent; the auditor can formulate a testable criterion for each checked dimension.

---

## Audit Objective

The objective is to determine whether the companion file faithfully reflects and supports the spec without introducing contradiction, omission, ambiguity, or unjustified drift.

The auditor must identify:

- contradictions
- omissions
- vague or unenforceable language
- requirements present in one file but absent in the other
- accidental semantic drift
- duplicated but mismatched concepts
- structural weaknesses that make future divergence likely

---

## Precedence Rules

Unless otherwise stated:

1. This skill spec defines how the audit must be conducted.
2. The audited spec defines what is authoritative about the subject matter.
3. The companion target is subordinate to the audited spec.

If the companion target conflicts with the audited spec, the audited spec wins.

If the audited spec conflicts with this skill spec's audit rules, this skill
spec wins for audit procedure, while the audited spec remains authoritative for
domain content.

The auditor must never silently reconcile conflicts. All meaningful conflicts must be reported.

---

## Inputs

The auditor expects:

- one target path: either the spec file or the companion file being audited
- optional explicit spec path override when the target path points to a companion file (`--spec <spec-path>`)
- required report output path supplied by the host (`--report-path <path>`); executor writes the hash-record verdict there; skip write if absent or empty (no-cache path)
- optional audit context, including an explicit request for spec-only mode when the caller wants to audit a spec in isolation
- optional repository or project conventions
- optional severity thresholds
- optional audit kind flag (`--kind meta` or `--kind domain`) to control how Unauthorized Additions (§ Unauthorized Additions) are evaluated in pair-audit mode; see § Audit Kind.

If the spec file is missing, the audit must fail with a clear explanation.
A missing companion file triggers companion auto-detect and possibly spec-only
mode — it is not an immediate failure.

### Spec Lookup Convention

If no spec path is provided, the auditor should look for `spec.md`
in the same directory as the target file. This convention co-locates specs with
their files and makes the relationship discoverable without a registry.

### Companion Auto-Detect

When the target filename ends in `spec.md`, no `--spec` flag is provided, and
the caller has not explicitly requested spec-only mode, the auditor checks for
a companion via this fallback chain (in order):

1. If the target is a named file spec, sibling `<name>.md` in the same directory

For a folder spec, companion auto-detect has no additional universal fallback.
If the folder spec should pair-audit against a specific companion, that
relationship must be supplied by the caller through an explicit path.

If a companion is found, the auditor proceeds in pair-audit mode and reports
which candidate was auto-detected. If multiple candidates match, the first in
the priority order above is used and the ambiguity is reported.

If no companion is found, the auditor proceeds in spec-only mode and reports
"no companion present — auditing spec alone."

### One Per Invocation

The auditor evaluates exactly one spec or spec-file pair per invocation.
Callers chain multiple subjects as separate runs.

### Dispatch Requirement

This skill must be invoked via a dispatch agent with zero inherited context. Inline invocation is prohibited — it produces shallow, inconsistent audits and burns tokens on content only the dispatched auditor needs.

### Audit Kind

The auditor supports two audit kind values, selectable via `--kind meta|domain` or auto-detected:

**Meta mode** (`--kind meta`): Applies full pair-audit with all 13 steps unchanged — 2 extraction steps plus 11 audit dimensions (see §Required Audit Dimensions and §Behavior). Use when pairing a companion against a meta-spec (e.g., `spec-writing/spec.md`).

**Domain mode** (`--kind domain`): Applies pair-audit with § Unauthorized Additions modified. Use when auditing a domain spec against a domain authority, or when no authority is declared. Domain-specific requirements in the companion must not be flagged as unauthorized simply because they do not appear in a meta-spec.

**Auto-detection** (when `--kind` is not provided): if the spec path contains `spec-writing`, the auditor infers meta mode and reports the inference. Otherwise, the auditor infers domain mode and reports the inference.

Audit kind applies to pair-audit mode only. Spec-only mode is unaffected.

---

## Defaults and Assumptions

Unless explicitly overridden, the auditor may assume:

- both files are intended to describe the same system, behavior, or contract
- both files should be meaningfully aligned
- markdown headings and structure are semantically relevant
- normative statements include explicit or implied requirements
- examples are subordinate to rules unless explicitly designated as normative

The auditor must not assume that similarity of wording implies similarity of meaning.

---

## Required Audit Dimensions

The auditor must evaluate the following dimensions.

### 1. Semantic Alignment

Determine whether the companion file preserves the intended meaning of the spec.

Checks include:

- same concepts refer to the same things
- terminology is used consistently
- no meaning is weakened, broadened, or narrowed without justification
- examples do not contradict the rules they illustrate

### 2. Requirement Coverage

Determine whether all meaningful requirements in the spec appear in the companion file at the appropriate level.

Checks include:

- explicit requirements are represented
- implied operational constraints are represented when necessary
- important prohibitions are preserved
- mandatory behaviors are not omitted

### 3. Contradiction Detection

Determine whether the files disagree.

Checks include:

- direct contradictions
- indirect contradictions through wording changes
- contradictory defaults
- conflicting precedence or override rules
- conflicting terminology definitions

### 4. Completeness

Determine whether either file is materially incomplete relative to its purpose.

Checks include:

- missing sections needed for interpretation
- dangling references
- undefined terms
- incomplete procedures
- missing exception handling
- absent decision criteria

### 5. Enforceability

Determine whether the spec can actually be audited or followed.

Checks include:

- vague words without criteria
- non-testable requirements
- aspirational language presented as requirements
- subjective phrases without rubric
- instructions that cannot be verified from the text

### 6. Structural Integrity

Determine whether document organization helps or harms reliable interpretation.

Checks include:

- logical section ordering
- stable heading structure
- no duplicated rules across multiple sections unless intentionally cross-referenced
- no hidden requirements buried in examples or notes
- consistent use of normative language
- spec file must not contain YAML frontmatter — specs are human-authored governance documents; frontmatter (`name:`, `description:`, `type:`) belongs only in runtime artifacts (`SKILL.md`, agent files, tool scripts). A spec with frontmatter signals confused authoring intent and may cause tooling to treat it as a runtime artifact.

### 7. Terminology and Definitions

Determine whether important terms are stable and well-defined.

Checks include:

- defined terms are used consistently
- undefined critical terms are flagged
- synonyms that create ambiguity are flagged
- renamed concepts are mapped or reported

### 8. Change Drift Risk

Determine whether the current structure makes future divergence likely.

Checks include:

- duplicated requirement statements
- companion paraphrases that restate rules loosely
- hidden assumptions only present in one file
- structurally isolated sections that should cross-reference each other

### 9. Unauthorized Additions (Scope Expansion)

Determine whether the companion (target) file introduces concepts, rules, behaviors, constraints, or terminology that do not exist in the primary spec.

Checks include:

- new requirements not present in the primary spec
- additional constraints or restrictions
- new features, capabilities, or behaviors
- new terminology that implies new concepts
- expanded scope beyond what the spec defines
- inferred rules presented as explicit requirements
- defaults or assumptions introduced without basis in the spec

Each addition must be classified as one of:

- **Valid Extension (Explicitly Allowed)**
  The spec permits extension and the addition fits within defined extension points.

- **Derived but Unstated**
  Reasonable inference from the spec, but not explicitly stated. Must be flagged.

- **Unauthorized Addition**
  No support in the spec. This is a defect.

**Domain mode behavior:** When audit kind is domain:

- If a domain authority spec is provided via `--spec`, apply the three-way classification against that authority.
- If no domain authority spec is provided, skip this check and report as Informational: "domain mode, no authority declared — Unauthorized Additions check skipped."

The auditor must not assume additions are acceptable unless the spec explicitly allows extension.

### 10. Economy

Determine whether every element earns its place. The test for each element: *can it be removed and the effect is the same?* If yes, it is waste.

Checks include:

- sections that duplicate content already stated elsewhere
- requirements that could be merged without loss of precision
- definitions, examples, or prose that add length but not meaning
- companion longer than the spec it implements (signal of bloat)
- structural scaffolding that exceeds the complexity of the content it frames

The auditor must apply the removal test to each flagged element and confirm the effect before reporting it. Consolidation opportunities are Informational findings. Where waste creates drift risk, escalate to Low or Medium.

### 11. Compression Fidelity

Determine whether the companion preserves the spec's meaning without loss,
gain, or unjustified bloat.

Checks include:

- loss: requirements, constraints, or distinctions dropped from the spec
- gain: new requirements or behaviors introduced without support in the spec
- bloat: added material that does not improve the companion's fit for purpose

Compression fidelity failures are governance defects: loss and gain should be
treated as High or higher depending on impact; bloat is normally Medium unless
it materially increases drift risk.

---

## Severity Levels

All findings must be labeled with one severity:

### Critical

A defect that breaks trust in the spec, makes implementation unsafe, or reverses important meaning.

Examples:

- direct contradiction of a must/shall requirement
- missing gating rule
- inverted precedence
- omitted safety constraint

### High

A defect that materially weakens correctness, completeness, or auditability.

Examples:

- missing required behavior
- ambiguous rule with real downstream impact
- companion file broadens spec scope without authorization

### Medium

A meaningful weakness that should be corrected but does not immediately invalidate the spec.

Examples:

- undefined important term
- unclear wording
- incomplete section that is still partly usable

### Low

A minor quality issue.

Examples:

- wording roughness
- minor structure issue
- non-blocking duplication

### Informational

An observation, improvement opportunity, or note about maintainability.

---

## Pass / Fail Rules

The audit result must be one of:

- **Pass**
- **Pass with Findings**
- **Fail**

Default rules:

- **Fail** if any Critical finding exists
- **Fail** if two or more High findings exist
- **Pass with Findings** if the audit produces any finding and no fail condition is met
- **Pass** only if no findings are produced

If a custom threshold is provided and it tightens the default rules, the
auditor must apply it and state the threshold used. Custom thresholds must
never loosen the default rules.

---

## Evidence Standard

Every non-trivial finding must include evidence.

Evidence should include:

- file name
- section heading, if available
- quoted text or precise excerpt
- explanation of why the issue exists
- explanation of why the issue matters

The auditor must distinguish clearly between:

- direct evidence
- reasonable inference
- uncertainty

The auditor must not present inference as fact.

---

## Output Requirements

The audit output must contain these sections in order:

### 1. Audit Result

A single top-level result:

- Pass
- Pass with Findings
- Fail

### 2. Executive Summary

A concise summary of the overall state of alignment between the two files.

### 3. Findings

A numbered list of findings.
Each finding must include:

- ID
- Severity
- Title
- Affected file(s)
- Evidence
- Explanation
- Recommended fix

### 4. Coverage Summary

A short assessment of:

- what parts of the spec are well represented
- what parts are missing or weakly represented
- whether the companion file is fit for purpose

**Spec-only mode:** label this section "N/A — spec-only mode, no companion
present." Do not include companion coverage assessment.

### 5. Drift and Risk Notes

Any structural observations about likely future divergence.

### 6. Repair Priorities

A prioritized repair sequence, highest value first.

### 7. Return Token

After writing the report to the hash-record path, the executor must emit exactly one final line of stdout — the return token. This line must be the last line of stdout, starting at column 0 with no indentation, no quoting, and no list-marker prefix. Nothing may follow it.

`PATH: <abs-path>` is emitted by the HOST on a cache hit (executor not invoked).
The executor emits one of the following:

- `Pass: <abs-path>` — audit complete, no findings
- `Pass with Findings: <abs-path>` — audit complete, findings present, no fail condition
- `Fail: <abs-path>` — audit failed; Critical or 2+ High findings
- `ERROR: <reason>` — pre-write failure; no report written

---

## Required Auditor Behavior

The auditor must:

- prefer precision over politeness
- avoid inventing unstated intent
- challenge ambiguous wording
- identify hidden assumptions
- call out missing definitions
- separate hard failures from optional improvements
- avoid proposing rewrites until the audit is complete

The auditor must not:

- silently normalize contradictions
- treat examples as authoritative unless explicitly marked normative
- assume a companion paraphrase is acceptable just because it sounds similar
- rewrite the files during the audit unless explicitly asked
- downgrade issues merely because the likely intent seems obvious

---

## Requirements

Atomic, testable requirements for the auditor:

1. The auditor must evaluate every dimension listed in §Required Audit Dimensions that applies to the current mode.
2. Every non-trivial finding must carry a severity label (Critical, High, Medium, Low, or Informational).
3. Every finding must include: ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.
4. The auditor must read all resolved input files fully before issuing any judgment.
5. The auditor must never modify the spec file under any circumstances.
6. The auditor must report every conflict between files; silent normalization is prohibited.
7. The auditor must classify each companion-only addition as Valid Extension, Derived but Unstated, or Unauthorized Addition.
8. The auditor must apply the pass/fail gate rules in §Pass / Fail Rules and state the result as Pass, Pass with Findings, or Fail.
9. The auditor must emit output sections in the order: Audit Result, Executive Summary, Findings, Coverage Summary, Drift and Risk Notes, Repair Priorities, Return Token.
10. When `--fix` is active, the auditor must re-audit after each fix pass; maximum 3 passes.
11. In fix mode, fixes must be applied in severity order: Critical → High → Medium → Low; within severity: semantic → terminology → structural → stylistic.
12. The auditor must not propose rewrites until the full audit is complete.
13. Evidence must be labeled: direct evidence, reasonable inference, or uncertainty. Inference must never be presented as fact.
14. When a spec lacks sufficient information to audit the companion, the auditor must say so explicitly, state what is missing, and assess whether the result can still pass.

Additional requirements covering hash-record cache behavior are defined in §Hash-Record Cache, sub-section Requirements (hash-record) (R-HR-1 through R-HR-5). Both sets are normative.

---

## Hash-Record Cache

### Overview

spec-auditing is a deterministic, read-only operation. Given the same set of
input files and the same audit logic version, the result is identical. The
hash-record cache exploits this: on a cache hit, the auditor returns the
stored verdict immediately without dispatching an LLM.

### Manifest Hash

Compute from all input files (target spec and companion, if present):

1. For each input file, compute `git hash-object <file>`.
2. Sort file paths lexically (repo-relative).
3. Concatenate as `<blob-hash> <repo-relative-path>\n` for each file.
4. `sha256sum` the concatenation.

Exclude dot-prefixed directories and non-input files. Include only the files
actually audited in this invocation.

### Cache Path

```text
<repo_root>/.hash-record/<manifest_hash[0:2]>/<manifest_hash>/spec-auditing/v1/report.md
```

`<manifest_hash[0:2]>` is the first two characters of the manifest hash
(shard directory). `spec-auditing/v1` is the operation kind for this version.

### Cache Check (at host surface)

The host runs the inline hash check (via `hash-record-manifest/manifest.sh` or `.ps1`) with `op_kind = spec-auditing/v1` and `record_filename = report.md` before any dispatch.

- **Hit** (`HIT: <abs-path>`): host emits `PATH: <abs-path>` and stops. No executor dispatched.
- **Miss** (`MISS: <abs-path>`): host binds `<report_path>` and passes it via `--report-path` to the executor.
- **Error** (untracked / non-git): host skips caching; executor runs without `--report-path` and omits record write.

The executor must NOT re-check or re-compute the cache. It receives `--report-path` from the host and writes there on completion.

### Record Write (executor, when `--report-path` is provided)

After completing the audit and before returning, write the hash-record to the
path supplied via `--report-path`. If `--report-path` is absent or empty (no-cache
path), skip this step. The file must contain a YAML frontmatter block followed
by the verdict:

```yaml
---
hash: <manifest-hash>
file_paths:
  - <repo-relative-path>     # sorted lexically; one entry per audited file
operation_kind: spec-auditing/v1
result: pass | pass_with_findings | fail | error
---
```

`result` maps: Pass → `pass`; Pass with Findings → `pass_with_findings`;
Fail → `fail`; error → `error`.

### Return Token

The final line of stdout of the overall skill invocation MUST be the return
token, at column 0, no indent, no list markers, no quoting.

Host emits (cache hit, executor not invoked):

```text
PATH: <report_path>
```

Executor emits (after full audit and hash-record write):

```text
Pass: <report_path>
Pass with Findings: <report_path>
Fail: <report_path>
ERROR: <reason>
```

`<report_path>` is the absolute path to the written hash-record file. All
narrative output MUST appear before this line; nothing may follow it.

### Repo-Root Computation

```bash
repo_root=$(git -C "$(dirname <spec_path>)" rev-parse --show-toplevel 2>/dev/null)
# Fallback if not in a git repo: place .hash-record/ adjacent to spec_path
[ -z "$repo_root" ] && repo_root="$(dirname <spec_path>)"
```

### Requirements (hash-record)

R-HR-1: The HOST MUST invoke the manifest tool (`hash-record-manifest/manifest.sh`
or `.ps1`) before dispatching the executor — before any LLM is dispatched and
before any other side effect related to this invocation.

R-HR-2: On a cache hit (`HIT:`), the host MUST emit `PATH: <abs-path>` as the
final line of stdout and MUST stop immediately without dispatching an executor.

R-HR-3: On a cache miss, the host MUST pass the computed cache path to the
executor via `--report-path <path>`. The executor MUST write the hash-record to
that path before returning any result.

R-HR-4: The `file_paths` frontmatter field MUST list only repo-relative
paths, sorted lexically. Absolute paths are prohibited.

R-HR-5: The return token MUST be the final line of stdout with no indentation
or prefix. No output may follow it.

---

## Constraints

1. The auditor must never modify the spec file. In `--fix` mode, modifications apply to the companion/target file only; the spec remains immutable. If the audit surfaces a defect in the spec itself, the auditor reports it as a finding for the caller to act on — it does not attempt to repair the spec.
2. The auditor must not approve or stamp any file — approve mode is not supported.
3. The auditor must not silently reconcile conflicts between files.
4. The auditor must not choose an interpretation silently when multiple plausible interpretations exist.
5. The auditor must not assume additions are acceptable unless the spec explicitly allows extension.
6. The auditor must not treat examples as authoritative unless explicitly marked normative.
7. The auditor must not assume a companion paraphrase is acceptable merely because it sounds similar.
8. The auditor must not downgrade a finding's severity merely because the likely intent seems obvious.
9. The auditor must not apply `--fix` in spec-only mode; if `--fix` is passed in spec-only mode, ignore the flag, report that fix mode is unavailable, and continue with a read-only audit.
10. The auditor must not invent product requirements or resolve domain disputes without textual basis.
11. One spec or spec/target pair per invocation. Multi-subject audits must be chained as separate runs.

## Banned Terminology

The auditor must not use the term **"non-goals"** in any finding text, recommendation, or output. The term is ambiguous and confusing. Use **"Out of Scope"** instead.

When auditing target or companion content, the auditor must flag any occurrence of "non-goals" as a Medium-severity Terminology finding (Audit step 9) and recommend renaming the section, heading, or term to "Out of Scope".

---

## Behavior

### Audit flow

0. **[Host]** Resolve input paths and detect mode (pair-audit or spec-only) per §Inputs and §Spec-Only Mode.
1. **[Host]** Invoke manifest tool inline (per §Hash-Record Cache / Cache Check). On a hit, emit `PATH: <abs-path>` and STOP — no executor dispatched. On a miss, bind `<report_path>` and pass via `--report-path` to the executor.
2. **[Executor]** Read all resolved files fully.
3. **[Executor]** Extract normative content (requirements, prohibitions, definitions, defaults, procedures, exceptions).
4. **[Executor]** Evaluate all applicable audit dimensions in sequence.
5. **[Executor]** Assign severity and evidence to each finding.
6. **[Executor]** Apply pass/fail gate rules.
7. **[Executor]** MUST write hash-record to the path from `--report-path` before emitting any output. Skip if `--report-path` is absent or empty. See §Hash-Record Cache / Record Write.
8. **[Executor]** Emit output in required section order.
9. **[Executor]** Emit return token as the final stdout line. See §Hash-Record Cache / Return Token.

### Pass/Fail gate

- **Fail** if any Critical finding exists.
- **Fail** if two or more High findings exist.
- **Pass with Findings** if the audit produces any finding and no fail condition is met.
- **Pass** only if no findings are produced.
- Custom thresholds may tighten (never loosen) these rules; the threshold used must be stated.

### Fix mode behavior

This is the normative home for fix-mode mechanics. §Optional Modes / §Repair Mode references this section.

When `--fix` is active:

1. Run full audit first (read-only pass).
2. The target file must be tracked in git with a clean working tree; untracked/modified/conflicted → STOP: report "target must be git-tracked and clean".
3. Apply fixes to the target file only; spec is immutable. If the audit surfaces a defect in the spec itself, report it as a finding — do not repair the spec.
4. Apply in severity order: Critical → High → Medium → Low; within severity: semantic → terminology → structural → stylistic.
5. Re-audit after each fix pass. Stop at 3 passes or earlier alignment.
6. When the spec lacks sufficient detail to guide a fix, report as a spec critique ("section X too vague", "no rationale for rule Y") rather than guessing.

---

## Iteration Safety

See §Hash-Record Cache above for caching behavior. See `../iteration-safety/SKILL.md` for the broader iteration safety pattern.

---

## Error Handling

| Condition | Action |
| --- | --- |
| Target file missing or unreadable | STOP: report "target file missing" |
| Spec file path explicitly provided but missing | STOP: report "spec file missing" |
| Target not ending in `spec.md` and sibling `spec.md` absent | STOP: report "spec file missing" |
| Input files only partially readable | STOP: report "incomplete input — cannot audit partial content" |
| Companion auto-detect finds no candidate | Proceed in spec-only mode; report "no companion present — auditing spec alone" |
| Multiple companion candidates found | Use first in priority order; report ambiguity |
| `--fix` passed in spec-only mode | Ignore the flag; report "fix mode unavailable in spec-only mode — no companion to modify"; continue with a read-only audit |
| `--fix` passed with untracked/modified/conflicted target | STOP: report "target must be git-tracked and clean" |
| Approve/stamp request received | STOP: report "approve mode not supported" |
| Manifest tool returns `ERROR:` (e.g. file untracked, non-git environment) | Host skips caching; dispatches executor without `--report-path`; executor runs full audit, omits hash-record write, emits verdict without path |

---

## Normative Language Interpretation

Unless the files define otherwise, interpret language as follows:

- **must / shall / required** = mandatory
- **must not / shall not** = prohibited
- **should / recommended** = strong guidance, not absolute
- **may / optional** = discretionary

If mandatory behavior is expressed without clear normative language but context makes it obviously binding, the auditor should flag this as an enforceability issue.

---

## Handling Ambiguity

When wording is ambiguous, the auditor must:

1. identify the ambiguity
2. explain the plausible interpretations
3. state the operational risk
4. recommend the minimum clarification needed

The auditor must not choose an interpretation silently when multiple plausible interpretations exist.

---

## Handling Missing Information

If the spec lacks information required to fairly audit the companion file, the auditor must say so explicitly.

In such cases, the auditor should report:

- what is missing
- why it blocks confidence
- whether the result is still passable
- what additional information would resolve it

---

## The Spec-File Relationship as Compression

The relationship between a spec and its companion file is a form of compression.
The spec holds full design rationale; the companion is the compressed executable
form. The auditor verifies this compression is faithful:

- **Loss (forward):** Did the companion drop something the spec requires?
- **Gain (reverse):** Did the companion add something the spec doesn't authorize?
- **Bloat:** Does the companion contain content that serves no purpose?

Both loss and gain are governance failures. Bloat is a quality issue.

## Companion File Expectations

Unless explicitly exempted, the companion file should:

- reflect all material requirements from the spec
- preserve the same intent and boundaries
- avoid introducing conflicting rules
- remain understandable to its intended audience
- never reference the spec — the companion must be self-contained and operate as if the spec does not exist
- avoid loose paraphrasing of critical requirements
- contain only content that serves the file's purpose — unnecessary information is a finding

**Dispatch-pattern exception:** A companion for a dispatch skill (one whose behavioral contract lives in a separate `instructions.txt` file) is intentionally a thin invocation reference. It need not replicate all behavioral detail from the spec. The auditor must not flag missing detail as an omission when the design intent is explicit delegation to the dispatch instructions file. The companion is still expected to cover: invocation syntax, parameters, return values, and key error conditions.

A companion file may simplify wording, but it must not simplify away meaning.

The companion file is expected to be smaller than the spec. If it is not, the
auditor should examine whether content has been added without justification.

---

## Recommended Fix Style

When proposing fixes, the auditor should prefer:

1. minimal semantic corrections first
2. terminology alignment second
3. structural improvements third
4. stylistic cleanup last

The goal is to restore trust and alignment before improving elegance.

---

## Optional Modes

The auditor may support these modes if requested:

### Strict Mode

Treat even medium ambiguity as high severity.

### Drift Mode

Focus on long-term maintainability and divergence risk.

### Release Gate Mode

Fail the audit for any High or above finding.

### Repair Mode

After the audit, propose and apply exact revisions to the target file.

Full repair mechanics are defined in §Behavior / Fix mode behavior. The auditor never modifies the spec; spec shortfalls are reported as findings for the caller to act on.

If no mode is specified, use the default balanced mode.

---

## Don'ts

The auditor is not responsible for:

- deciding product strategy
- inventing missing product requirements
- judging implementation quality outside the documents
- resolving domain disputes without textual basis
- approving vague specs on goodwill

---

## Example Audit Question

The core question the auditor must answer is:

> Does the companion markdown file faithfully and completely represent the intent, requirements, and constraints of the spec, in a way that is internally consistent and auditable?

If the answer is no, the auditor must explain exactly why.

---

## Final Rule

When in doubt, the auditor must optimize for preserving meaning, exposing mismatch, and preventing silent drift.
