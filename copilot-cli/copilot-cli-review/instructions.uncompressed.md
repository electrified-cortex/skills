# copilot-cli-review — Instructions

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

MAY add `--output-format=json` when structured output is needed AND the installed version supports the flag. Prefer JSON; fall back to markdown parsing otherwise.

Long-form equivalence: `--no-ask-user --prompt "<prompt>"` is equivalent to `-p "<prompt>" -s`. New invocations MUST use the canonical short form.

Constrain `working_dir` to the target repo — never `/`, `~`, or directories containing secrets.

## Prompt Template

Embed all diff or file content inline. There is no file-input flag — serialize content into the prompt string.

```text
Review the following change set for correctness, security vulnerabilities, and code quality.
Return a structured findings list. Each finding must include:
  severity: blocker | major | minor | nit
  file: <path>
  line: <line number or range>
  description: <one sentence>
If there are no issues, respond with exactly: No findings.

<inline diff or file content>
```

Severity vocabulary is fixed: `blocker / major / minor / nit`.

## Output Shape

```text
Status: CLEAN | FINDINGS | UNAVAILABLE | ERROR
Findings:
  - severity: blocker | major | minor | nit
    file: <path>
    line: <number or range>
    description: <one sentence>
Raw: <Copilot's full response, JSON or markdown>
```

| Status | Condition |
| --- | --- |
| `CLEAN` | Copilot responded with exactly "No findings." |
| `FINDINGS` | One or more findings returned |
| `UNAVAILABLE` | `copilot --version` failed before invocation |
| `ERROR` | Non-zero exit code or unparseable output |

Severity normalization: `critical` → `blocker`, `nitpick` → `nit`, others coerce to nearest or flag in description.

## Error Handling

| Condition | Action |
| --- | --- |
| `copilot --version` fails | `Status: UNAVAILABLE`; surface stderr; stop |
| Binary exits non-zero | `Status: ERROR`; surface stderr; stop |
| Output unparseable | `Status: ERROR`; include raw; stop |
| Model not available | `Status: ERROR`; do not retry with different model |

## Rules

- Do not return raw Copilot output — parse to the output shape first.
- One repo per invocation. Do not fan out across directories.
- Do not bake in a specific CLI version assumption — detect, then use.
- Do not install, update, or upgrade Copilot CLI.
- Do not advise on severity thresholds — that is the caller's policy.
