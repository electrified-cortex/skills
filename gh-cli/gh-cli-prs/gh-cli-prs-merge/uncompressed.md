# GH CLI PR Merge

Finalize pull requests using `gh pr merge`, `gh pr update-branch`, and `gh pr revert`. Covers merging, keeping a branch current, reverting a merged PR, and closing without merging.

## Merging a Pull Request

Choose the merge strategy that matches the repository's policy:

**Merge commit** — preserves full commit history:

```bash
gh pr merge 123 --merge --delete-branch
```

**Squash** — combines all commits into one:

```bash
gh pr merge 123 --squash --delete-branch
```

**Rebase** — replays commits on top of the base branch:

```bash
gh pr merge 123 --rebase
```

Use `--delete-branch` to remove the source branch after a successful merge.

## Updating a Branch That Is Behind

When the PR branch has fallen behind its base branch, update it:

```bash
gh pr update-branch 123
```

If there are conflicts and you need to force the update:

```bash
gh pr update-branch 123 --force
```

Use `--force` with care — it may overwrite local changes.

## Reverting a Merged PR

Open a new revert PR that undoes the changes from a previously merged PR:

```bash
gh pr revert 123 --branch revert-pr-123
```

## Closing Without Merging

Close a PR without merging it, with an optional explanation comment:

```bash
gh pr close 123 --comment "Superseded by #456"
```

## Checking Readiness Before Merge

Check CI status before merging using `gh pr checks 123`. That command is covered by the `gh-cli-prs` inspection commands, not this sub-skill.

## Scope Boundaries

This skill covers `gh pr merge`, `gh pr update-branch`, `gh pr revert`, and `gh pr close`. It does not cover reviewing a PR before merge (see `gh-cli-prs-review`) or git operations after merge such as pulling the updated base locally.
