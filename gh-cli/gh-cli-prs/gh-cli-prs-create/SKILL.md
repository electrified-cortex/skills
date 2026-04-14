---
name: gh-cli-prs-create
description: Open pull request via GitHub CLI.
---

Before creating — confirm no open PR for branch:
```
gh pr list --head $(git branch --show-current)
```

Create:
```
gh pr create --title "title" --body "body" --base main
gh pr create --title "title" --body-file .github/PULL_REQUEST_TEMPLATE.md \
  --reviewer user1,user2 --assignee @me --label enhancement --draft
```

Link to closing issue — include in body: `Closes #123`

Draft → ready when review-ready:
```
gh pr ready 123
```

Edit metadata post-creation:
```
gh pr edit 123 --add-reviewer user3 --add-label bug --remove-label wip
```
