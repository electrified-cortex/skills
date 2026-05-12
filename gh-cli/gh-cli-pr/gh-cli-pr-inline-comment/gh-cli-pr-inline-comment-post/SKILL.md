---
name: gh-cli-pr-inline-comment-post
description: Post an inline PR review comment on a diff line. Triggers — post inline comment, pr review comment, inline diff comment, pr inline annotation, gh api pr comment.
---

Inputs:

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| OWNER | yes | GitHub org or user name |
| REPO | yes | Repository name |
| PR_NUMBER | yes | Integer PR number |
| FILE_PATH | yes | Repo-relative path (e.g. `src/foo.ts`) |
| LINE_NUMBER | yes | Absolute line number in file |
| BODY | yes | Comment text |
| SIDE | no | `RIGHT` (default) or `LEFT` |
| START_LINE | no | Multi-line only: start of range |

Dispatch by shell — resolve `<shell>`:
bash 4+ on Linux, macOS, or Windows Git Bash → `bash`
PowerShell 7+ on any platform → `pwsh`

`<instructions>` = `instructions.<shell>.txt` in this skill folder (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `OWNER={OWNER} REPO={REPO} PR_NUMBER={PR_NUMBER} FILE_PATH={FILE_PATH} LINE_NUMBER={LINE_NUMBER} BODY={BODY} SIDE={SIDE} START_LINE={START_LINE}`
`<tier>` = fast-cheap
`<description>` = post inline PR comment on {FILE_PATH}:{LINE_NUMBER}
`<prompt>` = Read and follow `<instructions-abspath>`. Input: `<input-args>`

Follow dispatch skill. See `../../../../dispatch/SKILL.md`.
Should return: `{ "status": "posted" | "duplicate" | "error", "comment_id": <integer or null>, "comment_url": "<https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r{ID} or null>", "message": "<one-line summary>" }`
