---
name: gh-cli-prs-review
description: Approve, request changes on, or dismiss a pull request review via the GitHub CLI.
---

Approve:
```
gh pr review 123 --approve --body "LGTM"
```

Request changes (body required):
```
gh pr review 123 --request-changes --body "Please address X before merging"
```

Comment-only review (no verdict):
```
gh pr review 123 --comment --body "Thoughts inline"
```

Dismiss a review:
```
gh pr review 123 --dismiss
```

Resolving review threads → `gh-cli-api/SKILL.md` (`resolveReviewThread` mutation).
Adding reviewers at creation → `gh-cli-prs-create/SKILL.md`.
Adding reviewers post-creation → `gh pr edit 123 --add-reviewer user`.
