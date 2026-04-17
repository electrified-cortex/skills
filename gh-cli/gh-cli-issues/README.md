# gh-cli-issues

Create, list, edit, close, comment on, and bulk-manage GitHub issues.

## When to Use

- Filing new issues from task descriptions or bug reports
- Querying open/closed issues by label, assignee, or milestone
- Updating issue metadata (labels, assignees, milestone, title, body)
- Adding comments to existing issues
- Bulk triage: applying labels or closing batches of issues

## Common Commands

```bash
# Create an issue
gh issue create --title "Fix login timeout" --body "Steps to reproduce..." --label bug

# List open issues with a label
gh issue list --state open --label bug

# List all issues (open and closed)
gh issue list --state all

# View an issue
gh issue view 123

# Edit an issue
gh issue edit 123 --add-label triage --add-assignee username

# Close an issue
gh issue close 123 --comment "Fixed in #456"

# Comment on an issue
gh issue comment 123 --body "Investigating now."

# Reopen an issue
gh issue reopen 123
```

## Notes

- `--repo owner/name` targets a specific repo when not in a local clone
- Multiple labels can be set with comma-separated values or repeated flags
- `gh issue list` defaults to open issues; add `--state all` for full history

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-prs`](../gh-cli-prs/) — pull request lifecycle
- [`gh-cli-projects`](../gh-cli-projects/) — link issues to Projects v2 boards

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
