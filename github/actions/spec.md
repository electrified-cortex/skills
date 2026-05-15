# actions — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through GitHub Actions automation using `gh`. Covers triggering workflows, monitoring run status, downloading artifacts, and managing the secrets and variables that workflows depend on.

## Scope

Covers `gh run`, `gh workflow`, `gh cache`, `gh secret`, and `gh variable` subcommands. Includes listing, inspecting, triggering, watching, and canceling workflow runs; enabling and disabling workflows; managing action caches; and setting or deleting secrets and environment variables. Does not cover writing workflow YAML or configuring runners.

## Definitions

- **Workflow**: a YAML-defined automation process in `.github/workflows/` identified by filename and `name` field.
- **Run ID**: the unique integer identifier assigned to a single workflow execution; used to target log, artifact, and rerun operations.
- **Repository-level secret/variable**: a secret or variable scoped to the entire repository, accessible to all workflows.
- **Environment-level secret/variable**: a secret or variable scoped to a named deployment environment, overriding repo-level values for that environment.

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

## Behavior

The skill guides the agent through the full Actions operation lifecycle: listing and enabling workflows, triggering a run and capturing its run ID, monitoring run status in real time via `--watch`, viewing logs (full run or specific job), rerunning failed jobs, canceling live runs, downloading artifacts, and managing secrets and variables at repository or environment scope. Secret values must always be piped from stdin or an environment variable — never passed as command arguments.

## Error Handling

If a run fails, the agent must view logs for the specific failed job rather than the full run to isolate the cause. If a secret or variable operation targets an environment that does not exist, the `gh` CLI will return an error — the agent must surface this to the caller and confirm the environment name before retrying. If `--json statusCheckRollup` returns an unexpected shape, the agent must not assume success.

## Precedence Rules

Repository-level secrets and variables take precedence in scope resolution unless the environment name is explicitly specified. Monitoring a run ID captured at trigger time takes precedence over relisting runs to find the target run.

## Constraints

- Does not cover writing or editing workflow YAML files.
- Does not configure self-hosted runners or runner groups.
- Does not manage GitHub Actions permissions or OIDC trust configurations.
- Does not cover reusable workflow publishing or composite action authoring.

## Safety Classification

| Command | Class | Notes |
| --- | --- | --- |
| gh run list | Safe | Read-only |
| gh run view | Safe | Read-only |
| gh run watch | Safe | Read-only |
| gh run download | Safe | Read-only |
| gh run rerun | Destructive | Operator approval required before execution |
| gh run cancel | Destructive | Operator approval required before execution |
| gh workflow list | Safe | Read-only |
| gh workflow view | Safe | Read-only |
| gh workflow enable | Destructive | Operator approval required before execution |
| gh workflow disable | Destructive | Operator approval required before execution |
| gh workflow run | Destructive | Operator approval required before execution |
| gh cache list | Safe | Read-only |
| gh cache delete | Destructive | Operator approval required before execution |
| gh secret list | Safe | Read-only |
| gh secret set | Destructive | Operator approval required before execution |
| gh secret delete | Destructive | Operator approval required before execution |
| gh variable list | Safe | Read-only |
| gh variable get | Safe | Read-only |
| gh variable set | Destructive | Operator approval required before execution |
| gh variable delete | Destructive | Operator approval required before execution |

**Destructive operations require explicit operator authorization in the current session before the agent executes them.** Approval from another agent (e.g., Overseer confirming CI green) does not constitute operator authorization.
