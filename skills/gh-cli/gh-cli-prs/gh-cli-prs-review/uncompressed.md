---
name: gh-cli-prs-review
description: Approve, request changes on, dismiss pull request review via GitHub CLI.
---

# GH CLI PR Review

Perform and dismiss pull request reviews using `gh pr review`.

## Approving a Pull Request

Approve a PR with an optional body message:

```bash
gh pr review 123 --approve --body "LGTM"
```

## Requesting Changes

Request changes on a PR. A body is required to explain what needs to be addressed:

```bash
gh pr review 123 --request-changes --body "Please address X before merging"
```

## Comment-Only Review (No Verdict)

Submit a review comment without approving or requesting changes:

```bash
gh pr review 123 --comment --body "Thoughts inline"
```

## Dismissing a Review

Dismiss a previously submitted review. `--review-id` is required — the `gh` CLI will not accept `--dismiss` without it:

```bash
gh pr review 123 --dismiss --review-id <review-id> --body "reason"
```

To obtain the review ID:

```bash
gh pr view 123 --json reviews --jq '.reviews[].id'
```

## Adding Reviewers

To add reviewers at PR creation time, use `gh pr create --reviewer`. To add reviewers after creation:

```bash
gh pr edit 123 --add-reviewer user
```

These are covered by `gh-cli-prs-create`, not by this skill.

## Resolving Review Threads

Resolving review threads has no `gh pr` command. Use the `resolveReviewThread` GraphQL mutation via `gh-cli-api`:

```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

## Scope Boundaries

This skill covers `gh pr review` only. It does not cover inline review comments (adding comments to specific lines of code), requesting reviewers (see `gh-cli-prs-create`), or resolving review threads (see `gh-cli-api`).

## Error Paths

- **`--request-changes` without `--body`**: the `gh` CLI requires a body for request-changes reviews. If no body is provided by the caller, prompt for the change rationale before running the command.
- **`--dismiss` with non-existent review ID**: `gh` surfaces a 422 or "not found" error. Surface the error message to the caller; use `gh pr view --json reviews` to list current review IDs and ask the caller to reconfirm.

## Related

- `gh-cli-prs-create` — adding reviewers, creating PRs
- `gh-cli-api` — resolving review threads via GraphQL
