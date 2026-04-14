---
name: gh-cli-prs
description: Pull request lifecycle via the GitHub CLI. Start here, follow sub-skills.
---

Sub-skills — read the one you need:

- **Open a PR** → `gh-cli-prs/gh-cli-prs-create/SKILL.md`
- **Review a PR** → `gh-cli-prs/gh-cli-prs-review/SKILL.md`
- **Comment on a PR** → `gh-cli-prs/gh-cli-prs-comments/SKILL.md`
- **Merge / update / revert a PR** → `gh-cli-prs/gh-cli-prs-merge/SKILL.md`

Common inspection commands (all stages):
```
gh pr list --state open --author @me --json number,title,headRefName
gh pr view 123 --comments
gh pr diff 123
gh pr checks 123 --watch
gh pr status
```

Scope: `gh pr` only. Git operations, branch protection, CODEOWNERS out of scope.
