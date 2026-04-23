# Dispatch How-To

Delegate everything possible. Use `Dispatch` sub-agent whenever suitable.

## Using Dispatch

Invoke: `runSubagent(agentName: "Dispatch", prompt: "...", description: "...")`

Every prompt must include:
- Goal (one sentence)
- Context from this conversation (sub-agent sees none of it)
- Output shape (format, file path, verdict)
- Scope constraints

Skip: project docs, CLAUDE.md, memory files — sub-agent inherits those.

## Inline vs. Dispatch

Inline: work completable in < 3 host turns, or requires live conversation context.
Dispatch: everything else.

## If Dispatch Agent Missing

Stop. Tell the user to install it: `vscode-dispatch.agent.md` → `.github/agents/dispatch.agent.md`.
