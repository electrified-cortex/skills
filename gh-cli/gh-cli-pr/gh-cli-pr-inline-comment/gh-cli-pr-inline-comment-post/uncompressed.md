---
name: gh-cli-pr-inline-comment-post
description: Post a single or multi-line inline review comment on a PR diff line via GitHub CLI. Handles SHA lookup, diff verification, deduplication, and POST.
---

# GH CLI PR Inline Comment — Post

Dispatch skill. Posts an inline review comment anchored to a specific line in a PR diff.

This is the complex operation: before POSTing, the sub-agent must fetch the PR head commit SHA, verify the target file appears in the diff, confirm the target line is visible, and check for duplicate comments.

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
| START_LINE | no | For multi-line comments: start of the range |

## Execution

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>` in this skill folder
`<input-args>` = `OWNER={OWNER} REPO={REPO} PR_NUMBER={PR_NUMBER} FILE_PATH={FILE_PATH} LINE_NUMBER={LINE_NUMBER} BODY={BODY} SIDE={SIDE} START_LINE={START_LINE}`
`<tier>` = fast-cheap
`<description>` = post inline PR comment on {FILE_PATH}:{LINE_NUMBER}
`<prompt>` = Read and follow `<instructions-abspath>`. Input: `<input-args>`

Follow dispatch skill: `../../../../dispatch/SKILL.md`

## Return

```json
{ "status": "posted" | "duplicate" | "error", "comment_id": <id or null>, "message": "<one line>" }
```

## Why This Is Complex

GitHub requires:
1. A fresh `commit_id` from the PR head — stale SHAs cause 422
2. The target line must be visible in the diff — not all lines qualify
3. `side` must match the line type: `RIGHT` for additions/context, `LEFT` for deletions
4. `position` is deprecated — always use `line`
