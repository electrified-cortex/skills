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
- optional explicit spec path override when the target path points to a companion file
- optional audit context, including an explicit request for spec-only mode when the caller wants to audit a spec in isolation
- optional repository or project conventions
- optional severity thresholds

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
9. The auditor must emit output sections in the order: Audit Result, Executive Summary, Findings, Coverage Summary, Drift and Risk Notes, Repair Priorities.
10. When `--fix` is active, the auditor must re-audit after each fix pass; maximum 3 passes.
11. In fix mode, fixes must be applied in severity order: Critical → High → Medium → Low; within severity: semantic → terminology → structural → stylistic.
12. The auditor must not propose rewrites until the full audit is complete.
13. Evidence must be labeled: direct evidence, reasonable inference, or uncertainty. Inference must never be presented as fact.
14. When a spec lacks sufficient information to audit the companion, the auditor must say so explicitly, state what is missing, and assess whether the result can still pass.

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
9. The auditor must not apply `--fix` in spec-only mode.
10. The auditor must not invent product requirements or resolve domain disputes without textual basis.
11. One spec or spec/target pair per invocation. Multi-subject audits must be chained as separate runs.

---

## Behavior

### Audit flow

1. Resolve input paths and detect mode (pair-audit or spec-only) per §Inputs and §Spec-Only Mode.
2. Read all resolved files fully.
3. Extract normative content (requirements, prohibitions, definitions, defaults, procedures, exceptions).
4. Evaluate all applicable audit dimensions in sequence.
5. Assign severity and evidence to each finding.
6. Apply pass/fail gate rules.
7. Emit output in required section order.

### Pass/Fail gate

- **Fail** if any Critical finding exists.
- **Fail** if two or more High findings exist.
- **Pass with Findings** if the audit produces any finding and no fail condition is met.
- **Pass** only if no findings are produced.
- Custom thresholds may tighten (never loosen) these rules; the threshold used must be stated.

### Fix mode behavior

When `--fix` is active:

1. Run full audit first.
2. Apply fixes to the target file only; spec is immutable.
3. Re-audit after each pass. Stop at 3 passes or earlier alignment.
4. When the spec lacks sufficient detail to guide a fix, report as a spec critique rather than guessing.

---

## Iteration Safety

Root cause: an agent ran consecutive audits against the same spec with no content change
between runs. Both rules below exist to prevent this class of wasted-work loop.

**Rule A — Fix before re-audit.** If an audit produces findings (verdict is Pass with Findings or
Fail), the agent MUST resolve those findings — by fixing directly or dispatching the fix — before
running another audit against the same spec. Running another audit without acting on prior
findings is forbidden.

**Rule B — Never re-audit unchanged content.** "Never re-audit a file that has not been modified
since the previous audit, period, full stop." If the spec's content is unchanged, the
verdict is deterministic and a re-audit is wasted work.

The caller MUST verify, before dispatching a follow-up audit, that the spec file (or its
companion, in pair-audit mode) has changed since the previous audit completed. If no file
has changed, the prior verdict stands and re-dispatch is forbidden.

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

After the audit, propose exact revisions.

Repair mechanics:

1. The target file must be tracked in git with a clean working tree (safety net: `git restore`).
2. Fix findings in severity order: Critical → High → Medium → Low.
3. When the spec lacks sufficient detail to guide a fix, report it as a spec
   critique ("section X too vague", "no rationale for rule Y") rather than guessing.
4. Re-audit after fixes. Maximum 3 passes. Stop early if aligned.
5. Report: findings, fixes applied, remaining issues, spec critiques.

The auditor never modifies the spec. Spec shortfalls are reported, not fixed.

If no mode is specified, use the default balanced mode.

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

## Footguns

**F1: Spec file contains YAML frontmatter** — specs are governance documents for humans and auditors, not runtime artifacts. Frontmatter (`name:`, `description:`, `type:`) belongs only in `SKILL.md`, agent files, and tool scripts. A spec with frontmatter signals confused authoring intent.
Why: tooling may classify the file as a runtime artifact; the frontmatter carries no meaning at audit time and creates noise.
Mitigation: strip frontmatter from `spec.md` files at authoring time. Flag any `---` YAML block at the top of a spec file as a Structural Integrity finding.

---

## Don'ts

The auditor is not responsible for:

- deciding product strategy
- inventing missing product requirements
- judging implementation quality outside the documents
- resolving domain disputes without textual basis
- approving vague specs on goodwill
- re-auditing when the prior audit had findings but no fix was applied — resolve findings first (Rule A).
- re-auditing when no spec or companion file has changed since the prior audit — the verdict is deterministic and re-dispatch is wasted work (Rule B).

---

## Minimal Output Template

The auditor should be able to emit results in this shape:

- Audit Result
- Executive Summary
- Findings
- Coverage Summary
- Drift and Risk Notes
- Repair Priorities

---

## Example Audit Question

The core question the auditor must answer is:

> Does the companion markdown file faithfully and completely represent the intent, requirements, and constraints of the spec, in a way that is internally consistent and auditable?

If the answer is no, the auditor must explain exactly why.

---

## Final Rule

When in doubt, the auditor must optimize for preserving meaning, exposing mismatch, and preventing silent drift.
