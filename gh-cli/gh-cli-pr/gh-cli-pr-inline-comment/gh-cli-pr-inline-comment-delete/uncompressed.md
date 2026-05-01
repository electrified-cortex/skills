---
name: gh-cli-pr-inline-comment-delete
description: Delete an existing inline PR review comment by comment ID via GitHub CLI.
---

# GH CLI PR Inline Comment — Delete

Delete an existing inline review comment permanently.

## Inputs

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| OWNER | yes | GitHub org or user name |
| REPO | yes | Repository name |
| COMMENT_ID | yes | Integer inline review comment ID |

## Command

```bash
gh api --method DELETE repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}
```

## Notes

- Use `/pulls/comments/{id}` — not `/issues/comments/{id}` (different endpoint).
- Deletion is permanent — no undo.
- To find a comment ID: `gh api --paginate repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments --jq '.[] | {id, path, line, body}'`
