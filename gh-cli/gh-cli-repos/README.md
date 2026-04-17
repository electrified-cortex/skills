# gh-cli-repos

Create, clone, fork, sync, edit, and delete GitHub repositories.

## When to Use

- Creating a new repo (public, private, or internal)
- Cloning a repo locally
- Forking a repo and setting up the upstream remote
- Syncing a fork with upstream changes
- Editing repo metadata (description, homepage, visibility, topics)

## Common Commands

```bash
# Create a new public repo and clone it locally
gh repo create owner/my-new-repo --public --clone

# Create a private repo from the current directory
gh repo create my-new-repo --private --source=. --push

# Clone a repo
gh repo clone owner/repo

# Fork a repo and set up upstream remote
gh repo fork owner/repo --clone --remote-name upstream

# Sync a fork's default branch with upstream
gh repo sync

# View repo details
gh repo view owner/repo

# Edit repo metadata
gh repo edit owner/repo --description "New description" --homepage "https://example.com"

# Archive a repo
gh repo archive owner/repo

# Delete a repo (irreversible)
gh repo delete owner/repo --yes
```

## Notes

- `--clone` after `create` or `fork` sets up the local directory and remotes automatically
- `gh repo sync` requires the local clone to be on the default branch
- `gh repo delete` is permanent; confirm the repo name carefully
- Use `--visibility private|public|internal` to control access

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-setup`](../gh-cli-setup/) — authenticate before repo operations
- [`gh-cli-releases`](../gh-cli-releases/) — publish releases from a repo

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
