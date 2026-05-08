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

RESULT: aggregated review result (see spec.md for schema)
ERROR: <reason>

## Extension Modes

### Single-Adversary Mode

Quick targeted review: one pass, focused finding list. Low cost, fast.

Input:
- `file_path` OR `pr_number` — target of the review.
- `model` — which model to use. If omitted, read capability-cache for available models; use first listed, or fall back to host model.
- `focus` — optional. Specific concern (e.g. "security", "logic errors", "API surface").

Output:
- Finding list: each finding as `{file, line_or_range, severity, description}`. Severity: `critical | high | medium | low | info`.
- Summary: 1-3 sentences — top concern + overall verdict.

Procedure:
1. Check capability cache (see `capability-cache` skill) to determine available models.
2. If `model` specified, use it. If not, use first available from cache (fall back to host model if cache MISS or unavailable).
3. Read the target (file contents or PR diff).
4. Produce ONE adversarial review pass: assume the author is wrong and look for problems.
5. Return finding list + summary.

### Swarm Integration

Dispatch code-review via `swarm` skill. See `swarm/SKILL.md`.
