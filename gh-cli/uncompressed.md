---
name: gh-cli
description: Route any GitHub CLI task to the correct domain sub-skill. Triggers — github cli, gh commands, pull request, repository management, issue lifecycle, release management.
---

# GH CLI Router

## Input

Natural language task describing a GitHub CLI operation. Optionally includes: domain hint, target repo, PR number, or other context.

## Dispatch

Without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent in the background:

Claude Code: `Agent` tool. Pass: `"Read and follow instructions.txt in <skill_dir>. Input: <task>"`

VS Code / Copilot: `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: <task>")`

Don't read `instructions.txt` yourself.

Returns: Result from the dispatched domain sub-skill.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent do the work.
