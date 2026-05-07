# GH CLI PR Inline Comment — Post

Execution sequence and parameter handling for the gh-cli-pr-inline-comment-post skill.

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
gh auth status 2>&1
```

## Step 1: Fetch the Commit SHA

Always fetch fresh — stale SHAs cause 422 errors.

```bash
gh pr view {PR_NUMBER} --repo {OWNER}/{REPO} --json headRefOid --jq '.headRefOid'
```

Save as COMMIT_SHA.

## Step 2: Verify the File Is in the Diff

```bash
gh pr diff {PR_NUMBER} --repo {OWNER}/{REPO} --name-only
```

If FILE_PATH is not listed, stop: the file has no changes in this PR.

## Step 3: Verify the Line Is in the Diff

Use the bundled tool — do not parse the diff manually.

If SIDE was not provided by the caller, use `RIGHT` as the default before invoking the tool.

```bash
bash verify-line-in-diff.sh {OWNER} {REPO} {PR_NUMBER} {FILE_PATH} {LINE_NUMBER} {SIDE}
```

```pwsh
pwsh verify-line-in-diff.ps1 {OWNER} {REPO} {PR_NUMBER} {FILE_PATH} {LINE_NUMBER} {SIDE}
```

Exit code semantics:
- **0 (IN_DIFF)** — line is in the diff; proceed.
- **1 (NOT_IN_DIFF)** — line is outside all hunk ranges; stop and surface the listed valid ranges to the caller.
- **2 (FILE_NOT_IN_DIFF)** — file has no changes in this PR; stop.
- **3 (USAGE_ERROR)** — invalid arguments passed to the tool; check invocation signature.
- **4 (API_ERROR)** — `gh pr diff` call failed; surface the error output to the caller.

> **WINDOWS**: Never use a leading `/` in `gh api` paths — Git Bash rewrites `/repos/...` as a filesystem path. Use `repos/...` not `/repos/...`.

## Step 4: Check for Existing Comment (Deduplication)

```bash
gh api --paginate repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.path == "{FILE_PATH}" and .line == {LINE_NUMBER} and .side == "{SIDE}") | {id, body, author: .user.login}'
```

If a matching comment already exists, return:
`{ "status": "duplicate", "comment_id": <existing_id>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<existing_id>", "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

## Step 5: Post the Comment

Single-line:

```bash
gh api --method POST repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}"
```

Multi-line (when START_LINE is provided):

```bash
gh api --method POST repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
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
`{ "status": "posted", "comment_id": <id from response>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<id from response>", "message": "posted at {FILE_PATH}:{LINE_NUMBER}" }`

On duplicate (Step 4 match):
`{ "status": "duplicate", "comment_id": <existing_id>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<existing_id>", "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

On 422 where `errors[0].field == "pull_request_review_thread.line"` and `message == "could not be resolved"`:
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "Line {LINE_NUMBER} is not in the diff for {FILE_PATH}" }`

On other 422: surface the full `errors` array to the caller:
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "<errors array as string>" }`

On any other error:
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "<error description>" }`
