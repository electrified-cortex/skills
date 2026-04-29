---
name: gh-cli-prs-review
description: Spec for reviewing pull requests via the GitHub CLI.
---

# gh-cli-prs-review — Spec

## Purpose

Guide an agent through performing, editing, and dismissing pull request reviews.

## Scope

`gh pr review`. Does not cover inline comments or general (non-review) PR comments — see `gh-cli-prs-comments`.

## Definitions

- **Approve review**: a review verdict that marks the PR as approved by the reviewer.
- **Request changes review**: a review verdict that blocks merge until the reviewer dismisses or changes their verdict; requires a body explaining what needs fixing.
- **Comment-only review**: a review submitted with no approve/reject verdict — informational only.
- **Dismiss**: the act of removing a previously submitted review verdict, replacing it with no verdict.
- **Review ID**: the unique identifier of a submitted review, required by `gh pr review --dismiss`.

## Requirements

The skill must enable an agent to:

- Approve a PR with an optional body
- Request changes with a required body explaining what needs fixing
- Submit a comment-only review without a verdict
- Dismiss a previous review

## Behavior

The skill covers four review operations via `gh pr review`: approve (with optional body), request changes (with required body), submit a comment-only review (no verdict), and dismiss a previous review. Approving and comment-only reviews may omit a body. Requesting changes must always include a body explaining what needs to be fixed.

## Error Handling

If a request-changes review is submitted without a body, `gh` will require one — the agent must prompt the caller for the body before submitting. If a dismiss operation targets a review that does not exist or belongs to a different user, `gh` will return an error — the agent must surface this.

## Precedence Rules

N/A — each review operation is a discrete single command; there are no competing execution paths within this skill.

## Constraints

- Does not cover requesting reviewers — that belongs to `gh-cli-prs-create` (at creation) or the `gh pr edit --add-reviewer` path.
- Does not cover resolving review threads — see `gh-cli-api` for the GraphQL mutation.
- Does not cover inline comments or general PR comments — see `gh-cli-prs-comments`.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh pr review --approve | Destructive | Operator approval required before execution |
| gh pr review --request-changes | Destructive | Operator approval required before execution |
| gh pr review --comment | Destructive | Operator approval required before execution |
| gh pr review --dismiss | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
