# gh-cli-prs

Router for the pull request lifecycle. Handles common PR inspection and
dispatches to sub-skills for create, review, comments, and merge.

## When to Use

Use this skill for PR-related tasks when you want routing handled automatically.
For inspection tasks (list, view, diff, checks), this skill handles them directly.
For write operations, it dispatches to the appropriate sub-skill.

## Common Inspection Commands

```bash
# List open PRs
gh pr list

# View a PR
gh pr view 123

# Show the diff
gh pr diff 123

# Check CI status
gh pr checks 123

# List PRs for a specific branch
gh pr list --head feature/my-branch
```

## Sub-skills

| Sub-skill | Handles |
| --- | --- |
| [`gh-cli-prs-create`](gh-cli-prs-create/) | Open new PRs, convert drafts to ready |
| [`gh-cli-prs-review`](gh-cli-prs-review/) | Approve, request changes, dismiss reviews |
| [`gh-cli-prs-comments`](gh-cli-prs-comments/) | Add, edit, delete PR comments |
| [`gh-cli-prs-merge`](gh-cli-prs-merge/) | Merge, update branch, revert, close |

## Notes

- Use `--repo owner/name` when not inside a local clone of the target repo
- `gh pr checks` is useful for confirming CI passes before merge

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-prs-create`](gh-cli-prs-create/) — opening new pull requests
- [`gh-cli-prs-review`](gh-cli-prs-review/) — approving or requesting changes
- [`gh-cli-prs-comments`](gh-cli-prs-comments/) — adding, editing, deleting comments
- [`gh-cli-prs-merge`](gh-cli-prs-merge/) — merging, closing, or reverting PRs

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
