---
name: gh-cli-prs
description: Entry point for pull request management via the GitHub CLI. Handles common PR inspection and routes write operations to sub-skills.
---

Entry point for PR management via GitHub CLI. Handles common PR inspection; routes write ops to sub-skills.

When to Use:
Inspect PRs (list, view, diff, check status) or auto-route write ops. Know sub-skill → dispatch directly.

Inspection Commands:
List open PRs by you:
```bash
gh pr list --state open --author @me --json number,title,headRefName
```

View PR with comments:
```bash
gh pr view 123 --comments
```

Show PR diff:
```bash
gh pr diff 123
```

Watch CI until complete:
```bash
gh pr checks 123 --watch
```

PR status summary:
```bash
gh pr status
```

Sub-skills:

| Sub-skill | Handles |
| --- | --- |
| gh-cli-prs-create/ | Open PRs, convert drafts to ready |
| gh-cli-prs-review/ | Approve, request changes, dismiss reviews |
| gh-cli-prs-comments/ | Add, edit, delete PR comments |
| gh-cli-prs-merge/ | Merge, update branch, revert, close |

Notes:
Use `--repo owner/name` when not in local clone of target repo.
`gh pr checks --watch` blocks until CI completes.
Covers `gh pr` commands only. Git ops, branch protection, CODEOWNERS out of scope.
