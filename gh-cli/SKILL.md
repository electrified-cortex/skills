---
name: gh-cli
description: GitHub CLI operations — routes to domain-specific sub-skills via dispatch.
---

# GH CLI

Read and follow instructions.txt for the routing procedure.

Domains:
- actions → gh-cli-actions/SKILL.md (workflows, runs, secrets, vars)
- api → gh-cli-api/SKILL.md (REST/GraphQL)
- issues → gh-cli-issues/SKILL.md (create, list, close, label, comment)
- projects → gh-cli-projects/SKILL.md (Projects v2)
- prs → gh-cli-prs/SKILL.md (PR lifecycle)
- releases → gh-cli-releases/SKILL.md (create, edit, delete, list)
- repos → gh-cli-repos/SKILL.md (clone, fork, create, configure)
- setup → gh-cli-setup/SKILL.md (auth, config, defaults)

Rules:
- Domain unclear → ask caller.
- Verify `gh auth status` if setup skill not loaded.
- Never improvise commands.
- One domain per invocation; note remaining work.
