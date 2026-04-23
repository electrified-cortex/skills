---
name: gh-cli
description: GitHub CLI operations — routes to domain-specific sub-skills via dispatch.
---

# GH CLI Router

This skill routes GitHub CLI tasks to the correct domain sub-skill. It does not run `gh` commands itself.

## When to Use

Use this skill when you have a GitHub CLI task and you are not sure which sub-skill owns it, or when you want routing handled automatically. If you already know the domain, dispatch the sub-skill directly.

## How It Works

1. Parse the task to identify the domain.
2. If the domain is unclear, ask the caller for clarification before proceeding.
3. Load and invoke the domain sub-skill and follow its instructions.
4. The sub-skill executes the commands and reports the results.
5. If the task spans multiple domains, handle the primary domain and report remaining work to the caller.

## Domain Routing

| Domain | Sub-skill | Use for |
| --- | --- | --- |
| actions | gh-cli-actions/ | Workflows, runs, secrets, variables, caches |
| api | gh-cli-api/ | Raw REST and GraphQL API calls |
| issues | gh-cli-issues/ | Issue lifecycle: create, list, edit, close, comment |
| projects | gh-cli-projects/ | GitHub Projects v2: boards, items, fields |
| prs | gh-cli-prs/ | Pull request lifecycle router |
| releases | gh-cli-releases/ | Release lifecycle: create, publish, upload assets |
| repos | gh-cli-repos/ | Repository management: create, clone, fork, sync |
| setup | gh-cli-setup/ | Install, authenticate, and configure gh |

## PR Sub-skills

The prs domain has its own sub-skills under gh-cli-prs/:

- gh-cli-prs-comments/ — adding, editing, deleting PR comments
- gh-cli-prs-create/ — opening new pull requests
- gh-cli-prs-merge/ — merge strategies, branch updates, revert
- gh-cli-prs-review/ — approve, request changes, dismiss reviews

## Rules

- Always verify `gh auth status` before executing commands if the setup skill was not already loaded.
- Never improvise commands — use only what the domain skill documents.
- One domain per invocation. If the task spans multiple domains, complete the primary one first and note remaining work.

## Related

`dispatch`, `gh-cli-actions`, `gh-cli-api`, `gh-cli-issues`, `gh-cli-projects`, `gh-cli-prs`, `gh-cli-releases`, `gh-cli-repos`, `gh-cli-setup`
