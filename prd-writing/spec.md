# PRD Writing Specification

## Purpose

A Product Requirements Document (PRD) is a domain flavor of a spec
for product-layer requirements. This specification extends
`spec-writing/spec.md` with the additional sections, rules, and
constraints that distinguish a PRD from a generic spec.

Read `spec-writing/spec.md` first. This document records deltas
only.

## Scope

Applies when authoring a new PRD or revising an existing one.
Inherits the scope of `spec-writing` for all non-PRD-specific rules.

## Inheritance

This specification extends `spec-writing/spec.md`. Every rule,
content mode, constraint, and audit gate in the parent applies
unless explicitly overridden below. No rule below contradicts the
parent; this document only adds.

## Definitions (additions)

- **PRD**: a Product Requirements Document. A spec at the product
  layer that specifies *what* a product must do and *why* it
  matters, without prescribing *how* it is built.
- **Outcome**: a measurable change in user, customer, or system
  state. PRD Goals are outcomes.
- **Output**: a deliverable, feature, or artifact. Outputs are not
  Goals.
- **Acceptance Criterion (AC)**: a binary, verifiable predicate
  attached to a Functional Requirement, determining satisfaction
  from the document text alone.
- **Out of Scope**: an explicit list of adjacent capabilities
  deliberately excluded. Replaces the term "non-goals".

## Content Modes

Content modes follow `spec-writing/spec.md` (Normative, Descriptive,
Exploratory, Informational). The definitions and rules declared there
apply to this document without restatement.

PRD-writing additions:

- Sections that define required PRD structure or authoring rules are
  **Normative**.
- Sections that explain rationale, order, or examples are
  **Informational**.
- No section in this spec may introduce requirements using Exploratory
  mode.

The Section Classification table at the end of this document records
the mode for every top-level section in this spec.

## Additional Required Sections

Beyond the sections required by `spec-writing/spec.md` (Purpose,
Scope, Definitions, Requirements, Constraints), a PRD MUST also
contain:

1. **Header** — title, author, status (draft / review / approved),
   version, last-updated date.
2. **Summary** — ≤ 5 sentences covering problem, product, and
   primary outcome. Written last.
3. **Problem** — user, customer, or system problem; affected
   audience; cost of status quo.
4. **Users / Personas** — affected audience. For internal-only
   infrastructure with no end-user, a single explicit exemption
   sentence replaces the section.
5. **Goals and Success Metrics** — each Goal pairs with at least
   one quantified metric and a target, threshold, or direction.
6. **Functional Requirements** — numbered, atomic, each carrying
   at least one Acceptance Criterion.
7. **Non-Functional Requirements** — each stating a measurable
   threshold or compliance standard.
8. **Out of Scope** — explicit exclusions. The term "Out of Scope"
   is mandatory; "non-goals" is prohibited.
9. **Assumptions, Constraints, and Dependencies** — external
   conditions, regulatory or technical limits, upstream and
   downstream dependencies.
10. **Open Questions** — unresolved items. Blocking items name a
    decider and the blocking effect; non-blocking items are marked.
11. **Release / Rollout Notes** — launch plan, phasing, feature
    flags. A one-line "no special rollout" is acceptable when true.

## Additional Quality Rules

1. Each Goal MUST be an outcome (measurable change), not an output
   (deliverable). ANTI-PATTERN: "Goal: ship the new dashboard."
2. Each Goal MUST pair with at least one quantified Success Metric
   and a target value, threshold, or direction.
3. Each Functional Requirement MUST carry at least one Acceptance
   Criterion. Acceptance Criteria MUST be binary and verifiable
   from document text alone.
4. Each Non-Functional Requirement MUST state a measurable
   threshold or compliance standard.
5. Out of Scope MUST enumerate at least one explicit exclusion when
   the product has any adjacent capability that could plausibly be
   confused with it.
6. Open Questions blocking implementation MUST name a decider (role
   or person) and the blocking effect.
7. The Summary MUST be ≤ 5 sentences and MUST cover problem,
   product, and primary outcome.
8. The PRD MUST be internally consistent: no Functional Requirement
   contradicts an Out-of-Scope item; no Goal contradicts a
   Constraint.

## Additional Constraints

A PRD MUST NOT contain:

- **Implementation detail** — architecture, programming language,
  API design, database schema, library choices. Belongs in an SRD,
  TRD, or design document.
- **Market analysis** — TAM, SAM, competitive landscape. Belongs in
  an MRD.
- **Business case argumentation** — ROI calculations, headcount
  justifications. Belongs in a BRD.
- **Pixel-perfect UX design** — wireframes, mockups, visual specs.
  Belongs in design artifacts. Conceptual flow descriptions are
  permitted.
- **Sprint backlog** — task breakdowns, story points, assignments.
  Belongs in the tracker.
- **Staffing detail** — RACI, team rosters, individual assignments.
  Belongs in a project charter.

## Banned Terminology

- **"non-goals"** — prohibited. Use **"Out of Scope"** instead. Any
  occurrence is a HIGH finding by `prd-auditing`.
- **Subjective qualifiers in Acceptance Criteria or NFRs** —
  "fast", "easy", "intuitive", "responsive", "robust", "should
  feel". Each MUST be replaced with a measurable predicate or
  removed.

## Drafting Order

Write the PRD in the order below. Each section anchors the next;
the Summary is written last.

1. Problem
2. Users / Personas
3. Goals and Success Metrics
4. Out of Scope (before drafting requirements — sharpens scope)
5. Functional Requirements (with Acceptance Criteria)
6. Non-Functional Requirements (with measurable thresholds)
7. Assumptions, Constraints, Dependencies
8. Open Questions
9. Release / Rollout Notes
10. Summary (written last)
11. Header (any point)

## Patterns

- **Outcome > output**. Goals are measurable changes, not feature
  launches.
- **One requirement, one condition**. Split compound requirements.
- **Concrete examples next to requirements**. A worked example
  anchors interpretation better than additional prose.
- **Out of Scope written before requirements**. Enumerating
  exclusions sharpens the requirements that follow.
- **Living document**. Version and date updated on every material
  change; resolved Open Questions are removed, not annotated.

## Anti-Patterns

- **Sprint backlog masquerading as PRD** — tickets with story
  points are not a PRD.
- **Wireframes in place of requirements** — state the required
  behavior; design owns the visuals.
- **Implementation detail leakage** — "Use Redis for caching" is
  implementation; the PRD requires cache invalidation behavior.
- **Multi-clause requirements** — "MUST accept uploads and validate
  them and emit a webhook" is three requirements.
- **Hidden requirements in descriptive prose** — if it affects
  required behavior, move it to a normative section.

## Quality Gate

A PRD is ready for review when:

1. All required sections from `spec-writing/spec.md` plus this
   spec's additional sections are present.
2. Every Goal pairs with at least one quantified Success Metric.
3. Every Functional Requirement has at least one binary Acceptance
   Criterion.
4. Every Non-Functional Requirement states a measurable threshold.
5. Out of Scope contains at least one explicit exclusion when the
   product has adjacent capability.
6. Open Questions are ordered with blocking items first; each
   blocker names a decider.
7. No banned terminology.
8. No content from the Additional Constraints list.
9. Summary ≤ 5 sentences.
10. Header complete.

Run `prd-auditing` against the draft. Not done until PASS or CLEAN.

## Behavior

### Conflict resolution — Goals vs. Constraints

When a Goal and a Constraint in the same PRD conflict, the Constraint
wins. An unreachable Goal under stated Constraints is itself a
finding. The author must either relax the Constraint, narrow the
Goal, or document the conflict as a blocking Open Question naming a
decider and the blocking effect.

### Out of Scope interaction with Functional Requirements

A Functional Requirement MUST NOT describe behavior that the Out of
Scope section explicitly excludes. Any such contradiction is
immediately a FAIL in `prd-auditing`. The author must resolve it
before submission by either removing the exclusion or removing the
requirement.

### Open Questions and release readiness

A PRD with one or more **blocking** Open Questions MUST NOT be
declared ready for implementation. Blocking status requires a named
decider and a statement of the blocking effect. Non-blocking Open
Questions do not gate release readiness but must be marked as
non-blocking.

### Drafting-order enforcement

Sections must be authored in the Drafting Order sequence. The Summary
must be written last. A Summary authored before the Functional
Requirements or Out of Scope sections is considered a defect because
it cannot accurately represent the completed scope.

## Defaults and Assumptions

- **Open Questions section** — the section is required. An empty
  Open Questions section (no items) is permitted when there are
  genuinely no open questions; omitting the section entirely is a
  LOW finding per `prd-auditing` Step A.
- **Users / Personas section** — required. For internal-only
  infrastructure with no end-user, a single explicit exemption
  sentence substitutes for the full section. Absence without an
  exemption sentence is a HIGH finding per `prd-auditing` Step A.
- **Release / Rollout Notes section** — required. A one-line
  statement "No special rollout required" is acceptable when true.
  Omitting the section entirely is a LOW finding per `prd-auditing`
  Step A.
- **Goal-Metric pairing threshold** — every Goal must pair with at
  least one quantified Success Metric and a target, threshold, or
  direction. Zero pairings is a HIGH finding per `prd-auditing`
  Step B.
- **Acceptance Criteria threshold** — every Functional Requirement
  must carry at least one Acceptance Criterion. Zero ACs on any
  single requirement is a HIGH finding per `prd-auditing` Step B.
- **NFR measurability threshold** — each Non-Functional Requirement
  must state a measurable threshold or compliance standard. A
  qualitative-only NFR is a HIGH finding per `prd-auditing` Step B.
- **Out of Scope minimum** — when the product has any adjacent
  capability that could plausibly be confused with it, at least one
  explicit exclusion must appear. An empty Out of Scope section where
  exclusions are warranted is a HIGH finding per `prd-auditing`
  Step B.
- **Summary length** — maximum 5 sentences. Exceeding this limit is
  a HIGH finding. The summary must cover problem, product, and
  primary outcome; missing any of these is a HIGH finding.

## Error Handling

- **Ambiguous normative statement** — any normative statement in the
  PRD that can be interpreted in more than one reasonable way must be
  rewritten before the PRD is submitted for audit. Ambiguity in a
  normative statement is not permitted to stand; it must be resolved
  or moved to a non-normative section.
- **Missing required section** — absence of any required PRD section
  (as listed in Additional Required Sections) is a defect. The PRD
  MUST NOT pass audit while any required section is absent. The
  author must add the missing section and re-run `prd-auditing`.
- **Goal contradicts a Constraint** — a PRD where any Goal is
  unreachable under its own stated Constraints MUST receive a FAIL
  verdict from `prd-auditing`. The author must resolve the
  contradiction before re-submission.
- **Banned terminology occurrence** — any occurrence of "non-goals"
  or a subjective qualifier in an Acceptance Criterion or
  Non-Functional Requirement is a HIGH finding per `prd-auditing`
  Step D. The author must replace each occurrence with the required
  substitute ("Out of Scope" for "non-goals"; a measurable predicate
  for subjective qualifiers) and re-run the audit.

## Precedence Rules

1. `spec-writing/spec.md` governs the meta-structure of a spec. This
   PRD-writing spec adds product-layer rules. In any conflict
   between parent and this spec, the parent wins.
2. `prd-auditing/spec.md` governs the audit procedure for a PRD;
   this spec governs how to author one.
3. Constraints override Goals — an unreachable goal under stated
   constraints is itself a finding.

## Don'ts

- Do not use the term "non-goals"; use "Out of Scope".
- Do not include implementation detail, market analysis, business
  case argumentation, pixel-perfect design, backlog tasks, or
  staffing detail.
- Do not write the Summary first.
- Do not leave blocking Open Questions without a decider.
- Do not call a deliverable a Goal — Goals are outcomes.
- Do not declare the PRD ready until `prd-auditing` returns PASS or
  CLEAN.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Descriptive | yes |
| Scope | Descriptive | yes |
| Inheritance | Descriptive | yes |
| Definitions (additions) | Descriptive | yes |
| Content Modes | Normative | yes |
| Additional Required Sections | Normative | yes |
| Additional Quality Rules | Normative | yes |
| Additional Constraints | Normative | yes |
| Banned Terminology | Normative | yes |
| Drafting Order | Normative | yes |
| Patterns | Informational | yes |
| Anti-Patterns | Informational | yes |
| Quality Gate | Normative | yes |
| Behavior | Normative | yes |
| Defaults and Assumptions | Normative | yes |
| Error Handling | Normative | yes |
| Precedence Rules | Normative | yes |
| Don'ts | Normative | yes |
| Section Classification | Informational | yes |
