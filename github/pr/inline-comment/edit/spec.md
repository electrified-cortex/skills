---
name: edit
description: Spec for editing the body of an existing inline review comment via GitHub CLI.
---

# edit — Spec

## Purpose

Update the body of an existing inline review comment by comment ID.

## Scope

REST PATCH `/repos/{owner}/{repo}/pulls/comments/{comment_id}` via `gh api`. Body update only.

## Requirements

1. Requires a known `comment_id` (integer).
2. Only `body` can be updated via this endpoint.
3. Must use `/pulls/comments/{id}` — not `/issues/comments/{id}`.

## Definitions

- **Inline review comment**: a comment anchored to a specific file and line in the PR diff; visible in "Files changed".
- **comment_id**: integer ID of the target inline review comment. Use the list endpoint to look it up.

## Inputs

| Parameter | Required |
| --------- | -------- |
| OWNER | yes |
| REPO | yes |
| COMMENT_ID | yes |
| BODY | yes |

## Constraints

- Only the `body` field can be updated via this endpoint.
- Must use `/pulls/comments/{id}` — not `/issues/comments/{id}` (different endpoint).
- Comment ID must exist; 404 if not found.
