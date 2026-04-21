---
name: code-reviewer
description: Tiered code review on a change set. Haiku smoke pass surfaces easy or lint-grade findings; Sonnet substantive pass produces the authoritative sign-off. Reviews only; never modifies code.
---

# Code Reviewer

Two-tier code review on a change set. Calling agent orchestrates; each pass dispatched as isolated agent, zero caller context.

Code reviews use exactly one haiku-class smoke pass followed by one or more sonnet-class substantive passes. Haiku iteration after the smoke pass is forbidden. Audits are a separate pattern — see `spec-auditing` and `skill-auditing`.

When to use:
Executable or compilable code: source files, build scripts, CI config, infra-as-code manifests. Non-code (specs, skills, docs) → `spec-auditing` or `skill-auditing`.

Procedure (calling agent orchestrates):
1. Smoke pass — dispatch exactly one haiku-class agent. Pass change set + `tier=smoke`.
2. Caller acts (optional) — read smoke findings; decide which to act on; edit yourself or via another skill. Dispatched review agents never edit.
3. Substantive pass — dispatch sonnet-class agent. Pass change set, `tier=substantive`, prior findings unmodified.
4. Iterate Sonnet-only (optional) — re-review updated change set: dispatch another Sonnet pass, forward all prior findings unmodified. Never re-introduce Haiku.
5. Sign-off — most recent Sonnet pass is authoritative. Record its report.

Empty change set: skip all passes; return empty-result aggregate (see spec).

Dispatch invocation (per pass):
"Read and follow `instructions.txt` (in this directory). Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

`model: haiku` for `tier=smoke`; `model: sonnet` for `tier=substantive`. Tier substitution is prohibited.

Inputs (per pass):
`change_set` (required): inline unified diff, list of absolute file paths, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): findings from every prior pass, forwarded unmodified.
`focus` (optional): comma-separated areas (e.g. `security,concurrency`). Reorders priority, doesn't reduce depth — `blocker`/`major` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md / README / style guide for local conventions.

Output (per pass):
`findings`: list of `{severity, location, description, recommended_action}`. Severity: `blocker`, `major`, `minor`, `nit`.
`verdict`: `clean`, `findings`, or `error` (see Errors).
`tier`: `smoke` or `substantive`.
`pass_index`: smoke=0; first Sonnet=1; subsequent increment.

Aggregated review result:
`passes`: per-pass reports in dispatch order.
`sign_off_pass_index`: most recent successful Sonnet index; `null` if empty change set or only failed passes.
`severity_aggregate`: finding counts by severity in sign-off pass only (zero per bucket when null or clean).
`verdict`: `clean`, `findings`, or `error` (only failed passes — keep dispatching until successful Sonnet).
`preserved_contradictions`: smoke findings sign-off contradicted, paired with contradicting commentary.

Rules (calling agent obligations):
Never treat smoke-only as authoritative. Skipping substantive pass is prohibited.
Forward prior-pass findings unmodified — no annotations, dispute flags, or reordering.
Don't relay caller disputes to substantive pass; it forms its own judgment.
Don't modify change set during a pass. Edits between passes only.
Record sign-off for downstream verification.
No max pass count, no convergence criterion. Caller decides when to stop.

Errors:
Timeout, malformed output, or unresolvable change set → record `{tier, pass_index, verdict: "error", failure_reason}` in `passes`. NO findings list. Re-dispatch at next index. Failed pass doesn't consume smoke-once budget. `sign_off_pass_index` never points to error entry.

Related: `spec-auditing`, `skill-auditing`, `dispatch.agent.md`, `compression`, `skill-writing`.
