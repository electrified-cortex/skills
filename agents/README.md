# Agents

Reusable agent definitions for use with skills. These are `.agent.md` files
that can be placed in your project's `.claude/agents/` directory (or
equivalent) and invoked as subagents.

| Agent | Description |
| --- | --- |
| [dispatch](dispatch.agent.md) | Minimal pass-through agent — reads a target file, follows its instructions, returns the result |

## Usage

Copy the agent file into your project's agent directory and invoke it via
your runtime's subagent mechanism. For Claude Code, that's
`Agent(subagent_type: "Dispatch")` with a prompt pointing to the target file.

The Dispatch agent is intentionally minimal — it carries no context of its
own. All behavior comes from the file it reads. This makes it a general-purpose
runner for any skill that defines its own procedure.
