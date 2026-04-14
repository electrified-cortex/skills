---
name: gh-cli-api
description: Spec for the gh-cli-api skill — intent, scope, and required behavior for making direct GitHub API calls and GraphQL queries via the CLI.
---

# gh-cli-api — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through direct GitHub API access using `gh api`. Covers REST and GraphQL queries, pagination, response shaping, and scripting patterns that go beyond what the higher-level `gh` subcommands expose.

## Scope

Covers `gh api` for REST endpoint access and `gh api graphql` for GraphQL queries. Includes making authenticated requests, sending fields and bodies, handling pagination, filtering responses with `--jq`, and using `--template` for Go template formatting. Does not cover the higher-level `gh` subcommands — those belong to the domain skills. Does not cover OAuth app or GitHub App development.

## Intent

The skill must enable an agent to:

- Make GET, POST, PATCH, DELETE requests to any GitHub REST endpoint
- Query GitHub's GraphQL API with inline or file-based query strings
- Pass fields and JSON bodies to mutation endpoints
- Page through full result sets using `--paginate`
- Filter and reshape responses using `--jq` expressions
- Target GitHub Enterprise endpoints using `--hostname`
- Use the API skill as an escape hatch when a specific operation has no dedicated `gh` subcommand

## Requirements

- The skill must make clear when `gh api` is the right choice versus using a higher-level subcommand — API access should be a deliberate choice for operations without CLI coverage, not a default.
- `--jq` usage must be demonstrated for both simple field extraction and complex filtering/transformation.
- GraphQL examples must cover both queries (read) and mutations (write).
- The skill must show how to safely pass secrets or tokens to API calls without leaking them into command history.
- Pagination behavior must be explained: `--paginate` makes multiple requests automatically; the agent must understand this can be slow for large datasets.

## Non-Goals

- Does not cover creating or managing GitHub Apps, OAuth Apps, or personal access tokens.
- Does not replace the domain-specific skills — `gh api` is for gaps, not everyday use.
- Does not cover GitHub Copilot API or model-specific endpoints.
- Does not cover webhook creation or management via the API.
