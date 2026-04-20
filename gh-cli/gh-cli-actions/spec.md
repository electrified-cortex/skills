---
name: gh-cli-actions
description: Spec for the gh-cli-actions skill — intent, scope, and required behavior for managing GitHub Actions workflows, runs, secrets, and variables via the CLI.
---

# gh-cli-actions — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through GitHub Actions automation using `gh`. Covers triggering workflows, monitoring run status, downloading artifacts, and managing the secrets and variables that workflows depend on.

## Scope

Covers `gh run`, `gh workflow`, `gh cache`, `gh secret`, and `gh variable` subcommands. Includes listing, inspecting, triggering, watching, and canceling workflow runs; enabling and disabling workflows; managing action caches; and setting or deleting secrets and environment variables. Does not cover writing workflow YAML or configuring runners.

## Intent

The skill must enable an agent to:

- List workflows in a repository and identify which are enabled
- Trigger a workflow manually, including passing input parameters
- List recent workflow runs filtered by workflow, branch, or status
- Watch a running workflow in real time and wait for completion
- View logs for a failed run to diagnose the cause
- Rerun a failed workflow or a specific failed job
- Cancel a running workflow
- Download artifacts produced by a completed run
- Manage repository and environment secrets (set, list, delete)
- Manage repository and environment variables (set, get, list, delete)
- List and delete action caches

## Requirements

- The skill must demonstrate how to trigger a workflow and capture its run ID for subsequent monitoring.
- Log viewing must distinguish between viewing the full run log and targeting a specific job.
- Secret-setting guidance must show how to pipe a value from stdin or an environment variable — never hard-coding the secret value in a command argument.
- The skill must distinguish between repository-level and environment-level secrets and variables.
- The skill must show how to interpret `--json statusCheckRollup` output to determine overall run health.

## Don'ts

- Does not cover writing or editing workflow YAML files.
- Does not configure self-hosted runners or runner groups.
- Does not manage GitHub Actions permissions or OIDC trust configurations.
- Does not cover reusable workflow publishing or composite action authoring.
