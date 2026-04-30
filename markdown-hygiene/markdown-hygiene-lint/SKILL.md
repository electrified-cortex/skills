---
name: markdown-hygiene-lint
description: MD rule violation scan for a .md file. Fixes known safe rules in-place before scanning. Triggers — lint phase, MD violations, markdownlint scan.
---

# Markdown Hygiene — Lint

## Inputs

`<markdown_file_path>` — absolute path to the `.md` file to scan.
`<lint_path>` — absolute path to write `lint.md`.
`--ignore <RULE>[,<RULE>...]` (optional) — rule codes to suppress.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Lint: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Returns: `clean` | `findings: <lint_path>` | `ERROR: <reason>`
