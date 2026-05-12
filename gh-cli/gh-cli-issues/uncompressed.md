---
name: gh-cli-issues
description: Manage GitHub issues using the gh issue subcommand. Full lifecycle: create, list, view, edit, comment, close, transfer.
---

# GH CLI Issues

Manage GitHub issues using the `gh issue` subcommand. Covers the full issue lifecycle: creating, listing, viewing, editing, commenting, closing, and bulk operations.

## Creating Issues

For arbitrary body content (markdown, code fences, `$VAR` references, backticks), write the body to a temp file and pass `--body-file`. Never substitute user-supplied body content inline as a shell argument.

**Bash:**

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh issue create --title "title" --body-file "$BODY_FILE" --label bug,high-priority --assignee user1,@me
rm -f "$BODY_FILE"
```

**PowerShell 7+:**

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh issue create --title "title" --body-file $bodyFile --label bug,high-priority --assignee user1,@me
Remove-Item $bodyFile -Force
```

Create an issue with a body from a static file:

```bash
gh issue create --title "title" --body-file issue.md
```

## Listing Issues

List issues with filters. Default state is open:

```bash
gh issue list --state all --assignee @me --label bug --milestone "v1.0" --limit 50
```

Use a search query and extract structured data with jq:

```bash
gh issue list --search "is:open label:stale" --json number,title --jq '.[].number'
```

States: `open`, `closed`, `all`.

## Viewing Issues

View an issue with its comments:

```bash
gh issue view 123 --comments
```

## Editing Issue Metadata

Edit title and labels without losing existing values:

```bash
gh issue edit 123 --title "new" --add-label triage --remove-label stale
```

Edit assignees and milestone:

```bash
gh issue edit 123 --add-assignee user1 --remove-assignee user2 --milestone "v2.0"
```

## Closing and Reopening

Close with an optional closing comment:

```bash
gh issue close 123 --comment "Fixed in #456"
```

Reopen a closed issue:

```bash
gh issue reopen 123
```

## Commenting

Add a comment — write BODY to a temp file first to prevent shell corruption of markdown content:

**Bash:**

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh issue comment 123 --body-file "$BODY_FILE"
rm -f "$BODY_FILE"
```

**PowerShell 7+:**

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh issue comment 123 --body-file $bodyFile
Remove-Item $bodyFile -Force
```

`gh issue comment` has no `--edit` or `--delete` flags. Use the REST API directly. First find the comment ID, then PATCH or DELETE it:

```bash
# List comments to find the comment ID
gh api repos/{owner}/{repo}/issues/{issue_number}/comments
```

Edit the comment — write BODY to a temp file:

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

```bash
# Delete the comment
gh api --method DELETE repos/{owner}/{repo}/issues/comments/{comment_id}
```

## Transferring Issues

Transfer an issue to another repository:

```bash
gh issue transfer 123 --repo owner/other-repo
```

## Bulk Operations

Close all issues matching a filter by pipelining JSON output through xargs:

```bash
gh issue list --search "label:stale" --json number --jq '.[].number' \
  | xargs -I {} gh issue close {} --comment "Closing stale"
```

## Scope Boundaries

This skill covers `gh issue` only. GitHub Projects v2 placement belongs to `gh-cli-projects`. PR linking belongs to `gh-cli-prs-create`. Milestone creation belongs outside this skill — this skill only assigns issues to existing milestones.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh issue list | Safe | Read-only |
| gh issue view | Safe | Read-only |
| gh issue create | Destructive | Operator approval required before execution |
| gh issue close | Destructive | Operator approval required before execution |
| gh issue reopen | Destructive | Operator approval required before execution |
| gh issue edit | Destructive | Operator approval required before execution |
| gh issue delete | Destructive | Operator approval required before execution |
| gh issue comment | Destructive | Operator approval required before execution |
| gh issue transfer | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
