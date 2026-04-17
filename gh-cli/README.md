# gh-cli

Router for GitHub CLI tasks. Reads the request and dispatches to the correct
sub-skill by domain. Never attempts GitHub operations directly.

## When to Use

Use this skill when you have a GitHub CLI task and you're not sure which
sub-skill owns it — or when a task spans multiple domains (e.g., create a repo
and open an issue). This skill resolves the routing for you.

If you already know the domain, dispatch the sub-skill directly.

## Domains Covered

| Sub-skill | Handles |
| --- | --- |
| [`gh-cli-actions`](gh-cli-actions/) | Workflows, runs, secrets, variables |
| [`gh-cli-api`](gh-cli-api/) | Raw REST and GraphQL calls |
| [`gh-cli-issues`](gh-cli-issues/) | Issues: create, list, edit, close, comment |
| [`gh-cli-projects`](gh-cli-projects/) | Projects v2: boards, items, fields |
| [`gh-cli-prs`](gh-cli-prs/) | Pull requests: lifecycle router |
| [`gh-cli-releases`](gh-cli-releases/) | Releases: create, publish, upload assets |
| [`gh-cli-repos`](gh-cli-repos/) | Repos: create, clone, fork, sync |
| [`gh-cli-setup`](gh-cli-setup/) | Install, auth, configure `gh` |

## How Dispatch Works

This skill is invoked via `AGENT.md`. The agent reads the request, identifies
the domain, and dispatches a subagent to the appropriate sub-skill's `SKILL.md`.

Do not load this skill expecting it to run `gh` commands itself. It routes.

## Related Skills

- All `gh-cli-*` sub-skills listed above
- `gh-cli-api` — fallback when no dedicated sub-skill covers the operation

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../LICENSE) in the repository root.
