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

## Parameters

`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `critical` and `high` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.

## Returns

RESULT: aggregated review result
ERROR: <reason>

## Single-Adversary Mode

One-pass adversarial review. Runs inline (no tiered dispatch). Caller accepts reduced isolation.

Inputs: `file_path` OR `pr_number`, optional `model`, optional `focus`.

Procedure:
1. Check capability-cache for available models. Use `model` if specified; else first available from cache; else host model.
2. Read target (file contents or PR diff) fully.
3. Dispatch ONE adversarial pass: `<input-args>` = `change_set=<target> tier=smoke [focus=<focus>]`; `<tier>` = `fast-cheap`; `<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
4. Return finding list + 1-3 sentence summary. Do NOT treat output as tiered sign-off.

