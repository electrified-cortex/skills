---
name: gh-cli-prs-merge
description: Spec for merging, updating, and reverting pull requests via the GitHub CLI.
---

# gh-cli-prs-merge — Spec

## Purpose

Guide an agent through finalizing a pull request — merging, keeping the branch current, or undoing a merge.

## Scope

`gh pr merge`, `gh pr update-branch`, and `gh pr revert`. Does not cover checks or review status — those are inputs to the decision to merge, not part of this skill.

## Definitions

- **Merge commit**: a strategy that preserves all commits from the source branch as-is, adding a merge commit to the base.
- **Squash**: a strategy that combines all commits from the source branch into a single commit on the base.
- **Rebase**: a strategy that replays commits from the source branch onto the base without a merge commit.
- **Branch update**: the act of synchronizing a PR branch with its base when the base has moved ahead.
- **Revert PR**: a new pull request that undoes the changes introduced by a previously merged PR.

## Requirements

The skill must enable an agent to:

- Merge a PR using merge commit, squash, or rebase strategy
- Delete the source branch after merge
- Update a PR branch that has fallen behind its base
- Revert a merged PR by opening a revert PR
- Close a PR without merging

## Behavior

The skill covers PR finalization via `gh pr merge`, `gh pr update-branch`, and `gh pr revert`. Merge accepts an explicit strategy (merge commit, squash, or rebase) and optionally deletes the source branch after merge. `gh pr update-branch` rebases or merges the base into a PR branch that has fallen behind. `gh pr revert` opens a new revert PR. A PR may be closed without merging via `gh pr close`.

## Error Handling

If a merge is attempted without specifying a strategy and the repository has multiple strategies enabled, `gh` may prompt interactively — the agent must always pass an explicit strategy flag to avoid blocking. If `gh pr update-branch` fails due to a conflict, the agent must surface the conflict to the caller; it must not force-update.

## Precedence Rules

Merge strategy must be explicitly specified — no default strategy may be assumed. Branch deletion after merge is opt-in — the agent must not delete the source branch unless the caller explicitly requests it.

## Constraints

- Does not cover `gh pr checks` — checking readiness before merge is out of scope here.
- Does not cover git operations after merge (e.g., pulling the updated base locally).

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr merge | Destructive | Operator approval required before execution |
| gh pr update-branch | Destructive | Operator approval required before execution |
| gh pr revert | Destructive | Operator approval required before execution |
| gh pr close | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
