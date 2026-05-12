---
name: gh-cli-pr-create
description: Open pull request via GitHub CLI. Triggers - create pull request, open PR, submit PR, new pull request, open a pull request.
---

Before Creating:
Check for existing open PR on current branch:

```bash
gh pr list --head $(git branch --show-current)
```

If PR exists, edit or view — don't create duplicate.

Creating:
For arbitrary body content (markdown, code fences, `$VAR` refs, backticks) write body to temp file and pass `--body-file`. NEVER substitute user-supplied body inline as shell arg.

Bash:

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
gh pr create --title "title" --body-file "$BODY_FILE" --base main
rm -f "$BODY_FILE"
```

PowerShell 7+:

```powershell
$bodyFile = [System.IO.Path]::GetTempFileName()
[System.IO.File]::WriteAllText($bodyFile, $BODY, [System.Text.Encoding]::UTF8)
gh pr create --title "title" --body-file $bodyFile --base main
Remove-Item $bodyFile -Force
```

PR with full metadata — reviewers, assignee, labels, draft:

```bash
gh pr create --title "title" --body-file .github/PULL_REQUEST_TEMPLATE.md \
  --reviewer user1,user2 --assignee @me --label enhancement --draft
```

Closing Issue:
Include closing keyword in PR body to auto-close linked issue on merge:

```bash
# In the --body-file content:
Closes #123
```

Promote Draft:
PR ready for review — promote:

```bash
gh pr ready 123
```

Edit Metadata:
Add/remove reviewers, labels after PR is open:

```bash
gh pr edit 123 --add-reviewer user3 --add-label bug --remove-label wip
```

Scope:
Covers `gh pr create`, `gh pr ready`, `gh pr edit`. Branch must exist on remote first — branch creation and `git push` not covered. Reviewing and merging → respective sub-skills.

Safety:

| Command | Class | Notes |
| --- | --- | --- |
| gh pr create | Destructive | Operator approval required before execution |
| gh pr ready | Destructive | Operator approval required before execution |

DESTRUCTIVE OPERATIONS REQUIRE EXPLICIT OPERATOR AUTHORIZATION in current session before execution. Approval from another agent doesn't constitute operator authorization.
