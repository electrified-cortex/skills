---
name: gh-cli-prs-create
description: Spec for creating and opening pull requests via the GitHub CLI.
---

# gh-cli-prs-create — Spec

## Purpose

Guide an agent through opening a pull request — from a ready branch through to a published or draft PR with correct metadata.

## Scope

`gh pr create` and `gh pr ready`. Listing, reviewing, merging out of scope — see sibling skills.

## Intent

The skill must enable an agent to:

- Open a PR with title, body, base branch, reviewers, assignees, and labels
- Create a draft PR and later promote it to ready
- Link the PR to a closing issue via body syntax
- Use a body file for structured or templated descriptions
- List existing PRs to confirm the branch isn't already open before creating

## Don'ts

- Does not cover `gh pr edit` after creation — that is post-creation metadata management.
- Does not cover branch creation or git push — assumes the branch already exists on remote.
