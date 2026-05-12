# PRD Auditing Specification

## Purpose

Define the audit procedure for a Product Requirements Document
(PRD). The PRD auditor is the source of truth for PRD quality. PRD
writers conform to the auditor's rules. The auditor can verify its
own companion documents for compliance (dogfooding).

This specification extends `spec-auditing/spec.md`. The base
auditor runs first; this document defines the PRD-specific
additions that follow.

## Scope

Applies when auditing a single PRD document for structural
correctness, content discipline, and scope boundary. Inherits the
scope of `spec-auditing` for all base spec checks.

This is a **dispatch skill** — the audit procedure is
context-independent and runs in an isolated agent.

## Inheritance

This specification extends `spec-auditing/spec.md`. Every check,
verdict rule, error contract, and read-only constraint in the
parent applies unless explicitly overridden below. The base
audit runs first against the PRD as a spec; PRD-specific checks
run only after the base audit completes.

## Definitions (additions)

- **PRD**: a Product Requirements Document. See `prd-writing/spec.md`.
- **Outcome / Output**: see `prd-writing/spec.md`.
- **Acceptance Criterion (AC)**: binary, verifiable predicate
  attached to a Functional Requirement.
- **Out of Scope**: explicit list of adjacent capabilities excluded.

## Audit Procedure

The audit executes as a single sweep in two ordered phases:

### Phase 1 — Base Spec Audit (inherited)

Run `spec-auditing` against the PRD. All findings, verdict, and
error semantics from `spec-auditing/spec.md` apply unchanged.

If `spec-auditing` returns FAIL, the PRD audit verdict is FAIL.
PRD-specific checks still run and contribute to the findings
report, but do not change the verdict.

### Phase 2 — PRD-Specific Checks

After Phase 1 completes, run the following checks against the
PRD. Findings accumulate into the report.

#### Step A — Required PRD Sections

1. **Header** — title, author, status, version, last-updated date
   present. Missing field → HIGH.
2. **Summary** — present, ≤ 5 sentences, covers problem, product,
   primary outcome. Missing → FAIL. Length or content failure →
   HIGH.
3. **Problem** — present, names affected audience and cost of
   status quo. Missing → FAIL.
4. **Users / Personas** — present, or an explicit exemption
   sentence justifies absence. Missing without exemption → HIGH.
5. **Goals and Success Metrics** — present. Missing → FAIL.
6. **Functional Requirements** — present. Missing → FAIL.
7. **Non-Functional Requirements** — present. Missing → HIGH.
8. **Out of Scope** — present. Missing → FAIL.
9. **Assumptions, Constraints, Dependencies** — present. Missing
   → HIGH.
10. **Open Questions** — present (may be empty when truly so).
    Missing as a section → LOW.
11. **Release / Rollout Notes** — present. Missing → LOW.

#### Step B — Content Discipline

1. **Outcome vs output** — each Goal expressed as a measurable
   change, not a deliverable. Output-as-goal → HIGH.
2. **Goal-Metric pairing** — each Goal pairs with at least one
   quantified Success Metric and a target, threshold, or
   direction. Missing pairing → HIGH.
3. **Acceptance Criteria coverage** — each Functional Requirement
   carries at least one Acceptance Criterion. Missing → HIGH.
4. **Binary Acceptance Criteria** — each AC is pass/fail and
   verifiable from document text alone. Non-binary → HIGH.
5. **Subjective qualifiers** — scan ACs and NFRs for "fast",
   "easy", "intuitive", "responsive", "robust", "should feel" or
   equivalents. Any occurrence → HIGH.
6. **NFR measurability** — each NFR states a measurable threshold
   or compliance standard. Missing → HIGH.
7. **Out-of-Scope discipline** — at least one explicit exclusion
   when the product has any adjacent capability that could
   plausibly be confused with it. Empty when not warranted by
   product simplicity → HIGH.
8. **Open Question hygiene** — each blocking item names a
   decider; non-blocking items are marked. Blocking item without
   decider → HIGH.
9. **Internal consistency** — no Functional Requirement
   contradicts an Out-of-Scope item; no Goal contradicts a
   Constraint. Any contradiction → FAIL.

#### Step C — Scope Boundary

1. **No implementation detail** — scan FRs and NFRs for
   architecture, API, schema, or library specifics. Any
   occurrence → HIGH.
2. **No market analysis** — TAM/SAM, competitive landscape →
   HIGH.
3. **No business case** — ROI calculations, staffing
   justifications → HIGH.
4. **No pixel-perfect UX** — embedded wireframes or pixel-precise
   mockups → HIGH. Conceptual flow descriptions are permitted.
5. **No sprint backlog** — task breakdowns, story points,
   assignments → HIGH.
6. **No staffing detail** — RACI, team rosters → HIGH.

#### Step D — Banned Terminology

1. **"non-goals"** — any occurrence in the PRD → HIGH. Recommend
   rename to "Out of Scope".

## Verdict Rules

Verdicts inherit from `spec-auditing/spec.md` with the following
clarifications:

- **CLEAN** — Phase 1 CLEAN AND no Phase 2 findings.
- **PASS** — Phase 1 PASS or CLEAN AND no HIGH or FAIL findings in
  Phase 2. Non-blocking LOW or informational findings are
  permitted.
- **NEEDS_REVISION** — No FAIL in either phase, but any HIGH
  finding in Phase 2 OR two or more LOW findings combined across
  phases.
- **FAIL** — Phase 1 FAIL, OR any Phase 2 FAIL finding, OR 3+ HIGH
  findings combined across phases.

When in doubt between PASS and NEEDS_REVISION, choose
NEEDS_REVISION. The auditor is adversarial.

## Audit Report Format

The report contains the base spec-auditing record plus a PRD
section:

- **Verdict** — combined.
- **Path** — repo-relative path to the audited PRD.
- **Phase 1 findings** — inherited from `spec-auditing`.
- **Phase 2 findings** — tables for Steps A through D, one row per
  check.
- **Issues** — bulleted list of findings with location (section,
  requirement ID, or excerpted phrase) and fix.
- **Recommendation** — one-line summary.

All findings MUST cite evidence from the PRD. Unsupported
assertions are prohibited.

## Defaults and Assumptions

Inherits from `spec-auditing/spec.md`:

- Read-only auditor.
- One PRD per dispatch.
- Skeptical, evidence-based disposition.

## Error Handling

Inherits from `spec-auditing/spec.md`. PRD-specific:

- **Target not found** — return `ERROR: prd_path not found:
  <path>`. No partial report.
- **Empty or unreadable PRD** — return `ERROR: <reason>`.

## Precedence Rules

1. `spec-auditing/spec.md` governs the base audit procedure. This
   spec adds PRD-specific checks. In conflict, the parent wins.
2. `prd-writing/spec.md` is the writer's contract; this spec is
   the auditor's contract. In conflict between writer and auditor
   intent, this spec wins.
3. Phase 1 verdict thresholds compose with Phase 2 thresholds per
   the Verdict Rules above.

## Don'ts

- Do not modify the audited PRD — auditor is read-only.
- Do not infer intent — verdicts must be grounded in document
  text.
- Do not produce a PASS when evidence is ambiguous — use
  NEEDS_REVISION.
- Do not skip Phase 1 — the base spec audit runs first.
- Do not collapse multiple findings into a single line — each
  finding gets its own entry with location and fix.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Descriptive | yes |
| Scope | Descriptive | yes |
| Inheritance | Descriptive | yes |
| Definitions (additions) | Descriptive | yes |
| Audit Procedure | Normative | yes |
| Verdict Rules | Normative | yes |
| Audit Report Format | Normative | yes |
| Defaults and Assumptions | Normative | yes |
| Error Handling | Normative | yes |
| Precedence Rules | Normative | yes |
| Don'ts | Normative | yes |
| Section Classification | Informational | yes |
