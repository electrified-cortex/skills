---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — lint markdown, scan markdown, MD violations, markdownlint pass, fix markdown.
---

# Markdown Hygiene

## Input

`<markdown_file_path>` — path to target file

## Result check

Run the `result` tool (in this folder), whichever your runtime has:

- Bash: `bash result.sh <markdown_file_path>`
- PS7: `pwsh result.ps1 <markdown_file_path>`

If stdout is `MISS: <abs-path>` -> bind `<report_path>` = `<abs-path>`, continue.
Otherwise -> emit stdout verbatim, stop.

## Preparation

If your runtime has a markdown linter, run its auto-fix pass on `<markdown_file_path>`. Don't install one if absent.

## Inspect

Variables:

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --report-path <report_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Inspecting Markdown Hygiene: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
If returns `ERROR: <reason>` -> stop, surface reason.

## Result check (post-execute)

Re-run `result` (same invocation as first Result check).
If stdout is `findings: <report_path>` -> continue to Iteration loop.
Otherwise -> emit stdout verbatim, stop.

## Iteration loop

Max 3 iterations. Still findings after 3rd -> stop, report last `<report_path>`.

`<tier>` = `standard`
`<description>` = `Fixing Markdown Hygiene: <markdown_file_path>`
`<prompt>` = `For this <markdown_file_path>, read <report_path> and fix any issues.`

Follow `dispatch` skill (same as Inspect). Then loop from "Inspect".
