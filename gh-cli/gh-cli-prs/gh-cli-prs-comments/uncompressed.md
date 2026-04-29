---
name: gh-cli-prs-comments
description: Add, edit, delete pull request comments via GitHub CLI.
---

# GH CLI PR Comments

Add, edit, and delete general comments on pull requests using `gh pr comment`.

## Adding a Comment

Add a comment to a pull request:

```bash
gh pr comment 123 --body "text"
```

## Editing a Comment

`gh pr comment` has no `--edit` flag. Use the REST API directly. First find the comment ID, then PATCH it:

```bash
# List ALL comments to find the comment ID (--paginate collects all pages)
gh api --paginate /repos/{owner}/{repo}/issues/{issue_number}/comments

# Edit the comment
gh api --method PATCH /repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body="updated text"
```

## Deleting a Comment

`gh pr comment` has no `--delete` flag. Use the REST API directly:

```bash
gh api --method DELETE /repos/{owner}/{repo}/issues/comments/{comment_id}
```

## Viewing Comments

`gh pr view --comments` truncates output and misses later pages. For a complete list of all review comments, use the paginated API:

```bash
# All inline/review comments (paginated — all pages)
gh api --paginate /repos/{owner}/{repo}/pulls/{pull_number}/comments

# All review-level submissions (paginated)
gh api --paginate /repos/{owner}/{repo}/pulls/{pull_number}/reviews
```

For general PR (issue) comments, also paginate:

```bash
gh api --paginate /repos/{owner}/{repo}/issues/{pull_number}/comments
```

Use `gh pr view --comments` only for a quick human-readable glance — never for exhaustive comment checks.

## Resolving Review Threads

There is no `gh pr` command for resolving review threads. Use the `resolveReviewThread` GraphQL mutation via `gh-cli-api`:

```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

## Scope Boundaries

This skill covers `gh pr comment` only. Review-level comments (those submitted with an approve or request-changes verdict) belong to `gh-cli-prs-review`. Viewing comments is supported here but is also available in `gh-cli-prs` inspection commands.
