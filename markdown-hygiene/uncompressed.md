---
name: markdown-hygiene
description: Detect markdownlint violations in a .md file. Detect-only — no fix. Triggers — lint markdown, scan markdown, MD violations, markdownlint pass, detect markdown issues.
---

# Markdown Hygiene

`<instructions>`: `instructions.txt` (in this skill folder; NEVER READ THIS FILE)
`<instructions-abspath>`: the absolute path to `<instructions>`
`<hashname>`: the model being dispatched
`<dispatch-prompt>`: `Read and follow <instructions-abspath>`
`<input-suffix>`: `Input: <markdown_file_path> --hashname <hashname> [--ignore <RULE>[,<RULE>...]]`

Without reading `instructions.txt` yourself, spawn a zero-context Dispatch sub-agent (haiku-class):

Claude Code `Agent` tool:
`subagent_type: "Dispatch"`, `prompt: "<dispatch-prompt>; <input-suffix>"`, `model: "haiku"`
Run in background if possible.

VS Code / Copilot `runSubagent(agentName: "Dispatch", model: "Claude Haiku 4.5", prompt: "<prompt>")`. Synchronous.

`<path-to-instructions.txt>` resolves to `markdown-hygiene/instructions.txt` in this skill's directory.

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.

`CLEAN`: done.

`findings`: dispatch again using the pattern above WITHOUT the `model` field (sonnet-class default), passing the findings record path as `<path-to-instructions.txt>`. The record's `Fix:` lines are the imperative instructions.

NEVER READ OR INTERPRET `<instructions>` YOURSELF. Let the sub-agent handle.
