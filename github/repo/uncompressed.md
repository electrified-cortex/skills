---
name: repo
description: Create, clone, fork, sync, edit, delete GitHub repositories via CLI. Triggers - create repo, clone repository, fork repo, github repo operations, manage repositories.
---

# GH CLI Repos

Manage GitHub repositories using the `gh repo` subcommand. Covers creating, cloning, forking, syncing, editing metadata, and deleting repositories.

## Creating a Repository

Always specify visibility explicitly — no default is assumed:

```bash
gh repo create owner/name --public --description "desc" --clone
gh repo create owner/name --private --gitignore node --license mit
```

## Cloning

Clone a repository to a local directory (optional):

```bash
gh repo clone owner/repo [dir]
```

## Forking

Fork a repository and configure the upstream remote:

```bash
gh repo fork owner/repo --clone --remote-name upstream
```

The `--remote-name upstream` flag sets the original repo as the `upstream` remote in the cloned fork.

## Syncing a Fork

Sync the current fork with its upstream:

```bash
gh repo sync [--branch branch] [--force]
```

Use `--force` with care — it overwrites local changes to match upstream.

## Editing Repository Metadata

Update description, homepage, visibility, or default branch:

```bash
gh repo edit --description "new" --homepage https://example.com
gh repo edit --visibility private
gh repo edit --default-branch main
```

## Rename, Archive, Delete

Rename the current repository:

```bash
gh repo rename new-name
```

Archive or unarchive:

```bash
gh repo archive
gh repo unarchive
```

Delete a repository permanently:

```bash
gh repo delete owner/repo --yes
```

## Listing Repositories

List repositories for a user or organization and extract names:

```bash
gh repo list [owner] --limit 50 --json name,visibility,owner --jq '.[].name'
```

## Setting a Default Repository

Set a default repository for the current directory so subsequent commands do not need `--repo`:

```bash
gh repo set-default owner/repo
gh repo set-default --unset
```

## Scope Boundaries

This skill covers `gh repo` only. It does not manage repository content (files, branches, commits — those are git operations), repository secrets or deploy keys, GitHub Apps, webhooks, or repository integrations.

Related: `actions` (Actions configuration), `api` (advanced repo operations via API)

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh repo view | Safe | Read-only |
| gh repo list | Safe | Read-only |
| gh repo clone | Safe | Local only |
| gh repo create | Destructive | Operator approval required before execution |
| gh repo delete | Destructive | Operator approval required before execution |
| gh repo archive | Destructive | Operator approval required before execution |
| gh repo rename | Destructive | Operator approval required before execution |
| gh repo fork | Destructive | Operator approval required before execution |
| gh repo sync | Destructive | Operator approval required before execution |
| gh repo edit | Destructive | Operator approval required before execution |
| gh repo set-default | Safe | Local config only |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
