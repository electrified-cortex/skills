---
name: actions
description: Trigger, monitor, manage GitHub Actions workflows, runs, secrets, variables via CLI. Triggers - run workflow, trigger GitHub Actions, check workflow status, manage workflows, github actions CLI.
---

# GH CLI Actions

Manage GitHub Actions workflows, runs, secrets, variables, and caches using the `gh` CLI.

## Workflows

List all workflows in the repository:

```bash
gh workflow list
```

Enable or disable a workflow by name or filename:

```bash
gh workflow enable ci.yml
gh workflow disable ci.yml
```

## Triggering a Workflow and Capturing the Run ID

Trigger a workflow manually and immediately capture the resulting run ID for monitoring:

```bash
gh workflow run ci.yml --ref main --raw-field version="1.0.0"
RUN_ID=$(gh run list --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

## Monitoring Runs

List recent runs filtered by workflow, branch, or status:

```bash
gh run list --workflow ci.yml --branch main --json databaseId,status,conclusion
```

Watch a run in real time until it completes:

```bash
gh run watch "$RUN_ID"
```

Check overall run health via statusCheckRollup:

```bash
gh run view "$RUN_ID" --json statusCheckRollup --jq '.statusCheckRollup[] | {name, status, conclusion}'
```

`conclusion`: `SUCCESS` = healthy; `FAILURE`/`CANCELLED` = unhealthy; `null` = still in progress. If `statusCheckRollup` returns an unexpected shape, do not assume success.

## Viewing Logs

View logs for failed steps in a run:

```bash
gh run view "$RUN_ID" --log-failed
```

View logs for a specific job by its ID:

```bash
gh run view "$RUN_ID" --job 987654321 --log
```

## Rerunning and Canceling

Rerun only the failed jobs in a run:

```bash
gh run rerun "$RUN_ID" --failed
```

Cancel a running workflow:

```bash
gh run cancel "$RUN_ID"
```

## Downloading Artifacts

Download all artifacts from a run to a directory:

```bash
gh run download "$RUN_ID" --dir ./artifacts
```

Download a specific artifact by name:

```bash
gh run download "$RUN_ID" --name build
```

## Secrets

Never pass secret values as command-line arguments. Pipe from stdin or use an environment variable:

```bash
echo "$SECRET_VALUE" | gh secret set MY_SECRET
gh secret set MY_SECRET --body "value"
gh secret list
gh secret delete MY_SECRET
```

To scope a secret to a specific environment rather than the repository, add `--env <environment-name>`:

```bash
echo "$SECRET_VALUE" | gh secret set MY_SECRET --env production
```

Note: `gh secret set` without a value source (`--body` or stdin pipe) will prompt interactively. Always prefer piping from a variable or using `--body` in automated contexts.

## Variables

Set, get, list, and delete variables. Use `--env` to scope to a specific environment:

```bash
gh variable set MY_VAR "value"
gh variable set MY_VAR "value" --env production
gh variable get MY_VAR
gh variable list
gh variable delete MY_VAR
```

## Caches

List caches for a branch and delete them individually or all at once:

```bash
gh cache list --branch main
gh cache delete "$CACHE_ID"
gh cache delete --all
```

## Scope Boundaries

This skill covers `gh run`, `gh workflow`, `gh secret`, `gh variable`, and `gh cache`. It does not cover writing workflow YAML, configuring self-hosted runners, or managing OIDC trust configurations.

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
