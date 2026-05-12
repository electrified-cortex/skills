# GH CLI PR Inline Comment — Post (Bash)

Execution sequence and parameter handling for the gh-cli-pr-inline-comment-post skill — Bash shell only.

## Inputs

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| OWNER | yes | GitHub org or user name |
| REPO | yes | Repository name |
| PR_NUMBER | yes | Integer PR number |
| FILE_PATH | yes | Repo-relative path (e.g. `src/foo.ts`) |
| LINE_NUMBER | yes | Absolute line number in the file |
| BODY | yes | Comment text |
| SIDE | no | `RIGHT` (default) or `LEFT` |

## Prerequisites

```bash
gh auth status 2>&1
```

## Step 1: Fetch the Commit SHA

Always fetch fresh — stale SHAs cause 422 errors.

```bash
COMMIT_SHA=$(gh pr view "$PR_NUMBER" --repo "$OWNER/$REPO" --json headRefOid --jq '.headRefOid')
```

## Step 2: Verify the File Is in the Diff

```bash
gh pr diff "$PR_NUMBER" --repo "$OWNER/$REPO" --name-only
```

If FILE_PATH is not listed, stop: the file has no changes in this PR.

## Step 3: Verify the Line Is in the Diff

Use the bundled tool — do not parse the diff manually.

If SIDE was not provided by the caller, default it to `RIGHT` before invoking the tool.

```bash
bash verify-line-in-diff.sh "$OWNER" "$REPO" "$PR_NUMBER" "$FILE_PATH" "$LINE_NUMBER" "$SIDE"
VERIFY_EXIT=$?
```

Exit code semantics:

- **0 (IN_DIFF)** — line is in the diff; proceed.
- **1 (NOT_IN_DIFF)** — line is outside all hunk ranges; stop and surface the listed valid ranges to the caller.
- **2 (FILE_NOT_IN_DIFF)** — file has no changes in this PR; stop.
- **3 (USAGE_ERROR)** — invalid arguments passed to the tool; check invocation signature.
- **4 (API_ERROR)** — `gh pr diff` call failed; surface the error output to the caller.

> **WINDOWS / Git Bash**: Never use a leading `/` in `gh api` paths — Git Bash rewrites `/repos/...` as a filesystem path. Use `repos/...` not `/repos/...`.

## Step 4: Check for Existing Comment (Deduplication)

```bash
gh api --paginate "repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" \
  --jq ".[] | select(.path == \"$FILE_PATH\" and .line == $LINE_NUMBER and .side == \"$SIDE\") | {id, body, author: .user.login}"
```

If a matching comment already exists, return:
`{ "status": "duplicate", "comment_id": <existing_id>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<existing_id>", "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

## Step 5: Post the Comment

Write BODY to a temp file — inline shell substitution corrupts bodies that contain backticks, `$VAR` references, double quotes, or code fences.

```bash
BODY_FILE=$(mktemp /tmp/gh-body-XXXXXX.md)
printf '%s' "$BODY" > "$BODY_FILE"
```

Invoke the local post tool:

```bash
POST_URL=$(bash post.sh \
  --owner "$OWNER" \
  --repo "$REPO" \
  --pr "$PR_NUMBER" \
  --commit-sha "$COMMIT_SHA" \
  --file "$FILE_PATH" \
  --line "$LINE_NUMBER" \
  --side "$SIDE" \
  --body-file "$BODY_FILE")
POST_EXIT=$?
rm -f "$BODY_FILE"
```

## Step 6: Parse and Return

The tool emits the comment URL as a single line on stdout (exit 0) or nothing on error.

```bash
case $POST_EXIT in
  0)
    COMMENT_ID=$(printf '%s' "$POST_URL" | grep -oP '#discussion_r\K\d+')
    COMMENT_URL="$POST_URL"
    ;;
  3)
    # Line not in diff
    printf '{ "status": "error", "comment_id": null, "comment_url": null, "message": "Line %s is not in the diff for %s" }\n' \
      "$LINE_NUMBER" "$FILE_PATH"
    exit 0
    ;;
  4)
    # gh error — POST_URL is empty; stderr was forwarded by the tool
    printf '{ "status": "error", "comment_id": null, "comment_url": null, "message": "gh api error — see stderr" }\n'
    exit 0
    ;;
  2)
    # Usage error — should not happen if args were constructed correctly
    printf '{ "status": "error", "comment_id": null, "comment_url": null, "message": "internal error: bad args to post.sh" }\n'
    exit 0
    ;;
esac
```

## Return

On success:
`{ "status": "posted", "comment_id": <id from response>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<id from response>", "message": "posted at {FILE_PATH}:{LINE_NUMBER}" }`

On duplicate (Step 4 match):
`{ "status": "duplicate", "comment_id": <existing_id>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<existing_id>", "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

On line not in diff (exit 3 from post.sh):
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "Line {LINE_NUMBER} is not in the diff for {FILE_PATH}" }`

On gh error (exit 4 from post.sh):
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "gh api error — see stderr" }`

On any other error:
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "<error description>" }`
