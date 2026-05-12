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

## Shell selection

Choose `<shell>` based on the executing runtime:

- bash 4+ on Linux, macOS, or Windows Git Bash → `<shell>` = `bash`
- PowerShell 7+ on any platform → `<shell>` = `pwsh`

## Dispatch

`<instructions>` = `instructions.<shell>.txt` in this skill folder (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `OWNER={OWNER} REPO={REPO} PR_NUMBER={PR_NUMBER} FILE_PATH={FILE_PATH} LINE_NUMBER={LINE_NUMBER} BODY={BODY} SIDE={SIDE}`
`<tier>` = fast-cheap
`<description>` = post inline PR comment on {FILE_PATH}:{LINE_NUMBER}
`<prompt>` = Read and follow `<instructions-abspath>`. Input: `<input-args>`

Follow dispatch skill. See `../../../../dispatch/SKILL.md`.

## Return

```json
{ "status": "posted" | "duplicate" | "error", "comment_id": <integer or null>, "comment_url": "<https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r{ID} or null>", "message": "<one-line summary>" }
```

On success:
`{ "status": "posted", "comment_id": <id from response>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<id from response>", "message": "posted at {FILE_PATH}:{LINE_NUMBER}" }`

On duplicate (deduplication check match):
`{ "status": "duplicate", "comment_id": <existing_id>, "comment_url": "https://github.com/{OWNER}/{REPO}/pull/{PR_NUMBER}#discussion_r<existing_id>", "message": "comment already exists at {FILE_PATH}:{LINE_NUMBER}" }`

On line not in diff (exit 3 from post tool):
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "Line {LINE_NUMBER} is not in the diff for {FILE_PATH}" }`

On gh error (exit 4 from post tool):
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "gh api error — see stderr" }`

On any other error:
`{ "status": "error", "comment_id": null, "comment_url": null, "message": "<error description>" }`
