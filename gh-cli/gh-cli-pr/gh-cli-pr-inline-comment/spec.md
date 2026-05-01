---
name: gh-cli-pr-inline-comments
description: Spec for posting, editing, and deleting inline code review comments on pull request diffs via GitHub CLI.
---

# gh-cli-pr-inline-comments — Spec

## Purpose

Guide an agent through creating, editing, and deleting inline review comments anchored to specific lines in a pull request diff.

## Scope

REST API endpoint `/repos/{owner}/{repo}/pulls/{pull_number}/comments` via `gh api`. Does not cover general PR conversation comments or review submissions.

## Definitions

- **Inline review comment**: a comment anchored to a specific file path and line number in the PR diff; visible in the "Files changed" tab.
- **General PR comment**: a top-level conversation comment on the PR (not file-anchored); covered by `gh-cli-pr-comments`.
- **commit_id**: the SHA of a commit in the PR branch; required for inline comments. Must be fetched at execution time via `headRefOid`.
- **side**: `RIGHT` = new/added version of the file (additions and context); `LEFT` = deleted/old version (deletions only).
- **line**: absolute line number in the file. Use `line`, never the deprecated `position` (raw diff-patch offset).
- **Multi-line comment**: an inline comment spanning a range; requires `start_line`, `start_side`, `line`, and `side`.

## Requirements

The skill must enable an agent to:

- Fetch the current commit SHA from the PR head (`headRefOid`)
- Verify the target file and line appear in the PR diff before posting
- Post a single-line inline comment with `body`, `commit_id`, `path`, `line`, `side`
- Post a multi-line inline comment spanning a range
- Edit an existing inline comment by `comment_id`
- Delete an existing inline comment by `comment_id`
- List all inline comments on a PR
- Diagnose and recover from 422 errors (line not in diff, wrong side, stale SHA)

## Behavior

Before posting, the agent must: (1) fetch `commit_id` from `gh pr view --json headRefOid`, (2) verify the file is in `gh pr diff --name-only`, (3) confirm the target line is visible in `gh pr diff -- {path}`. Only then post via REST API with `line` and `side`. On 422, re-inspect the diff and correct the parameters.

## Error Handling

| Error | Cause | Recovery |
| --- | --- | --- |
| 422 `line is not part of the pull request` | Line not in diff; wrong `side`; stale `commit_id` | Re-fetch SHA; view diff; correct `line`/`side` |
| 422 `position` rejected | Deprecated `position` parameter used | Replace with `line` + `side` |
| 404 | Wrong repo, PR number, or comment ID | Verify owner/repo and PR exists |
| 403 | Insufficient write access | Verify auth; check repo permissions |

The agent must surface 422 errors to the caller with the diagnosed cause, not silently retry.

## Precedence Rules

Step order is fixed: fetch SHA → verify diff → post comment. The agent must not skip the diff verification step even if the caller claims the line is correct. A stale commit SHA is a common source of 422 errors; always fetch fresh.

## Constraints

- Does not cover general PR conversation comments → `gh-cli-pr-comments`
- Does not cover review submission verdicts (approve/request-changes) → `gh-cli-pr-review`
- Does not cover resolving review threads → `gh-cli-api` (GraphQL `resolveReviewThread`)
- `position` parameter is deprecated; never use it
- All destructive operations require explicit operator authorization in the current session

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| POST inline comment | Destructive | Operator approval required before execution |
| PATCH inline comment | Destructive | Operator approval required before execution |
| DELETE inline comment | Destructive | Operator approval required before execution |
| GET/list inline comments | Read-only | Safe to execute without approval |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.**
