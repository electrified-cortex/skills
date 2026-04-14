---
name: gh-cli-repos
description: Create, clone, fork, sync, edit, and delete GitHub repositories via the CLI.
---

Create:
```
gh repo create owner/name --public --description "desc" --clone
gh repo create owner/name --private --gitignore node --license mit
```
Always specify `--public` or `--private` — no default assumed.

Clone: `gh repo clone owner/repo [dir]`

Fork + configure upstream remote:
```
gh repo fork owner/repo --clone --remote-name upstream
```

Sync fork with upstream: `gh repo sync [--branch branch] [--force]`

Edit metadata:
```
gh repo edit --description "new" --homepage https://example.com
gh repo edit --visibility private
gh repo edit --default-branch main
```

Rename: `gh repo rename new-name`
Archive: `gh repo archive` / `gh repo unarchive`
Delete: `gh repo delete owner/repo --yes`

List:
```
gh repo list [owner] --limit 50 --json name,visibility,owner --jq '.[].name'
```

Set default repo for current directory: `gh repo set-default owner/repo`
Unset: `gh repo set-default --unset`
