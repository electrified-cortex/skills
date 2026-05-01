---
name: gh-cli-pr-inline-comment-delete
description: Spec for deleting an existing inline review comment via GitHub CLI.
---

# gh-cli-pr-inline-comment-delete — Spec

## Purpose

Delete an existing inline review comment by comment ID.

## Scope

REST DELETE `/repos/{owner}/{repo}/pulls/comments/{comment_id}` via `gh api`.

## Requirements

1. Requires a known `comment_id` (integer).
2. Must use `/pulls/comments/{id}` — not `/issues/comments/{id}`.
3. Deletion is permanent — no undo.

## Inputs

| Parameter | Required |
| --------- | -------- |
| OWNER | yes |
| REPO | yes |
| COMMENT_ID | yes |
