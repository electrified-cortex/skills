# GH CLI Setup

Install, authenticate, and configure the GitHub CLI (`gh`). This is the prerequisite skill that all other gh-cli skills depend on.

## Checking if gh is Installed

```bash
gh --version
```

If the command is not found, install it for your platform.

## Installation

### Windows

```bash
winget install --id GitHub.cli
```

### macOS

```bash
brew install gh
```

### Linux (Debian/Ubuntu)

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh
```

## Authentication

### Interactive — Browser-Based

For local development where a browser is available:

```bash
gh auth login
```

Follow the prompts to authenticate via GitHub.com or GitHub Enterprise.

### Automated — Token-Based

For CI environments or automation where a browser is not available:

```bash
echo "$GH_TOKEN" | gh auth login --with-token
```

Never hard-code the token value in the command. Set `GH_TOKEN` as an environment variable or CI secret before invoking.

## Verifying Authentication

After login, confirm the correct hostname and account are active:

```bash
gh auth status
```

A successful setup shows the hostname, authenticated username, and token scopes.

## Configuration for Automation

Disable interactive prompts and set SSH as the git protocol (recommended for CI):

```bash
gh config set git_protocol ssh
gh config set prompt disabled
```

## Setting a Default Repository

Suppress the need to pass `--repo` on every command when working in a specific repo context:

```bash
gh repo set-default owner/repo
```

## GitHub Enterprise

Add `--hostname enterprise.internal` to the auth login command to target a GitHub Enterprise instance:

```bash
gh auth login --hostname enterprise.internal
```

## Scope Boundaries

This skill covers `gh auth`, `gh config`, and `gh repo set-default` only. It does not cover any domain-specific `gh` subcommands, GitHub token management beyond what `gh auth` provides, or CI/CD pipeline configuration.
