---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code. Triggers - security, correctness, code-quality, change-review, architectural-risk.
---

# Code Review

Dispatch zero-context sub-agents per tier.

## Dispatch

`<instructions>` = `<path>/code-review/instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`

Pre-dispatch: if `context_pointer` not supplied by caller, check repo root for these files in order: `CLAUDE.md`, `README.md`, `.cursorrules`, `copilot-instructions.md`. Use the first file found as `context_pointer`. If none are found, omit the parameter.

Optional blast-radius gate (git-range input only): if `change_set` is a git ref or range (contains `..`, `...`, or matches `HEAD~N`), run `git diff --name-only <change_set>` to enumerate affected files. Restrict the review context to those files. Skip this step if `change_set` is an inline diff or an explicit file list.

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

## Extension Modes

### Single-Adversary Mode

Single-adversary: one-pass targeted review — see `instructions.uncompressed.md` for procedure.

### Swarm Integration

Dispatch code-review via `swarm` skill. See `swarm/SKILL.md`.
