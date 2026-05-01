---
name: gh-cli-pr-inline-comment-delete
description: Delete an existing inline PR review comment by comment ID via GitHub CLI.
---

Input: OWNER, REPO, COMMENT_ID

```bash
gh api --method DELETE repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}
```

Note: endpoint is `/pulls/comments/{id}`, not `/issues/comments/{id}`.
