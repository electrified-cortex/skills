---
name: gh-cli-releases
description: Create, publish, upload assets for, edit, and delete GitHub releases via the CLI.
---

List: `gh release list`
Latest published: `gh release view --json tagName,publishedAt | jq 'select(.publishedAt != null)'`

Create — direct publish:
```
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes" --target main
gh release create v1.0.0 --notes-file CHANGELOG.md
```

Create — draft first, publish when ready:
```
gh release create v1.0.0 --draft --notes "..."
gh release edit v1.0.0 --draft=false   # publish
```

Pre-release: `gh release create v1.0.0-rc1 --prerelease --notes "..."`

Upload assets:
```
gh release upload v1.0.0 ./dist/app.tar.gz ./dist/app.zip
```

Edit published release:
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

Note: `gh release create` uses an existing tag. It doesn't create the tag — ensure the tag exists or push it before running.
