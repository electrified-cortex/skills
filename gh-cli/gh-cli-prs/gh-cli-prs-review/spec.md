---
name: gh-cli-prs-review
description: Spec for reviewing pull requests via the GitHub CLI.
---

# gh-cli-prs-review — Spec

## Purpose

Guide an agent through performing, editing, and dismissing pull request reviews.

## Scope

`gh pr review`. Does not cover inline comments or general (non-review) PR comments — see `gh-cli-prs-comments`.

## Intent

The skill must enable an agent to:

- Approve a PR with an optional body
- Request changes with a required body explaining what needs fixing
- Submit a comment-only review without a verdict
- Dismiss a previous review

## Don'ts

- Does not cover requesting reviewers — that belongs to `gh-cli-prs-create` (at creation) or cover the `gh pr edit --add-reviewer` path.
- Does not cover resolving review threads — see `gh-cli-api` for the GraphQL mutation.
