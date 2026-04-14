---
name: gh-cli-setup
description: Spec for the gh-cli-setup skill — intent, scope, and required behavior for guiding installation, authentication, and configuration of the GitHub CLI.
---

# gh-cli-setup — Spec

## Purpose

Define the intent and scope of a skill that guides an agent through getting the GitHub CLI (`gh`) installed, authenticated, and configured for use. This is the prerequisite skill all other gh-cli skills depend on.

## Scope

Covers the initial setup lifecycle: installation across supported platforms, authenticating with GitHub (github.com or GitHub Enterprise), and configuring CLI behavior (editor, protocol, pager, prompts). Does not cover workflow-specific usage of `gh` — that belongs to the domain skills.

## Intent

The skill must enable an agent to:

- Detect whether `gh` is already installed and at what version
- Provide correct installation instructions for the current platform (Windows, macOS, Linux)
- Guide through interactive or token-based authentication
- Verify authentication succeeded
- Apply common configuration settings that make the CLI ready for automation use (e.g., disabling prompts, setting git protocol)
- Set a default repository when operating in a specific repo context

## Requirements

- The skill must not assume any particular shell. It must adapt to the environment.
- The skill must distinguish between interactive and automated (scriptable) setup paths.
- Authentication guidance must include both browser-based OAuth and token-based flows.
- The skill must communicate what a successful setup looks like so the agent can verify before proceeding.

## Non-Goals

- Does not cover any `gh` subcommand usage beyond `auth`, `config`, and `repo set-default`.
- Does not manage GitHub tokens or secrets storage beyond what `gh auth` provides.
- Does not configure CI/CD environments — only local or agent environments.
