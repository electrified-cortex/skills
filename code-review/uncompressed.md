---
name: code-review
description: Tiered code review on a change set. Read-only. Never modifies code. Triggers - security, correctness, code-quality, change-review, architectural-risk.
---

# Code Review

## Cache Probe

Before dispatching any pass:
1. Compute canonical manifest hash: SHA-256 of sorted `change_set` file paths + their content hashes + `tier` + `focus` (if set) + `context_pointer` hash (if set) + `prior_findings` hash (substantive, if set).
2. Check `.hash-record/XX/HASH/code-review/vN[/<model>]/report.md` (caller: SKILL.md owns probe + write; dispatched agents don't cache).
3. Cache hit → return cached report, skip dispatch.
4. Cache miss → proceed to dispatch. After receiving result, write to cache path.

## Dispatch

`<instructions>` = `<absolute-path>/code-review/instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`

**Smoke pass:**
`<description>` = `code-review smoke — fast surface scan`
`<input-args>` = `change_set=<form> tier=smoke [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `fast-cheap` (shallow scan; surface-level findings only)
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`
Should return: JSON findings report `{tier, pass_index, verdict, findings[], failure_reason?}`

**Substantive pass:**
`<description>` = `code-review substantive — full depth pass`
`<input-args>` = `change_set=<form> tier=substantive prior_findings=<json> [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `standard` (full depth; design, correctness, security, architectural risk)
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`
Should return: JSON findings report `{tier, pass_index, verdict, findings[], failure_reason?}`

## Inputs

`change_set` (required): inline unified diff, absolute file path list, or git ref/range (refs require shell access in dispatched agent).
`tier` (required): `smoke` or `substantive`.
`prior_findings` (substantive only, required): all prior-pass findings forwarded unmodified.
`focus` (optional): comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; doesn't reduce depth — `critical` and `high` outside focus must still surface.
`context_pointer` (optional): path to CLAUDE.md, README, or style guide for local conventions.
`model` (optional): model override. Affects cache path subfolder (`.../vN/<model>/report.md`). Applies to all tiers.

## Returns

RESULT: aggregated review result `{passes[], sign_off_pass_index, severity_aggregate, verdict, preserved_contradictions[]}`
ERROR: <reason>

Calling agent assembles aggregated result from per-pass reports. Aggregation rules in `instructions.txt`.

## Single-Adversary Mode

`<description>` = `code-review single-adversary — focused adversarial pass`
`<input-args>` = `change_set=<file_path|pr_number> tier=single-adversary [model=<model>] [focus=<csv>] [context_pointer=<path>]`
`<tier>` = `fast-cheap` (focused adversarial pass; catches obvious logic errors; may miss subtle security flaws — use `model=standard` for security-critical code)
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`
Follow dispatch skill. See `../dispatch/SKILL.md`
Should return: JSON findings report `{tier, pass_index, verdict, findings[], failure_reason?}`

Inputs: `file_path` OR `pr_number` as `change_set`, optional `focus`.
Output: finding list (`{file, line_or_range, severity, description}`) + 1-3 sentence summary.

## Related

`dispatch` (`../dispatch/SKILL.md`), `swarm` (`../swarm/SKILL.md`), `code-review-setup` (`./code-review-setup/SKILL.md`)

