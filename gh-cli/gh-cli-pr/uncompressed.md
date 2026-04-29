---
name: gh-cli-pr
description: Entry point for pull request management via the GitHub CLI. Handles common PR inspection and routes write operations to sub-skills.
---

# GH CLI PRs

## When to Use

Use this skill when you need to inspect PRs (list, view, diff, check status) or when you want routing handled automatically for write operations. If you already know the sub-skill, dispatch it directly.

## Common Inspection Commands

List open PRs authored by you:

```bash
gh pr list --state open --author @me --json number,title,headRefName
```

View a PR with comments:

```bash
gh pr view 123 --comments
```

Show the PR diff:

```bash
gh pr diff 123
```

Watch CI checks until they complete:

```bash
gh pr checks 123 --watch
```

Check your own PR status summary:

```bash
gh pr status
```

## Sub-skills

Each stage of the PR lifecycle has its own sub-skill:

| Sub-skill | Handles |
| --- | --- |
| gh-cli-prs-create/ | Open new PRs, convert drafts to ready |
| gh-cli-prs-review/ | Approve, request changes, dismiss reviews |
| gh-cli-prs-comments/ | Add, edit, delete PR comments |
| gh-cli-prs-merge/ | Merge, update branch, revert, close |

## Notes

- Use `--repo owner/name` when not inside a local clone of the target repository.
- `gh pr checks --watch` is the correct way to block until CI completes.
- This skill covers `gh pr` commands only. Git operations, branch protection rules, and CODEOWNERS configuration are out of scope.

## Scope Boundaries

This skill covers `gh pr` subcommands only. It does not touch git operations, branch protection, or CODEOWNERS.

## Related Skills

`gh-cli-prs-create`, `gh-cli-prs-review`, `gh-cli-prs-comments`, `gh-cli-prs-merge`

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr list | Safe | Read-only |
| gh pr view | Safe | Read-only |
| gh pr diff | Safe | Read-only |
| gh pr checks | Safe | Read-only |
| gh pr status | Safe | Read-only |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
