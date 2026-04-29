---
name: gh-cli-releases
description: Manage GitHub releases via gh release. Full lifecycle: create, publish, upload assets, edit, delete.
---

# GH CLI Releases

Manage GitHub releases using the `gh release` subcommand. Covers the full release lifecycle: creating, publishing, uploading assets, editing, and deleting releases.

## Listing Releases

List all releases:

```bash
gh release list
```

Identify the latest published release (filtering out drafts):

```bash
gh release list --exclude-drafts --limit 1
```

Note: `gh release view` without a tag shows the latest release, but returns empty if the latest release is a draft. Use `--exclude-drafts` to reliably find the latest published release.

## Creating a Release — Direct Publish

Create and publish a release immediately from an existing tag:

```bash
gh release create v1.0.0 --title "v1.0.0" --notes "Release notes" --target main
```

Write release notes from a file:

```bash
gh release create v1.0.0 --notes-file CHANGELOG.md
```

Important: `gh release create` uses an existing Git tag. Ensure the tag exists and is pushed before running this command.

## Creating a Release — Draft then Publish

Create a draft for review first, then publish when ready:

```bash
gh release create v1.0.0 --draft --notes "..."
gh release edit v1.0.0 --draft=false
```

## Pre-releases

Mark a release as a pre-release:

```bash
gh release create v1.0.0-rc1 --prerelease --notes "..."
```

## Uploading Assets

Upload one or more files to an existing release:

```bash
gh release upload v1.0.0 ./dist/app.tar.gz ./dist/app.zip
```

## Editing a Published Release

Update the title, notes, or pre-release status:

```bash
gh release edit v1.0.0 --title "new title" --notes "updated notes"
gh release edit v1.0.0 --prerelease=false
```

## Deleting Releases and Assets

Delete a release:

```bash
gh release delete v1.0.0 --yes
```

Delete a single asset from a release:

```bash
gh release delete-asset v1.0.0 app.tar.gz
```

## Downloading Release Assets

Download assets matching a pattern or as an archive:

```bash
gh release download v1.0.0 --pattern "*.tar.gz" --dir ./downloads
gh release download v1.0.0 --archive zip
```

## Scope Boundaries

This skill covers `gh release` only. It does not manage Git tags directly, generate changelogs automatically from commits, handle release attestations or artifact signing, or configure release automation in CI/CD pipelines.
