---
name: markdown-hygiene-lint
description: MD rule violation scan for a .md file. Fixes known safe rules in-place before scanning. Triggers — lint phase, MD violations, markdownlint scan.
---

Inputs:

`<markdown_file_path>` — absolute path to the `.md` file to scan.
`--ignore <RULE>[,<RULE>...]` (optional) — rule codes to suppress.

## Cached Result Check

Run inline result check for `lint`. See `../markdown-hygiene-result/SKILL.md`.

- `MISS: <abs-path>` — bind `<lint_path>`. Jump to Dispatch.
- Otherwise: stop here, return result to caller.

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<markdown_file_path> --lint-path <lint_path> [--ignore <RULE>[,<RULE>...]]`
`<tier>` = `fast-cheap`
`<description>` = `Markdown Hygiene Lint: <markdown_file_path>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `../../dispatch/SKILL.md`.

Should return: `clean` | `findings: <lint_path>` | `ERROR: <reason>`

## Result

If `ERROR:` stop here and return the result to the caller.
Otherwise rerun the result check for `lint`.
If that result is a `MISS: <abs-path>` then something is wrong and report it as: `ERROR: Expected lint report at <abs-path>. None found.`

If `clean`, return the result to the caller and stop here.

To fix, `dispatch` a sub-agent with this report as input instructing it to fix all the issues.
Then follow this skill again, keep track of the number of revision rounds. If it has been 3, stop here and surface the report.
