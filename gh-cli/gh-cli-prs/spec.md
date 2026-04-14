---
name: gh-cli-prs
description: Entry point for the gh-cli-prs skill suite — pull request lifecycle via the GitHub CLI.
---

# gh-cli-prs

Index skill for pull request management. Each stage of the PR lifecycle has its own sub-skill.

## Sub-skills

- **Creating PRs** — `gh-cli-prs/gh-cli-prs-create/spec.md`
- **Reviewing PRs** — `gh-cli-prs/gh-cli-prs-review/spec.md`
- **Commenting on PRs** — `gh-cli-prs/gh-cli-prs-comments/spec.md`
- **Merging PRs** — `gh-cli-prs/gh-cli-prs-merge/spec.md`

## Scope

Covers `gh pr` subcommands only. Does not touch git operations, branch protection rules, or CODEOWNERS.
