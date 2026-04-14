---
name: gh-cli-projects
description: Create and manage GitHub Projects v2 boards, items, and fields via the CLI.
---

`gh project` operates on numeric project IDs, not names. Resolve first:
```
gh project list --owner owner --format json --jq '.projects[] | select(.title=="My Project") | .number'
```

Create project:
```
gh project create --owner owner --title "My Project"
gh project create --owner orgname --title "Project"    # org project
```

Add items (issues or PRs):
```
gh project item-add PROJECT_NUM --owner owner --url https://github.com/owner/repo/issues/123
```

List items: `gh project item-list PROJECT_NUM --owner owner`

Create field:
```
gh project field-create PROJECT_NUM --owner owner --name "Status" --data-type "SINGLE_SELECT"
```

Edit item field value — single-select requires option ID, not label:
```
# Get option ID first
gh project field-list PROJECT_NUM --owner owner --format json --jq '.fields[] | select(.name=="Status") | .options'
# Then update
gh project item-edit PROJECT_NUM --owner owner --id ITEM_ID --field-id FIELD_ID --single-select-option-id OPTION_ID
```

Archive item (hidden, not deleted): `gh project item-archive PROJECT_NUM --owner owner --id ITEM_ID`
Delete item (permanent): `gh project item-delete PROJECT_NUM --owner owner --id ITEM_ID`

Copy project as template:
```
gh project copy PROJECT_NUM --source-owner owner --target-owner owner --title "New Project"
```

Delete project: `gh project delete PROJECT_NUM --owner owner`
