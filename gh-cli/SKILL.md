---
name: gh-cli
description: GitHub CLI operations — routes to domain-specific sub-skills via agent dispatch.
---

# GH CLI

Dispatch `./AGENT.md` as a subagent with your GitHub CLI task.

The agent identifies the domain (actions, API, issues, PRs, releases, repos, setup, projects),
loads the correct sub-skill, and executes the commands.

## Domains

| Domain | Sub-skill | Use for |
| --- | --- | --- |
| actions | `gh-cli-actions/` | Workflows, runs, secrets, variables |
| api | `gh-cli-api/` | Raw REST/GraphQL calls |
| issues | `gh-cli-issues/` | Create, list, close, label, comment |
| projects | `gh-cli-projects/` | GitHub Projects v2 |
| prs | `gh-cli-prs/` | Pull requests (create, review, merge) |
| releases | `gh-cli-releases/` | Create, edit, delete, list |
| repos | `gh-cli-repos/` | Clone, fork, create, configure |
| setup | `gh-cli-setup/` | Auth, config, defaults |
