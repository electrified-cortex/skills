---
name: markdown-hygiene
description: Fix markdownlint violations in a .md file. Triggers — lint markdown, scan markdown, MD violations, markdownlint pass, fix markdown.
---

Input: `<markdown_file_path>` — path to target file

## Preparation

If runtime has a markdown linter, run its auto-fix pass on `<markdown_file_path>` first (cheap mechanical fixes — trailing spaces, blanks around headings, list-marker consistency). Don't install one if absent. Dispatch verifies regardless.

## Inspect

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Inspecting Markdown Hygiene: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `CLEAN` | `findings: <report-path>` | `ERROR: <reason>`
(`<report-path>` = path to output file.)

## Iteration loop

`CLEAN` → stop.
`ERROR` → stop, surface reason.

Max 3 iterations. If still findings after 3rd, stop and report last `<report-path>` to host.

`findings: <report-path>` → dispatch fix pass:

`<tier>` = `standard`
`<description>` = `Fixing Markdown Hygiene: <markdown_file_path>`
`<prompt>` = `For this <markdown_file_path>, read <report-path> and fix any issues.`

Follow `dispatch` skill (same as Inspect). Then loop from "Inspect".
