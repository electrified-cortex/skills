# issues — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through the full issue lifecycle using `gh issue`. Covers creating, triaging, editing, closing, and bulk-managing issues on a repository.

## Scope

Covers issue creation, listing with filters, viewing details, editing metadata (title, body, labels, assignees, milestone), commenting, closing, reopening, transferring, and bulk operations using JSON output piped to shell tools. Does not cover issue templates, project board placement, or linked PRs — those belong to other skills.

## Definitions

- **Lifecycle**: the full state progression of an issue from creation through triage, active work, and closure.
- **Metadata**: issue fields that classify and organize without being body content — labels, assignees, milestone, title.
- **Bulk operation**: a pipeline-based pattern that processes multiple issues in a single command chain rather than repeating individual commands.
- **Triage**: the process of reviewing new issues to assign metadata and determine action.

## Intent

The skill must enable an agent to:

- Create issues with correct metadata (title, body, labels, assignees, milestone)
- List issues with meaningful filters (state, assignee, label, milestone, search query)
- View an issue's full detail including comments
- Edit issue metadata without losing existing values
- Close or reopen issues, optionally with a closing comment
- Comment on issues
- Transfer an issue to another repository
- Perform bulk operations (e.g., close all stale issues matching a filter)

## Requirements

- The skill must demonstrate JSON output with `--json` and `--jq` for scriptable filtering — this is how agents extract structured data for decision-making.
- Bulk operations must pipeline `gh issue list --json` output through shell tools, not repeat individual commands.
- The skill must cover `@me` as an assignee filter for self-assignment patterns.
- Listing must cover all states: open, closed, and all.

## Behavior

The skill covers the full issue lifecycle: creating with metadata, listing with filters (state, assignee, label, milestone, search query), viewing details and comments, editing metadata without losing existing values, closing or reopening with an optional comment, commenting, transferring, and bulk operations. Structured output is obtained with `--json` and `--jq`. Bulk operations must pipeline `gh issue list --json` through shell tools — not repeat individual commands. The `@me` shorthand is used for self-assignment filters.

## Error Handling

If an edit command would clear an existing field unintentionally, the agent must read the current issue state before editing to preserve values not explicitly being changed. If a transfer target repository does not exist or the caller lacks write access, `gh` returns an error — the agent must surface this before retrying. If a bulk operation pipeline produces no results, the agent must confirm the filter criteria with the caller rather than treating zero results as success.

## Precedence Rules

Explicit filter flags (`--state`, `--assignee`, `--label`) take precedence over free-text search query when both are provided. Bulk pipeline operations take precedence over repeated individual commands for multi-issue edits.

## Constraints

- Does not cover GitHub issue forms or issue templates configuration.
- Does not manage milestones — only assigns issues to existing ones.
- Does not link issues to Projects v2 — that belongs to `projects`.
- Does not create branches from issues — that belongs to `pr`.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh issue list | Safe | Read-only |
| gh issue view | Safe | Read-only |
| gh issue create | Destructive | Operator approval required before execution |
| gh issue close | Destructive | Operator approval required before execution |
| gh issue reopen | Destructive | Operator approval required before execution |
| gh issue edit | Destructive | Operator approval required before execution |
| gh issue delete | Destructive | Operator approval required before execution |
| gh issue comment | Destructive | Operator approval required before execution |
| gh issue transfer | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
