---
name: code-review-setup
description: Preflight readiness check — verify the host environment can run code-review. Inline. Returns structured ready / not-ready report with remediation.
---

# Code Review Setup

## When to invoke

Before the first code-review claim in a new environment, on a new machine, after a permission allow-list change, or after a fresh checkout/install. Idempotent — safe to re-run.

Code-review may auto-invoke this on its first dispatch in an environment and refuse to proceed if `overall: not-ready`. Hosts that want to skip the auto-gate can call setup explicitly first and proceed once `ready`.

## Inputs

| Input | Required | Description |
| --- | --- | --- |
| `target_repo` | optional | Path to the repository where code-review will run. Default: current working directory. Used for repo-scoped checks. |

## Output

```yaml
overall: ready | not-ready
checks:
  - name: <check identifier>
    status: ready | not-ready | not-applicable
    detail: <what was tested, what was found>
    remediation: <required action; null when status is ready or not-applicable>
```

`overall` is `ready` only when every check is `ready` or `not-applicable`. One `not-ready` fails the overall.

## Required checks (floor)

| Check | Verifies |
| --- | --- |
| `git-installed` | `git --version` returns a version string. |
| `git-hash-object` | `git hash-object --stdin` accepts content and returns a 40-char SHA-1 (probe with a small constant string). |
| `code-reviews-dir-writable` | `target_repo` permits creation of `.code-reviews/` (probe via dry-run check, not actual create). |
| `code-reviews-gitignored` | `.code-reviews/` is listed in `<target_repo>/.gitignore`. Read-only check — never modify `.gitignore`. |
| `swarm-reachable` | The `swarm` skill is discoverable from the host's skill index. |

Implementations may add informational checks (e.g., `copilot-cli-available`) that mark `not-applicable` when absent rather than failing overall.

## Remediation requirement

Every `not-ready` check produces remediation specific enough to act on without further investigation. Examples:

- `git-installed` → "Install git from <https://git-scm.com/downloads> and ensure `git` is on PATH."
- `git-hash-object` → "Add `Bash(git hash-object*)` to the agent's permission allow-list at `<config-file-path>`."
- `code-reviews-dir-writable` → "Grant write access to `<target_repo>` or invoke code-review against a writable repository."
- `code-reviews-gitignored` → "Append `.code-reviews/` to `<target_repo>/.gitignore` so review cache files don't get committed."

Vague remediation ("fix permissions", "see docs") is insufficient.

## Behaviors

1. Run every required check independently. One failure does not short-circuit the rest.
2. Compose the report only after all checks complete.
3. Return the report; do not refuse, throw, or exit on `not-ready`. The host owns the response.
4. Each check is read-only. No file writes, no configuration changes, no side-effecting commands.
5. Each check is fast. Total budget under 5 seconds. Timeouts in any check report `not-ready` with the timeout itself as the failure mode.

## Don'ts

- Don't write or modify files during the check.
- Don't fail overall on optional capabilities (Copilot CLI, etc.). Mark `not-applicable`.
- Don't include remediation that requires further diagnosis.
- Don't dispatch code-review as part of the check.
- Don't depend on one check's result inside another. Each check is independent.

## Iteration safety

No caching. The check runs end-to-end every invocation. Stale-result risk outweighs re-run cost.

Related: `code-review`, `swarm`.
