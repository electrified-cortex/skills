# gh-cli-prs-create — Spec

## Purpose

Guide an agent through opening a pull request — from a ready branch through to a published or draft PR with correct metadata.

## Scope

`gh pr create` and `gh pr ready`. Listing, reviewing, merging out of scope — see sibling skills.

## Definitions

- **Draft PR**: a pull request created with `--draft` that signals work-in-progress; not eligible for merge until promoted to ready.
- **Ready PR**: a fully open pull request eligible for review and merge; promoted from draft via `gh pr ready`.
- **Closing issue link**: a `Closes #NNN` reference in the PR body that automatically closes the linked issue when the PR is merged.

## Requirements

The skill must enable an agent to:

- Open a PR with title, body, base branch, reviewers, assignees, and labels
- Create a draft PR and later promote it to ready
- Link the PR to a closing issue via body syntax
- Use a body file for structured or templated descriptions
- List existing PRs to confirm the branch isn't already open before creating

## Behavior

The skill covers opening a PR via `gh pr create` with title, body, base branch, reviewers, assignees, and labels. A PR may be created as a draft and later promoted to ready via `gh pr ready`. The body may be provided inline or from a file. A closing issue link is embedded in the body via the `Closes #NNN` syntax. Before creating, the agent must check for an existing open PR on the same branch to avoid duplicates.

## Error Handling

If the branch does not exist on the remote, `gh pr create` will fail — the agent must surface this and halt; branch creation and push are out of scope. If an open PR already exists for the branch, the agent must report it to the caller rather than creating a duplicate.

## Precedence Rules

N/A — this skill issues a single `gh pr create` or `gh pr ready` command per invocation; there are no competing resolution paths.

## Constraints

- Does not cover `gh pr edit` after creation — that is post-creation metadata management.
- Does not cover branch creation or git push — assumes the branch already exists on remote.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr create | Destructive | Operator approval required before execution |
| gh pr ready | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
