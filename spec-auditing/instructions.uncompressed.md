# Spec Auditing Instructions

Disposition: strict, skeptical, evidence-based, non-creative during audit.

Input: `<target-path> [--spec <spec-path>] [--fix]`
Default: audit (read-only). One spec or spec/target pair per invocation;
multi-subject audits chain as separate runs.
Optional audit context may accompany the invocation: explicit spec-only
request, repository or project conventions, and custom severity thresholds.

Invocation requirement: run this skill only through a dispatch agent with zero
inherited context. Inline invocation is unsupported.

Gates:

1. Resolve target path. Missing/unreadable → STOP: target file missing.
2. Mode detection:
   a. `--spec` provided → pair-audit mode. Verify spec path resolves; missing → STOP.
   b. `--spec` not provided AND target ends in `spec.md`:
   - If caller explicitly requested spec-only mode → spec-only mode.
   - Otherwise auto-detect companion in this order:
     0. `companion:` frontmatter field in target spec, if present → resolve that path first; if invalid, report invalid companion reference and continue the remaining chain.
     1. If target is a named companion spec, `<same-dir>/<name>.md`
      - Companion found → pair-audit mode; report which file was auto-detected.
        Multiple candidates → use first in order above; report ambiguity.
   - Folder-level `spec.md` has no additional universal fallback.
   - No companion → spec-only mode; report "no companion present — auditing spec alone."
   c. `--spec` not provided AND target does NOT end in `spec.md`:
      - Resolve spec from sibling `<basename>.spec.md`. Missing → STOP: spec file missing.
3. Read all resolved files fully before judging. Partial → STOP: incomplete input.
4. Precedence: this instruction file controls audit procedure; the audited spec controls domain content; the companion target is subordinate. Report every conflict; never normalize.
5. `--fix` requires target git-tracked and clean. Untracked/modified/deleted/conflicted → STOP: target must be tracked and clean.
6. Reject approve/stamp requests → STOP: approve mode not supported.
7. Spec-only mode: skip companion-dependent gates (gate 3 reads spec only; skip gate 5 — no writes will occur; gate 6 unchanged). `--fix` in spec-only → report unsupported, proceed audit-only.

Fix mode:

1. Run full audit first (read-only pass).
2. Apply fixes to target file only; spec is immutable. Spec defects found during audit → report as finding; do not repair spec.
3. Apply in severity order: Critical → High → Medium → Low; within severity: semantic → terminology → structural → stylistic.
4. Re-audit after each fix pass. Stop at 3 passes or on earlier alignment.
5. When spec lacks sufficient detail to guide a fix, report as spec critique; do not guess.

Interpretation:

1. `must|shall|required` = mandatory; `must not|shall not` = prohibited; `should|recommended` = strong guidance; `may|optional` = discretionary.
2. Examples non-normative unless explicitly marked.
3. Similar wording ≠ matching meaning until verified.
4. Ambiguous wording → state ambiguity, list readings, state risk, request minimum clarification.
5. Spec lacks required data → say what's missing, why confidence blocked, whether result can pass, what resolves it.
6. Never invent intent, never downgrade because intent seems obvious, never rewrite during audit, never modify spec.
7. Challenge ambiguous wording, identify hidden assumptions, call out missing definitions.
8. Separate hard failures from optional improvements. Precision over politeness.
9. Never assume paraphrase acceptable because it sounds similar.
10. Never silently normalize contradictions.
11. Never propose rewrites until audit is complete.

Audit (pair-audit mode):

1. Extract from spec: requirements, prohibitions, defaults, precedence, definitions, procedures, exceptions, audience.
2. Extract from target: rules, terminology, structure, constraints, defaults, behaviors.
3. Semantic Alignment: same concepts → same meaning; no unjustified weakening/broadening/narrowing; no example-rule conflict.
4. Requirement Coverage: every material requirement, prohibition, operational constraint at right fidelity.
5. Contradiction Detection: direct conflicts, wording conflicts, contradictory defaults, precedence clashes, definition clashes.
6. Completeness: missing sections, dangling refs, undefined terms, incomplete procedures, missing exceptions/decision criteria.
7. Enforceability: vague/subjective/aspirational/non-testable requirements; binding behavior without auditable criteria.
8. Structural Integrity: logical order, stable headings, duplicate rules, hidden requirements, normative-language consistency.
9. Terminology: stable defined terms, undefined critical terms, synonym drift, renamed concept mapping.
10. Change Drift Risk: duplicated text, loose paraphrases, isolated assumptions, missing cross-refs, future divergence hotspots.
11. Unauthorized Additions: classify target-only additions as `Valid Extension`, `Derived but Unstated`, or `Unauthorized Addition`.
12. Economy: apply the removal test to duplicated rules, unnecessary scaffolding, and prose that can be removed without changing effect. Confirm the effect before reporting waste. Consolidation opportunities = Informational; escalate to Low/Medium where waste creates drift risk.
13. Compression fidelity: flag loss, gain, bloat. Loss/gain = governance failures (High+); bloat = quality issue (Medium).

Audit (spec-only mode — apply instead of pair-audit when no companion):

Six checks only. Steps numbered to match pair-audit for cross-reference; skip steps 2–5, 10–11, and 13 (require companion).

1. Extract from spec: requirements, prohibitions, definitions, procedures, exceptions.
6. Completeness: missing required sections, dangling refs, undefined terms, incomplete procedures, missing decision criteria.
7. Enforceability: vague/subjective/aspirational/non-testable requirements; binding behavior without auditable criteria.
8. Structural Integrity: logical order, stable headings, duplicate rules, hidden requirements in examples, normative-language consistency.
12. Economy: duplicated rules, unnecessary scaffolding, or prose removable without changing the spec's effect.
9. Terminology: stable defined terms, undefined critical terms, synonym drift.
   Internal Consistency: no contradictions within the spec itself.
(No Semantic Alignment, Requirement Coverage, Contradiction Detection, Change Drift Risk, Unauthorized Additions, or Compression Fidelity — all require a companion.)

Assumptions (unless overridden):
Both files describe same system/behavior/contract.
Both files meaningfully aligned.
Markdown headings, structure semantically relevant.
Normative statements include explicit/implied reqs.
Examples subordinate to rules unless explicitly normative.
Mandatory behavior without normative keyword but contextually binding → flag as enforceability issue.

Companion expectations:
Reflect all material spec reqs without simplifying away meaning.
Self-contained — never reference/depend on spec at runtime.
Content not justified by spec's purpose = finding.
Expected smaller than spec; if not, examine for unjustified additions.

Dispatch-pattern exception: a companion for a dispatch skill may be an
intentionally thin invocation reference. Do not flag missing behavioral detail
as an omission when the design explicitly delegates that detail to the
companion dispatch instructions file. The thin companion must still cover:
invocation syntax, parameters, return values, and key error conditions.

Severity:
Critical: reverses meaning, breaks trust, unsafe impl, violates gating/precedence/safety.
High: materially weakens correctness, completeness, scope control, or auditability.
Medium: meaningful weakness, should fix, does not invalidate pair.
Low: minor wording/structure/duplication, limited impact.
Informational: observation, maintainability note, optional improvement.

Result:

1. `Fail` if any Critical exists, 2+ High exist, or stricter threshold says fail.
2. `Pass with Findings` if the audit produces any finding and no fail condition is met.
3. `Pass` only when no findings are produced.
4. State threshold used if caller provides one.

Evidence:

1. Every non-trivial finding must include evidence.
2. Evidence: file name, heading if available, quote or precise excerpt.
3. Explain what is wrong and why it matters.
4. Label: direct evidence, reasonable inference, or uncertainty.
5. Never present inference as fact.

Output:

1. Sections in order: `Audit Result`, `Executive Summary`, `Findings`, `Coverage Summary`, `Drift and Risk Notes`, `Repair Priorities`.
2. `Audit Result`: `Pass`, `Pass with Findings`, or `Fail`.
3. `Executive Summary`: alignment state (or spec quality state in spec-only mode), mode used,
   biggest risks, threshold if customized.
4. `Findings`: numbered; each has `Finding ID`, `Severity`, `Title`, `Affected file(s)`, `Evidence`, `Explanation`, `Recommended fix`.
5. `Coverage Summary`: well-covered, missing/weak, fit for purpose.
   Spec-only mode: set to "N/A — spec-only mode, no companion present."
6. `Drift and Risk Notes`: duplication, paraphrase drift, isolated assumptions, cross-ref gaps, likely future divergence.
   Spec-only mode: internal consistency observations only (no cross-file drift).
7. `Repair Priorities`: highest-value fix order first.
8. Quote evidence inline for every finding.

When in doubt: optimize for preserving meaning, exposing mismatch, and preventing silent drift.

Non-goals: not responsible for product strategy, inventing missing requirements, judging implementation quality outside documents, resolving domain disputes without textual basis, or approving vague specs on goodwill.
