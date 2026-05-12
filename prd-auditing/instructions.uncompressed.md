# PRD Auditing — Executor Instructions

Audit a PRD in two phases: spec-auditing first, then PRD-specific
checks. Write a combined report to `<report_path>`.

## Phase 1 — Base Spec Audit

Read and apply `../spec-auditing/instructions.txt` against
`prd_path`. Treat the PRD as the spec under audit. Collect all
Phase 1 findings into a buffer; do not write the report yet.

If Phase 1 returns an executor `ERROR`, surface the error and stop
without writing.

## Phase 2 — PRD-Specific Checks

After Phase 1 completes, apply the following checks to the PRD.
Accumulate findings.

### Step A — Required PRD Sections

For each section below, verify presence and required content.

| Section | Severity if missing |
| --- | --- |
| Header (title, author, status, version, date) | HIGH per missing field |
| Summary (≤ 5 sentences, problem + product + outcome) | FAIL if absent; HIGH if length or content fails |
| Problem (audience + cost of status quo) | FAIL if absent |
| Users / Personas (or explicit exemption sentence) | HIGH if absent without exemption |
| Goals and Success Metrics | FAIL if absent |
| Functional Requirements | FAIL if absent |
| Non-Functional Requirements | HIGH if absent |
| Out of Scope | FAIL if absent |
| Assumptions, Constraints, Dependencies | HIGH if absent |
| Open Questions (section may be empty) | LOW if absent |
| Release / Rollout Notes | LOW if absent |

### Step B — Content Discipline

1. **Outcome vs output** — each Goal expresses a measurable change.
   Output-as-goal → HIGH.
2. **Goal-Metric pairing** — each Goal pairs with a quantified
   Success Metric and a target, threshold, or direction. Missing
   pairing → HIGH.
3. **Acceptance Criteria coverage** — each Functional Requirement
   has at least one Acceptance Criterion. Missing → HIGH.
4. **Binary Acceptance Criteria** — each AC is pass/fail and
   verifiable from document text. Non-binary → HIGH.
5. **Subjective qualifiers** — scan ACs and NFRs for "fast",
   "easy", "intuitive", "responsive", "robust", "should feel" or
   equivalents. Any occurrence → HIGH.
6. **NFR measurability** — each NFR states a measurable threshold
   or compliance standard. Missing → HIGH.
7. **Out-of-Scope discipline** — at least one explicit exclusion
   when the product has any adjacent capability that could
   plausibly be confused with it. Empty when warranted → HIGH.
8. **Open Question hygiene** — each blocking item names a decider
   (role or person) and the blocking effect; non-blocking items
   are marked. Blocking without decider → HIGH.
9. **Internal consistency** — no Functional Requirement
   contradicts an Out-of-Scope item; no Goal contradicts a
   Constraint. Any contradiction → FAIL.

### Step C — Scope Boundary

1. **No implementation detail** — architecture, API design,
   schemas, library choices in FRs or NFRs → HIGH.
2. **No market analysis** — TAM, SAM, competitive landscape →
   HIGH.
3. **No business case** — ROI, staffing justifications → HIGH.
4. **No pixel-perfect UX** — embedded wireframes, pixel-precise
   mockups → HIGH. Conceptual flow descriptions are permitted.
5. **No sprint backlog** — story points, assignments, ticket
   breakdowns → HIGH.
6. **No staffing detail** — RACI, team rosters → HIGH.

### Step D — Banned Terminology

1. **"non-goals"** — any occurrence in the PRD → HIGH. Recommend
   rename to "Out of Scope".

## Verdict

Combine Phase 1 and Phase 2 findings:

- **CLEAN** — Phase 1 CLEAN AND no Phase 2 findings.
- **PASS** — Phase 1 PASS or CLEAN AND no HIGH or FAIL findings in
  Phase 2.
- **NEEDS_REVISION** — No FAIL in either phase, but any HIGH in
  Phase 2 OR 2+ LOW findings combined.
- **FAIL** — Phase 1 FAIL, OR any Phase 2 FAIL, OR 3+ combined
  HIGH findings.

When in doubt between PASS and NEEDS_REVISION, choose
NEEDS_REVISION.

## Output

Write the combined report to `<report_path>`. Body:

```markdown
# Result

CLEAN | PASS | NEEDS_REVISION | FAIL

## PRD Audit: <prd-name>

**Verdict:** CLEAN | PASS | NEEDS_REVISION | FAIL
**Path:** <repo-relative path to the PRD>

### Phase 1 — Base Spec Audit

(Inherited findings table from spec-auditing.)

### Phase 2 — PRD-Specific Checks

#### Step A — Required Sections

| Section | Result | Notes |
| --- | --- | --- |
| Header | PASS/FAIL | |
| Summary | PASS/FAIL | |
| Problem | PASS/FAIL | |
| Users / Personas | PASS/FAIL | |
| Goals and Metrics | PASS/FAIL | |
| Functional Requirements | PASS/FAIL | |
| Non-Functional Requirements | PASS/FAIL | |
| Out of Scope | PASS/FAIL | |
| Assumptions / Constraints / Deps | PASS/FAIL | |
| Open Questions | PASS/FAIL | |
| Release / Rollout Notes | PASS/FAIL | |

#### Step B — Content Discipline

| Check | Result | Notes |
| --- | --- | --- |
| Outcome vs output | PASS/FAIL | |
| Goal-Metric pairing | PASS/FAIL | |
| AC coverage | PASS/FAIL | |
| Binary AC | PASS/FAIL | |
| No subjective qualifiers | PASS/FAIL | |
| NFR measurability | PASS/FAIL | |
| Out-of-Scope discipline | PASS/FAIL | |
| Open Question hygiene | PASS/FAIL | |
| Internal consistency | PASS/FAIL | |

#### Step C — Scope Boundary

| Check | Result | Notes |
| --- | --- | --- |
| No implementation detail | PASS/FAIL | |
| No market analysis | PASS/FAIL | |
| No business case | PASS/FAIL | |
| No pixel-perfect UX | PASS/FAIL | |
| No sprint backlog | PASS/FAIL | |
| No staffing detail | PASS/FAIL | |

#### Step D — Banned Terminology

| Check | Result | Notes |
| --- | --- | --- |
| "non-goals" absent | PASS/FAIL | |

### Issues

- <specific finding with location and fix>

### Recommendation

<one-line summary>
```

Emit the verdict token as the final line of stdout per the SKILL.md
return contract. `ERROR: <reason>` is reserved for runtime failures
(target not found, report path not writable); errors are never
persisted.

## Read-Only Constraint

The auditor never modifies the PRD or any other file in the
target's directory. Fixes are the caller's responsibility.
