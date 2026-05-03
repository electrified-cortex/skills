---
name: gh-cli-pr-file-viewed
description: Spec for marking and unmarking files as viewed in a GitHub pull request.
---

# gh-cli-pr-file-viewed — Spec

## Purpose

Define the behavior and requirements for an agent skill that marks or unmarks one, multiple, or all changed files in a GitHub PR as viewed using GitHub's GraphQL API.

## Scope

Covers `markFileAsViewed` and `unmarkFileAsViewed` GraphQL mutations accessed via `gh api graphql`. Does not cover submitting PR reviews, posting comments, or resolving review threads.

## Definitions

- **Viewed state**: per-file, per-authenticated-user state tracked by GitHub. Possible values: `VIEWED`, `UNVIEWED`, `DISMISSED`. `DISMISSED` means the file was previously marked viewed but a new commit was pushed, resetting it.
- **PR node ID**: the GraphQL global identifier for a pull request. Distinct from the PR number. Retrieved via `gh pr view --json id`.
- **File path**: the relative path of a changed file in the PR diff. Must match exactly (case-sensitive) the path returned by `gh pr view --json files`.

## Intent

The skill must enable an agent to:

- Mark a single file in a PR as viewed
- Unmark a single file in a PR as viewed
- Mark multiple specific files as viewed
- Mark all changed files in a PR as viewed
- Check the current viewed state of all files in a PR

## Requirements

- The skill must resolve the PR node ID via `gh pr view --json id` before calling any mutation.
- The skill must verify file paths against `gh pr view --json files` before marking — paths passed that don't appear in the PR files list must be surfaced as an error to the caller.
- The skill must handle fork PR resolution: if a PR was discovered via `gh pr list --repo {fork}`, the actual repo must be extracted from the `url` field before proceeding.
- For marking all files, the skill must retrieve the full file list first, then iterate mutations.
- For PRs with more than 100 files, the skill must paginate the GraphQL `files` connection using `pageInfo.endCursor`.
- The skill must surface `DISMISSED` state to the caller when querying viewed state, with a note that a new commit reset previously viewed files.

## Behavior

The agent resolves the PR node ID and file list in a single `gh pr view --json id,files` call. It then applies `markFileAsViewed` or `unmarkFileAsViewed` mutations per file. When marking all files, it iterates over all file paths from the file list. When checking state, it queries `files.nodes[].viewerViewedState` via GraphQL, paginating if `pageInfo.hasNextPage` is true.

## Error Handling

- **PR not found via GraphQL**: the PR was likely discovered via a fork; extract the real repo from the `url` field in `gh pr list --json url` and retry.
- **Path not in PR files**: the requested path does not appear in the PR diff. Surface to caller — do not attempt mutation.
- **Mutation failure on a specific file when marking all**: log the failure and continue marking remaining files. Report all failures at the end.

## Gotchas (Verified Against Live API)

- `gh pr list --repo {fork}` returns the upstream repo's PRs via REST. The `url` field shows the real repo. `gh pr view {number} --repo {fork}` fails with GraphQL error "Could not resolve to a PullRequest" because it looks in the fork, not the upstream.
- `gh pr view --json id` returns the deprecated base64 node ID (`MDExOl...`). Mutations still succeed with it but may include a `next_global_id` deprecation warning. No `gh pr view` flag returns the new `PR_kwDO...` format.
- `viewerViewedFiles` does not exist on the GraphQL `PullRequest` type. Use `files(first: N) { nodes { path viewerViewedState } }` to query file-level view state.
- File paths are case-sensitive and must match exactly what `gh pr view --json files[].path` returns.

## Constraints

- Does not post review verdicts or comments.
- Does not manage CODEOWNERS, branch protection, or merge rules.
- Viewed state is per-authenticated-user. Marking files as viewed only affects the user authenticated via `gh auth`.
