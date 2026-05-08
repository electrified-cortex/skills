---
name: code-review
description: Tiered code review on a change set. Read-only. Never modifies code. Triggers - security, correctness, code-quality, change-review, architectural-risk.
---

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

`change_set` (required): inline unified diff, absolute file path list, or git ref/range.
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas. Reorders priority; doesn't reduce depth.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide.

## Returns

RESULT: aggregated review result
ERROR: <reason>

## Single-Adversary Mode

One-pass adversarial review. Runs inline (no tiered dispatch). Caller accepts reduced isolation.

Inputs: `file_path` OR `pr_number`, optional `model`, optional `focus`.
Output: finding list (`{file, line_or_range, severity, description}`) + 1-3 sentence summary.

## Related

`dispatch` (`../dispatch/SKILL.md`), `swarm` (`../swarm/SKILL.md`), `code-review-setup` (`./code-review-setup/SKILL.md`)
