---
name: gh-cli-pr-inline-comment
description: Post, edit, or delete inline code review comments on PR diff lines. Routes to sub-skills by operation.
---

# GH CLI PR Inline Comment

Routes inline review comment operations to specialized sub-skills.

Inline review comments are anchored to a specific file and line in the PR diff. They appear in the "Files changed" view and require a `commit_id` and `path` — unlike general PR comments.

## Operation Routing

| Operation | Sub-skill | Notes |
| --------- | --------- | ----- |
| Post (create) | `gh-cli-pr-inline-comment-post/` | Multi-step: SHA lookup, diff verify, dedup, POST |
| Edit (update body) | `gh-cli-pr-inline-comment-edit/` | Single PATCH call by comment ID |
| Delete | `gh-cli-pr-inline-comment-delete/` | Single DELETE call by comment ID |

Read the sub-skill SKILL.md for the requested operation and follow it.

## Related Skills

- General PR comments: `gh-cli-pr-comments/`
- Review verdicts (approve/request-changes): `gh-cli-pr-review/`
- Thread resolution: `gh-cli-api/` (GraphQL `resolveReviewThread`)
