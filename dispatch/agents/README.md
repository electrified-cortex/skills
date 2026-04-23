# Dispatch Agent Files

Canonical Dispatch agent definitions, one per runtime environment.
Copy the appropriate file into your project's agent directory and invoke it
via your runtime's subagent dispatch mechanism with a prompt pointing to the
target instruction file.

| File | Environment | Role |
| --- | --- | --- |
| [claude-dispatch.agent.md](claude-dispatch.agent.md) | Claude Code CLI | Minimal executor — reads a file and follows it |
| [vscode-dispatch.agent.md](vscode-dispatch.agent.md) | VS Code (GitHub Copilot) | Minimal executor — reads a file and follows it |
| [vscode-orchestrator.agent.md](vscode-orchestrator.agent.md) | VS Code (GitHub Copilot) | Dispatch-first orchestrator — delegates to Dispatch |

Companion: `vscode-orchestration.txt` — ultra-compressed how-to for the orchestrator.

## Executor (Dispatch)

Intentionally minimal — carries no context of its own. All behavior comes from
the file it reads. General-purpose runner for any skill that defines its own procedure.

Install path: `.github/agents/dispatch.agent.md`

## Orchestrator

Dispatch-first agent. Delegates everything possible to the `Dispatch` sub-agent.
Companion `vscode-orchestration.txt` (same folder) — ultra-compressed how-to.

Install path: `.github/agents/orchestrator.agent.md`

If Orchestrator is installed, Dispatch must be installed too.

## Source

These files are maintained in `dispatch/agents/` and are the canonical source.
Copies installed in host agent directories should be periodically verified against this source.
