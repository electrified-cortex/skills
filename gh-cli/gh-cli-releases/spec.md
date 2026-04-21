---
name: gh-cli-releases
description: Spec for the gh-cli-releases skill — intent, scope, and required behavior for managing GitHub releases via the CLI.
---

# gh-cli-releases — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through creating and managing GitHub releases using `gh release`. Covers the full release lifecycle from tagging to publishing, including asset uploads and pre-release management.

## Scope

Covers `gh release` subcommands: creating releases, listing and viewing existing releases, uploading and managing assets, editing release notes, deleting releases, and downloading release assets. Does not cover tagging strategy, changelog generation, or CI/CD pipeline orchestration around releases.

## Intent

The skill must enable an agent to:

- Create a release from a tag, optionally targeting a specific branch or commit
- Write release notes inline or from a file
- Publish as a draft first for review before making public
- Mark a release as a pre-release when appropriate
- Upload binary assets or archives to a release
- Edit a published release (update notes, title, or pre-release status)
- List all releases and distinguish draft, pre-release, and published states
- Delete a release and optionally its associated tag
- Download release assets programmatically

## Requirements

- The skill must cover both the draft-then-publish flow and the direct publish flow as distinct patterns.
- Asset upload must support multiple files in a single command.
- The skill must clarify the relationship between a release and its Git tag — creating a release does not automatically create a tag unless one is specified.
- The skill must show how to identify the latest published release reliably (not just most recent by date).

## Behavior

The skill covers the full release lifecycle: creating a release from a tag (draft or direct publish), writing notes inline or from a file, uploading multiple assets in a single command, editing a published release, listing releases to distinguish draft/pre-release/published states, deleting a release and optionally its tag, and downloading assets programmatically. The draft-then-publish flow and the direct publish flow are treated as distinct patterns. The `latest` release is identified by published state, not most-recent date.

## Error Handling

If a release is created from a tag that does not yet exist, the agent must confirm whether `gh release create` should also create the tag or whether the tag must be created via git first. If an asset upload partially fails mid-batch, the agent must check which assets were uploaded before retrying to avoid duplicates. If a delete is attempted on a release with associated tags, the agent must confirm with the caller whether the tag should also be deleted.

## Precedence Rules

Draft status takes precedence — a draft release is never exposed as the `latest` release regardless of creation date. The relationship between a release and its tag must be clarified before creation: the tag must exist or be explicitly created as part of the release command.

## Don'ts

- Does not manage Git tags directly — only interacts with tags through `gh release`.
- Does not generate changelogs or release notes automatically from commits.
- Does not cover GitHub release attestations or artifact signing workflows.
- Does not configure release automation in CI/CD workflows.
