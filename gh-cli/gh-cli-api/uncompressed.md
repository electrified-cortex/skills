---
name: gh-cli-api
description: Make authenticated REST and GraphQL calls to the GitHub API via the CLI. Use when no dedicated gh subcommand covers the operation.
---

# GH CLI API

## When to Use

Use `gh api` as an escape hatch — not as a default. Prefer domain-specific skills (issues, prs, releases, etc.) when they cover the operation. Use this skill for:

- Operations with no dedicated `gh` subcommand
- Complex GraphQL queries or mutations
- Bulk or scripted API interactions

## REST — Reading Data

Fetch a resource with a GET request:

```bash
gh api /repos/owner/repo
gh api /user --jq '.login'
```

## REST — Writing Data

Create or update resources with POST or PATCH:

```bash
gh api --method POST /repos/owner/repo/issues \
  --field title="title" --field body="body"

gh api --method PATCH /repos/owner/repo/issues/123 \
  --field state="closed"
```

## Pagination

Retrieve all pages of a paginated result. Note: this makes multiple requests and can be slow on large datasets:

```bash
gh api /user/repos --paginate --jq '.[].name'
```

## Filtering with jq

Extract a single field:

```bash
gh api /repos/owner/repo --jq '.stargazers_count'
```

Filter and transform a collection:

```bash
gh api /repos/owner/repo/issues --jq '[.[] | select(.state=="open") | {number, title}]'
```

## GraphQL — Queries

Run a GraphQL query inline:

```bash
gh api graphql -f query='
  { viewer { login repositories(first: 5) { nodes { name } } } }'
```

## GraphQL — Mutations

Run a GraphQL mutation (for example, resolving a review thread):

```bash
gh api graphql -f query='
  mutation { resolveReviewThread(input: {threadId: "THREAD_ID"}) { thread { isResolved } } }'
```

## GitHub Enterprise

Add `--hostname enterprise.internal` to any call targeting a GitHub Enterprise instance:

```bash
gh api --hostname enterprise.internal /repos/owner/repo
```

## Token Safety

Never pass tokens as command-line arguments or inline environment variables — they leak to shell history. Instead:

- Use `gh auth login` to authenticate interactively before running commands.
- Set `GH_TOKEN` in your environment configuration (shell profile or CI secret) before invoking commands.

## Scope Boundaries

This skill covers `gh api` for REST and `gh api graphql` for GraphQL. It does not replace domain skills, manage GitHub Apps or OAuth Apps, or cover webhook configuration.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh api GET | Safe | Read-only |
| gh api POST | Destructive | Operator approval required before execution |
| gh api PATCH | Destructive | Operator approval required before execution |
| gh api DELETE | Destructive | Operator approval required before execution |
| gh api graphql (query) | Safe | Read-only |
| gh api graphql (mutation) | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
