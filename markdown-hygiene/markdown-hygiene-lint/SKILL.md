---
name: markdown-hygiene-lint
description: MD rule violation scan for a .md file. Fixes known safe rules in-place before scanning. Triggers — lint phase, MD violations, markdownlint scan.
---

# Markdown Hygiene — Lint

## Preparation

Run the in-place auto-fix script on `<markdown_file_path>`:

- PS7: `pwsh <this-skill-dir>/lint.ps1 <markdown_file_path>`
- Bash: `bash <this-skill-dir>/lint.sh <markdown_file_path>`

This fixes MD009 (trailing spaces), MD012 (consecutive blanks), MD047 (trailing newline) in-place before scanning.

## Cached Result check (lint)

Run inline result check for `lint`. See `../markdown-hygiene-result/SKILL.md`.

- `MISS: <abs-path>` — bind `<lint_path>`. Jump to Dispatch.
- Otherwise: stop here, return result to caller.

## Dispatch

Inputs:

`<markdown_file_path>` — absolute path to the `.md` file to scan.
`<lint_path>` — absolute path to write `lint.md`.
`--ignore <RULE>[,<RULE>...]` (optional) — rule codes to suppress.

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Lint: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../../dispatch/SKILL.md`.

Should return: `clean` | `findings: <lint_path>` | `ERROR: <reason>`

## Result

If `ERROR:` stop here and return the result to the caller.
Otherwise rerun the result check for `lint`.
If that result is a `MISS: <abs-path>` then something is wrong and report it as:
  `ERROR: Expected lint report at <abs-path>. None found.`
Otherwise return the result to the caller.
