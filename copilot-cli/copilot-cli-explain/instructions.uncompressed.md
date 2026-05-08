---
name: copilot-cli-explain
description: Explain operation via the standalone Copilot CLI binary. Returns an explanatory markdown description of a code region or file.
---

# copilot-cli-explain — Instructions

## Prerequisites

```bash
copilot --version   # must resolve; fail-fast if not
```

If this fails: return `Status: UNAVAILABLE`; surface stderr; stop. Do NOT attempt installation.

## Invocation

```bash
copilot -p "<prompt>" -s --allow-all-tools
```

MAY add `--model <model>` only when the caller explicitly supplied a model name. Omit otherwise; do not pin a model.

> **Note:** Specific model names (e.g. `gpt-4o`, `gpt-4.5`) may be unavailable via `--model`. Use the default unless the caller requires a named model and it's confirmed available.

Constrain the working directory to the repo containing the target file — never `/`, `~`, or directories containing secrets.

## Prompt Construction

Frame the prompt to request an explanation. Serialize all content inline — Copilot CLI has no file-input flag:

```text
Explain the following code. Describe what it does, why it works that way, and any
non-obvious behavior. Be concise.

<inline code content>
```

Replace `<inline code content>` with the caller-supplied content as a string.

## Output Shape

```text
Status: OK | ERROR | UNAVAILABLE
Explanation: <Copilot's markdown explanation>
```

| Status | Condition |
| --- | --- |
| `OK` | Copilot returned a response |
| `ERROR` | Binary returned non-zero exit code |
| `UNAVAILABLE` | `copilot --version` failed before invocation |

## Error Handling

| Condition | Action |
| --- | --- |
| `copilot --version` fails | `Status: UNAVAILABLE`; surface stderr; stop |
| Model unavailable | `Status: ERROR`; surface "model not available"; stop |
| Copilot exits non-zero | `Status: ERROR`; surface stderr; stop |

## Rules

- Return the explanation verbatim in the `Explanation` field — do not summarize or reinterpret.
- One code region per invocation.
- Constrain the working directory to the target file's repo.
