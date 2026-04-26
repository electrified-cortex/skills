# copilot-cli-explain spec

## Purpose

Define the dispatch contract for a code-explanation pass executed via the standalone GitHub Copilot CLI binary. Returns an explanatory markdown description of a code region or file.

## Scope

Applies when:

- The Copilot CLI binary is installed and reachable on the host (`copilot --version` succeeds).
- The caller supplies inline code content (a code region or file contents as a string).
- The caller wants a natural-language explanation, not structured review findings.

Does NOT cover:

- Installing Copilot CLI. The skill fails fast if absent.
- Code review (structured findings). That is the `copilot-cli-review` sub-skill.
- General advisory queries. That is the `copilot-cli-ask` sub-skill.

## Definitions

- **Copilot CLI**: the standalone `copilot` binary, distinct from the GitHub Copilot IDE extension.
- **Inline content**: code serialized as a string and embedded directly in the `-p` prompt argument. No file path reference — the binary has no file-input flag.
- **Code region**: a function, class, file, or other contiguous span of source code supplied by the caller.
- **UNAVAILABLE**: the binary could not be located or `copilot --version` returned a non-zero exit code before any invocation.
- **ERROR**: the binary was found and invoked but returned a non-zero exit code.
- **OK**: the binary was invoked and returned output without a non-zero exit code.
- **Working directory**: the directory in which `copilot` is invoked.
- **Target file**: the source file from which the caller serialized the inline code content. The skill never accesses this file directly; `working_dir` is set to its repo root to give Copilot contextual access.

## Interface

Parameters the caller passes when dispatching this skill:

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `content` | string | yes | The code content to explain, serialized inline. Do not pass file paths — embed the code text directly. |
| `working_dir` | path | yes | The repo root containing the source of the content. Used as the Copilot working directory. MUST NOT be `/`, `~`, or a directory containing secrets. |
| `model` | string | no | Copilot model name. Passed as `--model <model>` when supplied. Omit to use Copilot's default. |

## Requirements

### Invocation

R1. The skill MUST detect Copilot CLI availability via `copilot --version` before any work. On failure, return immediately with `Status: UNAVAILABLE` and stderr output in `Explanation` (see R6c); do NOT attempt install or fall back.

R2. The skill MUST invoke the binary as `copilot -p "<prompt>" -s --allow-all-tools` for the canonical headless path.

R3. The skill MUST pass `--model <model>` only when the caller supplied an explicit model. Default to Copilot's default; do not pin a specific model in the skill.

### Prompt construction

R4. The skill MUST embed all code content inline in the prompt string. Callers MUST serialize code into the prompt string before invocation. (File-path flags do not exist; see DN1.)

R5. The skill SHOULD frame the prompt to request an explanation covering: what the code does, why it works that way, and any non-obvious behavior.

### Output

R6. The skill MUST return a structured result in the following normative format:

```text
Status: OK | ERROR | UNAVAILABLE
Explanation: <Copilot's markdown explanation>
```

R6a. `UNAVAILABLE` when `copilot --version` fails. `ERROR` when the binary returns non-zero. `OK` otherwise.

R6b. In `OK` state, the `Explanation` field MUST contain Copilot's response verbatim. Do not summarize or reinterpret.

R6c. In `ERROR` or `UNAVAILABLE` state, the `Explanation` field MUST contain the binary's stderr output verbatim. If stderr is empty, `Explanation` MUST contain an empty string.

### Safety

R7. The skill MUST use the caller-supplied `working_dir` as the working directory. The skill MUST NOT run in `/` or `~`. The `working_dir` MUST be the repo root from which the inline content originates. Callers MUST NOT supply a path containing sensitive files (e.g., `.env`, `*.key`, `credentials.*`).

## Constraints

C1. The skill MUST NOT install, update, or upgrade Copilot CLI. Detection-only.

C2. The skill MUST NOT retry with a different Copilot model on first failure. Surface the error and stop.

## Don'ts

DN1. The skill MUST NOT use `-P` (uppercase) or any file-path flag. The flag does not exist; content MUST be embedded inline.
DN2. The skill MUST NOT return raw Copilot output without parsing into the structured result shape (R6/R6b).
DN3. The skill MUST NOT process multiple code regions in one invocation. One code region per call.
DN4. The skill MUST NOT embed a specific Copilot CLI version assumption. Detect at runtime; do not hardcode version strings.
