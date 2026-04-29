---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code. Triggers — security, correctness, code-quality, change-review, architectural-risk.
---

# Code Review

Without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent:

Claude Code: `Agent` tool. Pass: "Read and follow `instructions.txt` here. Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`"

VS Code / Copilot: `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow `instructions.txt` in this directory. Input: `change_set=<form> tier=<smoke|substantive> [prior_findings=<json>] [focus=<csv>] [context_pointer=<path>]`")`

Don't read `instructions.txt` yourself.

Returns: `{tier, pass_index, verdict, findings[]}` per pass. Verdict: `clean`, `findings`, `error`. Severity: `blocker`, `major`, `minor`, `nit`.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent do the work.

## Tier vocabulary

`fast-cheap` — cost-optimized (e.g. Haiku-class), use for `tier=smoke`.
`standard` — capable (e.g. Sonnet-class), use for `tier=substantive`.
Tier substitution is prohibited.

## Parameters

`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `blocker` and `major` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.

Related: `spec-auditing`, `skill-auditing`, `dispatch`, `compression`
