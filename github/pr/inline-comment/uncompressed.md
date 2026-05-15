---
name: inline-comment
description: Post, edit, or delete inline code review comments on PR diff lines. Routes to sub-skills by operation.
---

# GH CLI PR Inline Comment

Routes inline review comment operations to specialized sub-skills.

## Operation Routing

| Operation | Sub-skill | Notes |
| --------- | --------- | ----- |
| Post (create) | `post/` | Multi-step: SHA lookup, diff verify, dedup, POST |
| Edit (update body) | `edit/` | Single PATCH call by comment ID |
| Delete | `delete/` | Single DELETE call by comment ID |

Read the sub-skill SKILL.md for the requested operation and follow it.

## Related Skills

- General PR comments: `comments/`
- Review verdicts (approve/request-changes): `review/`
- Thread resolution: `api/` (GraphQL `resolveReviewThread`)
