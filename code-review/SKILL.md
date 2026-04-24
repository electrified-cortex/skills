---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code.
---

# Code Review

Don't read `instructions.txt` yourself — use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory).
Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

Do NOT run code review inline. Inline execution: shallow/inconsistent results, caller context bleeds into judgment.

Tier vocabulary:
`fast-cheap` — cost-optimized (e.g. Haiku-class), use for `tier=smoke`.
`standard` — capable (e.g. Sonnet-class), use for `tier=substantive`.
Tier substitution is prohibited.

Parameters:
`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `blocker` and `major` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.

Returns (per pass): `{tier, pass_index, verdict, findings[]}`. Verdict: `clean`, `findings`, `error`. Severity: `blocker`, `major`, `minor`, `nit`.

One skill per invocation. Each pass is separate dispatch. Smoke always runs before substantive. Two-pass policy applies regardless of change-set size — no size threshold permits single-pass review.

Procedure (calling agent orchestrates):
1. Smoke pass — dispatch fast-cheap agent with `tier=smoke`.
2. Caller acts (optional) — read smoke findings; act on any; edits are caller's, not review agent's.
3. Substantive pass — dispatch standard agent with `tier=substantive` and all prior-pass findings unmodified.
4. Iterate standard-only (optional) — if findings warrant re-review, dispatch another standard pass. Forward all prior findings unmodified. Never re-introduce fast-cheap.
5. Sign-off — most recent standard pass is authoritative. Record its report.

Empty change set: skip all passes; return empty-result aggregate.

Aggregated Result:
Calling agent assembles after all passes:
`passes`: per-pass reports in dispatch order.
`sign_off_pass_index`: index of most recent successful standard pass; `null` when empty change set or only failed passes exist.
`severity_aggregate`: finding counts by severity in sign-off pass only (zero per bucket when null or clean).
`verdict`: `clean`, `findings`, or `error`.
`preserved_contradictions`: smoke findings sign-off contradicted, each paired with contradicting commentary.

Calling Agent Rules:
Never treat smoke-only as authoritative. Skipping substantive pass is prohibited.
Forward prior-pass findings unmodified — no annotations, dispute flags, or reordering.
Don't communicate caller disputes about smoke findings to substantive pass.
Don't modify change set during a pass. Edits happen between passes only.
Record sign-off so downstream consumers can verify review occurred.

Iteration Safety:
Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

When to Use:
Reviewing change set of executable or compilable code: source files, build scripts, CI config, IaC manifests.
For non-code artifacts (specs, skills, docs), use `spec-auditing` or `skill-auditing` — different tier policy.

Related: `spec-auditing`, `skill-auditing`, `dispatch`, `compression`
