---
name: markdown-hygiene
description: Detect markdownlint violations in a .md file. Detect-only — no fix. Triggers — lint markdown, scan markdown, MD violations, markdownlint pass, detect markdown issues.
---

# Markdown Hygiene

`<instructions>`= `instructions.txt` (in this skill folder; NEVER READ THIS FILE)
`<instructions-abspath>`= the absolute path to `<instructions>`
`<input-suffix>`= `Input: <markdown_file_path> [--ignore <RULE>[,<RULE>...]]`
`<prompt>`= `Read and follow <instructions-abspath>; <input-suffix>`
`<description>`= `Inspecting Markdown Hygiene: <markdown_file_path>`
`<report>`= The result file produced by the instructions.

If you have any markdown linter available in your runtime, run its auto-fix pass on `<markdown_file_path>` now (the cheap mechanical fixes — trailing spaces, blanks around headings, list-marker consistency). Don't install one if it's not present; continue without. The dispatch verifies regardless.

Without reading `instructions.txt` yourself, spawn a zero-context Dispatch sub-agent (haiku-class):

Claude Code:

```tool
Agent({
  subagent_type: "Dispatch",
  prompt: "<prompt>",
  model: "haiku",
  run_in_background: true,
  description: "<description>"
})
```

VS Code / Copilot:

```tool
runSubagent({
  agentName: "Dispatch",
  prompt: "<prompt>",
  model: "Claude Haiku 4.5",
  description: "<description>"
})
```

If you are unable to use the "Dispatch" agent, omit the subagent name/type,
but notify the host that the "Dispatch" agent needs to be installed.

NEVER READ/INTERPRET `<instructions-abspath>` YOURSELF. Let the sub-agent handle.

Returns: `CLEAN` | `findings: <report>` | `ERROR: <reason>`.

`CLEAN`: done. Stop here.

If `ERROR` or the 3rd iteration stop and report findings; otherwise:
`<prompt>`= `For this <markdown_file_path>, read <report> and fix any issues.`
`<description>`= `Fixing Markdown Hygiene: <markdown_file_path>`
Use the same pattern for dispatch above but omit the model.

Keep iteration count; repeat from the top.
