# copilot-cli-review spec

## Purpose

Define the dispatch contract for an adversarial code-review pass executed via the standalone GitHub Copilot CLI binary. Returns structured findings in a vocabulary aligned with the canonical `code-review` skill so callers can aggregate Copilot output with Claude review output without translation.

This skill exists to provide a non-Claude review lane for callers (typically the `code-review` skill via a `backends` parameter, or direct Worker dispatch) that want adversarial cross-model perspective without paying a second Claude dispatch.

## Scope

Applies when:

- The Copilot CLI binary is installed and reachable on the host (`copilot --version` succeeds).
- The caller supplies either a git diff, a file path list, or inline content to review.
- The caller wants structured findings, not free-form Copilot chat.

Does NOT cover:

- Installing Copilot CLI. The skill fails fast if absent.
- Fixing the findings. Output is read-only review; remediation is the caller's job.
- Other Copilot CLI operations (chat, explain). Those are sibling sub-skills under `copilot-cli/`.

## Definitions

- **working_dir**: the directory passed by the caller in which Copilot CLI is invoked. Must be constrained to the target repo or worktree; never a root or secrets directory.
- **threat surface**: the set of actions `--allow-all-tools` permits — read, edit, and execute within the working directory. The working_dir constraint is the mitigation.
- **severity vocabulary (canonical)**: `blocker / major / minor / nit`. This skill normalizes all Copilot severity output to this four-value set before returning.
- **inline content serialization**: embedding diff or file content as a string literal inside the `-p` prompt argument, since Copilot CLI has no file-input flag.
- **Copilot CLI binary**: the `copilot` executable on the host PATH. This skill detects it via `copilot --version`; it does not install or manage it.

## Requirements

### Invocation

R1. The skill MUST detect Copilot CLI availability via `copilot --version` before any review work. On failure, return immediately with `Status: UNAVAILABLE` and stderr output; do NOT attempt install or fall back.

R2. The skill MUST invoke the binary as `copilot -p "<prompt>" -s --allow-all-tools` for the canonical headless review path. Aligns with the documented headless-mode flag set.

R2a. The skill MAY also invoke with `--output-format=json` when a structured machine-readable response is required AND the installed Copilot CLI version supports the flag. Prefer JSON when available; fall back to markdown parsing otherwise.

R2b. The skill MUST treat `--no-ask-user --prompt "<prompt>"` (long-form aliases) as equivalent to `-p "<prompt>" -s` when reading existing tool wrappers (e.g. `tools/copilot-review.ps1`). New invocations MUST use the short form per R2 for consistency.

R3. The skill MUST pass `--model <model>` only when the caller supplied an explicit model. Default to Copilot's default; do not pin a specific model in the skill.

### Prompt construction

R4. The skill MUST frame the prompt as an adversarial review request asking for a structured findings list with the canonical severity vocabulary: `blocker / major / minor / nit`. NOT `critical / major / minor / nitpick`. Output severity is normalized in the skill before return.

R5. The skill MUST instruct the model to return `No findings.` (literal) when nothing is wrong, so the parser has an unambiguous clean signal.

R6. The skill MUST embed file content (or diff) inline in the prompt string. Copilot CLI has no file-input flag — there is no `-P` or equivalent. Callers must serialize content into the prompt string before invocation.

### Output

R7. The skill MUST return a structured result regardless of Copilot's output format:

```text
Status: CLEAN | FINDINGS | UNAVAILABLE | ERROR
Findings:
  - severity: blocker | major | minor | nit
    file: <path>
    line: <number or range>
    description: <one sentence>
Raw: <Copilot's full response, JSON or markdown>
```

R7a. `UNAVAILABLE` when `copilot --version` fails. `ERROR` when the binary returns non-zero or output is unparseable. `CLEAN` when Copilot reports "No findings." `FINDINGS` otherwise.

R7b. Severity normalization MUST happen in this skill before return. Map `critical → blocker`, `nitpick → nit`. Other severity labels not in the canonical four MUST be coerced or flagged in the description.

### Safety

R8. The skill MUST constrain the working directory to the target repo or worktree. Never run `copilot` in `/`, `~`, the workspace root, or any directory containing secrets. Caller passes `working_dir`; skill enforces.

R9. The skill MUST acknowledge `--allow-all-tools` is a real threat surface. The constraint in R8 is the mitigation; agents MUST NOT run this skill in unconstrained paths even on operator request unless the operator explicitly waives R8 for one call.

## Constraints

C1. Runtime card under ~150 lines. Sub-skill of a router; verbosity not justified.

C2. Severity vocabulary is `blocker / major / minor / nit` (aligned to canonical code-review). Do NOT introduce a fifth severity tier without coordination across both skills.

C3. The skill MUST NOT install, update, or upgrade Copilot CLI. Detection-only.

C4. The skill MUST NOT retry with a different Copilot model on first failure. Surface the error and stop.

## Don'ts

DN1. Do NOT use `-P` (uppercase) or any non-existent flag. The flag is `-p` (lowercase) for prompt text. File content is embedded inline.
DN2. Do NOT instruct the caller on which severity threshold to fail at — that's the caller's policy.
DN3. Do NOT chain reviews across multiple directories in one invocation. One repo per call.
DN4. Do NOT bake a specific Copilot CLI version assumption into the skill. Detect, then use; report version in output for caller observability.
DN5. Do NOT return raw Copilot markdown without parsing. Caller expects the structured shape from R7.
