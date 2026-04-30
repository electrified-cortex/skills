---
name: gh-cli-pr-inline-comments
description: Post, edit, and delete inline code review comments on specific diff lines via GitHub CLI.
---

# GH CLI PR Inline Comments

Post, edit, and delete inline review comments tied to specific lines in a pull request diff using `gh api`.

Inline review comments differ from general PR comments (`gh pr comment`): they are attached to a specific file and line in the diff, appear in the "Files changed" view, and require a `commit_id` and `path`.

## Required Parameters

| Parameter | Source | Notes |
| --- | --- | --- |
| `OWNER` | Caller-provided | GitHub org or user name |
| `REPO` | Caller-provided | Repository name |
| `PR_NUMBER` | Caller-provided | Integer PR number |
| `FILE_PATH` | Caller-provided | Repo-relative path (e.g. `src/foo.ts`) |
| `LINE_NUMBER` | Caller-provided | Absolute line number in the file |
| `BODY` | Caller-provided | Comment text |

## Prerequisites

Verify GitHub CLI is authenticated:

```bash
gh auth status
```

## Step 1: Get the Commit SHA

Inline comments must reference a commit that is part of the PR. Always use the PR's latest commit:

```bash
gh pr view {PR_NUMBER} --json headRefOid --jq '.headRefOid'
```

Save this as `COMMIT_SHA`. Using stale or incorrect commit SHAs causes 422 errors.

## Step 2: Verify the File and Line Are in the Diff

The target line **must** appear in the PR diff. It can be an added line, context line, or deleted line, but it must be visible in the diff.

Check changed files:

```bash
gh pr diff {PR_NUMBER} --name-only
```

View the diff for a specific file to identify valid line numbers:

```bash
gh pr diff {PR_NUMBER} -- {FILE_PATH}
```

`+` lines are RIGHT-side additions; `-` lines are LEFT-side deletions; space-prefixed lines are context (use `RIGHT` for context lines).

## Step 3: Check for Existing Comments at the Target Line (Deduplication)

Before posting, list existing inline comments and check whether a comment already exists at the same file path and line. Posting a duplicate wastes review noise and may confuse reviewers.

```bash
gh api --paginate /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --jq '.[] | select(.path == "{FILE_PATH}" and .line == {LINE_NUMBER}) | {id, body, author: .user.login}'
```

If a comment already exists at that line, review its content before proceeding. If it matches what you intended to post, do not repost.

## Step 4: Post the Inline Comment

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field line={LINE_NUMBER} \
  --field side="{SIDE}"
```

`side` values:

- `RIGHT` — the new/added version of the file (additions and context lines)
- `LEFT` — the deleted/old version of the file (removals only)

Do **not** use the deprecated `position` parameter (counts raw diff-patch lines; error-prone). Always use `line` (absolute file line number).

## Step 5: Multi-Line Inline Comment

To span a range of lines, add `start_line` and `start_side` alongside `line` and `side`:

```bash
gh api --method POST /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments \
  --field body="{BODY}" \
  --field commit_id="{COMMIT_SHA}" \
  --field path="{FILE_PATH}" \
  --field start_line={START_LINE} \
  --field start_side="RIGHT" \
  --field line={END_LINE} \
  --field side="RIGHT"
```

Both `start_line` and `line` must be in the diff; `side` and `start_side` must match.

## Editing an Inline Comment

Inline review comment IDs are available from the list endpoint. PATCH to update the body:

```bash
gh api --method PATCH /repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID} \
  --field body="{UPDATED_BODY}"
```

Note: `/pulls/comments/{id}` — not `/issues/comments/{id}` (different endpoint from general PR comments).

## Deleting an Inline Comment

```bash
gh api --method DELETE /repos/{OWNER}/{REPO}/pulls/comments/{COMMENT_ID}
```

## Listing Existing Inline Comments

```bash
gh api --paginate /repos/{OWNER}/{REPO}/pulls/{PR_NUMBER}/comments
```

Each result includes `id`, `path`, `line`, `side`, `body`, `author`, `created_at`.

## Comments vs. Threads

Each inline comment you post creates a **review thread**. The comment and the thread are separate objects:

- **Comment** (`id` integer) — the individual message. Created/edited/deleted via REST (`/pulls/comments/{id}`).
- **Thread** (`node_id` string) — the container holding one or more replies. Resolved via GraphQL `resolveReviewThread` mutation.

The thread ID is not the same as the comment ID. To get thread IDs, use `gh-cli-pr-review` or the GraphQL API. Resolving a thread (marking it done) is out of scope for this skill — see `gh-cli-api` for the `resolveReviewThread` mutation.

## Error Reference

| Error | Cause | Fix |
| --- | --- | --- |
| 422 `line is not part of the pull request` | Line not in diff; wrong `side`; stale `commit_id` | View `gh pr diff {PR} -- {PATH}`; verify line and side; refresh `commit_id` |
| 422 `position` rejected | Using deprecated `position` parameter | Replace with `line` + `side` |
| 404 | Wrong `OWNER/REPO` or `PR_NUMBER`; comment ID not found | Verify repo path and PR exists |
| 403 | No write access to repo | Check GitHub CLI auth and repo permissions |

## Scope

Inline review comments on PR diff lines (`/repos/.../pulls/.../comments`). Excludes:

- General PR comments (`gh pr comment`) → `gh-cli-pr-comments`
- Review verdicts (approve/request-changes) → `gh-cli-pr-review`
- Thread resolution → `gh-cli-api` (GraphQL `resolveReviewThread`)
