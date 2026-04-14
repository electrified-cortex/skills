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

## Non-Goals

- Does not manage Git tags directly — only interacts with tags through `gh release`.
- Does not generate changelogs or release notes automatically from commits.
- Does not cover GitHub release attestations or artifact signing workflows.
- Does not configure release automation in CI/CD workflows.
