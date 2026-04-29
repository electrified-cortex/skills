---
name: dispatch
description: How to dispatch a sub-agent. Triggers — dispatch, sub-agent, isolated scope, background, background execution, background task, background agent.
---

Input:

`<prompt>` — verbatim prompt sent to sub-agent
`<description>` — short run label shown by host
`<tier>` — `fast-cheap` | `standard` (default) | `deep`
`<model-override>` (optional) — concrete model or alias (e.g. `Claude Sonnet 4.6`, `GPT 5.4`, `gpt-5-codex`); bypasses tier lookup when set

Derived:

`<concrete-model>` = `<model-override>` if set, else derived from `<tier>` via table.

Process:

If `<prompt>` instructs sub-agent to read a file, don't read it yourself — sub-agent does. Spawn zero-context Dispatch sub-agent:

Claude Code:

Claude Model Aliases:

| Tier | Class | `model` value |
| ---- | ----- | ------------- |
| `fast-cheap` | haiku-class | `haiku` |
| `standard` | sonnet-class | `sonnet` |
| `deep` | opus-class | `opus` |

```tool
Agent({
  subagent_type: "Dispatch",
  prompt: "<prompt>",
  model: "<concrete-model>",
  run_in_background: true,
  description: "<description>"
})
```

VS Code / Copilot:

Copilot Model Aliases:

| Tier | Class | `model` value |
| ---- | ----- | ------------- |
| `fast-cheap` | haiku-class | `Claude Haiku 4.5` |
| `standard` | sonnet-class | `Claude Sonnet 4.6` |
| `deep` | opus-class | `Claude Opus 4.6` |

GPT alts (gpt-class): GPT 5.3 codex (code), GPT 5.4 (prose). Update on new Anthropic model release.

```tool
runSubagent({
  agentName: "Dispatch",
  prompt: "<prompt>",
  model: "<concrete-model>",
  description: "<description>"
})
```

Fallback:
Can't use "Dispatch" agent: omit subagent name/type, continue. Notify host: "Dispatch" agent needs install for optimal perf and isolation.

Return:
Return (passthrough) sub-agent output to caller.
