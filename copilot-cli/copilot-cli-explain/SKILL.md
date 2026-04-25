---
name: copilot-cli-explain
description: Explain operation via the standalone Copilot CLI binary. Returns an explanatory markdown description of a code region or file.
---

Runs `copilot` to explain a code region or file. Dispatched by the `copilot-cli` router.

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

`--allow-all-tools` permits the Copilot CLI to read within the working directory. Set the working directory to the repo containing the target file. Never run in `/`, `~`, or any directory containing secrets.

## Prompt Construction

Frame the prompt to request an explanation:

```
Explain the following code. Describe what it does, why it works that way, and any
non-obvious behavior. Be concise.

<code region or file path>
```

Replace `<code region or file path>` with the caller-supplied content (file path, function name, or pasted code block).

## Output Parsing

Return Copilot's response as a structured result:

```
Status: OK | ERROR
Explanation: <Copilot's markdown explanation>
```

## Error Handling

- `copilot --version` fails → surface "copilot not installed" and stop.
- Model unavailable → surface "model not available" and stop.
- Copilot exits non-zero → surface the stderr output as the error and stop.

## Rules

- Return the explanation verbatim in the `Explanation` field — do not summarize or reinterpret.
- One code region per invocation.
