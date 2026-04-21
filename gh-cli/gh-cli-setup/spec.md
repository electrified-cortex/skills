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

## Behavior

The skill covers the setup lifecycle for `gh`: detecting whether it is installed and at what version, providing platform-correct installation instructions (Windows, macOS, Linux), guiding through browser-based OAuth or token-based authentication, verifying authentication succeeded via `gh auth status`, applying configuration for automation use (disable prompts, set git protocol), and setting a default repository with `gh repo set-default`. The skill adapts to the current shell environment — it does not assume any particular shell.

## Error Handling

If `gh auth status` reports not authenticated, the agent must guide through the appropriate authentication flow before any other operation proceeds. If installation fails due to a missing package manager or permissions issue, the agent must surface the underlying error and propose an alternative installation method for the platform. If `gh auth login --with-token` receives a token with insufficient scopes, `gh` will fail on subsequent operations — the agent must check required scopes against the token before accepting it as valid.

## Precedence Rules

Authentication verification takes precedence over all other setup steps — no configuration or default-setting should proceed until `gh auth status` confirms a valid session. Interactive setup paths and automated (scriptable) paths must be presented as distinct options; the automated path takes precedence in non-interactive environments.

## Don'ts

- Does not cover any `gh` subcommand usage beyond `auth`, `config`, and `repo set-default`.
- Does not manage GitHub tokens or secrets storage beyond what `gh auth` provides.
- Does not configure CI/CD environments — only local or agent environments.
