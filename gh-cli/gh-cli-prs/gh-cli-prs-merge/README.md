# gh-cli-prs-merge

Merge, update, revert, and close pull requests.

## When to Use

- Merging an approved, CI-passing PR
- Keeping a PR branch up to date with its base
- Reverting a merged PR
- Closing a PR without merging

## Common Commands

```bash
# Merge with squash and delete the branch
gh pr merge 123 --squash --delete-branch

# Merge commit (preserves all commits)
gh pr merge 123 --merge --delete-branch

# Rebase merge
gh pr merge 123 --rebase --delete-branch

# Update PR branch with latest from base
gh pr update-branch 123

# Revert a merged PR (creates a new revert PR)
gh pr revert 123

# Close without merging
gh pr close 123

# Close with a comment
gh pr close 123 --comment "Superseded by #456"
```

## Merge Strategy Guide

| Strategy | When to use |
| --- | --- |
| `--squash` | Feature branches; keeps main history clean |
| `--merge` | Merge commits; preserves full branch history |
| `--rebase` | Linear history preferred; no merge commit |

## Notes

- Always verify CI passes before merging: `gh pr checks 123`
- `--delete-branch` removes the remote branch after merge; recommended for
  short-lived feature branches
- `gh pr revert` creates a new PR; it does not immediately push a revert commit

## Related Skills

- [`gh-cli-prs`](../) — PR lifecycle router
- [`gh-cli-prs-create`](../gh-cli-prs-create/) — open PRs
- [`gh-cli-prs-review`](../gh-cli-prs-review/) — approve before merging

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../../LICENSE) in the repository root.
