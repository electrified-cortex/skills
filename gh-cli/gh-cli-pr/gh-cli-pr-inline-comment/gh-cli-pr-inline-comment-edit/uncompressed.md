---
name: gh-cli-pr-inline-comment-edit
description: Edit the body of an existing inline PR review comment by comment ID via GitHub CLI.
---

# GH CLI PR Inline Comment — Edit

Update the body of an existing inline review comment.

## Inputs

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| OWNER | yes | GitHub org or user name |
| REPO | yes | Repository name |
| COMMENT_ID | yes | Integer inline review comment ID |
| BODY | yes | New comment text |

## Command

```bash
gh api --method PATCH repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID} \
  --field body="{BODY}"
```

## Notes

- Use `/pulls/comments/{id}` — not `/issues/comments/{id}` (different endpoint).
- Comment IDs come from the list endpoint: `gh api --paginate repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments`.
- Only `body` can be updated via this endpoint.
