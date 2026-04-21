---
name: gh-cli-prs-comments
description: Spec for commenting on pull requests via the GitHub CLI.
---

# gh-cli-prs-comments — Spec

## Purpose

Guide an agent through adding, editing, and deleting comments on a pull request.

## Scope

`gh pr comment`. Does not cover review submissions (approve/request changes) — see `gh-cli-prs-review`.

## Intent

The skill must enable an agent to:

- Add a general comment to a PR
- Edit an existing comment by ID
- Delete a comment by ID

## Behavior

The skill covers general PR comments via `gh pr comment`: adding a new comment, editing an existing comment by its ID, and deleting a comment by its ID. Review-level comments (tied to approve/request-changes verdicts) are not handled here. Resolving review threads has no `gh pr` command — the agent must redirect to `gh-cli-api` for the `resolveReviewThread` GraphQL mutation.

## Error Handling

If an edit or delete operation is attempted without a comment ID, it will fail — the agent must obtain the comment ID (via `gh pr view --comments` or the API) before proceeding. If a comment ID does not exist on the target PR, `gh` returns an error — the agent must surface this to the caller.

## Precedence Rules

N/A — add, edit, and delete are discrete non-overlapping operations; no resolution path conflicts exist within this skill.

## Don'ts

- Does not cover review-level comments (those with approve/request-changes verdicts).
- Does not cover viewing comments — use `gh pr view --comments`.
