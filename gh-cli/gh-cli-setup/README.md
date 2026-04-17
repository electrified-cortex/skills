# gh-cli-setup

Install, authenticate, and configure the GitHub CLI (`gh`).

## When to Use

- First-time setup on a new machine or container
- Authenticating with a Personal Access Token (PAT) or OAuth
- Checking auth status before running other `gh` commands
- Changing protocol (HTTPS vs SSH) or default editor settings

## Installation

```bash
# Check if gh is installed
gh --version

# Install on Debian/Ubuntu
sudo apt install gh

# Install on macOS
brew install gh

# Install on Windows (winget)
winget install --id GitHub.cli
```

## Authentication

```bash
# Interactive login (opens browser)
gh auth login

# Non-interactive login with a token (CI/headless environments)
echo "$GH_TOKEN" | gh auth login --with-token

# Authenticate for a specific host (GitHub Enterprise)
gh auth login --hostname github.example.com

# Check auth status
gh auth status

# Log out
gh auth logout
```

## Configuration

```bash
# Set preferred git protocol
gh config set git_protocol ssh

# Set default editor
gh config set editor vim

# List all config values
gh config list
```

## Notes

- In CI environments, set the `GH_TOKEN` environment variable instead of
  running `gh auth login` — most `gh` commands pick it up automatically
- `gh auth status` is a fast sanity check; run it before other operations
  if auth issues are suspected
- Scopes granted at login determine which operations are available; re-login
  with `--scopes` to add missing permissions

## Related Skills

- [`gh-cli`](../) — top-level router
- All other `gh-cli-*` sub-skills require a valid auth session

## Standards

This skill follows the [Agent Skills](https://agentskills.io) open standard.

## License

MIT — see [LICENSE](../../LICENSE) in the repository root.
