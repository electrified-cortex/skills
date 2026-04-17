# gh-cli-prs-create

Open pull requests, create drafts, and convert drafts to ready-for-review.

## When to Use

- Opening a new PR from a feature branch
- Creating a draft PR to signal work-in-progress
- Converting an existing draft PR to ready-for-review
- Checking whether a PR already exists before creating one

## Workflow

Always check for an existing PR before creating a new one to avoid duplicates:

```bash
# Check for existing PR on this branch
gh pr list --head feature/my-branch
```

Then create if none exists:

```bash
# Create a PR
gh pr create --title "Add login timeout" --body "Fixes #42" --base main

# Create a draft PR
gh pr create --title "WIP: login timeout" --body "Draft — not ready yet" \
  --base main --draft

# Create with reviewer and label
gh pr create --title "Add login timeout" --body "Fixes #42" \
  --base main --reviewer alice --label enhancement

# Convert draft to ready
gh pr ready 123
```

## Notes

- `--base` defaults to the repo's default branch; set explicitly when targeting
  a non-default base
- `--body-file` reads the PR description from a file
- `--fill` populates title and body from commits (useful for single-commit PRs)
- GitHub will reject creation if a PR already exists for the same head/base pair

## Related Skills

- [`gh-cli-prs`](../) — PR lifecycle router
- [`gh-cli-prs-merge`](../gh-cli-prs-merge/) — merge the PR once approved
- [`gh-cli-issues`](../../gh-cli-issues/) — linking issues to PRs

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../../LICENSE) in the repository root.
