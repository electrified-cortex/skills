---
name: dispatch
description: How to dispatch a sub-agent. Triggers — dispatch, sub-agent, isolated scope, background, background execution, background task, background agent.
---

# Dispatch

## Input

`<prompt>` — verbatim prompt sent to the sub-agent
`<description>` — short run label shown by the host
`<tier>` — `fast-cheap` | `standard` (default) | `deep`
`<model-override>` (optional) — concrete model string or alias (e.g. `Claude Sonnet 4.6`, `GPT 5.4`, `gpt-5-codex`); bypasses tier lookup when set

## Derived

`<concrete-model>` = `<model-override>` if set, else derived from `<tier>` via the table below.

## Process

If `<prompt>` instructs the sub-agent to read a file, do not read that file yourself — the sub-agent does. Spawn a zero-context Dispatch sub-agent:

### Claude Code

#### Claude Model Aliases

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

### VS Code / Copilot

#### Copilot Model Aliases

| Tier | Class | `model` value |
| ---- | ----- | ------------- |
| `fast-cheap` | haiku-class | `Claude Haiku 4.5` |
| `standard` | sonnet-class | `Claude Sonnet 4.6` |
| `deep` | opus-class | `Claude Opus 4.6` |

GPT alts (gpt-class): `GPT-5.3-Codex` (code), `GPT-5.4` (prose), `GPT-5.4 mini` (fast-cheap prose).
Update minimum models as needed.

```tool
runSubagent({
  agentName: "Dispatch",
  prompt: "<prompt>",
  model: "<concrete-model>",
  description: "<description>"
})
```

## Fallback

If you are unable to use the "Dispatch" agent, omit the subagent name/type and continue anyway,
but notify the host after completion that the "Dispatch" agent needs to be installed for optimal performance and isolation.

If the model requested is not available, stop and inform the caller; suggest an alternative model.

## Return

Return (passthrough) whatever the sub-agent output was to the caller of this skill.
