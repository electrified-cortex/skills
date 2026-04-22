# Agents

Reusable agent definitions for use with skills. These are `.agent.md` files
that can be placed in your project's agent directory
(`.claude/agents/` or equivalent)
and invoked as subagents.

## Dispatch Agent

The canonical Dispatch agent files are maintained in
[`dispatch/agents/`](../dispatch/agents/). Two variants are
available — one for each runtime environment:

| Variant | File | Tools |
| --- | --- | --- |
| Claude Code CLI | [claude-dispatch.agent.md](../dispatch/agents/claude-dispatch.agent.md) | `Read, Edit, Bash, Grep, Glob, WebFetch, WebSearch` |
| Claude Code in VS Code | [vscode-dispatch.agent.md](../dispatch/agents/vscode-dispatch.agent.md) | `read, edit, search, execute, fetch, websearch` |

Copy the appropriate file into `.claude/agents/` in your project and rename it
`dispatch.agent.md`.

## Usage

The Dispatch agent is intentionally minimal — it carries no context of its
own. All behavior comes from the file it reads. This makes it a general-purpose
runner for any skill that defines its own procedure.

