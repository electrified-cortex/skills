---
name: gh-cli-prs-create
description: Open pull request via GitHub CLI.
---

# GH CLI PR Create

Open pull requests using `gh pr create`. Covers creating standard PRs, draft PRs, and promoting drafts to ready.

## Before Creating — Check for Existing PR

Before opening a PR, confirm there is no existing open PR for the current branch:

```bash
gh pr list --head $(git branch --show-current)
```

If a PR already exists, edit or view it rather than creating a duplicate.

## Creating a Pull Request

Create a PR with title, body, and base branch:

```bash
gh pr create --title "title" --body "body" --base main
```

Create a PR with full metadata — reviewers, assignee, labels, and start as draft:

```bash
gh pr create --title "title" --body-file .github/PULL_REQUEST_TEMPLATE.md \
  --reviewer user1,user2 --assignee @me --label enhancement --draft
```

## Linking to a Closing Issue

Include a closing keyword in the PR body to automatically close the linked issue when the PR merges:

```bash
# In the --body value or --body-file content:
Closes #123
```

## Promoting a Draft to Ready

When the PR is ready for review, promote it:

```bash
gh pr ready 123
```

## Editing Metadata After Creation

Add reviewers, labels, or remove labels after the PR is open:

```bash
gh pr edit 123 --add-reviewer user3 --add-label bug --remove-label wip
```

## Scope Boundaries

This skill covers `gh pr create`, `gh pr ready`, and `gh pr edit`. It does not cover branch creation or `git push` — the branch must already exist on the remote before running these commands. Reviewing and merging the PR belong to their respective sub-skills.
