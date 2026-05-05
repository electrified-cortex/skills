# copilot-cli-explain — Expanded Reference

Full operational reference for the explain sub-skill. Compressed form: `SKILL.md`.

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

Constrain working directory to the repo containing the target file — never `/`, `~`, or a directory containing secrets.

## Prompt Construction

Frame the prompt to request an explanation:

```text
Explain the following code. Describe what it does, why it works that way, and any
non-obvious behavior. Be concise.

<inline code content>
```

Replace `<inline code content>` with the caller-supplied content serialized to a string. Copilot CLI has no file-input flag; all content must be embedded inline.

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

- `copilot --version` fails → return `Status: UNAVAILABLE`; surface stderr; stop.
- Model unavailable → surface "model not available" and stop.
- Copilot exits non-zero → surface the stderr output as the error and stop.

## Rules

- Return the explanation verbatim in the `Explanation` field — do not summarize or reinterpret.
- One code region per invocation.
- Constrain the working directory to the repo containing the target file.
