---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code. Triggers — security, correctness, code-quality, change-review, architectural-risk.
---

# Code Review

Dispatch zero-context sub-agents per tier. NEVER read or interpret `instructions.txt` yourself — let the sub-agent do the work.

## Dispatch

**Smoke pass** (`tier=smoke`) — Haiku-class / fast-cheap:

Claude Code: `Agent` tool. Pass: "Read and follow `instructions.txt` here. Input: `change_set=<form> tier=smoke [focus=<csv>] [context_pointer=<path>]`"

VS Code / Copilot: `runSubagent(model: "Claude Haiku 4.5 (Copilot)", prompt: "Read and follow \`instructions.txt\` in this directory. Input: `change_set=<form> tier=smoke [focus=<csv>] [context_pointer=<path>]`")`

**Substantive pass** (`tier=substantive`) — Sonnet-class / standard:

Claude Code: `Agent` tool. Pass: "Read and follow `instructions.txt` here. Input: `change_set=<form> tier=substantive prior_findings=<json> [focus=<csv>] [context_pointer=<path>]`"

VS Code / Copilot: `runSubagent(model: "Claude Sonnet 4.6 (Copilot)", prompt: "Read and follow \`instructions.txt\` in this directory. Input: `change_set=<form> tier=substantive prior_findings=<json> [focus=<csv>] [context_pointer=<path>]`")`

## Orchestration

1. Dispatch smoke pass (Haiku/fast-cheap). Receive per-pass result.
2. Dispatch substantive pass (Sonnet/standard). Forward all smoke findings unmodified as `prior_findings`.
3. Collect both per-pass results. Build the aggregated result.

Per-pass result: `{tier, pass_index, verdict, findings[]}`. Verdict: `clean`, `findings`, `error`. Severity: `blocker`, `major`, `minor`, `nit`.

Aggregated result (caller builds after both passes complete):

| Field | Description |
| --- | --- |
| `passes` | Array of per-pass results, ordered by `pass_index`. |
| `sign_off_pass_index` | Index of the most recent successful standard pass (the authoritative sign-off). `null` if no successful standard pass yet. |
| `severity_aggregate` | Count of findings by severity (`blocker`, `major`, `minor`, `nit`) from the sign-off pass only. |
| `verdict` | Sign-off pass verdict propagated (`clean`, `findings`, or `error` if no successful standard pass). |
| `preserved_contradictions` | Findings where smoke and substantive disagree — surface as-is, do not resolve. |

## Caller obligations

- Smoke is not sign-off. Always dispatch substantive before acting on results.
- Forward `prior_findings` to substantive unmodified — no filtering, no summarizing.
- Tier substitution is prohibited: smoke must use fast-cheap, substantive must use standard.

## Parameters

`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `blocker` and `major` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.

Related: `spec-auditing`, `skill-auditing`, `dispatch`, `compression`
