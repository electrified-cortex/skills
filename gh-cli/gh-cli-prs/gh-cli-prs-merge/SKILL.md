---
name: gh-cli-prs-merge
description: Merge, update, revert, close pull request via GitHub CLI.
---

Merge (choose strategy):
```
gh pr merge 123 --merge --delete-branch
gh pr merge 123 --squash --delete-branch
gh pr merge 123 --rebase
```

Update branch (PR behind base):
```
gh pr update-branch 123
gh pr update-branch 123 --force     # force if conflicts
```

Revert merged PR (opens new revert PR):
```
gh pr revert 123 --branch revert-pr-123
```

Close without merging:
```
gh pr close 123 --comment "Superseded by #456"
```

Check readiness: `gh pr checks 123` — out of scope, covered by `gh-cli-prs/SKILL.md` inspection commands.
