# gh-cli-actions

Trigger, monitor, and manage GitHub Actions workflows, runs, secrets, and
variables using the `gh` CLI.

## When to Use

- Trigger a workflow manually or by event
- Watch a run in progress or check its status
- List workflows and recent runs
- Manage secrets and variables for a repo or environment

## Common Commands

```bash
# List workflows
gh workflow list

# Trigger a workflow
gh workflow run deploy.yml --ref main

# Watch a run live
gh run watch 12345678

# View run logs
gh run view 12345678 --log

# List recent runs
gh run list --workflow deploy.yml --limit 10

# Set a secret
gh secret set MY_SECRET --body "value"

# List secrets
gh secret list

# Set a variable
gh variable set MY_VAR --body "value"
```

## Notes

- Use `--repo owner/name` to target a repo other than the current directory's origin
- `gh run watch` streams live output and exits when the run completes
- Secrets are write-only via CLI; values cannot be read back

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-repos`](../gh-cli-repos/) — repo management
- [`gh-cli-api`](../gh-cli-api/) — advanced workflow triggers or GraphQL queries

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
