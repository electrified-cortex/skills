# gh-cli-releases

Create, publish, edit, upload assets to, and delete GitHub releases.

## When to Use

- Tagging and publishing a new release
- Uploading build artifacts (binaries, archives, checksums) to an existing release
- Editing release notes or toggling draft/prerelease flags
- Listing or deleting old releases

## Common Commands

```bash
# Create a release with auto-generated notes
gh release create v1.2.0 --generate-notes

# Create a release with custom notes
gh release create v1.2.0 --title "v1.2.0 — Stability fixes" \
  --notes "See CHANGELOG.md for details"

# Create a draft release (not public until published)
gh release create v1.2.0 --draft --notes "Draft: review before publishing"

# Upload an asset to an existing release
gh release upload v1.2.0 ./dist/app-linux-amd64.tar.gz

# Upload multiple assets
gh release upload v1.2.0 ./dist/*.tar.gz ./dist/checksums.txt

# Edit a release (publish a draft, change notes)
gh release edit v1.2.0 --draft=false --latest

# List releases
gh release list

# Delete a release
gh release delete v1.2.0 --yes
```

## Notes

- Tags are created automatically if they do not already exist in the repo
- `--prerelease` marks the release as a pre-release in the GitHub UI
- `--latest` sets this as the "Latest release" badge on the repo
- Asset uploads are appended; existing assets with the same name are replaced

## Related Skills

- [`gh-cli`](../) — top-level router
- [`gh-cli-repos`](../gh-cli-repos/) — repo management
- [`gh-cli-api`](../gh-cli-api/) — advanced release queries or bulk operations

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
