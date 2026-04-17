# gh-cli-prs-comments

Add, edit, and delete comments on pull requests.

## When to Use

- Posting a comment on a PR (status update, question, note for reviewers)
- Editing a previously posted comment
- Deleting a comment that is no longer relevant

For review-level feedback (approve, request changes), use
[`gh-cli-prs-review`](../gh-cli-prs-review/) instead.

## Common Commands

```bash
# Add a comment
gh pr comment 123 --body "Looks good, just waiting on CI."

# Add a comment from a file
gh pr comment 123 --body-file comment.md
```

## Getting Comment IDs

Comment IDs are not shown by default in `gh pr view`. Retrieve them via the API:

```bash
gh api /repos/owner/repo/issues/123/comments --jq '.[].id'
```

## Editing and Deleting Comments

The `gh pr comment` command does not have `--edit` or `--delete` flags. Use the
GitHub API directly:

```bash
# Edit a comment
gh api --method PATCH /repos/OWNER/REPO/issues/comments/COMMENT_ID \
  --field body="Updated text."

# Delete a comment
gh api --method DELETE /repos/OWNER/REPO/issues/comments/COMMENT_ID
```

Replace `OWNER`, `REPO`, and `COMMENT_ID` with the appropriate values. Use the
"Getting Comment IDs" section above to find the numeric comment ID.

## Notes

- `--body` accepts inline text; `--body-file` reads from a file path
- Comments posted here are general PR comments, not inline code review comments
- Inline review comments require the GitHub API directly via `gh-cli-api`

## Related Skills

- [`gh-cli-prs`](../) — PR lifecycle router
- [`gh-cli-prs-review`](../gh-cli-prs-review/) — formal reviews (approve/request changes)
- [`gh-cli-api`](../../gh-cli-api/) — inline code review comments via raw API

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../../LICENSE) in the repository root.
