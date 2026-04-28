---
name: spec-auditing
description: >-
  Audit a spec/companion pair or a spec alone. Dispatch instructions.txt —
  don't audit inline.
---

Don't read `instructions.txt` yourself. Use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `<target-path> [--spec <spec-path>] [--fix]`"

Parameters:
`target-path` (required): path to spec or companion file
`--spec <spec-path>` (optional): explicit spec path (pair-audit mode)
`--fix` (flag, optional): fix mode — target must be git-tracked and clean; modifies to match spec, up to 3 passes

Returns: Pass / Pass with Findings / Fail. Each finding: Finding ID, Severity, Title, Affected file(s), Evidence (with quote), Explanation, Recommended fix.
One skill per invocation. Chain multiple subjects as separate runs.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.
