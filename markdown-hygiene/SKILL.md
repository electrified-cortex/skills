---
name: markdown-hygiene
description: Fix markdownlint violations and analyze semantic quality in a .md file. Triggers — lint markdown, scan markdown, MD violations, markdownlint pass, fix markdown, analyze markdown, semantic hygiene.
---

## Input

`<markdown_file_path>` — path to target file

## Inline result check

Run `result` tool (in this folder), whichever your runtime has. DON'T READ the script source at any point — before, during, or after invocation. Run it, branch on stdout, move on.

- Bash: `bash result.sh <markdown_file_path>`
- PS7: `pwsh result.ps1 <markdown_file_path>`

(Note: the terminal output might wrap)

If stdout is `MISS: <abs-path>` -> bind `<report_path>` = `<abs-path>`, derive siblings:
  `<lint_path>` = `$(dirname <report_path>)/lint.md`
  `<analysis_path>` = `$(dirname <report_path>)/analysis.md`
  Continue.
Otherwise -> emit stdout verbatim, stop.

## Preparation

If runtime has markdown linter, run auto-fix on `<markdown_file_path>`. Don't install if absent.
Ignore MD041 warnings if target file: SKILL.md.
NEVER lint before result check as it will invalidate cached results.

No linter: skip to Phase 1.
If lint fix applied, hash may have changed: go back to "Inline result check"; on 2nd MISS skip Preparation.

## Phase 1 — Lint (Haiku-class)

Variables:

`<lint-instructions>` = `markdown-hygiene-lint/instructions.txt` (NEVER READ)
`<lint-instructions-abspath>` = absolute path to `<lint-instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Linting Markdown: <markdown_file_path>`
`<prompt>` = `Read and follow <lint-instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
If returns `ERROR: <reason>` -> stop, surface reason.
Bind phase 1 result: `clean` or `findings: <lint_path>`.

## Phase 2 — Analysis (Sonnet-class)

Variables:

`<analysis-instructions>` = `markdown-hygiene-analysis/instructions.txt` (NEVER READ)
`<analysis-instructions-abspath>` = absolute path to `<analysis-instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> --analysis-path <analysis_path> --report-path <report_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `standard`
`<description>` = `Analyzing Markdown Quality: <markdown_file_path>`
`<prompt>` = `Read and follow <analysis-instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
If returns `ERROR: <reason>` -> stop, surface reason.

## Inline result check (post-execute)

You (the host) run `result` again directly — do NOT dispatch it.
Same invocation as first Inline result check.
Output is always exactly one line starting with a prefix. Long paths may visually wrap in terminal display — ignore the wrap, match from the start of the full output string.
If stdout is `findings: <report_path>` -> continue to Iteration loop.
Otherwise -> emit stdout verbatim, stop.

## Iteration loop

Max 3 iterations. Still findings after 3rd -> stop, report last `<report_path>`.

**Lint-only re-run** (host applied fixes from `lint.md`):

`<tier>` = `fast-cheap`
`<description>` = `Re-linting Markdown: <markdown_file_path>`
`<prompt>` = `Read and follow <lint-instructions-abspath>; Input: <markdown_file_path> --lint-path <lint_path> [--ignore ...]`

Follow `dispatch` skill (same as Phase 1). Then check `lint.md` result. If lint now clean, re-run Phase 2 to refresh `analysis.md` and `report.md`. Then loop from "Inline result check".

**Full re-run** (host applied changes from `analysis.md` suggestions):

Re-run Phase 1 then Phase 2 in sequence. Then loop from "Inline result check".

