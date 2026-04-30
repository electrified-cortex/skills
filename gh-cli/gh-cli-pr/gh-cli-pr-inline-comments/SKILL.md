---
name: gh-cli-pr-inline-comments
description: Post, edit, and delete inline code review comments on specific diff lines via GitHub CLI.
---

Post, edit, delete inline review comments on PR diff lines via `gh api`.
Inline comments are file+line-anchored (Files Changed view). Different from general PR comments.

Required: OWNER, REPO, PR_NUMBER, FILE_PATH, LINE_NUMBER, BODY.

Prerequisites — verify auth:

```bash
gh auth status
```

Step 1 — get commit SHA (required; stale SHA → 422):

```bash
gh pr view {PR_NUMBER} --json headRefOid --jq '.headRefOid'
```

Step 2 — verify file + line are in the diff:

```bash
gh pr diff {PR_NUMBER} --name-only          # check file is changed
gh pr diff {PR_NUMBER} -- {FILE_PATH}       # view diff to find valid lines
```

`+` = RIGHT (additions); `-` = LEFT (deletions); space-prefix = context (use RIGHT).

Step 3 — deduplication check (check before posting):

```bash
gh api --paginate /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.path == "{FILE_PATH}" and .line == {LINE_NUMBER}) | {id, body, author: .user.login}'
```

If a comment already exists at that line, review it before posting.

Step 4 — post inline comment:

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}"
```

`side`: `RIGHT` (new/added/context) or `LEFT` (deleted lines only).
Use `line` (absolute line number). Never use deprecated `position`.

Multi-line range — add `start_line` + `start_side`:

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field start_line={START_LINE} \
  --field start_side="RIGHT" \
  --field line={END_LINE} \
  --field side="RIGHT"
```

Edit:

```bash
gh api --method PATCH /repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID} \
  --field body="{UPDATED_BODY}"
```

Delete:

```bash
gh api --method DELETE /repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}
```

List all inline comments:

```bash
gh api --paginate /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments
```

Comments vs. Threads:
Each post creates a review thread. Comment `id` (integer) ≠ thread `node_id` (string).
Edit/delete via `/pulls/comments/{id}`. Resolve threads via GraphQL `resolveReviewThread` — see `gh-cli-api`.

Errors:

| Error | Cause | Fix |
| --- | --- | --- |
| 422 `line is not part of the pull request` | Line not in diff; wrong `side`; stale `commit_id` | View diff; verify line/side; refresh SHA |
| 422 `position` rejected | Deprecated `position` parameter | Use `line` + `side` |
| 404 | Wrong repo/PR/comment ID | Verify path |
| 403 | No write access | Check auth/permissions |

Scope: `/repos/.../pulls/.../comments` only.
General PR comments → `gh-cli-pr-comments`. Review verdicts → `gh-cli-pr-review`. Thread resolution → `gh-cli-api`.
