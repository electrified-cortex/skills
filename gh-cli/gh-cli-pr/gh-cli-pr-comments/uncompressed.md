---
name: gh-cli-pr-comments
description: Add, edit, delete pull request comments via GitHub CLI.
---

# GH CLI PR Comments

Add, edit, and delete general comments on pull requests using `gh pr comment`.

## Adding a Comment

Write BODY to a temp file first — inline shell substitution corrupts bodies containing backticks, `$VAR` references, double quotes, or code fences.

**Bash:**

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh pr comment 123 --body-file "$BODY_FILE"
rm -f "$BODY_FILE"
```

**PowerShell 7+:**

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh pr comment 123 --body-file $bodyFile
Remove-Item $bodyFile -Force
```

## Editing a Comment

`gh pr comment` has no `--edit` flag. Use the REST API directly. First find the comment ID, then PATCH it:

```bash
# List ALL comments to find the comment ID (--paginate collects all pages)
gh api --paginate repos/{owner}/{repo}/issues/{issue_number}/comments
```

Write BODY to a temp file before PATCHing:

**Bash:**

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh api --method PATCH repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body=@"$BODY_FILE"
rm -f "$BODY_FILE"
```

**PowerShell 7+:**

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh api --method PATCH "repos/{owner}/{repo}/issues/comments/{comment_id}" `
  --field "body=@$bodyFile"
Remove-Item $bodyFile -Force
```

## Deleting a Comment

`gh pr comment` has no `--delete` flag. Use the REST API directly:

```bash
gh api --method DELETE repos/{owner}/{repo}/issues/comments/{comment_id}
```

## Viewing Comments

`gh pr view --comments` truncates output and misses later pages. For a complete list of all review comments, use the paginated API:

```bash
# All inline/review comments (paginated — all pages)
gh api --paginate repos/{owner}/{repo}/pulls/{pull_number}/comments

# All review-level submissions (paginated)
gh api --paginate repos/{owner}/{repo}/pulls/{pull_number}/reviews
```

For general PR (issue) comments, also paginate:

```bash
gh api --paginate repos/{owner}/{repo}/issues/{pull_number}/comments
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

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr comment (add) | Destructive | Operator approval required before execution |
| gh pr comment --edit | Destructive | Operator approval required before execution |
| gh pr comment --delete | Destructive | Operator approval required before execution |
| gh pr view --comments | Safe | Read-only |
| gh api --paginate (GET) | Safe | Read-only |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
