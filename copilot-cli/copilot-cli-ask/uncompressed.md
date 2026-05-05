---
name: copilot-cli-ask
description: General query or advice operation via the standalone Copilot CLI binary. Returns Copilot's plain text answer.
---

# copilot-cli-ask — Expanded Reference

Full operational reference for the ask sub-skill. Compressed form: `SKILL.md`.

## Prerequisites

```bash
copilot --version   # must resolve; fail-fast if not
```

If this fails: return `Status: UNAVAILABLE`; surface stderr; stop. Do NOT attempt installation.

## Invocation

```bash
copilot -p "<prompt>" -s --allow-all-tools
```

MAY add `--model <model>` only when the caller explicitly supplied a model name. Omit otherwise; do not pin a model inside the skill.

Constrain working directory to a neutral path — never `/`, `~`, or a directory containing secrets.

## Prompt Construction

Pass the caller's question directly. Prepend context if supplied:

```text
<context if any>

<caller's question>
```

Do not add framing or instructions — prompt pass-through is verbatim.

## Output Shape

```text
Status: OK | ERROR | UNAVAILABLE
Answer: <Copilot's plain text response>
```

| Status | Condition |
| --- | --- |
| `OK` | Copilot returned a response |
| `ERROR` | Binary returned non-zero exit code |
| `UNAVAILABLE` | `copilot --version` failed before invocation |

## Error Handling

| Condition | Action |
| --- | --- |
| `copilot --version` fails | `Status: UNAVAILABLE`; set `Answer:` to stderr; stop |
| Caller-supplied model unsupported | `Status: ERROR`; set `Answer:` to "model not available: `<model>`"; stop |
| `copilot -p ...` exits non-zero | `Status: ERROR`; set `Answer:` to stderr; stop |
| `copilot -p ...` exits zero with empty stdout | `Status: OK`; set `Answer:` to empty string |

## Rules

- Do not interpret or filter Copilot's answer — return it verbatim in the `Answer` field.
- One question per invocation; do not chain questions.
- Do not pin a model; only pass `--model` when the caller explicitly supplies one.
