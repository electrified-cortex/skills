---
name: code-review
description: Tiered code review on a change set. Read-only. Never modifies code. Triggers - security, correctness, code-quality, change-review, architectural-risk.
---

# Code Review

## Dispatch

`<instructions>` = `<absolute-path>/code-review/instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`

**Smoke pass:**
`<input-args>` = `change_set=<form> tier=smoke [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `fast-cheap`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`

**Substantive pass:**
`<input-args>` = `change_set=<form> tier=substantive prior_findings=<json> [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `standard`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`

## Inputs

`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `critical` and `high` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.

## Returns

RESULT: aggregated review result
ERROR: <reason>

## Single-Adversary Mode

`<input-args>` = `change_set=<file_path|pr_number> tier=single-adversary [model=<model>] [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `fast-cheap`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`

Inputs: `file_path` OR `pr_number` as `change_set`, optional `focus`.
Output: finding list (`{file, line_or_range, severity, description}`) + 1-3 sentence summary.

## Related

`dispatch` (`../dispatch/SKILL.md`), `swarm` (`../swarm/SKILL.md`), `code-review-setup` (`./code-review-setup/SKILL.md`)

