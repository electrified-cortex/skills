---
name: chain-link-auditing
description: Mechanically verify a chain-link SKILL folder against the chain-link contract from chain-link-writing. Runs FIRST in the audit sequence — if the chain contract is wrong, general SKILL hygiene is moot. Checks manifest presence + schema, link row alignment, SKILL body boundary (no orchestration leak, no stack assumptions, no bloat), output declarations match manifest, inputs match upstream outputs, mode/instructions.txt consistency, terminus/first-link constraints, brevity targets, repo-relative paths. Triggers - chain-link audit, chain link audit, audit chain link, verify chain contract, chain contract check, chain manifest audit, link boundary audit, audit link folder.
---

Audits a chain-link folder against the contract in `chain-link-writing/spec.md`. Run BEFORE `skill-auditing`.

## Inputs

`<link_dir>` — repo-relative path to the link folder being audited.
`<chain_root>` — optional; if absent, walk up from `<link_dir>` to find `chain.md`.
`<report_path>` — absolute path to write the audit report (overwrite if present).

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `--link-dir <abs(link_dir)> [--chain-root <abs(chain_root)>] --report-path <abs(report_path)>`
`<tier>` = `fast-cheap` (haiku-class); standard only on re-dispatch for ambiguous results
`<description>` = `chain-link-audit: <link_dir>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Import the `dispatch` skill from `../dispatch/SKILL.md`.

## Post-dispatch

Verify `<report_path>` exists. If absent → surface `ERROR: executor did not write report at <report_path>`; stop. Read the last non-empty line of the report — that is the verdict.

## Verdict Routing

| Last line | Outcome | Caller action |
|---|---|---|
| `PASS: <path>` | PASS | proceed to `skill-auditing` (or ship if still developing) |
| `NEEDS_REVISION: <path>` | NEEDS_REVISION | fix MEDIUM findings; re-dispatch |
| `FAIL: <path>` | FAIL | fix HIGH findings; re-dispatch |
| `BLOCKED: <path>` | BLOCKED | resolve missing manifest / unreadable inputs |
| absent / unrecognized | ERROR | surface and stop |

To fix, load `../dispatch/SKILL.md` and dispatch a standard-tier sub-agent with the report as input, instructed to fix all flagged findings. Cap fix rounds at 3; surface the report if stuck.

## What gets checked

Per the chain-link-writing contract (see `chain-link-writing/spec.md`):

- Manifest presence at chain root; required columns; link row found.
- Link row field validity (`mode` ∈ inline/dispatch; `tier` ∈ fast-cheap/standard/deep; prev/next references resolve).
- SKILL body boundary — no orchestration leak (HIGH), no narrative bloat (MEDIUM), no stack-specific assumptions in non-stack-specific chains (HIGH), no duplicate restatement of sibling conventions (LOW).
- Outputs declared in SKILL match manifest `outputs` column (HIGH on mismatch).
- Inputs match upstream outputs OR chain entry-point inputs (HIGH on mismatch).
- `mode: dispatch` ↔ `instructions.txt` presence consistency (HIGH on mismatch).
- Manifest has exactly one first-link (`prev: —`) and at least one terminus (`next-pass: —`).
- Brevity: dispatch SKILL ≤ 50 lines · inline ≤ 75 · inline with loop ≤ 120 · presumptive bloat > 150.
- All paths repo-relative.

Hash-record usage is NEVER a finding (per chain-link-writing R-CLW-9).

## Verdict aggregation

| Findings | Verdict |
|---|---|
| Zero | `PASS` |
| LOW only | `PASS` (LOW listed for awareness) |
| MEDIUM present, no HIGH | `NEEDS_REVISION` |
| Any HIGH | `FAIL` |
| Unreadable manifest, missing link folder, or sub-agent failure | `BLOCKED` |

## Related

`chain-link-writing` — defines the contract this skill audits against
`skill-auditing` — general SKILL hygiene; runs AFTER chain-link-auditing PASS
`spec-auditing` — audit spec content separately
`dispatch` — dispatch mechanics
`hash-record` — optional cache for re-runs against unchanged inputs
