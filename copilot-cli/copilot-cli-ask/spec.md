# copilot-cli-ask spec

## Purpose

Define the dispatch contract for a general-query pass executed via the standalone GitHub Copilot CLI binary. Returns Copilot's plain-text answer to a caller-supplied question or request for advice.

## Scope

Applies when:

- The Copilot CLI binary is installed and reachable on the host (`copilot --version` succeeds).
- The caller supplies a question or advisory prompt.
- The caller wants Copilot's answer verbatim, not structured findings.

Does NOT cover:

- Installing Copilot CLI. The skill fails fast if absent.
- Code review (structured findings). That is the `copilot-cli-review` sub-skill.
- Code explanation. That is the `copilot-cli-explain` sub-skill.

## Definitions

- **Copilot CLI**: the standalone `copilot` binary, distinct from the GitHub Copilot IDE extension.
- **UNAVAILABLE**: the binary could not be located or `copilot --version` returned a non-zero exit code before any invocation.
- **ERROR**: the binary was found and invoked but returned a non-zero exit code.
- **OK**: the binary was invoked and returned output without a non-zero exit code.
- **Neutral directory**: any directory that is not the filesystem root (`/`) or user home directory (`~`). Callers must additionally ensure the chosen directory contains no sensitive files (e.g., `.env`, `*.key`, `credentials.*`).

## Interface

Parameters the caller passes when dispatching this skill:

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `question` | string | yes | The question or advisory prompt to send to Copilot. |
| `context` | string | no | Factual background to prepend to the question. Not a prior Q&A exchange — see DN2. |
| `model` | string | no | Copilot model name. Passed as `--model <model>` when supplied. Omit to use Copilot's default. |
| `working_dir` | path | no | Working directory for the invocation. Defaults to the dispatching repo if available, otherwise a neutral directory. |

## Requirements

### Invocation

R1. The skill MUST detect Copilot CLI availability via `copilot --version` before any work. On failure, return immediately with `Status: UNAVAILABLE` and stderr output; do NOT attempt install or fall back.

R2. The skill MUST invoke the binary as `copilot -p "<prompt>" -s --allow-all-tools` for the canonical headless path.

R3. The skill MUST pass `--model <model>` only when the caller supplied an explicit model. Default to Copilot's default; do not pin a specific model in the skill.

### Prompt construction

R4. The skill MUST pass the caller's question directly as the prompt. Prepend caller-supplied context when provided; do not add framing or instructions of its own.

### Output

R5. The skill MUST return a structured result in the following normative format:

```text
Status: OK | ERROR | UNAVAILABLE
Answer: <Copilot's plain text response>
```

R5a. `UNAVAILABLE` when `copilot --version` fails. `ERROR` when the binary returns non-zero exit code. `OK` when the binary exits zero, including when stdout is empty.

R5b. The `Answer` field MUST contain Copilot's response verbatim. Do not summarize, filter, reinterpret, or rewrite. (See also DN1.)

R5c. In `ERROR` state, the `Answer` field MUST contain the binary's stderr output verbatim. If stderr is empty, `Answer` MUST contain an empty string. The skill MUST discard stdout on non-zero exit and MUST NOT log or surface it. (Rationale: stdout on non-zero exit may contain partial or corrupted state that is not a valid answer; stderr is the authoritative error signal.)

### Safety

R6. The skill MUST set the working directory to the repo from which the skill was dispatched (if any), or a neutral directory when no repo context is available. The skill MUST NOT run in `/` or `~`.

## Constraints

C1. Runtime card under ~100 lines. Sub-skill of a router; verbosity not justified.

C2. The skill MUST NOT install, update, or upgrade Copilot CLI. Detection-only.

C3. The skill MUST NOT retry with a different Copilot model on first failure. Surface the error and stop.

## Don'ts

DN1. The skill MUST NOT interpret, filter, summarize, or rewrite Copilot's answer. (Cross-reference: R5b.)
DN2. The skill MUST NOT handle multiple questions in one invocation. One `question` parameter per call; `context` is factual background only, not a prior Q&A exchange.
DN3. The skill MUST NOT embed a specific Copilot CLI version assumption. Detect at runtime and use the installed version as-is.
