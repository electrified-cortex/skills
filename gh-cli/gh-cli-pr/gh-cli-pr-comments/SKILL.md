---
name: gh-cli-pr-comments
description: Add, edit, delete pull request comments via GitHub CLI.
---

gh-cli-pr-comments: Add, edit, delete general PR comments via `gh pr comment`.

Adding a Comment:
Write BODY to temp file first — inline shell substitution corrupts bodies with backticks, `$VAR` refs, double quotes, or code fences.

Bash:
```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh pr comment 123 --body-file "$BODY_FILE"
rm -f "$BODY_FILE"
```

PowerShell 7+:
```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh pr comment 123 --body-file $bodyFile
Remove-Item $bodyFile -Force
```

Editing a Comment:
`gh pr comment` has no `--edit` flag. Use REST API. Find comment ID first, then PATCH:

```bash
# List ALL comments (--paginate collects all pages)
gh api --paginate /repos/{owner}/{repo}/issues/{issue_number}/comments
```

Write BODY to temp file before PATCHing:

Bash:
```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh api --method PATCH /repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body=@"$BODY_FILE"
rm -f "$BODY_FILE"
```

PowerShell 7+:
```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh api --method PATCH "/repos/{owner}/{repo}/issues/comments/{comment_id}" `
  --field "body=@$bodyFile"
Remove-Item $bodyFile -Force
```

Deleting a Comment:
`gh pr comment` has no `--delete` flag. Use REST API:

```bash
gh api --method DELETE /repos/{owner}/{repo}/issues/comments/{comment_id}
```

Viewing Comments:
`gh pr view --comments` truncates + misses later pages. Use paginated API for complete lists:

```bash
# All inline/review comments (all pages)
gh api --paginate /repos/{owner}/{repo}/pulls/{pull_number}/comments

# All review-level submissions (all pages)
gh api --paginate /repos/{owner}/{repo}/pulls/{pull_number}/reviews

# General PR (issue) comments (all pages)
gh api --paginate /repos/{owner}/{repo}/issues/{pull_number}/comments
```

Use `gh pr view --comments` only for quick human-readable glance — NEVER for exhaustive comment checks.

Resolving Review Threads:
No `gh pr` command exists. Use `resolveReviewThread` GraphQL mutation via `gh-cli-api`:

```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

Scope Boundaries:
Covers `gh pr comment` only. Review-level comments (approve/request-changes verdicts) → `gh-cli-prs-review`. Viewing also available in `gh-cli-prs` inspection commands.

Safety Classification:

| Command | Class | Notes |
| --- | --- | --- |
| gh pr comment (add) | Destructive | Operator approval required before execution |
| gh pr comment --edit | Destructive | Operator approval required before execution |
| gh pr comment --delete | Destructive | Operator approval required before execution |
| gh pr view --comments | Safe | Read-only |
| gh api --paginate (GET) | Safe | Read-only |

Destructive ops require explicit operator authorization in current session before execution. Approval from another agent (e.g., Overseer confirming CI green) doesn't constitute operator authorization.
