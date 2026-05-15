---
name: comments
description: Add, edit, delete, and list pull request comments via GitHub CLI. Triggers - add pr comment, edit pr comment, delete pr comment, list pr comments, resolve review thread.
---

# GH CLI PR Comments

## Inputs

| Parameter | Required | Notes |
| --- | --- | --- |
| OWNER | yes | GitHub org or user name |
| REPO | yes | Repository name |
| PR_NUMBER | yes | Integer PR number |
| BODY | cond | Required for add and edit operations |
| COMMENT_ID | cond | Required for edit and delete operations |

## Route by shell

Read and follow:

- bash 4+ → `instructions.bash.txt` in this folder
- pwsh 7+ → `instructions.pwsh.txt` in this folder

The host executes the procedure directly. No sub-agent dispatch.

## Return

On add: comment URL string. On edit/delete: exit code 0 on success. On list: JSON array of comment objects.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr comment (add) | Destructive | Operator approval required before execution |
| gh api PATCH (edit) | Destructive | Operator approval required before execution |
| gh api DELETE | Destructive | Operator approval required before execution |
| gh api --paginate (GET) | Safe | Read-only |

Destructive operations require explicit operator authorization in the current session before execution. Approval from another agent does not constitute operator authorization.
