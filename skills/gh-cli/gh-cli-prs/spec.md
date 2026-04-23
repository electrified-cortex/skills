# gh-cli-prs — Spec

## Purpose

Define the intent and scope of a top-level PR router skill that handles common pull request inspection and dispatches write operations to the correct sub-skill. Covers the full pull request lifecycle across four sub-skills: create, review, comments, and merge.

## Scope

Covers all `gh pr` subcommands. Common inspection commands (list, view, diff, checks, status) are handled directly by this skill. Write operations are delegated to sub-skills. Does not cover git operations, branch protection rules, or CODEOWNERS.

## Definitions

- **Inspection command**: a read-only `gh pr` command that retrieves PR state without modifying it (list, view, diff, checks, status).
- **Write operation**: any `gh pr` command that mutates PR state; always delegated to a sub-skill.
- **Sub-skill routing**: the explicit dispatch of a write operation to the named sub-skill responsible for that operation class.

## Intent

The skill must enable an agent to:

- List pull requests filtered by state, author, label, or base branch
- View a PR's details and comment thread
- Show the diff for a PR
- Watch CI checks on a PR until they complete
- Check the current user's PR status summary
- Identify which sub-skill handles a given write operation and dispatch to it

## Sub-skills

| Sub-skill | Handles |
| --- | --- |
| gh-cli-prs-create/ | Opening new PRs, converting drafts to ready |
| gh-cli-prs-review/ | Approving, requesting changes, dismissing reviews |
| gh-cli-prs-comments/ | Adding, editing, deleting general PR comments |
| gh-cli-prs-merge/ | Merging, updating branch, reverting, closing |

## Requirements

- The skill must include inspection commands that work at any stage of the PR lifecycle.
- Routing to sub-skills must be explicit — the agent must know which sub-skill to use for each write operation.
- The skill must use `--json` and `--jq` for structured output in listing commands.
- `gh pr checks --watch` must be demonstrated as the correct pattern for blocking until CI completes.

## Behavior

The skill handles PR inspection directly (list, view, diff, checks, status) using `--json` and `--jq` for structured output. Write operations are not executed by this skill — they are dispatched to the correct sub-skill. `gh pr checks --watch` is the required pattern for blocking until CI completes. When a write operation is requested, the skill identifies the correct sub-skill from the Sub-skills table and dispatches to it.

## Error Handling

If `gh pr checks --watch` exits with a failure, the agent must surface which checks failed rather than reporting only the overall status. If a task could route to more than one sub-skill, the agent must ask the caller to clarify the intended operation before dispatching. If the caller requests a git operation (push, checkout), the agent must redirect them — this skill does not cover git.

## Precedence Rules

Inspection commands are handled directly by this skill; write operations are always delegated to sub-skills. Sub-skill routing table entries are authoritative — the agent must not infer routing from the operation name alone.

## Constraints

- Does not cover git operations (push, checkout, fetch) performed locally.
- Does not manage branch protection rules or required review policies.
- Does not configure CODEOWNERS files.
- Does not cover GitHub Actions triggered by PR events — see `gh-cli-actions`.
