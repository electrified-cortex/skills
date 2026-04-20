---
name: gh-cli-projects
description: Spec for the gh-cli-projects skill — intent, scope, and required behavior for managing GitHub Projects v2 via the CLI.
---

# gh-cli-projects — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through GitHub Projects v2 management using `gh project`. Covers creating and configuring project boards, managing items (issues and PRs), and editing fields to reflect workflow state.

## Scope

Covers `gh project` subcommands: creating, editing, and deleting projects; managing fields (create, list, delete); adding, editing, archiving, and removing project items; linking projects to repositories; and listing projects for a user or organization. Does not cover GitHub Projects v1 (classic) or project automation rules.

## Intent

The skill must enable an agent to:

- Create a new project for a user or organization
- List existing projects and identify their IDs
- Add issues or PRs to a project as items
- Create custom fields (text, number, date, single select, iteration) on a project
- Edit an item's field values to update its status or metadata
- Archive completed items to reduce board clutter
- Delete items, fields, or entire projects when no longer needed
- Copy a project as a template for a new one

## Requirements

- The skill must explain that `gh project` operates on project IDs, not names — commands for resolving a project name to its ID must be included.
- Field editing must cover single-select fields specifically, as these require the option's ID, not its label text.
- The skill must demonstrate adding both issues and PRs as items using the correct owner/repo/number form.
- The skill must distinguish between archiving an item (keeps it in the project, hidden) and deleting it (removes it permanently).

## Don'ts

- Does not cover GitHub Projects v1 (classic boards with columns).
- Does not configure project automation rules or status workflows.
- Does not generate project reports or analytics.
- Does not integrate with external project management tools.
