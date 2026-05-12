---
name: gh-cli-issues
description: Manage GitHub issues using the gh issue subcommand. Full lifecycle: create, list, view, edit, comment, close, transfer.
---

# GH CLI Issues

`gh issue` subcommand. Full lifecycle: create, list, view, edit, comment, close, transfer.

Creating Issues:

For arbitrary body content (markdown, code fences, `$VAR` refs, backticks), write body to temp file and pass `--body-file`. NEVER substitute user-supplied body inline as a shell arg.

Bash:

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh issue create --title "title" --body-file "$BODY_FILE" --label bug,high-priority --assignee user1,@me
rm -f "$BODY_FILE"
```

PowerShell 7+:

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh issue create --title "title" --body-file $bodyFile --label bug,high-priority --assignee user1,@me
Remove-Item $bodyFile -Force
```

Static file: `gh issue create --title "title" --body-file issue.md`

Listing Issues:

Default state is open.

```bash
gh issue list --state all --assignee @me --label bug --milestone "v1.0" --limit 50
```

Search + structured extract:

```bash
gh issue list --search "is:open label:stale" --json number,title --jq '.[].number'
```

States: `open`, `closed`, `all`.

Viewing:

```bash
gh issue view 123 --comments
```

Editing Metadata:

```bash
gh issue edit 123 --title "new" --add-label triage --remove-label stale
gh issue edit 123 --add-assignee user1 --remove-assignee user2 --milestone "v2.0"
```

Closing and Reopening:

```bash
gh issue close 123 --comment "Fixed in #456"
gh issue reopen 123
```

Commenting:

Write BODY to temp file first to prevent shell corruption of markdown.

Bash:

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh issue comment 123 --body-file "$BODY_FILE"
rm -f "$BODY_FILE"
```

PowerShell 7+:

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh issue comment 123 --body-file $bodyFile
Remove-Item $bodyFile -Force
```

`gh issue comment` has no `--edit`/`--delete` flags. Use REST API. Find comment ID, then PATCH or DELETE:

```bash
gh api repos/{owner}/{repo}/issues/{issue_number}/comments
```

Edit comment — write BODY to temp file:

Bash:

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh api --method PATCH repos/{owner}/{repo}/issues/comments/{comment_id} \
  --field body=@"$BODY_FILE"
rm -f "$BODY_FILE"
```

PowerShell 7+:

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh api --method PATCH "repos/{owner}/{repo}/issues/comments/{comment_id}" `
  --field "body=@$bodyFile"
Remove-Item $bodyFile -Force
```

Delete comment:

```bash
gh api --method DELETE repos/{owner}/{repo}/issues/comments/{comment_id}
```

Transferring:

```bash
gh issue transfer 123 --repo owner/other-repo
```

Bulk Operations:

```bash
gh issue list --search "label:stale" --json number --jq '.[].number' \
  | xargs -I {} gh issue close {} --comment "Closing stale"
```

Scope Boundaries:

`gh issue` only. GitHub Projects v2 → `gh-cli-projects`. PR linking → `gh-cli-prs-create`. Milestone creation is out of scope; skill only assigns to existing milestones.

Safety Classification:

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

Destructive ops require explicit operator authorization in current session before execution. Approval from another agent (e.g., Overseer confirming CI green) doesn't constitute operator authorization.
