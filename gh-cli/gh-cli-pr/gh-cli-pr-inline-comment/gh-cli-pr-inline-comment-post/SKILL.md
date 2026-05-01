---
name: gh-cli-pr-inline-comment-post
description: Post a single or multi-line inline review comment on a PR diff line via GitHub CLI. Handles SHA lookup, diff verification, deduplication, and POST.
---

Input: OWNER, REPO, PR_NUMBER, FILE_PATH, LINE_NUMBER, BODY, SIDE (optional — default RIGHT), START_LINE (optional — multi-line only)

`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>` in this skill folder
`<input-args>` = `OWNER={OWNER} REPO={REPO} PR_NUMBER={PR_NUMBER} FILE_PATH={FILE_PATH} LINE_NUMBER={LINE_NUMBER} BODY={BODY} SIDE={SIDE} START_LINE={START_LINE}`
`<tier>` = fast-cheap — scripted API sequence; sub-agent executes fixed CLI steps, no LLM judgment required
`<description>` = post inline PR comment on {FILE_PATH}:{LINE_NUMBER}
`<prompt>` = Read and follow `<instructions-abspath>`. Input: `<input-args>`

Follow dispatch skill: `../../../../dispatch/SKILL.md`
Should return: `{ "status": "posted" | "duplicate" | "error", "comment_id": <id or null>, "message": "<one line>" }`

## Known Gotchas (Verified Against Live API)

| Gotcha | Symptom | Fix |
| --- | --- | --- |
| `gh pr diff {PR} -- {file}` is invalid | `accepts at most 1 arg(s), received 2` | `gh pr diff` takes only the PR number; no file-filter arg. Get full patch and parse hunk headers per file. |
| Line not in diff | 422: `pull_request_review_thread.line` → `"could not be resolved"` | Line is outside all hunk ranges for the file. Check valid ranges from `@@ -OLD,LEN +NEW,LEN @@` headers. |
| `--json` missing `--repo` on forked repos | `Could not resolve to a PullRequest` | Always pass `--repo {OWNER}/{REPO}` to `gh pr view` and `gh pr diff` when not in a local clone. |
| `gh auth status` output goes to stderr | Command produces no stdout output | Use `gh auth status 2>&1` to capture. |
