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

## Notes

- Resolving review threads has no `gh pr` command. Use `resolveReviewThread` GraphQL mutation via `gh-cli-api`.

## Non-Goals

- Does not cover review-level comments (those with approve/request-changes verdicts).
- Does not cover viewing comments — use `gh pr view --comments`.
