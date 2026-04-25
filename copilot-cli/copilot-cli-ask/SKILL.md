---
name: copilot-cli-ask
description: General query or advice operation via the standalone Copilot CLI binary. Returns Copilot's plain text answer.
---

Runs `copilot` to answer a general question or provide advice. Dispatched by the `copilot-cli` router.

## Prerequisites

```bash
copilot --version   # must resolve; fail-fast if not
```

If this fails: surface the error to the caller and stop. Do NOT attempt installation.

## Invocation

```bash
copilot -p "<prompt>" -s --allow-all-tools
```

### Threat Model — `--allow-all-tools`

`--allow-all-tools` permits the Copilot CLI to read within the working directory. For ask operations, set the working directory to the relevant repo or a neutral directory. Never run in `/`, `~`, or any directory containing secrets.

## Prompt Construction

Pass the caller's question directly. Prepend context if supplied:

```
<context if any>

<caller's question>
```

Do not add framing or instructions — the ask operation passes the caller's intent through unchanged.

## Output Parsing

Return Copilot's response as a structured result:

```
Status: OK | ERROR
Answer: <Copilot's plain text response>
```

## Error Handling

- `copilot --version` fails → surface "copilot not installed" and stop.
- Model unavailable → surface "model not available" and stop.
- Copilot exits non-zero → surface the stderr output as the error and stop.

## Rules

- Do not interpret or filter Copilot's answer — return it verbatim in the `Answer` field.
- One question per invocation.
