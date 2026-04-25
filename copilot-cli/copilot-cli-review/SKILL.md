---
name: copilot-cli-review
description: Code review operation via the standalone Copilot CLI binary. Runs adversarial review of a change set and returns structured findings.
---

Runs `copilot` to perform a code review and returns structured findings. Dispatched by the `copilot-cli` router.

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

`--allow-all-tools` permits the Copilot CLI to read, edit, and execute within the working directory. Constrain the working directory to the repo under review. Never run in `/`, `~`, or any directory containing secrets or credentials.

## Prompt Construction

Frame the prompt as an adversarial review request:

```
Review the following change set for correctness, security issues, and code quality.
Respond with a structured list of findings. Each finding must include: severity
(critical/major/minor/nitpick), file path, line, and a one-sentence description.
If no issues are found, respond with: "No findings."

<diff or file list>
```

Replace `<diff or file list>` with the caller-supplied context (git diff, file paths, etc.).

## Output Parsing

Parse Copilot's markdown response into a structured result before returning:

```
Status: CLEAN | FINDINGS
Findings:
  - severity: <critical|major|minor|nitpick>
    file: <path>
    line: <number or range>
    description: <one sentence>
Raw: <Copilot's full markdown response>
```

If Copilot responds with "No findings.", return `Status: CLEAN` with an empty findings list.

## Error Handling

- `copilot --version` fails → surface "copilot not installed" and stop.
- Model unavailable → surface "model not available" and stop. Do not retry with a different model.
- Copilot exits non-zero → surface the stderr output as the error and stop.

## Rules

- Constrain working directory to the target repo — never run in an unconstrained path.
- Return the structured result, not raw markdown.
- One review per invocation; do not fan out across multiple directories.
