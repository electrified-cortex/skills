# gh-cli-projects

Create and manage GitHub Projects v2 boards, items, and fields.

## When to Use

- Creating a new Projects v2 board for a repo or organization
- Adding issues or PRs to a project board
- Creating custom fields (status, priority, date, etc.)
- Listing projects to resolve the project number before other operations

## Important: Resolve Project Number First

Most `gh project` subcommands require a numeric project number, not a name.
Always run `gh project list` first to get the right number.

```bash
# List projects (owner can be user or org)
gh project list --owner username

# View project details
gh project view 5 --owner username

# Add an issue or PR to a project
gh project item-add 5 --owner username --url https://github.com/owner/repo/issues/42

# List items in a project
gh project item-list 5 --owner username

# Create a custom field
gh project field-create 5 --owner username --name Priority \
  --data-type SINGLE_SELECT --single-select-options "Low,Medium,High"

# Create a new project
gh project create --owner username --title "Sprint 7"
```

## Notes

- Projects v2 is the current GitHub Projects API; Projects v1 (classic) is deprecated
- `--owner` accepts usernames or organization names
- GraphQL via `gh-cli-api` can do advanced project queries if the CLI subcommands fall short

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-issues`](../gh-cli-issues/) — issues that link to project boards
- [`gh-cli-prs`](../gh-cli-prs/) — PRs that link to project boards

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
