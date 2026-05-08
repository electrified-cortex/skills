---
name: gh-cli-pr-inline-comment-post
description: Post an inline PR review comment on a diff line. Triggers — post inline comment, pr review comment, inline diff comment, pr inline annotation, gh api pr comment.
---

# GH CLI PR Inline Comment — Post

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

Follow dispatch skill. See `../../../../dispatch/SKILL.md`.
Should return: `{ "status": "posted" | "duplicate" | "error", "comment_id": <integer or null>, "comment_url": "<https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r{ID} or null>", "message": "<one-line summary>" }`

## Return

```json
{ "status": "posted" | "duplicate" | "error", "comment_id": <integer or null>, "comment_url": "<https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r{ID} or null>", "message": "<one-line summary>" }
```
