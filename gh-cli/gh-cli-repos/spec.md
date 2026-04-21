---
name: gh-cli-repos
description: Spec for the gh-cli-repos skill — intent, scope, and required behavior for managing GitHub repositories via the CLI.
---

# gh-cli-repos — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through repository lifecycle operations using `gh repo`. Covers creating, cloning, forking, syncing, editing, and deleting repositories from the command line.

## Scope

Covers all repository management operations: creation from scratch or template, cloning locally, forking upstream repos, syncing forks with upstream, editing repository metadata, and archiving or deleting repos. Does not cover per-file content operations, issues, PRs, or Actions — those belong to their respective domain skills.

## Intent

The skill must enable an agent to:

- Create new repositories with correct visibility, description, license, and feature flags
- Clone a repository to a local working directory
- Fork a repository and configure remotes correctly
- Sync a fork to stay current with its upstream
- Edit repository settings (description, homepage, visibility, feature flags)
- Rename, archive, or delete a repository when appropriate
- List repositories for a user or organization and filter results
- Set a default repository context for subsequent CLI commands

## Requirements

- The skill must cover both personal and organization-owned repositories.
- Fork operations must include guidance on configuring the upstream remote so the local clone stays linkable to the original.
- Sync operations must distinguish between syncing via `gh repo sync` and manual git fetch/merge flows.
- The skill must not assume a default visibility — agents must explicitly choose public or private.

## Behavior

The skill covers repository lifecycle operations via `gh repo`: creating repos (personal or organization-owned, from scratch or template), cloning to a local directory, forking with upstream remote configuration, syncing forks via `gh repo sync`, editing metadata (description, homepage, visibility, feature flags), renaming, archiving, deleting, listing with filters, and setting a default repo context. Visibility must always be specified explicitly — the skill must not assume a default.

## Error Handling

If a fork operation completes but the upstream remote is not configured, the agent must add the upstream remote manually before reporting success. If `gh repo sync` fails due to a diverged history, the agent must surface the conflict to the caller — it must not force-sync without explicit instruction. If a delete operation is requested, the agent must confirm the repository name with the caller before executing, as deletion is irreversible.

## Precedence Rules

`gh repo sync` takes precedence over manual git fetch/merge for fork synchronization unless the caller explicitly requests the manual flow. Organization ownership takes precedence — when creating under an org, the `--org` flag must be present; personal repos must not be assumed.

## Don'ts

- Does not manage repository content (files, branches, commits) — that is git, not `gh repo`.
- Does not cover repository secrets, deploy keys, or rulesets — those are out of scope for basic repo management.
- Does not cover GitHub Apps, webhooks, or repository integrations.
