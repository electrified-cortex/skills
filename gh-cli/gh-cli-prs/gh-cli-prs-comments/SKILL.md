---
name: gh-cli-prs-comments
description: Add, edit, delete pull request comments via GitHub CLI.
---

Add, edit, delete PR comments via `gh pr comment`.

Adding:
Add comment to PR:
```bash
gh pr comment 123 --body "text"
```

Editing:
`gh pr comment` has no `--edit` flag. Use REST API — find comment ID, PATCH:
```bash
# List comments to find the comment ID
gh api /repos/{owner}/{repo}/issues/{issue_number}/comments

# Edit the comment
gh api --method PATCH /repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body="updated text"
```

Deleting:
`gh pr comment` has no `--delete` flag. Use REST API:
```bash
gh api --method DELETE /repos/{owner}/{repo}/issues/comments/{comment_id}
```

Viewing:
```bash
gh pr view 123 --comments
```

Resolving Review Threads:
No `gh pr` command for resolving threads. Use `resolveReviewThread` GraphQL mutation via `gh-cli-api`:
```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

Scope:
Covers `gh pr comment` only. Review-level comments (approve/request-changes verdict) → `gh-cli-prs-review`. Viewing also in `gh-cli-prs` inspection.
