---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone for alignment and completeness.
  Triggers — spec validation, requirements coverage, contradiction detection,
  document alignment, specification quality.
---

# Spec Auditing

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<target-path> [--spec <spec-path>] [--fix]`
`<tier>` = `fast-cheap`
`<description>` = `Spec Audit: <target-path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `Pass` | `Pass with Findings` | `Fail` | `ERROR: <reason>`

Parameters:

- `target-path` (string, required): path to spec file or companion file to audit
- `--spec <spec-path>` (string, optional): explicit path to spec file (pair-audit mode)
- `--fix` (flag, optional): fix mode — target must be git-tracked and clean; modifies target to match spec, up to 3 passes

One skill per invocation. Chain multiple subjects as separate runs.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
