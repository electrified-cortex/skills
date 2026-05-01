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
gh pr view {PR_NUMBER} --repo {OWNER}/{REPO} --json headRefOid --jq '.headRefOid'
```

Save as COMMIT_SHA.

## Step 2: Verify the File Is in the Diff

```bash
gh pr diff {PR_NUMBER} --name-only
```

If FILE_PATH is not listed, stop: the file has no changes in this PR.

## Step 3: Verify the Line Is in the Diff

> **GOTCHA**: `gh pr diff {PR_NUMBER} -- {FILE_PATH}` is INVALID — `gh pr diff` accepts at most one argument (the PR number). The `-- {FILE_PATH}` syntax causes a fatal error: "accepts at most 1 arg(s), received 2".

Get the full patch and parse hunk headers for the target file:

```bash
gh pr diff {PR_NUMBER} --patch
```

Locate the `diff --git a/{FILE_PATH}` section. For each `@@ -OLD,OLD_LEN +NEW,NEW_LEN @@` hunk header:
- SIDE=RIGHT: valid line range is NEW to (NEW + NEW_LEN - 1)
- SIDE=LEFT: valid line range is OLD to (OLD + OLD_LEN - 1)

If LINE_NUMBER falls outside all hunk ranges for FILE_PATH, stop and report:
`Line {LINE_NUMBER} not in diff for {FILE_PATH}`

Alternatively, skip this pre-check and rely on the 422 response in Step 5 — a 422 with `field=pull_request_review_thread.line` and `message="could not be resolved"` means the line is not commentable.

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

On 422 where `errors[0].field == "pull_request_review_thread.line"` and `message == "could not be resolved"`:
`{ "status": "error", "comment_id": null, "message": "Line {LINE_NUMBER} is not in the diff for {FILE_PATH}" }`

On other 422: surface the full `errors` array to the caller:
`{ "status": "error", "comment_id": null, "message": "<errors array as string>" }`
