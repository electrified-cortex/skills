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
# List comments to find the comment ID
gh api /repos/{owner}/{repo}/issues/{issue_number}/comments

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

To view existing comments before editing or deleting:

```bash
gh pr view 123 --comments
```

## Resolving Review Threads

There is no `gh pr` command for resolving review threads. Use the `resolveReviewThread` GraphQL mutation via `gh-cli-api`:

```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

## Scope Boundaries

This skill covers `gh pr comment` only. Review-level comments (those submitted with an approve or request-changes verdict) belong to `gh-cli-prs-review`. Viewing comments is supported here but is also available in `gh-cli-prs` inspection commands.
