# copilot-cli-explain — Uncompressed

This file preserves the full design rationale for the explain sub-skill before compression to SKILL.md.

## Why this sub-skill exists

The `copilot-cli` router needs a dedicated handler for code explanation requests that return prose, not structured findings. A separate sub-skill keeps the surface area narrow and ensures the prompt framing is always explanation-oriented.

## Inline-only content rationale

Copilot CLI does not accept a file path argument for content input. The only input surface is the prompt string passed via `-p`. Callers must serialize their code content into a string before invocation. This is consistent with the `copilot-cli-review` sub-skill (R6 in that spec). Accepting file paths in the prompt template would be misleading: the model reads the path string as text, not as a file reference.

## UNAVAILABLE vs ERROR distinction

`UNAVAILABLE` means the skill could not even attempt the explanation because `copilot` is not installed. `ERROR` means the binary was found but the invocation failed. Callers may handle these differently.

## Working-directory constraint

Setting the working directory to the repo containing the target file gives `--allow-all-tools` access to the relevant codebase context. This is intentional: Copilot may read surrounding files to produce a more accurate explanation. The constraint prevents exposure of unrelated directories.

## One code region per invocation

Explaining multiple unrelated code regions in a single invocation produces an interleaved response that is harder to attribute. The skill is one-in / one-out: one region, one structured explanation.

## --model flag and R3

The `--model` flag is optional and only passed when the caller explicitly supplies a model name. The skill does not pin a default model; this keeps the skill aligned with Copilot's own default behavior and prevents the skill from breaking silently when model availability changes.

## Threat Model — --allow-all-tools

`--allow-all-tools` permits the Copilot CLI to read within the working directory. For explain operations, setting the working directory to the repo containing the target file is intentional — it gives Copilot access to surrounding context for a more accurate explanation. The constraint prevents exposure of unrelated directories. This rationale is documented here in uncompressed rationale, not in the runtime card.
