---
name: gh-cli-releases
description: Create, publish, upload assets, edit, delete GitHub releases via CLI.
---

List: `gh release list`
Latest published: `gh release view --json tagName,publishedAt | jq 'select(.publishedAt != null)'`

Create — direct:
```
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes" --target main
gh release create v1.0.0 --notes-file CHANGELOG.md
```

Create — draft, publish when ready:
```
gh release create v1.0.0 --draft --notes "..."
gh release edit v1.0.0 --draft=false   # publish
```

Pre-release: `gh release create v1.0.0-rc1 --prerelease --notes "..."`

Upload assets:
```
gh release upload v1.0.0 ./dist/app.tar.gz ./dist/app.zip
```

Edit published:
```
gh release edit v1.0.0 --title "new title" --notes "updated notes"
gh release edit v1.0.0 --prerelease=false
```

Delete: `gh release delete v1.0.0 --yes`
Delete asset: `gh release delete-asset v1.0.0 app.tar.gz`

Download assets:
```
gh release download v1.0.0 --pattern "*.tar.gz" --dir ./downloads
gh release download v1.0.0 --archive zip
```

Note: `gh release create` uses existing tag. Doesn't create tag — ensure tag exists or push before running.
