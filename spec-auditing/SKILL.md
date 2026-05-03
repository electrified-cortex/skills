---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone for alignment and completeness.
  Triggers — spec validation, requirements coverage, contradiction detection,
  document alignment, specification quality.
---

## Dispatch

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<target-path> [--spec <spec-path>] [--fix]`
`<tier>` = `fast-cheap`
`<description>` = `Spec Audit: <target-path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `Pass` | `Pass with Findings` | `Fail` | `ERROR: <reason>`

Parameters:
`target-path` (required): path to spec or companion file
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (flag, optional): fix mode — target must be git-tracked and clean; modifies to match spec, up to 3 passes

One skill per invocation. Chain multiple subjects as separate runs.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
