# GH CLI PR Inline Comment — Post

Post an inline review comment anchored to a specific line in a pull request diff.

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
| START_LINE | no | Only for multi-line comments |

## Prerequisites

```bash
gh auth status
```

## Step 1: Fetch the Commit SHA

Always fetch fresh — stale SHAs cause 422 errors.

```bash
gh pr view {PR_NUMBER} --json headRefOid --jq '.headRefOid'
```

Save as COMMIT_SHA.

## Step 2: Verify the File Is in the Diff

```bash
gh pr diff {PR_NUMBER} --name-only
```

If FILE_PATH is not listed, stop: the file has no changes in this PR.

## Step 3: Verify the Line Is in the Diff

```bash
gh pr diff {PR_NUMBER} -- {FILE_PATH}
```

`+` lines = RIGHT-side additions. `-` lines = LEFT-side deletions. Space-prefixed = context (use RIGHT).

LINE_NUMBER must appear in the diff output. If not found, stop and report:
`Line {LINE_NUMBER} not visible in diff for {FILE_PATH}`

## Step 4: Check for Existing Comment (Deduplication)

```bash
gh api --paginate /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.path == "{FILE_PATH}" and .line == {LINE_NUMBER}) | {id, body, author: .user.login}'
```

If a matching comment already exists, return:
`{ "status": "duplicate", "comment_id": <existing_id>, "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

## Step 5: Post the Comment

Single-line:

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}"
```

Multi-line (when START_LINE is provided):

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field start_line={START_LINE} \
  --field start_side="RIGHT" \
  --field line={LINE_NUMBER} \
  --field side="RIGHT"
```

Both `start_line` and `line` must be in the diff. Do not use the deprecated `position` parameter.

## Return

On success:
`{ "status": "posted", "comment_id": <id from response>, "message": "posted at {FILE_PATH}:{LINE_NUMBER}" }`

On duplicate (Step 4 match):
`{ "status": "duplicate", "comment_id": <existing_id>, "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

On 422: diagnose cause from error body, return:
`{ "status": "error", "comment_id": null, "message": "<diagnosed cause>" }`
