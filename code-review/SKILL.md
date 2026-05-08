---
name: code-review
description: Tiered code review on a change set. Read-only — never modifies code. Triggers - security, correctness, code-quality, change-review, architectural-risk.
---

## Dispatch

`<instructions>` = `<absolute-path>/code-review/instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`

Pre-dispatch: if `context_pointer` not supplied by caller, check repo root for: `CLAUDE.md`, `README.md`, `.cursorrules`, `copilot-instructions.md`. Use first found. If none, omit.

Optional blast-radius gate (git-range input only): if `change_set` is a git ref/range (contains `..`, `...`, or matches `HEAD~N`), run `git diff --name-only <change_set>`. Restrict review context to those files. Skip if `change_set` is an inline diff or explicit file list.

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

RESULT: aggregated review result (see spec.md for schema)
ERROR: <reason>

## Extension Modes

Single-adversary: see uncompressed.md
Swarm integration: dispatch code-review via `swarm` skill — see swarm/SKILL.md

## Dependencies

- `capability-cache` skill
- `code-review-setup/` (sub-skill): preflight readiness check
- `dispatch` skill
- `swarm` skill (for swarm mode)
