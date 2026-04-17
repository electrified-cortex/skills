# gh-cli-prs-review

Approve pull requests, request changes, and dismiss existing reviews.

## When to Use

- Submitting a formal approval on a PR
- Requesting changes with feedback
- Dismissing a stale or outdated review

For general comments that are not formal reviews, use
[`gh-cli-prs-comments`](../gh-cli-prs-comments/) instead.

## Common Commands

```bash
# Approve a PR
gh pr review 123 --approve --body "LGTM, CI passing."

# Request changes
gh pr review 123 --request-changes --body "Please add tests for the edge case in utils.ts."

# Comment without a decision (no approve/reject)
gh pr review 123 --comment --body "Left some inline notes, not blocking."

# Dismiss an existing review
gh pr review 123 --dismiss --body "Addressed in latest commit."
```

## Notes

- `--body` is required when using `--request-changes` or `--dismiss`
- A user cannot approve their own PR; GitHub enforces this server-side
- Dismissing a review does not remove the review from history — it marks it as dismissed
- To see existing reviews: `gh pr view 123 --json reviews`

## Related Skills

- [`gh-cli-prs`](../) — PR lifecycle router
- [`gh-cli-prs-comments`](../gh-cli-prs-comments/) — non-review comments
- [`gh-cli-api`](../../gh-cli-api/) — inline code review threads via raw API

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../../LICENSE) in the repository root.
