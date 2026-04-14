---
name: gh-cli-setup
description: Install, authenticate, configure GitHub CLI.
---

Check installed: `gh --version`. If missing, install:

```
# Windows
winget install --id GitHub.cli

# macOS
brew install gh

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh
```

Auth — interactive (browser):
```
gh auth login
```

Auth — token (automation/CI):
```
echo "$GH_TOKEN" | gh auth login --with-token
```

Verify: `gh auth status`. Must show hostname + active account.

Key config for automation:
```
gh config set git_protocol ssh
gh config set prompt disabled
```

Set default repo (suppress `--repo` per command):
```
gh repo set-default owner/repo
```

GitHub Enterprise: add `--hostname enterprise.internal` to any `gh auth login` or `gh api` call.
