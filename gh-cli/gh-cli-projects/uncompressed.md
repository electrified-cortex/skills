# GH CLI Projects

Manage GitHub Projects v2 using the `gh project` subcommand. Covers creating projects, managing items (issues and PRs), editing fields, and deleting or archiving content.

## Important: Projects Use Numeric IDs

Most `gh project` commands operate on project numbers, not names. Resolve the project name to its number before running any other commands:

```bash
gh project list --owner owner --format json --jq '.projects[] | select(.title=="My Project") | .number'
```

## Creating a Project

Create a project for a user or organization:

```bash
gh project create --owner owner --title "My Project"
gh project create --owner orgname --title "Project"
```

## Adding Items

Add an issue or PR to a project by URL:

```bash
gh project item-add PROJECT_NUM --owner owner --url https://github.com/owner/repo/issues/123
```

## Listing Items

List all items in a project:

```bash
gh project item-list PROJECT_NUM --owner owner
```

## Creating Fields

Create a custom field on a project:

```bash
gh project field-create PROJECT_NUM --owner owner --name "Status" --data-type "SINGLE_SELECT"
```

Supported data types include: `TEXT`, `NUMBER`, `DATE`, `SINGLE_SELECT`, `ITERATION`.

## Editing Item Fields

Single-select fields require the option ID, not the label text. Retrieve the option ID first:

```bash
gh project field-list PROJECT_NUM --owner owner --format json --jq '.fields[] | select(.name=="Status") | .options'
```

Then update the item:

```bash
gh project item-edit PROJECT_NUM --owner owner --id ITEM_ID --field-id FIELD_ID --single-select-option-id OPTION_ID
```

## Archiving vs. Deleting Items

Archiving hides an item but keeps it in the project:

```bash
gh project item-archive PROJECT_NUM --owner owner --id ITEM_ID
```

Deleting an item removes it permanently:

```bash
gh project item-delete PROJECT_NUM --owner owner --id ITEM_ID
```

## Copying a Project as a Template

Copy an existing project to a new one:

```bash
gh project copy PROJECT_NUM --source-owner owner --target-owner owner --title "New Project"
```

## Deleting a Project

Delete an entire project permanently:

```bash
gh project delete PROJECT_NUM --owner owner
```

## Scope Boundaries

This skill covers `gh project` only. It does not manage GitHub Projects v1 (classic boards), configure project automation rules, or link issues to projects — item addition is the linking mechanism.
