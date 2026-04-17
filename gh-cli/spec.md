---
name: gh-cli
description: Spec for the gh-cli router skill — intent, scope, and routing rules for dispatching GitHub CLI tasks to domain sub-skills.
---

# gh-cli — Spec

## Purpose

Define the intent and scope of a top-level router skill that accepts any GitHub CLI task and dispatches it to the correct domain sub-skill. This skill does not execute `gh` commands itself; it identifies the domain and forwards the task.

## Scope

Covers routing logic only. The eight domains are: actions, api, issues, projects, prs, releases, repos, and setup. Each domain has its own sub-skill. The prs domain has four further sub-skills (create, review, comments, merge).

## Intent

The skill must enable an agent to:

- Accept a natural language GitHub CLI task from a caller
- Identify which domain the task belongs to
- Load and execute the correct domain sub-skill
- Handle ambiguous tasks by asking for clarification rather than guessing
- Note remaining work when a task spans multiple domains

## Domain Routing Table

| Domain | Sub-skill | Handles |
| --- | --- | --- |
| actions | gh-cli-actions/ | Workflows, runs, secrets, variables, caches |
| api | gh-cli-api/ | Raw REST and GraphQL API calls |
| issues | gh-cli-issues/ | Issue lifecycle: create, list, edit, close, comment |
| projects | gh-cli-projects/ | GitHub Projects v2: boards, items, fields |
| prs | gh-cli-prs/ | Pull request lifecycle router |
| releases | gh-cli-releases/ | Release lifecycle: create, publish, assets |
| repos | gh-cli-repos/ | Repository management: create, clone, fork, sync |
| setup | gh-cli-setup/ | Install, authenticate, configure gh |

## Requirements

- The router must not attempt `gh` commands directly. All execution happens inside domain sub-skills.
- Authentication must be verified via `gh auth status` if the setup skill was not previously loaded in the session.
- One domain is handled per invocation. Multi-domain tasks are split: primary domain runs, remaining domains are reported to the caller.
- Domain ambiguity must be resolved by asking the caller — never assume.

## Non-Goals

- Does not execute any `gh` subcommand itself.
- Does not manage routing state across multiple invocations.
- Does not validate the caller's input before routing — that is the domain skill's responsibility.
