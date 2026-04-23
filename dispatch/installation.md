# Dispatch — Installation

The dispatch skill requires a companion agent file installed in your project's agent directory.

## Agent Files

Source: `dispatch/agents/`

| File | Environment | Install path |
| --- | --- | --- |
| `claude-dispatch.agent.md` | Claude Code CLI | `.claude/agents/dispatch.agent.md` |
| `vscode-dispatch.agent.md` | VS Code (GitHub Copilot) | `.github/agents/dispatch.agent.md` |

Copy the appropriate file. The agent name is `Dispatch` in both environments.

## If Not Installed

Dispatch cannot function effectively without the agent file.
If it is absent, stop and tell the host to install it before proceeding.
