---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code.
---

# Code Review

Without reading `instructions.txt` yourself, use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

**Do NOT run code review inline.** Inline execution produces shallow, inconsistent results and allows caller context to bleed into review judgment.

Tier vocabulary:

- **fast-cheap** — cost-optimized model (e.g. Haiku-class). Use for `tier=smoke`.
- **standard** — capable model (e.g. Sonnet-class). Use for `tier=substantive`.

Tier substitution is prohibited.

## Parameters

- `change_set` (required): inline unified diff text, list of absolute file paths, or git ref/range (refs require shell access in the dispatched agent).
- `tier` (required): `smoke` or `substantive`.
- `prior_findings` (substantive only, required): findings from every prior pass on the same change set, forwarded unmodified.
- `focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; does not reduce depth — `blocker` and `major` outside focus must still surface.
- `context_pointer` (optional): path to a CLAUDE.md, README, or style guide for local conventions.

**Returns (per pass):** `{tier, pass_index, verdict, findings[]}`. Verdict: `clean`, `findings`, or `error`. Severity vocabulary: `blocker`, `major`, `minor`, `nit`.

One skill per invocation. Each pass is a separate dispatch. Smoke always runs before substantive. The two-pass policy (smoke + substantive) applies regardless of change-set size — there is no size threshold that permits a single-pass review.

## Procedure (calling agent orchestrates)

1. **Smoke pass** — dispatch a fast-cheap agent with `tier=smoke`.
2. **Caller acts (optional)** — read smoke findings; act on any; edits are yours, not the review agent's.
3. **Substantive pass** — dispatch a standard agent with `tier=substantive` and all prior-pass findings unmodified.
4. **Iterate standard-only (optional)** — if findings warrant re-review, dispatch another standard pass. Forward all prior findings unmodified. Never re-introduce fast-cheap.
5. **Sign-off** — the most recent standard pass is authoritative. Record its report.

Empty change set: skip all passes; return the empty-result aggregate.

## Aggregated Result

Calling agent assembles after all passes:

- `passes`: per-pass reports in dispatch order.
- `sign_off_pass_index`: index of the most recent successful standard pass; `null` when empty change set or only failed passes exist.
- `severity_aggregate`: finding counts by severity in the sign-off pass only (zero per bucket when null or clean).
- `verdict`: `clean`, `findings`, or `error`.
- `preserved_contradictions`: smoke findings the sign-off contradicted, each paired with contradicting commentary.

## Calling Agent Rules

- Never treat smoke-only as authoritative. Skipping the substantive pass is prohibited.
- Forward prior-pass findings unmodified — no annotations, dispute flags, or reordering.
- Do not communicate caller disputes about smoke findings to the substantive pass.
- Do not modify the change set during a pass. Edits happen between passes only.
- Record the sign-off so downstream consumers can verify the review occurred.

## Iteration Safety

Both rules exist to prevent wasted-work loops where a calling agent dispatches repeated review passes against the same change set with no code changes between runs.

**Rule A — Address findings before re-reviewing.** If a review pass produces findings, the calling agent must address each one — by fixing the code, explicitly accepting the finding, or waiving it with a recorded rationale — before dispatching another pass against the same change set. Dispatching another pass without acting on prior findings is forbidden.

**Rule B — Never re-review unchanged code.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." Before dispatching a follow-up pass, the calling agent must verify that at least one source file in the change set has been modified since the previous pass completed. If no file has changed, the prior verdict stands and re-dispatch is forbidden.

## When to Use

Reviewing a change set of executable or compilable code: source files, build scripts, CI configuration, infrastructure-as-code manifests.

For non-code artifacts (specs, skills, docs), use `spec-auditing` or `skill-auditing` instead — they use a different tier policy.

Related: `spec-auditing`, `skill-auditing`, `dispatch`, `compression`
