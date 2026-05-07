# Code Review Specification

## Purpose

Define the procedure and output contract for tiered code review on a change
set. Code review surfaces issues, risks, and improvement opportunities in
executable/compilable code so the calling agent can act on them. This spec
governs procedure, tier policy, inputs, outputs, and the boundary between
reviewing and fixing.

## Scope

Applies when a calling agent dispatches a code review on executable or
compilable code: source files, build scripts, CI configuration,
infrastructure-as-code manifests.

This is a **dispatch skill** — each review pass runs in an isolated, zero-context
agent. Inline execution is prohibited; it produces shallow, inconsistent results
and allows caller context to bleed into the review judgment.

Does not cover non-code artifacts (specs, skills, documents). Those are
governed by `spec-auditing` and `skill-auditing`, which use a different
tier policy. The difference is normative.

## Definitions

- **fast-cheap**: a cost-optimized model tier suitable for fast, surface-level passes (e.g. Haiku-class).
- **standard**: a capable model tier used for thorough, authoritative passes (e.g. Sonnet-class).
- **Calling agent**: the agent that invokes the code-reviewer skill. Owns
  the change set, owns the decision about which findings to act on, owns
  any subsequent edits.
- **Change set**: the bounded set of code being reviewed. Must be
  identifiable by file paths, refs, or other stable references.
- **Smoke pass**: a fast, low-cost review pass intended to surface easy or
  surface-level findings (style, naming, obvious bugs, missing error
  handling, lint-grade defects). Run by a fast-cheap model.
- **Substantive pass**: a deeper review pass intended to surface design,
  correctness, security, and architectural findings. Run by a standard
  model. Authoritative for sign-off.
- **Finding**: a single reported issue with severity, location (file +
  line range when applicable), description, and recommended action.
- **Severity**: classification of a finding's importance. The vocabulary
  is fixed: `blocker`, `major`, `minor`, `nit`.
- **Audit**: structured review of non-code artifacts (specifications,
  skill definitions, documentation, configuration policy). Audits are
  governed by the spec-auditing and skill-auditing skills and use a
  different tier policy (up to two fast-cheap iterations before standard
  sign-off). NOT covered by this spec; named here only to fix the
  boundary.
- **Code review**: the activity of producing a structured report of
  issues, risks, and improvement opportunities about a code change set
  without modifying the code. Scoped to executable or compilable code
  (source files, build scripts, CI configuration, infrastructure-as-code
  manifests). Code reviews are governed by THIS spec and use the fixed
  fast-cheap → standard two-tier procedure with no fast-cheap iteration.
- **Audit trail**: the historical record of every finding produced by
  every pass dispatched in a code review, preserved in the aggregated
  result even when later passes contradict earlier findings.
- **Sign-off**: the most recent standard pass in a code review. Its
  aggregated findings report is the authoritative result. When only one
  standard pass has been dispatched, that pass is the sign-off; when more
  than one has been dispatched, the latest one is the sign-off and
  earlier standard passes become historical context.
- **Tier**: the model class (fast-cheap or standard) assigned to a
  given pass at dispatch.

## Requirements

### Procedure

A code review on a non-empty change set requires exactly one fast-cheap
smoke pass followed by at least one standard substantive pass. A
review on an empty change set requires zero passes.

1. The calling agent must dispatch exactly one fast-cheap smoke pass
   first, before any standard pass, for any code review where the change set
   is non-empty.
2. The smoke pass must produce a findings report only. It must not modify
   any code.
3. After the smoke pass, the calling agent decides which findings, if any,
   to act on. Acting on findings is outside the code-reviewer skill; the
   calling agent or another skill performs edits.
4. After the smoke pass and any caller-driven fixes, the calling agent
   must dispatch at least one standard substantive pass.
5. The substantive pass must produce a findings report only. It must not
   modify any code.
6. The calling agent may dispatch additional standard passes after
   the first substantive pass if findings warrant re-review of an
   updated change set. (The smoke pass having already run, Constraint 4
   forbids any further fast-cheap pass.)
7. The final dispatched pass must be a standard pass. This pass is the
   sign-off. Its report is the authoritative review result.
8. Each pass must be dispatched as an isolated agent with no ambient
   caller state beyond the enumerated bootstrap inputs (a Dispatch-style
   agent or equivalent zero-context bootstrap). The complete list of
   permitted inputs is defined under `Inputs` below. Prior-pass findings
   are caller-produced but explicitly enumerated and therefore permitted;
   no working-tree context, no agent memories, and no repository or
   project context beyond the optional context pointer (Inputs item 5)
   is permitted.

### Inputs

Each dispatched pass must receive at minimum:

1. The change set, in one of these explicit forms:
   - inline diff text (a unified diff embedded directly in the dispatch
     payload), or
   - a list of absolute file paths the dispatched agent can read with
     general-purpose file-read tooling, or
   - a git ref or ref range the dispatched agent can resolve with `git`
     and shell tooling (the dispatched agent must have working-directory
     access to the relevant repository for refs to be a valid form).
   No other change-set form is permitted at bootstrap. The calling agent
   must select a form the dispatched agent's tooling supports; if the
   dispatched agent lacks shell access, refs are not a valid form and the
   caller must materialize the diff inline or as file paths.
2. The tier identifier so the agent knows which pass it is performing
   (smoke or substantive). The tier governs the depth and breadth the
   agent applies.

A substantive pass must additionally receive:

3. The findings from every prior pass on the same change set (the smoke
   pass and any earlier substantive passes). The substantive pass must
   verify resolution of each prior finding and must not re-surface what
   has already been addressed. A smoke pass must not receive prior
   findings; smoke passes are always first and have nothing to receive.

Each dispatched pass may optionally receive:

4. Focus areas (for example: security, performance, concurrency, public
   API surface, test coverage). Focus-area depth-floor behavior is
   defined normatively in Constraints item 11.
5. A repository or project context pointer (CLAUDE.md, README, style
   guide) the agent may read for local conventions.

The items above are the complete enumeration of permitted bootstrap
inputs referenced by Procedure item 8 and Constraints item 7. Nothing
else may be passed in at bootstrap.

### Outputs

Every pass must return a findings report containing:

1. A list of findings, each with: severity (from the fixed vocabulary),
   location (file plus line range when applicable, or "general" if
   not file-bound), description, recommended action.
2. A pass verdict: one of `clean`, `findings`, or `error`. `clean`
   means no findings were produced. `findings` means at least one
   finding was produced. `error` means the pass failed to complete; an
   `error` pass entry must conform to the failed-pass entry shape
   defined normatively in Error Handling and must NOT contain a
   findings list.
3. The tier of the pass (smoke or substantive).
4. The pass index within the review (smoke is always index 0; first
   standard is index 1; subsequent standard passes increment).

The aggregated review result returned to the calling agent must contain
exactly these fields:

1. `passes`: the report from every pass dispatched, in dispatch order.
   Each entry is the per-pass report defined above.
2. `sign_off_pass_index`: the index of the authoritative sign-off pass
   (the most recent successful standard pass). When the change set is
   empty and no passes were dispatched, this field must be `null`. When
   only failed passes exist (no successful standard pass yet), this field
   must also be `null` and the aggregated result is not a valid
   sign-off — the calling agent must continue dispatching until a
   successful standard pass produces a valid index.
3. `severity_aggregate`: a count of findings by severity across the
   sign-off pass only (not summed across all passes), with a key for
   each severity value in the fixed vocabulary (`blocker`, `major`,
   `minor`, `nit`). When a value has no findings, its count is zero.
4. `verdict`: the overall review verdict. When `sign_off_pass_index` is
   non-null, this is the sign-off pass's verdict (`clean` or
   `findings`), propagated. When `sign_off_pass_index` is `null` because
   the change set was empty, `verdict` must be `clean`. When
   `sign_off_pass_index` is `null` because all dispatched passes have
   failed and no successful standard pass exists yet, `verdict` must be
   `error`. The aggregated `verdict` vocabulary is therefore `clean`,
   `findings`, or `error`.
5. `preserved_contradictions`: the list of smoke-pass findings the
   sign-off pass contradicted, each paired with the contradicting
   commentary from the substantive pass that produced the contradiction.
   Empty list when no contradictions occurred.

When the change set is empty and no passes are dispatched, the
aggregated result must be exactly: `passes` empty, `sign_off_pass_index`
`null`, `severity_aggregate` zero in every bucket, `verdict` `clean`,
`preserved_contradictions` empty.

When all dispatched passes have failed and no successful standard pass
exists, the aggregated result must be: `passes` containing the failed
entries (per Error Handling), `sign_off_pass_index` `null`,
`severity_aggregate` zero in every bucket, `verdict` `error`,
`preserved_contradictions` empty. This is not a valid sign-off; the
calling agent must continue dispatching until a successful standard pass
produces a valid index.

When the substantive (sign-off) pass contradicts a smoke-pass finding,
both the original finding and the contradicting commentary must appear
in the aggregated result: the original finding stays in its `passes`
entry, and the (finding, commentary) pair must additionally appear in
`preserved_contradictions` so callers can see the dispute trail without
walking the full pass list.

### Severity vocabulary

The severity values are fixed. Dispatched agents must use only these
values. The vocabulary is:

- `blocker`: must be addressed before the change set advances. Examples:
  data loss risk, security hole, broken build, broken contract.
- `major`: should be addressed before the change set advances unless the
  calling agent explicitly defers. Examples: significant correctness risk,
  missing error handling on an externally observable failure, regression
  risk in unrelated code.
- `minor`: improvement worth making but not blocking. Examples: clarity,
  small refactor opportunity, redundant code.
- `nit`: stylistic preference, naming polish, comment wording. Never
  blocking.

### Calling agent obligations

1. The calling agent must not treat a smoke-pass-only review as
   authoritative. Acting on a change set after only the smoke pass and
   skipping the substantive pass is prohibited.
2. The calling agent must not modify the change set during a pass. Edits
   may only happen between passes.
3. The calling agent must record the sign-off report (or a reference to
   it) so downstream consumers can verify a review occurred and see what
   was found.
4. The calling agent may dispatch further substantive passes at its
   discretion after the first sign-off. This spec imposes no maximum
   pass count and no normative convergence criterion; the caller decides
   when to stop.
5. When forwarding prior-pass findings into a substantive pass (per
   Inputs item 3), the calling agent must forward them unmodified,
   exactly as the prior pass returned them. No annotations, metadata,
   tags, dispute flags, or reordering may be added.

## Constraints

1. The smoke pass tier is fast-cheap. The substantive pass tier is
   standard. Tier substitution is prohibited: the smoke pass must
   not be standard, and the substantive pass must not be fast-cheap.
2. Dispatched review agents must not commit, push, edit, stage, or
   otherwise mutate the working tree or the repository state. They are
   read-only.
3. Dispatched review agents must not fix findings, even when the fix is
   obvious. Reporting and fixing are separate concerns owned by separate
   actors.
4. The fast-cheap smoke pass runs at most once per code review. Repeated fast-cheap
   passes within a single review are prohibited. (This contrasts with
   audit procedures, which permit up to two fast-cheap iterations before
   escalating to standard. The audit pattern lives in the spec-auditing and
   skill-auditing skills and is intentionally different.)
5. standard iteration after the first substantive pass is permitted and
   expected when findings warrant re-review of an updated change set.
   The final standard pass is always the sign-off.
6. A code review with an empty change set must return a sign-off report
   with an empty findings list and no passes dispatched.
7. Dispatched agents must operate with zero caller context. The
   permitted bootstrap inputs are enumerated under `Inputs` and that
   enumeration is exhaustive. No caller working-tree state, no agent
   memories, and no repository or project context beyond the optional
   context pointer (Inputs item 5).
8. The substantive pass must automatically re-examine every finding
   produced by every prior pass on the same change set. This is enforced
   by Inputs item 3 (the substantive pass receives prior findings as
   bootstrap input).
9. Caller disputes about smoke-pass findings must not be communicated to
   the substantive pass. The substantive pass forms its own judgment
   independently from the change set and the prior findings; injecting
   the caller's view would compromise that independence.
10. A pass's tier is fixed at dispatch and must not change during the
    pass. (Reinforces Constraint 1's tier-substitution prohibition for
    the per-pass duration.)
11. Focus areas (Inputs item 4) reorder the dispatched agent's search
    priority but must not reduce review depth on non-focus areas. The
    dispatched agent must still surface every `blocker` and `major`
    finding that exists outside the focus areas. `minor` and `nit`
    findings outside the focus may be deprioritized.

## Behavior

### Empty change set

When the change set is empty (no files, no diff content, no refs
resolving to changes), see Requirements > Outputs for the exact
aggregated result shape. No tier policy applies; no pass is dispatched.

### Single-file or trivially small change

The two-pass requirement holds regardless of change-set size. A
one-line change still receives a fast-cheap smoke pass and a standard
substantive pass. Cost is bounded by the change-set size, so trivial
changes are cheap; the policy does not change.

### Disagreement and disputes between passes

The normative rules governing re-examination and dispute handling live
in Constraints items 8 and 9. This section describes the two outcomes
the substantive pass may reach when re-examining a smoke-pass finding:

1. The substantive pass agrees with the smoke-pass finding. The finding
   carries through into the aggregated report with severity as judged by
   the substantive pass (which may upgrade or downgrade the smoke pass's
   severity).
2. The substantive pass contradicts the smoke-pass finding (marks it a
   false positive, or judges the issue out of scope). The substantive
   pass governs. The smoke-pass finding is preserved in the aggregated
   report with the substantive pass's contradicting commentary attached,
   so the audit trail remains complete.

If the calling agent disputes a smoke-pass finding between passes
without acting on it, the substantive pass will independently reach
case 1 or case 2 on its own judgment, since Constraints item 9
prohibits passing the caller's dispute to the substantive pass.

### Smoke pass framing

Smoke pass uses adversarial framing: "Assume the author made at least one mistake." Security-focused smoke passes add pentester framing. Substantive pass uses neutral framing.

### Hallucination filter

Hallucination filter: before including a finding, reviewer must verify file path exists in change set, cited line is in or near a changed hunk (within 10 lines), any verbatim code quotes appear in diff, and directional claims match diff direction. Findings that fail any check must be omitted.

## Defaults and Assumptions

- Smoke pass tier defaults to fast-cheap. No override permitted.
- Substantive pass tier defaults to standard. No override permitted.
- Focus areas: default none (full review). Behavior constraints defined
  under Requirements > Inputs item 4.
- See Calling agent obligations item 4 — no maximum pass count, no
  normative convergence criterion.
- Severity vocabulary defaults to the fixed four-value set defined under
  Definitions. No project-local extension permitted.

## Error Handling

- If the change set cannot be resolved (file path missing, ref
  unreachable, PR not found), the dispatched agent must return a
  pass-level error, not a finding. The skill must propagate the error to
  the calling agent without producing a sign-off.
- If a dispatched pass times out or returns malformed output, the
  calling agent must re-dispatch that pass. A failed pass does not count
  against the smoke-pass-runs-once rule.
- A failed pass must be recorded in the `passes` list as an error entry
  containing: `tier` (smoke or substantive), `pass_index` (the
  dispatch index it was assigned), `verdict` set to `error`, and a
  `failure_reason` field describing the failure (timeout, malformed
  output, or other). The error entry must NOT contain a findings list.
  The re-dispatched replacement pass appends as a new entry at the next
  index. The `sign_off_pass_index` always points to the most recent
  successful standard pass and never to an error entry.
- If the smoke pass produces a finding the calling agent disputes, the
  caller may proceed to the substantive pass without acting on the
  disputed finding. The substantive pass will re-examine it
  independently per `Behavior > Disagreement and disputes between
  passes` and will govern the final disposition.

## Precedence Rules

- Substantive pass findings govern over smoke pass findings on
  contradiction.
- The most recent standard pass governs over earlier standard passes for
  sign-off purposes.
- Severity vocabulary defined in this spec governs over any
  project-local severity convention.
- This spec governs over any inline preference expressed by a calling
  agent. The skill enforces the procedure; the caller cannot override
  the tier policy or the two-pass minimum.

## Don'ts

- Don't run only fast-cheap and treat the result as a complete review.
- Don't run only standard and skip the smoke pass on routine reviews. The
  smoke pass exists to absorb cheap findings before the expensive pass.
  (Exception: an empty change set, per Behavior.)
- Don't let dispatched agents fix code (see Constraints item 3).
- Don't let dispatched agents commit, push, stage, or otherwise mutate
  repository state.
- Don't introduce a third tier (for example, a standard smoke pass
  followed by an opus-class substantive pass). The two-tier model is
  fixed by this spec.
- Don't conflate the code review pattern with the audit pattern. Audits
  permit fast-cheap iteration; code reviews do not. The two patterns are
  intentionally different and live in different skills.
- Don't dispatch review agents with caller context. Zero-context
  isolation is a normative requirement, not an optimization.
- Don't introduce additional severity values or rename the existing four.

## Relationship to Other Skills

- **spec-writing**: defines the meta-rules this specification document
  follows (normative language, structure, auditing).
- **skill-writing**: governs the structure of the SKILL.md, uncompressed,
  and dispatch instruction file derived from this spec.
- **spec-auditing**: verifies this spec meets quality bar before the
  derived skill is written. Uses the audit pattern (up to two fast-cheap
  iterations, then standard final), which is deliberately different from
  the code review pattern this spec defines.
- **skill-auditing**: verifies the derived SKILL.md and dispatch
  instruction file match this spec. Uses the same audit pattern as
  spec-auditing.
- **dispatch agent** (`dispatch.agent.md`): provides the zero-context
  bootstrap that review passes require.
