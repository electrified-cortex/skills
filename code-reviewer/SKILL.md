---
name: code-reviewer
description: Tiered code review on a change set. Haiku smoke pass surfaces easy or lint-grade findings; Sonnet substantive pass produces the authoritative sign-off. Reviews only; never modifies code.
---

# Code Reviewer

Two-tier code review on change set. Calling agent orchestrates; each pass dispatched as isolated agent, zero caller context.

Exactly one haiku-class smoke pass, then one or more sonnet-class substantive passes. Haiku iteration after smoke forbidden. Audits: separate pattern (up to 2 cheap-tier iterations before escalating) — see `spec-auditing`, `skill-auditing`.

When to use:
Executable/compilable code change sets: source files, build scripts, CI config, IaC manifests. Non-code artifacts (specs, skills, docs) → `spec-auditing` or `skill-auditing`.

Procedure (calling agent orchestrates):
1. Smoke pass — dispatch exactly one haiku-class Dispatch agent. Pass change set and `tier=smoke`.
2. Caller acts (optional) — read smoke findings, act on them, edit via skill. Review agents never edit.
3. Substantive pass — dispatch sonnet-class Dispatch agent. Pass change set, `tier=substantive`, prior findings unmodified.
4. Iterate Sonnet-only (optional) — if findings warrant re-review, dispatch another Sonnet pass. Forward all prior findings unmodified. Never re-introduce Haiku.
5. Sign-off — most recent Sonnet pass is authoritative. Record its report.

Empty change set: skip all passes; return empty-result aggregate (see spec).

Dispatch invocation (per pass):
Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

Tier governs model class — `model: haiku` for `tier=smoke`, `model: sonnet` for `tier=substantive`. Substitution prohibited.

Inputs (per pass):
`change_set` (required): inline unified diff text, list of absolute file paths, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): findings from every prior pass, forwarded unmodified.
`focus` (optional): CSV focus areas (e.g. `security,concurrency`). Reorders priority, doesn't reduce depth — `blocker`/`major` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md / README / style guide for local conventions.

Output (per pass):
`findings`: list of `{severity, location, description, recommended_action}`. Severity vocabulary fixed: `blocker`, `major`, `minor`, `nit`.
`verdict`: `clean` (no findings), `findings` (at least one), or `error` (pass failed — see Errors).
`tier`: `smoke` or `substantive`.
`pass_index`: smoke=0; first Sonnet=1; subsequent Sonnet passes increment.

Aggregated result:
`passes`: per-pass reports in dispatch order.
`sign_off_pass_index`: most recent successful Sonnet index; `null` when change set empty or only failed passes exist.
`severity_aggregate`: count by severity, sign-off pass only; zero per bucket when sign-off null/clean.
`verdict`: `clean` (sign-off clean or empty change set), `findings` (sign-off has findings), or `error` (only failed passes — keep dispatching until successful Sonnet pass).
`preserved_contradictions`: smoke findings sign-off contradicted, paired with contradicting commentary.

Rules (caller):
Never treat smoke-only as authoritative. Skipping substantive pass prohibited.
Forward prior-pass findings unmodified — no annotations, dispute flags, or reordering.
Don't communicate caller disputes about smoke findings to substantive pass. It forms its own judgment.
Don't modify change set during a pass. Edits between passes only.
Record sign-off so downstream consumers can verify review occurred.
No max pass count, no convergence criterion. Caller decides when to stop iterating Sonnet passes.

Errors:
Pass times out, returns malformed output, or can't resolve change set → record `{tier, pass_index, verdict: "error", failure_reason}` in `passes`. No findings list. Re-dispatch replacement pass at next index. Failed pass doesn't consume smoke-once budget. `sign_off_pass_index` never points to error entry.

Related: `spec-auditing` (audit pattern, not code-review), `skill-auditing` (audit pattern), `dispatch.agent.md` (zero-context bootstrap), `compression`, `skill-writing`.
