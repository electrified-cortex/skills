# copilot-cli — Spec

## Purpose

Define the intent and scope of a top-level router skill that accepts any GitHub Copilot CLI task and dispatches it to the correct operation sub-skill. This skill does not execute `copilot` commands itself; it identifies the operation and forwards the task. The host agent does not need to know flag mechanics, prompt construction, or output parsing — those concerns live inside the dispatched sub-skill.

## Scope

Covers routing logic only. Operations are: `review`, `ask`, `explain`. Each operation has its own sub-skill.

Out of scope:

- The Copilot CLI binary's installation or authentication. Setup is operator-only and lives outside this skill.
- Any operation other than the listed sub-skills. New operations require a new sub-skill folder and a routing-table entry — this skill is not extended via inline logic.
- Multi-CLI fan-out. A separate skill (e.g. extended `code-review`) orchestrates multiple model lanes; this skill is the single-CLI surface for one lane.
- Modifying source files. The Copilot CLI runs in read-mostly mode; if a sub-skill needs to permit file edits, it must declare that explicitly.

## Definitions

- **Operation**: a category of Copilot CLI tasks handled by a dedicated sub-skill (`review`, `ask`, `explain`).
- **Sub-skill**: a skill that handles one operation's full surface, including flag assembly, prompt framing, CLI invocation, and output parsing.
- **Router**: this skill; accepts any Copilot CLI task and dispatches to the correct operation sub-skill without executing commands itself.
- **Headless invocation**: running `copilot` with `-p` (prompt), `-s` (single-turn), and `--allow-all-tools` for non-interactive output.
- **Adversarial perspective**: a code review or analysis explicitly run via a non-Anthropic model to obtain a second opinion. The model for adversarial review is caller-supplied via `--model`; the skill does not pin a default.

## Intent

The skill must enable a host agent to:

- Accept a natural-language Copilot CLI task from a caller (e.g. "do a copilot review of these changes").
- Identify which operation the task belongs to.
- Load and dispatch to the correct operation sub-skill, passing the task and any context the sub-skill requires.
- Handle ambiguous tasks by asking for clarification rather than guessing.
- Note remaining work when a task spans multiple operations.

The host agent should never need to know:

- Which Copilot CLI flags exist, what they mean, or how they combine.
- How to construct a prompt that produces a structured Copilot response.
- How to parse Copilot's markdown output into findings.
- Which models are available or selectable via `--model`.
- Threat-model implications of `--allow-all-tools`.

All of that lives inside the dispatched sub-skill.

## Operation Routing Table

| Operation | Sub-skill | Handles |
| --- | --- | --- |
| review | review/ | Code review of a change set; returns structured findings + raw markdown. |
| ask | ask/ | General query / advice; returns Copilot's plain text answer. |
| explain | explain/ | Explain a code region / file; returns explanatory markdown. |

## Requirements

- The router must not attempt `copilot` commands directly. All execution happens inside operation sub-skills.
- Copilot CLI availability must be verified by the dispatched sub-skill at the start of its run (not by the router) — fail-fast if `copilot --version` is not resolvable.
- One operation is handled per invocation. Multi-operation tasks are split: primary operation runs, remaining operations are reported to the caller.
- Operation ambiguity must be resolved by asking the caller — never assume.
- The router must NOT inject default flags, model names, or prompts. The sub-skill owns those choices.
- The router must NOT see or log Copilot's raw output — it only returns the sub-skill's structured result to the caller.

## Behavior

The router accepts a Copilot CLI task in natural language. It identifies the target operation by matching the task to the Operation Routing Table, loads the corresponding sub-skill, and forwards the full task plus any context the caller provided. If the task spans multiple operations, the router executes the primary operation and reports the remaining operations to the caller without dispatching them. If the operation cannot be determined, the router asks the caller for clarification before proceeding.

## Error Handling

If no operation matches the task, the router must ask the caller for clarification — it must not guess or default to any operation. If the dispatched sub-skill reports `copilot` is not installed or authentication failed, the router surfaces that result unchanged to the caller and stops. The router must NOT attempt installation or authentication recovery — those are operator-only concerns.

## Precedence Rules

Sub-skill availability check takes precedence over routing — if the targeted sub-skill is missing, the router must report that and stop. Clarification takes precedence over guessing when operation is ambiguous. Primary-operation execution takes precedence over multi-operation splitting when the task is clear.

## Constraints

- Does not execute any `copilot` subcommand itself.
- Does not manage routing state across multiple invocations.
- Does not validate the caller's input before routing — that is the sub-skill's responsibility.
- Does not embed flag knowledge, prompt templates, or threat-model guidance — those live in sub-skills.
- Does not name specific Anthropic or Copilot model versions in this spec or the runtime card. Model selection lives in sub-skills with their own staleness anchors.

## Don'ts

- Do not extend this skill with operation-specific logic. New operations require new sub-skill folders.
- Do not couple this skill to `code-review` or any orchestrator. This skill is the single-CLI surface; orchestration is a separate skill.
- Do not document flag mechanics, prompt structure, or `--allow-all-tools` threat model in the runtime card. Sub-skills own those.
- Do not silently fallback when an operation is ambiguous. Always ask.
- Do not pass through caller-supplied free-form CLI flags. Sub-skills construct flags from structured task arguments only — direct flag pass-through is a security regression (caller could inject `--allow-all-tools` patterns the sub-skill does not sanction).

## Lessons / Don'ts (carry-forward from prior draft)

- **`--allow-all-tools` is dangerous.** Any sub-skill that uses it must document the threat model and constrain the working directory. Do not surface this flag at the router level.
- **Markdown output is not structured.** Sub-skills must parse Copilot's response into a typed result before returning. Returning raw markdown to the caller defeats the purpose of dispatch.
- **Model availability changes.** Sub-skills must handle "model not available" as a normal failure mode, not a hard error.
- **Prior wrapper-script draft was wrong direction.** Skills don't ship scripts; this is a dispatch skill, period. See `notes/copilot-review-skill-direction-2026-04-25.md` (Curator-only).
