---
name: gh-cli
description: GitHub CLI operations — routes to domain-specific sub-skills via dispatch.
---

# GH CLI Router

Routes any GitHub CLI task to the correct domain sub-skill. Does not run `gh` commands itself.

## Input

Natural language task describing a GitHub CLI operation. Optionally includes: domain hint, target repo, PR number, or other context.

## Output

Result from the dispatched domain sub-skill.

## Dispatch

Read and follow `instructions.txt` (in this directory).

## Related

`gh-cli-actions`, `gh-cli-api`, `gh-cli-issues`, `gh-cli-projects`, `gh-cli-prs`, `gh-cli-releases`, `gh-cli-repos`, `gh-cli-setup`
