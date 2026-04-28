---
name: dispatch-setup
description: How to correctly configure the dispatch skill agent file in VS Code and Cursor.
---

# Dispatch Setup — VS Code / Cursor

This is a reference card for configuring dispatch in VS Code (GitHub Copilot) and Cursor. It covers the mandatory steps before `runSubagent` works correctly. Claude Code CLI has no known setup problems; it is out of scope here.

## Agent File Placement

VS Code discovers agent files from `.github/agents/` in the project root. The dispatch agent file must be at:

```
.github/agents/dispatch.agent.md
```

The `.claude/agents/` path is for Claude Code CLI only. VS Code does not read it. Placing the file there causes "agent not found" at dispatch time with no helpful error.

Sub-agents called from within a dispatched agent must also be in `.github/agents/`. Agents at `.claude/agents/` are invisible to VS Code.

**Source to copy:** `dispatch/agents/vscode-dispatch.agent.md`. Do not use `claude-dispatch.agent.md` for VS Code.

## Required Frontmatter

Every agent file must have a YAML frontmatter block. Four fields are mandatory:

```yaml
---
name: Dispatch
description: Minimal agent that reads a target file and follows its instructions. No extra context.
model: Claude Sonnet 4.6
tools: [read, edit, search, execute, web/fetch, websearch]
---
```

**name** — must match the string passed as `agentName` in `runSubagent`. Canonical value: `Dispatch`.

**description** — non-empty string. Shown in IDE UI.

**model** — human-readable name with spaces. See below.

**tools** — list every tool the sub-agent needs. A missing or empty tools field causes silent failure: the agent runs but cannot use the tools it needs to complete the task.

## Model Name Format

VS Code requires the human-readable model name, not the API slug.

| Valid | Invalid (slug — do not use) |
| --- | --- |
| `Claude Sonnet 4.6` | `claude-sonnet-4-6` |
| `Claude Haiku 4.5 ` | `claude-haiku-4-5` |
| `Claude Opus 4.6 ` | `claude-opus-4-6` |

Using a slug causes silent fallback to an unintended model or an error. The failure mode is not always surfaced in the UI.

The same human-readable format applies to the optional `model` argument at the `runSubagent` call site. Omitting it defaults to the Copilot default (typically Sonnet).

## Host vs Sub-Agent Distinction

The host agent is the model running the current conversation. The sub-agent is dispatched via `runSubagent`. Selecting a model in the host's system prompt or IDE chat settings does not determine the dispatched agent's model — that comes from the agent file's `model` field (and optionally the `model` argument at call time).

Configuring the host's model and configuring the dispatched agent's model are independent operations.

## Context Inheritance

In VS Code, project context (CLAUDE.md, memory index) is unverified as inherited by the sub-agent. Treat context as NOT inherited. Hand-feed everything the sub-agent needs in the `runSubagent` prompt:

- Goal (one sentence)
- All relevant file paths (absolute)
- Decisions, preferences, prior findings
- Output shape and constraints

Do not expect the sub-agent to know anything from the current conversation. This is consistent with the parent dispatch skill's PG4 guidance.

## Dispatch Primitive

VS Code uses `runSubagent`, not the `Agent` tool.

```tool
runSubagent(agentName: "Dispatch", prompt: "...", description: "...")
```

`runSubagent` is always synchronous. The host blocks until the sub-agent returns. There is no background dispatch in VS Code. "Background dispatch" from the parent dispatch decision tree is not available; all VS Code dispatch is foreground.

## Cursor

Cursor is assumed to follow the same requirements: `.github/agents/` placement, human-readable model names, mandatory frontmatter fields. No confirmed differences from VS Code are currently known. All Cursor guidance should be treated as "assumed similar" unless verified by a direct test.

## Common Pitfalls

| Symptom | Likely cause |
| --- | --- |
| "Agent not found" at dispatch | File in `.claude/agents/` instead of `.github/agents/` |
| Wrong model used silently | Slug in `model` field instead of human-readable name |
| Sub-agent cannot use required tools | `tools` field missing or incomplete |
| Sub-agent missing task context | Prompt relies on context that doesn't inherit; hand-feed explicitly |
| Dispatch hangs or appears parallel | No — `runSubagent` serializes; re-evaluate for blocking cost |
