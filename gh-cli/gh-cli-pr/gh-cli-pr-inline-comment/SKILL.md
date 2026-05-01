---
name: gh-cli-pr-inline-comment
description: Post, edit, or delete inline code review comments on PR diff lines. Routes to sub-skills by operation.
---

Routes inline review comment operations to sub-skills.

| Operation | Sub-skill | Notes |
| --------- | --------- | ----- |
| post | `gh-cli-pr-inline-comment-post/` | Complex: SHA lookup, diff verify, dedup, POST |
| edit | `gh-cli-pr-inline-comment-edit/` | Single PATCH by comment ID |
| delete | `gh-cli-pr-inline-comment-delete/` | Single DELETE by comment ID |

Read the sub-skill SKILL.md for the requested operation and follow it.
