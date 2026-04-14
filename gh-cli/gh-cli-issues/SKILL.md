---
name: gh-cli-issues
description: Create, list, edit, close, comment on, and bulk-manage GitHub issues via the CLI.
---

Create:
```
gh issue create --title "title" --body "body" --label bug,high-priority --assignee user1,@me
gh issue create --title "title" --body-file issue.md
```

List (open by default):
```
gh issue list --state all --assignee @me --label bug --milestone "v1.0" --limit 50
gh issue list --search "is:open label:stale" --json number,title --jq '.[].number'
```

View: `gh issue view 123 --comments`

Edit:
```
gh issue edit 123 --title "new" --add-label triage --remove-label stale
gh issue edit 123 --add-assignee user1 --remove-assignee user2 --milestone "v2.0"
```

Close / reopen:
```
gh issue close 123 --comment "Fixed in #456"
gh issue reopen 123
```

Comment:
```
gh issue comment 123 --body "text"
gh issue comment 123 --edit 456789 --body "updated"
gh issue comment 123 --delete 456789
```

Transfer: `gh issue transfer 123 --repo owner/other-repo`

Bulk ops — pipeline JSON through shell:
```
gh issue list --search "label:stale" --json number --jq '.[].number' \
  | xargs -I {} gh issue close {} --comment "Closing stale"
```

For Projects v2 placement → `gh-cli-projects/SKILL.md`.
For linking to a PR → `gh-cli-prs/gh-cli-prs-create/SKILL.md`.
