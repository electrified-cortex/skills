# Dispatch Agent Files

Canonical Dispatch agent definitions, one per runtime environment.
Copy the appropriate file into your project's agent directory and invoke it
via your runtime's subagent dispatch mechanism with a prompt pointing to the
target instruction file.

| File | Environment | Tools |
| --- | --- | --- |
| [claude-dispatch.agent.md](claude-dispatch.agent.md) | Claude Code CLI | `Read, Edit, Bash, Grep, Glob, WebFetch, WebSearch` |
| [vscode-dispatch.agent.md](vscode-dispatch.agent.md) | Claude Code in VS Code | `read, edit, search, execute, fetch, websearch` |

## Usage

The Dispatch agent is intentionally minimal — it carries no context of its
own. All behavior comes from the file it reads. This makes it a general-purpose
runner for any skill that defines its own procedure.

Install path (Claude Code): `.claude/agents/dispatch.agent.md`  
Install path (VS Code): `.github/agents/dispatch.agent.md` (same — agent loader is shared)

The only difference between the two files is the tool name casing convention,
which matches each environment's tool registry.

## Source

These files are maintained in `dispatch/agents/` and are the
canonical source. Copies installed in host agent directories should be
periodically verified against this source.
