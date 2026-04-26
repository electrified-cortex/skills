# copilot-cli-ask — Uncompressed

This file preserves the full design rationale for the ask sub-skill before compression to SKILL.md.

## Why this sub-skill exists

The `copilot-cli` router needs a dedicated handler for free-form advisory questions that do not require structured findings. Rather than reusing the review sub-skill with a different prompt, a separate sub-skill keeps the surface area narrow: review returns typed findings; ask returns verbatim prose.

## Prompt pass-through rationale

The ask operation passes the caller's prompt through unchanged (with optional prepended context). Adding framing or instructions would bias Copilot's response in ways the caller did not request. The caller owns prompt framing for advisory queries.

## UNAVAILABLE vs ERROR distinction

`UNAVAILABLE` means the skill could not even attempt the query because `copilot` is not installed. `ERROR` means the binary was found but the invocation failed. Callers may handle these differently: UNAVAILABLE typically indicates an operator configuration problem; ERROR may indicate a transient or model-availability issue.

## Working-directory constraint

For ask operations, there is no strict working-directory requirement (unlike review, which must run in the target repo). The skill defaults to a neutral directory and accepts a caller override. The constraint exists to limit `--allow-all-tools` exposure, not to provide file access to the model.

## One question per invocation

Chaining questions in a single prompt produces unpredictable output structure. The skill is one-in / one-out: one question, one structured result.

## --model flag and R3

The `--model` flag is optional and only passed when the caller explicitly supplies a model name. The skill does not pin a default model; this keeps the skill aligned with Copilot's own default behavior and prevents the skill from breaking silently when model availability changes.

## Threat Model — --allow-all-tools

`--allow-all-tools` permits the Copilot CLI to read within the working directory. This is the documented headless invocation flag. The mitigation is the working-directory constraint: for ask operations, set the working directory to a neutral directory (never `/`, `~`, or a directory containing secrets). The threat model is documented here in uncompressed rationale, not in the runtime card, because it is design context not operational instruction.
