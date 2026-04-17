# gh-cli-api

Direct REST and GraphQL access to the GitHub API. Use this skill when no
dedicated `gh-cli-*` sub-skill covers the operation you need.

## When to Use

- Querying endpoints not wrapped by other `gh` commands
- Batch or paginated data retrieval
- GraphQL queries for complex data shapes
- Any operation that requires raw API access

If a dedicated sub-skill exists (issues, PRs, releases, etc.), prefer that
instead — it has guardrails and common-case shortcuts.

## Common Commands

```bash
# GET request (REST)
gh api /repos/owner/repo/topics

# POST request
gh api --method POST /repos/owner/repo/labels \
  --field name="bug" --field color="d73a4a"

# Paginate through all results
gh api --paginate /repos/owner/repo/issues

# GraphQL query
gh api graphql -f query='
  query {
    repository(owner: "owner", name: "repo") {
      issues(first: 10, states: OPEN) {
        nodes { number title }
      }
    }
  }
'

# Pipe to jq for filtering
gh api /repos/owner/repo/releases | jq '.[0].tag_name'
```

## Notes

- Use `--jq` for inline filtering instead of piping to `jq` where possible
- Use `--template` for Go-template formatted output
- Pagination returns all pages concatenated; handle large result sets carefully
- Authentication uses the current `gh auth` session

## Related Skills

- [`gh-cli`](../) — top-level router
- All other `gh-cli-*` sub-skills — check these first before using raw API

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
