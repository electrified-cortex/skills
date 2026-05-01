---
name: gh-cli-pr-inline-comment-post
description: Post a single or multi-line inline review comment on a PR diff line via GitHub CLI. Handles SHA lookup, diff verification, deduplication, and POST.
---

Input: OWNER, REPO, PR_NUMBER, FILE_PATH, LINE_NUMBER, BODY, SIDE (optional — default RIGHT), START_LINE (optional — multi-line only)

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>` in this skill folder
`<input-args>` = `OWNER={OWNER} REPO={REPO} PR_NUMBER={PR_NUMBER} FILE_PATH={FILE_PATH} LINE_NUMBER={LINE_NUMBER} BODY={BODY} SIDE={SIDE} START_LINE={START_LINE}`
`<tier>` = fast-cheap
`<description>` = post inline PR comment on {FILE_PATH}:{LINE_NUMBER}
`<prompt>` = Read and follow `<instructions-abspath>`. Input: `<input-args>`

Follow dispatch skill: `../../../../dispatch/SKILL.md`
Returns: `{ "status": "posted" | "duplicate" | "error", "comment_id": <id or null>, "message": "<one line>" }`
