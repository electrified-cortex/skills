# Spec Auditing Instructions

Disposition: strict, skeptical, evidence-based, non-creative during audit.

## Gates

1. Resolve target path. Missing/unreadable → STOP: target file missing.
2. Mode detection:
   a. `--spec` provided → pair-audit mode. Verify spec path resolves; missing → STOP.
   b. `--spec` not provided AND target ends in `spec.md`:
   - If caller explicitly requested spec-only mode → spec-only mode.
   - Otherwise auto-detect companion in this order:
       1. If target is a named file spec, `<same-dir>/<name>.md`
      - Companion found → pair-audit mode; report which file was auto-detected.
        Multiple candidates → use first in order above; report ambiguity.
   - Folder-level `spec.md` has no additional universal fallback.
   - No companion → spec-only mode; report "no companion present — auditing spec alone."
   c. `--spec` not provided AND target does NOT end in `spec.md`:
      - Resolve spec from sibling `<basename>.spec.md`. Missing → STOP: spec file missing.
**Gate HC: hash-record cache check**

Cache check happens inline at the host surface; this executor receives `--report-path <path>` and writes the verdict there. Do not re-check or re-compute.

3. Audit kind (pair-audit mode only; skip in spec-only mode):
   a. `--kind meta` explicitly provided → meta mode.
   b. `--kind domain` explicitly provided → domain mode.
   c. Neither provided → auto-detect:
      - Spec path's directory components include `spec-writing` (path-component match, not substring; `/path/to/spec-writing/spec.md` matches; `/path/to/spec-writing-legacy/spec.md` does NOT) → meta mode; report "auto-detected: meta mode."
      - Spec path does not have `spec-writing` as a directory component → domain mode; report "auto-detected: domain mode."
   d. Auto-detect is ambiguous (neither signal) → STOP: cannot determine audit kind — supply `--kind meta` or `--kind domain` explicitly.
   Meta mode: run the full pair-audit — 11 audit dimensions (§Audit pair-audit mode steps 3–13) plus 2 extraction steps (steps 1–2).
   Domain mode: run pair-audit with Unauthorized Additions check modified — see Audit section.
4. Read all resolved files fully before judging. Partial → STOP: incomplete input.
5. Precedence: this instruction file controls audit procedure; the audited spec controls domain content; the companion target is subordinate. Report every conflict; never normalize.
6. `--fix` is not handled by the executor; fix iteration is caller-driven. If `--fix` is passed, ignore the flag, report "fix iteration is caller-driven — executor is single-pass read-only", and proceed with a read-only audit.
7. Reject approve/stamp requests → STOP: approve mode not supported.
8. Spec-only mode: skip companion-dependent gates (gate 4 reads spec only; gate 7 unchanged).

## Interpretation

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

## Banned terminology

Do not use the term **"non-goals"** in any finding text, recommendation,
or output. The term is ambiguous and confusing to humans and downstream
agents alike. Use **"Out of scope"** instead.

When auditing target or companion content, flag any occurrence of
"non-goals" as a Medium-severity terminology finding (Audit step 9).
Recommend renaming the section/heading/term to "Out of scope".

## Audit (pair-audit mode)

1. Extract from spec: requirements, prohibitions, defaults, precedence, definitions, procedures, exceptions, audience.
2. Extract from target: rules, terminology, structure, constraints, defaults, behaviors.
3. Semantic Alignment: same concepts → same meaning; no unjustified weakening/broadening/narrowing; no example-rule conflict.
4. Requirement Coverage: every material requirement, prohibition, operational constraint at right fidelity.
5. Contradiction Detection: direct conflicts, wording conflicts, contradictory defaults, precedence clashes, definition clashes.
6. Completeness: missing sections, dangling refs, undefined terms, incomplete procedures, missing exceptions/decision criteria.
7. Enforceability: vague/subjective/aspirational/non-testable requirements; binding behavior without auditable criteria.
8. Structural Integrity: logical order, stable headings, duplicate rules, hidden requirements, normative-language consistency; spec files must not contain YAML frontmatter (flag any leading `---` block as a structural defect — frontmatter belongs in runtime artifacts only).
9. Terminology: stable defined terms, undefined critical terms, synonym drift, renamed concept mapping.
10. Change Drift Risk: duplicated text, loose paraphrases, isolated assumptions, missing cross-refs, future divergence hotspots.
11. Unauthorized Additions:

- **Meta mode**: classify target-only additions as `Valid Extension`, `Derived but Unstated`, or `Unauthorized Addition`.
- **Domain mode, authority supplied**: authority spec is the domain spec provided via `--spec`. Apply the same three-way classification against that authority.
- **Domain mode, no authority supplied**: skip this check. Report as Informational: "domain mode, no authority declared — Unauthorized Additions check skipped."
- **Domain-flavor recognition (any mode)**: if the audited target is a spec that declares itself a domain-flavor extension of a parent spec via an explicit `Inheritance` section naming the parent, classify additional normative requirements unique to the domain as `Valid Extension`, provided that (a) the parent spec is named by canonical reference, (b) the additions satisfy the parent's atomicity / testability / normative-language rules, (c) the additions do not contradict the parent, and (d) additional sections are classified in a Section Classification table per the parent's Content Modes rules. Missing any of these conditions → fall back to the three-way rule. Resolving the parent's file path is not required; verify the parent by canonical name only.

12. Economy: apply the removal test to duplicated rules, unnecessary scaffolding, and prose that can be removed without changing effect. Confirm the effect before reporting waste. Consolidation opportunities = Informational; escalate to Low/Medium where waste creates drift risk.
13. Compression fidelity: flag loss, gain, bloat. Loss/gain = governance failures (High+); bloat = quality issue (Medium).

## Audit (spec-only mode — apply instead of pair-audit when no companion)

Six checks only. Steps numbered to match pair-audit for cross-reference; skip steps 2–5, 10–11, and 13 (require companion).
Apply steps 1, 6, 7, 8, 9, 12 as defined in pair-audit above.
Additionally: Internal Consistency — no contradictions within the spec itself.
(No Semantic Alignment, Requirement Coverage, Cross-File Contradiction Detection, Change Drift Risk, Unauthorized Additions, or Compression Fidelity — all require a companion. Internal Consistency is IN scope.)

## Assumptions (unless overridden)

Both files describe same system/behavior/contract.
Both files meaningfully aligned.
Markdown headings, structure semantically relevant.
Normative statements include explicit/implied reqs.
Examples subordinate to rules unless explicitly normative.
Mandatory behavior without normative keyword but contextually binding → flag as enforceability issue.

## Companion expectations

Reflect all material spec reqs without simplifying away meaning.
Self-contained — never reference/depend on spec at runtime.
Content not justified by spec's purpose = finding.
Expected smaller than spec; if not, examine for unjustified additions.

Dispatch-pattern exception: a companion for a dispatch skill may be an
intentionally thin invocation reference. Do not flag missing behavioral detail
as an omission when the design explicitly delegates that detail to the
companion dispatch instructions file. The thin companion must still cover:
invocation syntax, parameters, return values, and key error conditions.

## Severity

Critical: reverses meaning, breaks trust, unsafe impl, violates gating/precedence/safety.
High: materially weakens correctness, completeness, scope control, or auditability.
Medium: meaningful weakness, should fix, does not invalidate pair.
Low: minor wording/structure/duplication, limited impact.
Informational: observation, maintainability note, optional improvement.

## Result

1. `Fail` if any Critical exists, 2+ High exist, or stricter threshold says fail.
2. `Pass with Findings` if the audit produces any finding and no fail condition is met.
3. `Pass` only when no findings are produced.
4. State threshold used if caller provides one.

## Evidence

1. Every non-trivial finding must include evidence.
2. Evidence: file name, heading if available, quote or precise excerpt.
3. Explain what is wrong and why it matters.
4. Label: direct evidence, reasonable inference, or uncertainty.
5. Never present inference as fact.

**Step RW: write hash-record (when `--report-path` is provided)**

After the verdict is determined, write the hash-record before emitting the return token:

1. Use `<report_path>` from the `--report-path` argument supplied by the host. If `--report-path` is absent or empty, skip this step (no-cache path).
2. Create parent directories as needed.
3. Write the record using the schema defined in the hash-record skill's record-frontmatter contract. Spec-auditing-specific fields:
   - `operation_kind: spec-auditing/v1`
   - `result:` — one of `pass | pass_with_findings | fail | error` (Pass→pass; Pass with Findings→pass_with_findings; Fail→fail; error→error)
4. Emit the return token as the final stdout line (column 0, no indent, no list marker):
   `Pass: <cache_path>` | `Pass with Findings: <cache_path>` | `Fail: <cache_path>`

## Output

1. Sections in order: `Audit Result`, `Executive Summary`, `Findings`, `Coverage Summary`, `Drift and Risk Notes`, `Repair Priorities`, then the return token (final stdout line).
2. `Audit Result`: `Pass`, `Pass with Findings`, or `Fail`.
3. `Executive Summary`:
   - **Pair-audit mode**: alignment state between spec and companion, mode used, biggest risks, threshold if customized.
   - **Spec-only mode**: spec structural quality and standards-conformance — sections present, language enforceability, internal consistency, material weaknesses. No alignment assessment; there is no companion.
4. `Findings`: numbered; each has `Finding ID`, `Severity`, `Title`, `Affected file(s)`, `Evidence`, `Explanation`, `Recommended fix`.
5. `Coverage Summary`: well-covered, missing/weak, fit for purpose.
   Spec-only mode: set to "N/A — spec-only mode, no companion present."
6. `Drift and Risk Notes`: duplication, paraphrase drift, isolated assumptions, cross-ref gaps, likely future divergence.
   Spec-only mode: internal consistency observations only (no cross-file drift).
7. `Repair Priorities`: highest-value fix order first.
8. Quote evidence inline for every finding.

When in doubt: optimize for preserving meaning, exposing mismatch, and preventing silent drift.

## Out of scope

- Product strategy
- Inventing missing requirements
- Judging implementation quality outside documents
- Resolving domain disputes without textual basis
- Approving vague specs on goodwill.
