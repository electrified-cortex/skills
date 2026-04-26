# gh-cli-prs-comments — Spec

## Purpose

Guide an agent through adding, editing, and deleting comments on a pull request.

## Scope

`gh pr comment`. Does not cover review submissions (approve/request changes) — see `gh-cli-prs-review`.

## Definitions

- **General PR comment**: a top-level comment on a pull request with no approval verdict; distinct from review-level comments.
- **Comment ID**: the unique integer identifier for a specific comment; required for edit and delete operations.
- **Review thread**: a comment thread tied to a specific code line or review submission; not covered by this skill — use `gh-cli-api` for resolution.

## Requirements

The skill must enable an agent to:

- Add a general comment to a PR
- Edit an existing comment by ID
- Delete a comment by ID

## Behavior

The skill covers general PR comments via `gh pr comment`: adding a new comment, editing an existing comment by its ID, and deleting a comment by its ID. Review-level comments (tied to approve/request-changes verdicts) are not handled here. Resolving review threads has no `gh pr` command — the agent must redirect to `gh-cli-api` for the `resolveReviewThread` GraphQL mutation.

## Error Handling

If an edit or delete operation is attempted without a comment ID, it will fail — the agent must obtain the comment ID via the paginated API (`gh api --paginate /repos/{owner}/{repo}/issues/{issue_number}/comments`) before proceeding. Do not use `gh pr view --comments` for this purpose — it truncates and may miss later pages. If a comment ID does not exist on the target PR, `gh` returns an error — the agent must surface this to the caller.

## Precedence Rules

N/A — add, edit, and delete are discrete non-overlapping operations; no resolution path conflicts exist within this skill.

## Constraints

- Does not cover review-level comments (those with approve/request-changes verdicts).
- `gh pr view --comments` truncates at one page — use `gh api --paginate` for exhaustive listing. See the Viewing Comments section.
