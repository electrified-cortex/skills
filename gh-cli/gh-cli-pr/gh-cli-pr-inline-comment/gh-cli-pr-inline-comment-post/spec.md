# gh-cli-pr-inline-comment-post — Spec

## Purpose

Guide a sub-agent through the correct sequence to post an inline review comment anchored to a specific line in a pull request diff.

## Scope

REST API endpoint `/repos/{owner}/{repo}/pulls/{pull_number}/comments` via `gh api`. Post only — edit and delete are in sibling sub-skills.

## Definitions

- **Inline review comment**: anchored to a specific file path and line in the PR diff; visible in "Files changed".
- **commit_id**: SHA of a commit in the PR branch. Must be fetched fresh from `headRefOid` — stale SHAs cause 422.
- **side**: `RIGHT` = new/added version (additions + context); `LEFT` = deleted/old version (deletions only).
- **line**: absolute line number in the file. Never use deprecated `position`.
- **Multi-line comment**: spans a range; requires `start_line`, `start_side`, `line`, `side`.

## Inputs

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| OWNER | yes | GitHub org or user |
| REPO | yes | Repository name |
| PR_NUMBER | yes | Integer PR number |
| FILE_PATH | yes | Repo-relative path |
| LINE_NUMBER | yes | Absolute line number |
| BODY | yes | Comment text |
| SIDE | no | `RIGHT` (default) or `LEFT` |
| START_LINE | no | For multi-line comments only |

## Step Order (Fixed)

fetch SHA → verify file in diff → verify line in diff → dedup check → POST

## Requirements

1. Always fetch `commit_id` fresh from `gh pr view --json headRefOid`.
2. Verify the target file appears in `gh pr diff --name-only` before posting.
3. Confirm the target line is in a hunk for the target file by parsing `gh pr diff --patch` output. **`gh pr diff {PR} -- {file}` is invalid** — `gh pr diff` accepts only one argument; the file-filter syntax fails with "accepts at most 1 arg". Get the full patch and locate `@@ -OLD,LEN +NEW,LEN @@` hunk headers for the file to determine valid line ranges. Alternatively, rely on the 422 response at POST time.
4. Check for existing comments at the same file+line before posting (deduplication).
5. Post with `body`, `commit_id`, `path`, `line`, `side`. Never use deprecated `position`.
6. On 422: re-inspect diff, diagnose cause, surface to caller — do not silently retry.

## Error Handling

| Error | Cause | Recovery |
| ----- | ----- | -------- |
| 422 field=`pull_request_review_thread.line` message=`could not be resolved` | Line not in any hunk for this file; wrong `side`; stale SHA | Re-fetch SHA; check hunk ranges in `--patch`; correct params |
| 422 `position` rejected | Deprecated param used | Replace with `line` + `side` |
| 404 | Wrong repo or PR number | Verify owner/repo |
| 403 | No write access | Check auth |

## Verified Gotchas

- `gh pr diff {PR_NUMBER} -- {FILE_PATH}` fails: "accepts at most 1 arg(s), received 2". File-scoped diffs are not supported by `gh pr diff`. Use `--patch` and parse.
- `gh auth status` output goes to stderr. Capture with `2>&1`.
- Always pass `--repo {OWNER}/{REPO}` to `gh pr view` and `gh pr diff` when not running inside a local clone.
- Windows Git Bash rewrites leading `/` in `gh api` paths as a filesystem path (e.g. `/repos/...` → `C:/Program Files/Git/repos/...`). Always omit the leading `/`: `repos/{OWNER}/...` not `/repos/{OWNER}/...`.
- Compact hunk format: when a hunk spans exactly 1 line, git omits the count — `@@ -10 +10 @@` means length=1 (same as `@@ -10,1 +10,1 @@`). Treat a missing count as 1 or the range check will wrongly exclude single-line hunks.

## Constraints

- Step order is fixed: fetch SHA -> verify file -> verify line -> dedup -> POST. Never skip.
- Never use the deprecated `position` parameter. Always use `line` + `side`.
- `commit_id` must be fetched fresh each invocation — never reuse a cached SHA.
- Edit and delete operations are out of scope — see sibling sub-skills.

## Return Shape

Every invocation returns a JSON object with these fields:

| Field | Type | Notes |
| ----- | ---- | ----- |
| `status` | `"posted" \| "duplicate" \| "error"` | `"posted"` = new comment created; `"duplicate"` = comment already existed; `"error"` = failure |
| `comment_id` | integer or null | GitHub comment ID. Null on error. |
| `comment_url` | string or null | Full URL to the comment: `https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r{COMMENT_ID}`. Null on error. |
| `message` | string | One-line human summary. |

The `comment_url` MUST be returned on both the `"posted"` and `"duplicate"` paths so callers can surface it to the operator without making additional API calls.
