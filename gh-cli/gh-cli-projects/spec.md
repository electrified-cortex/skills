# gh-cli-projects — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through GitHub Projects v2 management using `gh project`. Covers creating and configuring project boards, managing items (issues and PRs), and editing fields to reflect workflow state.

## Scope

Covers `gh project` subcommands: creating, editing, and deleting projects; managing fields (create, list, delete); adding, editing, archiving, and removing project items; linking projects to repositories; and listing projects for a user or organization. Does not cover GitHub Projects v1 (classic) or project automation rules.

## Definitions

- **Project ID**: the numeric identifier assigned to a GitHub Projects v2 board; required for all `gh project` operations — names are not accepted directly.
- **Field option ID**: the internal identifier for a choice in a single-select field; required for edits — the label text is not accepted.
- **Single-select field**: a custom project field whose value is constrained to a predefined list of options, each with its own option ID.
- **Item**: an issue or PR added to a project board; distinct from the original issue/PR record.
- **Archive**: hiding a completed item within a project without deleting it; distinct from deletion, which removes the item permanently.

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

## Behavior

The skill covers Projects v2 operations via `gh project`: creating projects, listing them to resolve names to IDs, adding issues and PRs as items, creating and editing custom fields (text, number, date, single select, iteration), editing item field values, archiving and deleting items, and copying projects. Single-select field edits require the option's ID, not its label text — the skill must show how to resolve the option ID before editing. Archiving keeps an item in the project but hides it; deletion removes it permanently.

## Error Handling

If a project name cannot be resolved to an ID, the agent must list projects for the user or organization and ask the caller to confirm the correct ID before proceeding. If a field edit fails because an option ID is wrong for a single-select field, the agent must list field options and retry with the correct ID. If a delete operation is irreversible (project deletion), the agent must confirm with the caller before executing.

## Precedence Rules

Project ID takes precedence over project name — all operations must resolve the ID first. Option ID takes precedence over option label for single-select field edits.

## Constraints

- Does not cover GitHub Projects v1 (classic boards with columns).
- Does not configure project automation rules or status workflows.
- Does not generate project reports or analytics.
- Does not integrate with external project management tools.
