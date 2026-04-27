# Code-Review-Setup Specification

## Purpose

Define a preflight readiness check that an agent runs once in a new environment before invoking `code-review` for the first time. The check returns a structured ready/not-ready report with remediation guidance for any unready condition. Without this check, an agent attempting code-review against an unprepared environment can fail mid-dispatch, leaving partial state and offering no actionable signal back to the host.

## Scope

Applies to any agent in any environment that intends to dispatch code-review. The check is environment-scoped, not change-set-scoped — it verifies the runtime can run code-review at all, not whether a specific change set is reviewable.

This is an **inline sub-skill** of `code-review`. The check runs in the calling agent's context (no zero-context dispatch). It is a fast, side-effect-free probe — reads only.

Does not perform code-review itself. Does not install anything. Does not modify the environment. The agent is responsible for any remediation; setup only diagnoses.

## Definitions

- **Host**: the agent running code-review-setup. Same agent that will subsequently invoke code-review.
- **Readiness check**: a single named condition the host's environment must satisfy for code-review to function (e.g., "git installed").
- **Ready report**: structured output stating which checks passed and which failed.
- **Remediation**: per-failed-check, the specific action the host must take to resolve. Concrete enough that the host can execute the action without additional investigation.

## Requirements

### Inputs

The setup check accepts no required inputs. Optional input:

- `target_repo`: optional path to the repository where code-review will run. Default: current working directory. Used for repo-relative checks (e.g., directory creatability).

### Output

Structured ready/not-ready report:

```yaml
overall: ready | not-ready
checks:
  - name: <check identifier>
    status: ready | not-ready | not-applicable
    detail: <observation; what was tested and what was found>
    remediation: <required action when status is not-ready; null otherwise>
```

`overall` is `ready` only if every check is `ready` or `not-applicable`. A single `not-ready` check fails the overall.

### Required Checks

The set of checks at minimum verifies that:

1. Git is installed and on PATH.
2. The agent's environment permits `git hash-object` (or any necessary git read commands code-review depends on for content hashing).
3. The directory `.code-reviews/` is creatable in `target_repo` (write access; not blocked by deny rules).
4. **`.code-reviews/` is listed in the target repo's `.gitignore`.** Review files are local cache artifacts, not source-controlled; if missing from `.gitignore`, future commits would accidentally include them. Remediation when missing: append `.code-reviews/` to `<target_repo>/.gitignore`. The setup check itself MUST NOT modify `.gitignore` (read-only constraint); it surfaces the action for the host to take.
5. The `swarm` skill is reachable by name from the host (skill index lookup succeeds).

These four checks are the floor. Implementations may add probes (e.g., copilot CLI presence) as informational checks that mark `not-applicable` rather than failing the overall when absent.

### Remediation Detail Requirement

Each `not-ready` check must produce remediation specific enough to execute without further diagnosis. Examples of acceptable remediation:

- "Install git from `https://git-scm.com/downloads` and ensure `git` is on PATH."
- "Add `\"Bash(git hash-object*)\"` to the agent's permission allow-list at `<config-file-path>`."
- "Grant write access to `<target_repo>` or run code-review against a writable repository."

Examples of insufficient remediation:

- "Fix permissions." (too vague)
- "See documentation." (no documentation pointer)
- "Try again." (no actionable change)

### Idempotence

The check is idempotent. Running it repeatedly in the same environment yields the same result. The check writes nothing to disk and produces no side effects beyond the returned report.

## Constraints

1. The check is read-only. It must not write files, alter configuration, or invoke side-effecting commands.
2. The check is fast. Total wall-clock budget under 5 seconds in a typical environment. A check that times out is reported as `not-ready` with remediation that the timeout is itself the failure mode.
3. The check is non-fatal. A failed check returns a report; it does not throw, exit, or refuse to produce output. The host decides what to do with `not-ready`.
4. The check uses only commands and tools the host already has. It must not require installation of new tools, granting new permissions, or any preparatory step. If a check itself requires a permission the host lacks, that check returns `not-ready` with remediation describing the permission gap.

## Behavior

When called, the check runs every required check in turn. Each check captures its own success/failure independent of other checks (one failure does not short-circuit the rest — the host wants the full picture).

After all checks complete, the report is composed and returned. The host inspects `overall`. If `ready`, the host proceeds to invoke code-review. If `not-ready`, the host either applies the remediation (or surfaces it to the operator) before retrying.

## Don'ts

- Don't silently assume git is available — probe explicitly.
- Don't write or modify files during the check, even temporarily (the check is read-only).
- Don't fail the overall on missing-but-optional capabilities (e.g., copilot CLI). Mark them `not-applicable` and proceed.
- Don't include remediation that requires further diagnosis ("fix permissions", "see docs"). Remediation must be actionable as written.
- Don't attempt to dispatch code-review as part of the check. Setup verifies the environment; code-review is the next step.
- Don't depend on the result of a previous check inside another check. Each check is independent.

## Relationship to Other Skills

- **code-review**: parent skill; setup is a sub-skill that gates first invocation.
- **swarm**: code-review's downstream; setup verifies swarm is reachable.

Code-review may, at its option, invoke setup automatically on first run in an environment and refuse to dispatch if `overall: not-ready`. This automatic gating is recommended but not required by this spec — the host can call setup manually.

## Iteration Safety

The check has no caching or persistent state. It runs end-to-end every invocation. There is no equivalent of "skip if recently passed" — the cost of running setup is low, and stale-result risks are higher than re-run costs.
