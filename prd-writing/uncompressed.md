---
name: prd-writing
description: Write a Product Requirements Document as a product-layer flavor of a spec. Triggers — write a PRD, draft product requirements, author a PRD, new product requirements document, create PRD.
---

# PRD Writing

A PRD is a spec at the product layer. Read the `spec-writing`
skill first — it owns the base workflow, content modes, and
quality discipline. This skill records the deltas: the additional
sections, rules, and anti-patterns that distinguish a PRD from a
generic spec.

## Workflow

Follow the `spec-writing` workflow. The PRD-specific changes are:

1. **Use this skill's required sections list** in addition to the
   `spec-writing` base sections.
2. **Apply the PRD-specific quality rules** (outcome over output,
   binary AC, measurable NFR, Out-of-Scope discipline).
3. **Audit with `prd-auditing`**, not `spec-auditing`. The PRD
   auditor runs `spec-auditing` first, then PRD-specific checks.

## Drafting Order

Write the PRD in the order below. Each section anchors the next;
the Summary is written last.

1. **Problem** — what user, customer, or system cannot currently
   do; the cost of the status quo; who is affected.
2. **Users / Personas** — the audience. For internal-only
   infrastructure with no end-user, write one explicit exemption
   sentence and skip the rest.
3. **Goals and Success Metrics** — each Goal is an outcome (a
   measurable change), not an output (a deliverable). Each Goal
   pairs with at least one metric and a target or threshold.
4. **Out of Scope** — adjacent capabilities deliberately excluded.
   Write this *before* drafting requirements. The term **"Out of
   Scope"** is mandatory; **"non-goals" is banned**.
5. **Functional Requirements** — numbered, atomic. One testable
   condition per requirement. Each FR carries at least one binary
   Acceptance Criterion verifiable from document text alone.
6. **Non-Functional Requirements** — measurable thresholds:
   latency, uptime, viewport range, accessibility, compliance. No
   subjective adjectives.
7. **Assumptions, Constraints, Dependencies** — external
   conditions, regulatory or technical limits, upstream and
   downstream dependencies.
8. **Open Questions** — unresolved items. Each blocking question
   names a decider and the blocking effect, or is marked
   `non-blocking`.
9. **Release / Rollout Notes** — launch plan, phasing, feature
   flags. One line is fine when accurate.
10. **Summary** — written last. ≤ 5 sentences. Problem, product,
    primary outcome.
11. **Header** — title, author, status (draft / review / approved),
    version, last-updated date.

## Rules

- **Outcome > output.** A goal is a measurable change in user,
  customer, or system state. ANTI-PATTERN: "Goal: ship the new
  dashboard." Correct: "Goal: reduce time-to-first-insight from 5
  minutes to under 30 seconds, measured by session telemetry."
- **One requirement, one condition.** Split any FR containing
  "and", "or", or a list of behaviors.
- **Binary Acceptance Criteria.** Each AC is pass/fail and
  verifiable from document text. Subjective qualifiers are
  prohibited: "fast", "easy", "intuitive", "responsive", "robust",
  "should feel". Replace each with a measurable predicate or
  remove.
- **Measurable NFRs.** ANTI-PATTERN: "Must be performant." Correct:
  "p95 response time MUST be ≤ 200ms under 1000 RPS."
- **Out of Scope is mandatory.** Enumerate at least one explicit
  exclusion when the product has any adjacent capability that
  could plausibly be confused with it.
- **Open Questions name a decider.** A blocking question without a
  decider is a defect. Resolved questions are removed, not
  annotated.
- **Summary is short.** ≤ 5 sentences. Written last.
- **Internal consistency.** No FR may contradict an Out-of-Scope
  item; no Goal may contradict a Constraint.
- **Living document.** Update version and date on every material
  change.

## Anti-Patterns

- **Sprint backlog masquerading as PRD** — tickets with story
  points are not a PRD.
- **Wireframes in place of requirements** — state required
  behavior; design owns visuals.
- **Implementation detail leakage** — "Use Redis for caching" is
  implementation; the PRD requires cache invalidation behavior.
- **Multi-clause requirements** — split.
- **Hidden requirements in descriptive prose** — move to a
  normative section.
- **"Non-goals" section** — use "Out of Scope".
- **"Should feel fast"** — replace with measurable threshold.

## Out-of-Scope Constraints

A PRD MUST NOT contain implementation detail (architecture, APIs,
schemas, libraries), market analysis (TAM, competitive landscape),
business case argumentation (ROI, headcount), pixel-perfect UX
(wireframes, mockups), sprint backlog (tasks, story points), or
staffing detail (RACI, rosters). Conceptual UX flow descriptions
are permitted.

## Quality Gate

A PRD is ready for review when:

1. All `spec-writing` required sections are present, plus the PRD
   additions (Header, Summary, Problem, Users, Goals & Metrics,
   FRs, NFRs, Out of Scope, Assumptions / Constraints /
   Dependencies, Open Questions, Release Notes).
2. Every Goal pairs with at least one quantified Success Metric.
3. Every Functional Requirement has at least one binary Acceptance
   Criterion.
4. Every Non-Functional Requirement states a measurable threshold.
5. Out of Scope contains at least one explicit exclusion when the
   product has adjacent capability.
6. Open Questions are ordered with blocking items first; each
   blocker names a decider.
7. No banned terminology.
8. No content from the Out-of-Scope Constraints list.
9. Summary ≤ 5 sentences.
10. Header complete.

Run `prd-auditing` on the draft. The skill is not complete until
the auditor returns PASS or CLEAN.

## Related

- `spec-writing` — parent skill; the base workflow and rules
- `prd-auditing` — the audit gate
- `spec-auditing` — runs as the first phase of `prd-auditing`
