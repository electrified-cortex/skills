> ROUGH DRAFT — needs ground-up rewrite as a dispatch skill (per operator 2026-04-25). Current draft is wrapper-script-oriented, but e-cortex skills don't ship scripts. Operator's framing: dispatch skill where host agent says "do a copilot review of this" and the dispatched agent handles all flag/prompt/output details internally. Code-review skill separately should be enhanced to dispatch multiple model backends in parallel (haiku + copilot) and aggregate. This file kept for reference only; do NOT audit or implement as-is.

# Copilot Review Specification (DRAFT — see note above)

## Purpose

Define the procedure and output contract for headless GitHub Copilot CLI invocation as a code-review backend. The skill wraps a non-interactive Copilot CLI call so an agent with terminal access can obtain a markdown code review without driving an interactive session. Output of this skill is a markdown review report; the skill never modifies code.

## Scope

Applies when a calling agent has:

- Local terminal access on a host where `copilot` CLI is installed and authenticated.
- A change set expressible as a unified diff, a list of file paths, or a git ref/range.

Out of scope:

- Multi-tier review orchestration (smoke/substantive). That is governed by `code-review`. This skill is a single-pass primitive that `code-review` may dispatch as a backend, alongside Claude-based dispatch.
- Interactive Copilot sessions, Copilot Chat, or VS Code integrations.
- Hosts without `copilot` CLI installed or authenticated. Skill returns a hard error in that case; no fallback.

## Definitions

- **Copilot CLI**: GitHub's `copilot` command-line tool, version 1.0.18 or later, capable of non-interactive prompt mode (`-p`) and silent output (`-s`).
- **Headless invocation**: a single `copilot -p "<prompt>" -s --allow-all-tools` call that runs to completion without operator interaction and emits the model response on stdout.
- **Review prompt**: a fixed-prefix prompt the skill sends to Copilot CLI, optionally augmented by a caller-supplied focus directive.
- **Change set**: the bounded set of code reviewed in one invocation. Identified by one of: inline unified diff (stdin), absolute file path list, or git ref/range.
- **Review report**: the markdown emitted by Copilot CLI in response to the review prompt. Single document, structured by Copilot's response, not normalized by this skill.
- **Wrapper script**: the bash script that implements headless invocation; lives at workspace `tools/copilot-review.sh`.

## Content Modes

This skill has one operational mode: **dispatch via wrapper script**. The skill itself does not invoke `copilot` directly. The calling agent executes the wrapper script, which assembles the Copilot CLI command and pipes the change set to stdin when applicable.

Inline invocation (`copilot -p ...` typed by the caller without the wrapper) is permitted but discouraged: it skips wrapper-enforced flags and prompt scaffolding. When inline invocation is used, the caller must replicate the wrapper's flag set verbatim.

## Requirements

R1. The wrapper script must accept a change set in one of three forms: `--diff` (inline diff via stdin), `--paths <file...>` (explicit file list), or `--ref <git-ref-or-range>` (e.g. `HEAD~1`, `main..HEAD`). Exactly one form must be provided per invocation.

R2. The wrapper script must accept an optional `--focus <csv>` argument that injects a focus directive into the review prompt.

R3. The wrapper script must accept an optional `--model <name>` argument, defaulting to `gpt-5.3-codex`. Any model string accepted by `copilot --model` is permitted.

R4. The wrapper script must invoke Copilot CLI with `-p`, `-s`, and `--allow-all-tools`. These flags are mandatory; the wrapper must not omit any of them.

R5. The wrapper script must emit the Copilot CLI response on stdout unmodified. Emission to a file via `> path` is the caller's responsibility.

R6. The wrapper script must exit with status 0 on successful Copilot CLI completion, regardless of whether findings were reported.

R7. The wrapper script must exit with non-zero status when: `copilot` is not on PATH; required argument is missing; mutually-exclusive arguments conflict; Copilot CLI itself exits non-zero. Stderr must carry an actionable message in each case.

R8. The wrapper script must support `--help` printing usage, all flags, and one example invocation.

R9. The skill (`SKILL.md`) must direct calling agents to invoke the wrapper script via `tools/copilot-review.sh`, never via `copilot` directly, except in the inline-invocation case described under Content Modes.

R10. The skill must state that this is a single-pass review primitive, not a substitute for the tiered `code-review` skill.

R11. The skill must not require Copilot to modify files. Any prompt construction within the wrapper must include "Do not modify files" verbatim.

R12. The wrapper script must be idempotent over identical inputs except for Copilot's non-deterministic responses. The script must not write to disk, mutate the working tree, or alter git state.

## Constraints

- The wrapper script must be bash. A PowerShell wrapper may exist as a thin call-through; it must not duplicate logic.
- The wrapper script must not require any environment variables beyond those Copilot CLI itself requires for authentication.
- The skill must not bake operator-specific paths, usernames, or repo names into wrapper or skill text.
- The skill must not load on every agent turn; it loads on demand when invoked.
- The skill must be discoverable via the local skill index (`skill.index`).
- The wrapper script must not invoke any Copilot CLI subcommand other than the headless prompt path.

## Behavior

When the wrapper script is invoked:

1. Parse flags. Reject if no change-set form is supplied or multiple are supplied.
2. Verify `copilot` is on PATH; if not, exit non-zero with stderr message naming the binary.
3. Assemble the change-set payload according to the chosen form: read stdin for `--diff`; concatenate path contents for `--paths`; run `git diff <ref>` for `--ref`.
4. Construct the review prompt: fixed prefix ("Review this code for bugs, regressions, architecture concerns, missing tests. Do not modify files. Output concise markdown with sections: Critical, Concerns, Nits."), optional focus directive injected after the fixed prefix.
5. Invoke `copilot -p "<prompt>" -s --allow-all-tools --model <model>` with the change-set payload on stdin.
6. Stream Copilot CLI stdout to wrapper stdout unmodified.
7. Exit with Copilot CLI's exit status if it errored; exit 0 otherwise.

When the skill is consulted by a calling agent:

1. The agent reads `SKILL.md`.
2. The agent identifies that the change set fits headless review (single-pass acceptable, terminal access available).
3. The agent invokes `tools/copilot-review.sh` with the chosen flags.
4. The agent treats the returned markdown as input to its own decision-making. The skill makes no decisions.

## Defaults and Assumptions

- Default model: `gpt-5.3-codex`.
- Default `--focus`: empty (no focus injection).
- Assumed: `copilot` CLI is installed, authenticated, and accessible from the caller's working directory.
- Assumed: `--allow-all-tools` is acceptable for the caller's threat model. Callers reviewing untrusted code must consider that Copilot CLI runs in their authenticated session.

## Error Handling

E1. Missing required argument: stderr "missing required argument: one of --diff, --paths, --ref"; exit 2.

E2. Mutually exclusive arguments: stderr "exactly one of --diff, --paths, --ref must be supplied"; exit 2.

E3. `copilot` not on PATH: stderr "copilot CLI not found on PATH; install GitHub Copilot CLI v1.0.18+"; exit 127.

E4. `copilot` exits non-zero: wrapper exits with the same status; stderr passes through Copilot's stderr unmodified.

E5. `--paths` references a non-existent file: stderr "path not found: <path>"; exit 66.

E6. `--ref` invalid or repository not a git working tree: stderr "git diff failed for ref: <ref>"; exit 65.

## Precedence Rules

- This spec governs the wrapper script and the skill.
- When `code-review` invokes this skill as a backend, `code-review` precedence rules apply at orchestration level; this spec governs the single invocation.
- Where requirements appear to conflict between this spec and `code-review`, `code-review` wins for orchestration concerns and this spec wins for invocation mechanics.

## Don'ts

- Don't provide a multi-tier orchestration option in this skill. Tiered review is `code-review`'s responsibility.
- Don't add interactive prompts, progress bars, or animation to the wrapper script. It is a non-interactive primitive.
- Don't allow the wrapper to write Copilot's output to a default file. Output goes to stdout; caller redirects.
- Don't allow the wrapper to fall back to a different review backend. Failure to invoke Copilot is a hard error.
- Don't bake authentication setup into the wrapper. If `copilot` is not authenticated, the wrapper surfaces Copilot's own error.
- Don't add MCP integration, agent dispatch, or any indirection beyond the direct `copilot` invocation.
- Don't allow Copilot to modify files. The "Do not modify files" instruction is mandatory in the prompt.

## Section Classification

| Section                    | Type          | Required |
|----------------------------|---------------|----------|
| Purpose                    | Descriptive   | Yes      |
| Scope                      | Normative     | Yes      |
| Definitions                | Normative     | Yes      |
| Content Modes              | Normative     | Yes      |
| Requirements               | Normative     | Yes      |
| Constraints                | Normative     | Yes      |
| Behavior                   | Normative     | Yes      |
| Defaults and Assumptions   | Normative     | Yes      |
| Error Handling             | Normative     | Yes      |
| Precedence Rules           | Normative     | Yes      |
| Don'ts                     | Normative     | Yes      |
| Section Classification     | Structural    | Yes      |
| Footguns                   | Informational | Optional |

## Footguns

**F1: Treating Copilot review as authoritative.** Copilot CLI is one model with one perspective. A clean Copilot review does not mean the change is correct. Why: model-specific blind spots; non-determinism; older training cutoffs may miss recent vulnerabilities. Mitigation: pair with `code-review` substantive pass when stakes are high; treat findings as one signal among several.

**F2: `--allow-all-tools` in untrusted contexts.** This flag grants Copilot full tool access in the caller's authenticated session. Why: prompt injection in target code could exploit Copilot's tool permissions to do unintended things. Mitigation: only review trusted code, OR run the wrapper inside a sandbox where Copilot's tools cannot harm the caller's environment.

**F3: Forgetting that `--allow-all-tools` is required.** Non-interactive mode rejects without it; the prompt hangs or errors. Why: undocumented hard dependency. Mitigation: wrapper enforces it (R4).

**F4: Default model assumption.** The default `gpt-5.3-codex` may not be on every Copilot plan. Why: model availability varies by license tier. Mitigation: verify via `copilot -p "reply with your model name" -s --allow-all-tools` before relying on a default; surface upstream model errors via E4.

ANTI-PATTERN: `tools/copilot-review.sh --diff --ref HEAD~1` — multiple change-set forms. Reject per R1.
