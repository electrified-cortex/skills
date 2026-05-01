---
name: gh-cli-pr-inline-comment-edit
description: Spec for editing the body of an existing inline review comment via GitHub CLI.
---

# gh-cli-pr-inline-comment-edit — Spec

## Purpose

Update the body of an existing inline review comment by comment ID.

## Scope

REST PATCH `/repos/{owner}/{repo}/pulls/comments/{comment_id}` via `gh api`. Body update only.

## Requirements

1. Requires a known `comment_id` (integer).
2. Only `body` can be updated via this endpoint.
3. Must use `/pulls/comments/{id}` — not `/issues/comments/{id}`.

## Inputs

| Parameter | Required |
| --------- | -------- |
| OWNER | yes |
| REPO | yes |
| COMMENT_ID | yes |
| BODY | yes |
