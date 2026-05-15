# delete — Spec

## Purpose

Delete an existing inline review comment by comment ID.

## Scope

REST DELETE `/repos/{owner}/{repo}/pulls/comments/{comment_id}` via `gh api`.

## Requirements

1. Requires a known `comment_id` (integer).
2. Must use `/pulls/comments/{id}` — not `/issues/comments/{id}`.
3. Deletion is permanent — no undo.

## Definitions

- **Inline review comment**: a comment anchored to a specific file and line in the PR diff; visible in "Files changed".
- **comment_id**: integer ID of the target inline review comment. Use the list endpoint to look it up.

## Inputs

| Parameter | Required |
| --------- | -------- |
| OWNER | yes |
| REPO | yes |
| COMMENT_ID | yes |

## Constraints

- Must use `/pulls/comments/{id}` — not `/issues/comments/{id}` (different endpoint).
- Deletion is permanent — no undo.
- Comment ID must exist; 404 if not found.
