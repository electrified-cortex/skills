---
name: gh-cli-prs-comments
description: Add, edit, and delete pull request comments via the GitHub CLI.
---

Add:
```
gh pr comment 123 --body "text"
```

Edit (requires comment ID):
```
gh pr comment 123 --edit 456789 --body "updated text"
```

Delete:
```
gh pr comment 123 --delete 456789
```

View existing comments: `gh pr view 123 --comments`

Resolving review threads: no `gh pr` command exists. Use `resolveReviewThread` GraphQL mutation → `gh-cli-api/SKILL.md`.

Review-level comments (approve/request-changes) → `gh-cli-prs-review/SKILL.md`.
