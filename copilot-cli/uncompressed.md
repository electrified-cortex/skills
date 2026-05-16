# Copilot CLI — Uncompressed Reference

## Purpose

The host agent should never need to know which Copilot CLI flags exist, how to construct a prompt for structured Copilot output, how to parse Copilot's markdown output, which models are available, or the threat-model implications of `--allow-all-tools`. All of that lives inside the dispatched sub-skill.

## Operation Routing Table

| Operation | Sub-skill | Handles |
| --- | --- | --- |
| `review` | `review/` | Code review of a change set; returns structured findings + raw markdown |
| `ask` | `ask/` | General query / advice; returns plain text answer |
| `explain` | `explain/` | Explain a code region / file; returns explanatory markdown |

## Behavior

1. Accept a Copilot CLI task in natural language from the caller.
2. Identify the target operation by matching to the routing table.
3. Before dispatching, check the capability cache (see `capability-cache/SKILL.md`):
   - Cache HIT with `result: unavailable` — skip all CLI invocations; return `Status: UNAVAILABLE` immediately.
   - Cache HIT with `result: available` — use cached model list; skip re-probe.
   - Cache MISS — proceed to dispatch; probe happens inside the sub-skill; cache is populated on first run.
   - `capability-cache` not installed — treat as MISS; proceed normally.
4. Load and dispatch to the correct operation sub-skill, passing the full task and any context the caller provided.
5. If the task spans multiple operations: execute the primary operation; report remaining operations to the caller without dispatching them.
6. If the operation cannot be determined: ask the caller for clarification. In non-interactive flows, return `Status: NEEDS_CLARIFICATION`.

## Result Envelope

```text
Status: CLEAN | FINDINGS | OK | ERROR | UNAVAILABLE | NEEDS_CLARIFICATION
<sub-skill result fields>
Source: <sub-skill name>
```

`UNAVAILABLE` and `NEEDS_CLARIFICATION` originate from the router. All other statuses pass through from sub-skills unchanged.

## Requirements

- The router must not attempt `copilot` commands directly. All execution happens inside operation sub-skills.
- Copilot CLI availability is verified by the dispatched sub-skill at the start of its run, not by the router.
- One operation is handled per invocation.
- Operation ambiguity must be resolved by asking — never assume.
- The router must NOT inject default flags, model names, or prompts. The sub-skill owns those choices.
- The router must NOT see or log Copilot's raw output — it only returns the sub-skill's structured result.

## Error Handling

- No operation match: ask the caller for clarification. Do not guess or default.
- Sub-skill missing: report that and stop. Do not attempt to run the operation without the sub-skill.
- Sub-skill reports `copilot` not installed or authentication failed: surface the result unchanged and stop. Do not attempt installation or authentication recovery.

## Precedence Rules

- Sub-skill availability check takes precedence over routing — if the targeted sub-skill is missing, report and stop.
- Clarification takes precedence over guessing when operation is ambiguous.
- Primary-operation execution takes precedence over multi-operation splitting when the task is clear.

## Definitions

- **Operation:** a category of Copilot CLI tasks handled by a dedicated sub-skill (`review`, `ask`, `explain`).
- **Sub-skill:** a skill that handles one operation's full surface, including flag assembly, prompt framing, CLI invocation, and output parsing.
- **Router:** this skill; accepts any Copilot CLI task and dispatches to the correct operation sub-skill.
- **Headless invocation:** running `copilot` with `-p` (prompt), `-s` (single-turn), and `--allow-all-tools` for non-interactive output.

## Constraints

- Does not execute any `copilot` subcommand itself.
- Does not manage routing state across multiple invocations.
- Does not embed flag knowledge, prompt templates, or threat-model guidance — those live in sub-skills.
- Does not name specific model versions here or in the runtime card. Model selection lives in sub-skills.
- Does not pass through caller-supplied free-form CLI flags — direct flag pass-through is a security regression.

## Don'ts

- Do not extend this skill with operation-specific logic. New operations require new sub-skill folders.
- Do not silently fallback when an operation is ambiguous. Always ask.
- Do not document flag mechanics, prompt structure, or `--allow-all-tools` threat model in the runtime card. Sub-skills own those.
- Do not pass through caller-supplied free-form CLI flags.
