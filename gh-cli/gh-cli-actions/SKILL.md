---
name: gh-cli-actions
description: Trigger, monitor, and manage GitHub Actions workflows, runs, secrets, and variables via the CLI.
---

List workflows: `gh workflow list`
Enable / disable: `gh workflow enable ci.yml` / `gh workflow disable ci.yml`

Trigger + capture run ID:
```
gh workflow run ci.yml --ref main --raw-field version="1.0.0"
RUN_ID=$(gh run list --workflow ci.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

Monitor:
```
gh run list --workflow ci.yml --branch main --json databaseId,status,conclusion
gh run watch "$RUN_ID"
```

Logs (failed run):
```
gh run view "$RUN_ID" --log-failed
gh run view "$RUN_ID" --job 987654321 --log
```

Rerun / cancel:
```
gh run rerun "$RUN_ID" --failed    # rerun only failed jobs
gh run cancel "$RUN_ID"
```

Download artifacts:
```
gh run download "$RUN_ID" --dir ./artifacts
gh run download "$RUN_ID" --name build
```

Secrets — never pass value as argument; pipe or use env:
```
echo "$SECRET_VALUE" | gh secret set MY_SECRET
gh secret set MY_SECRET --env production
gh secret list
gh secret delete MY_SECRET
```

Variables:
```
gh variable set MY_VAR "value"
gh variable set MY_VAR "value" --env production
gh variable get MY_VAR
gh variable list
gh variable delete MY_VAR
```

Caches:
```
gh cache list --branch main
gh cache delete "$CACHE_ID"
gh cache delete --all
```
