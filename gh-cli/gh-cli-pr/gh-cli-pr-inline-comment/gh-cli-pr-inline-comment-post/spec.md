---
name: gh-cli-pr-inline-comment-post
description: Spec for posting a single or multi-line inline review comment on a PR diff line via GitHub CLI.
---

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
3. Confirm the target line is visible in `gh pr diff -- {path}`.
4. Check for existing comments at the same file+line before posting (deduplication).
5. Post with `body`, `commit_id`, `path`, `line`, `side`. Never use deprecated `position`.
6. On 422: re-inspect diff, diagnose cause, surface to caller — do not silently retry.

## Error Handling

| Error | Cause | Recovery |
| ----- | ----- | -------- |
| 422 `line is not part of the pull request` | Line not in diff; wrong `side`; stale SHA | Re-fetch SHA; view diff; correct params |
| 422 `position` rejected | Deprecated param used | Replace with `line` + `side` |
| 404 | Wrong repo or PR number | Verify owner/repo |
| 403 | No write access | Check auth |
