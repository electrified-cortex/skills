---
name: gh-cli-prs-merge
description: Spec for merging, updating, and reverting pull requests via the GitHub CLI.
---

# gh-cli-prs-merge — Spec

## Purpose

Guide an agent through finalizing a pull request — merging, keeping the branch current, or undoing a merge.

## Scope

`gh pr merge`, `gh pr update-branch`, and `gh pr revert`. Does not cover checks or review status — those are inputs to the decision to merge, not part of this skill.

## Intent

The skill must enable an agent to:

- Merge a PR using merge commit, squash, or rebase strategy
- Delete the source branch after merge
- Update a PR branch that has fallen behind its base
- Revert a merged PR by opening a revert PR
- Close a PR without merging

## Non-Goals

- Does not cover `gh pr checks` — checking readiness before merge is out of scope here.
- Does not cover git operations after merge (e.g., pulling the updated base locally).
