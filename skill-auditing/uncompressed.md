---
name: skill-auditing
description: Audit a skill for quality, classification, cost, and compliance with the skill-writing spec. Triggers — audit this skill, check skill quality, review skill compliance, validate skill structure, skill needs review.
---

# Skill Auditing

## Input

`<skill_dir>` — absolute path to the skill folder being audited.
`<flags>` — optional, any combination:

- `--uncompressed`: shifts audit focus from compiled artifacts (`SKILL.md` + `instructions.txt`) to uncompressed sources (`uncompressed.md` + `instructions.uncompressed.md` + `spec.md`). Manifest scope is unaffected (always all-files).

## Inline result check

Run the `result` tool (in this folder), whichever your runtime has. DON'T READ the script source at any point — before, during, or after invocation. Run it, branch on stdout, move on.

- Bash: `bash result.sh <skill_dir> [--uncompressed]`
- PS7: `pwsh result.ps1 <skill_dir> [-uncompressed]`

If stdout is `MISS: <abs-path>` -> bind `<report_path>` = `<abs-path>`, continue to Preparation.
Otherwise -> emit stdout verbatim, stop.

## Preparation

Pre-audit markdown-hygiene sweep. For each `.md` file in `<skill_dir>` (one by one, sequentially):

- Run the `markdown-hygiene` skill on that file (per `../markdown-hygiene/SKILL.md`).
- If mhygiene returns `findings: <report-path>` after its own 3-iteration loop, stop the whole audit and surface: `ERROR: pre-audit mhygiene failed on <file>: <report-path>`.
- If mhygiene returns `ERROR: <reason>`, stop and surface.
- Continue when CLEAN.

Audit proceeds only when every `.md` in `<skill_dir>` is CLEAN per mhygiene.

## Inspect

Variables:

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `skill_dir=<skill_dir> --report-path <report_path> [--uncompressed]`
`<tier>` = `standard` — audit requires judgment; fast-cheap models miss nuances
`<description>` = `Auditing skill: <skill_dir>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Should return: `PASS: <path>` | `NEEDS_REVISION: <path>` | `FAIL: <path>` | `ERROR: <reason>`
If returns `ERROR: <reason>` -> stop, surface reason.

## Inline result check (post-execute)

You (the host) run `result` again directly — do NOT dispatch it.
Same invocation as the first Inline result check.
Branch on stdout (last line):

- `PASS: <report_path>` -> done.
- `NEEDS_REVISION: <report_path>` -> caller may dispatch a fix pass with the report; surface and stop.
- `FAIL: <report_path>` -> surface and stop.
- `ERROR: <reason>` -> stop, surface reason.
- `MISS: <abs-path>` -> executor failed to write report; surface `ERROR: executor did not write report at <report_path>`, stop.
