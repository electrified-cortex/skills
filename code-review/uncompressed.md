---
name: code-review
description: Tiered code review on a change set. Fast-tier smoke pass surfaces surface-level findings; deep-tier substantive pass produces the authoritative sign-off. Reviews only; never modifies code.
---

# Code Reviewer

Two-tier code review on a change set. Calling agent orchestrates the passes; each pass is dispatched as an isolated agent with zero caller context.

Code reviews use exactly one haiku-class smoke pass followed by one or more sonnet-class substantive passes. Haiku iteration after the smoke pass is forbidden. Audits are a separate pattern (up to two iterations at the cheap tier before escalating) — see `spec-auditing` and `skill-auditing`.

## When to use

Reviewing a change set that consists of executable or compilable code: source files, build scripts, CI configuration, infrastructure-as-code manifests. For non-code artifacts (specs, skills, docs), use `spec-auditing` or `skill-auditing` instead.

## Procedure (calling agent orchestrates)

1. **Smoke pass** — dispatch exactly one haiku-class Dispatch agent. Pass the change set and `tier=smoke`.
2. **Caller acts (optional)** — read the smoke findings; decide which to act on; perform any edits yourself or via another skill. Dispatched review agents never edit.
3. **Substantive pass** — dispatch a sonnet-class Dispatch agent. Pass the change set, `tier=substantive`, and the prior pass's findings unmodified.
4. **Iterate Sonnet-only (optional)** — if findings warrant re-review of an updated change set, dispatch another Sonnet pass. Forward all prior-pass findings unmodified. Never re-introduce Haiku.
5. **Sign-off** — the most recent Sonnet pass is the authoritative sign-off. Record its report.

Empty change set: skip all passes; return the empty-result aggregate (see spec).

## Dispatch invocation (per pass)

Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

Tier governs model class — dispatch with `model: haiku` for `tier=smoke`, `model: sonnet` for `tier=substantive`. Tier substitution is prohibited.

## Inputs (per pass)

- `change_set` (required): one of — inline unified diff text, list of absolute file paths, or git ref/range (refs require shell access in the dispatched agent).
- `tier` (required): `smoke` or `substantive`.
- `prior_findings` (substantive only, required): the findings from every prior pass on the same change set, forwarded unmodified.
- `focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders search priority but does not reduce depth — `blocker` and `major` findings outside focus must still surface.
- `context_pointer` (optional): path to a CLAUDE.md / README / style guide for local conventions.

## Output (per pass)

Each dispatched pass returns a report containing:

- `findings`: list of `{severity, location, description, recommended_action}`. Severity vocabulary is fixed: `blocker`, `major`, `minor`, `nit`.
- `verdict`: `clean` (no findings), `findings` (at least one), or `error` (pass failed — see Errors).
- `tier`: `smoke` or `substantive`.
- `pass_index`: smoke is index 0; first Sonnet is index 1; subsequent Sonnet passes increment.

## Aggregated review result

Calling agent assembles:

- `passes`: per-pass reports in dispatch order.
- `sign_off_pass_index`: index of the most recent successful Sonnet pass; `null` when the change set was empty (no passes) or when only failed passes exist.
- `severity_aggregate`: count of findings by severity in the sign-off pass only (zero per bucket when sign-off is null or clean).
- `verdict`: `clean` (sign-off clean, or empty change set), `findings` (sign-off has findings), or `error` (only failed passes — keep dispatching until a successful Sonnet pass).
- `preserved_contradictions`: smoke findings the sign-off contradicted, paired with contradicting commentary.

## Rules (calling agent obligations)

- Never treat smoke-only as authoritative. Skipping the substantive pass is prohibited.
- Forward prior-pass findings unmodified into a substantive pass — no annotations, dispute flags, or reordering.
- Do not communicate caller disputes about smoke findings to the substantive pass. The substantive pass forms its own judgment.
- Do not modify the change set during a pass. Edits happen between passes only.
- Record the sign-off so downstream consumers can verify the review occurred.
- No maximum pass count, no normative convergence criterion. Caller decides when to stop iterating Sonnet passes.

## Errors

If a pass times out, returns malformed output, or cannot resolve the change set, record an error entry in `passes`: `{tier, pass_index, verdict: "error", failure_reason}`. NO findings list. Re-dispatch a replacement pass at the next index. A failed pass does not consume the smoke-pass-runs-once budget. `sign_off_pass_index` never points to an error entry.

Related: `spec-auditing` (audit pattern, not code-review pattern), `skill-auditing` (audit pattern), `dispatch.agent.md` (zero-context bootstrap), `compression`, `skill-writing`.
