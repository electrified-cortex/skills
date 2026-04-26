# copilot-cli-review — Uncompressed Reference

Adversarial code-review pass via the standalone GitHub Copilot CLI binary. Produces structured findings in the canonical severity vocabulary so callers can aggregate Copilot output alongside other review backends without translation.

## When to dispatch this skill

- The caller wants a non-Claude review lane for a change set (git diff, file list, or inline content).
- The caller wants structured findings, not free-form Copilot chat.
- Copilot CLI is expected to be installed on the host.

Do NOT dispatch this skill to install Copilot CLI, fix findings, or handle other Copilot CLI operations (ask, explain). Those live in sibling sub-skills.

## Availability check (R1)

Before any review work, run:

```bash
copilot --version
```

If this fails for any reason: return immediately with `Status: UNAVAILABLE`, include the stderr output, and stop. Do not attempt installation or fallback.

## Invocation (R2, R2a, R2b)

### Canonical form (use for new invocations)

```bash
copilot -p "<prompt>" -s --allow-all-tools
```

Flag table:

| Flag | Meaning |
| --- | --- |
| `-p "<prompt>"` | Inline prompt string — embed all content here |
| `-s` | Single-turn (non-interactive, headless) |
| `--allow-all-tools` | Permits read/edit/exec in the working directory — see Safety |
| `--model <model>` | Only when caller explicitly supplies a model; omit otherwise |
| `--output-format=json` | MAY use when structured machine-readable output is needed AND the installed version supports the flag; prefer JSON when available, fall back to markdown parsing otherwise |

### Long-form alias equivalence (R2b)

When reading existing tool wrappers (e.g. `tools/copilot-review.ps1`) you may encounter:

```bash
copilot --no-ask-user --prompt "<prompt>"
```

Treat `--no-ask-user --prompt "<prompt>"` as equivalent to `-p "<prompt>" -s`. New invocations MUST use the canonical short form.

### Model selection (R3)

Pass `--model <model>` only when the caller supplied an explicit model name. Default to Copilot's built-in default; do not pin a model inside the skill. Report the version in use via `copilot --version` output in the Raw field for caller observability.

## Prompt template (R4, R5, R6)

Embed the diff or file content inline in the prompt string. There is no file-input flag; `-P` (uppercase) does not exist in the Copilot CLI. The prompt MUST request the canonical severity vocabulary and the clean signal:

```
Review the following change set for correctness, security vulnerabilities, and code quality.
Return a structured findings list. Each finding must include:
  severity: blocker | major | minor | nit
  file: <path>
  line: <line number or range>
  description: <one sentence>
If there are no issues, respond with exactly: No findings.

<inline diff or file content>
```

Replace the final placeholder with the caller-supplied context serialized as a string. Do not pass a file path — content must be inline.

Severity vocabulary is fixed: `blocker / major / minor / nit`. Do NOT instruct Copilot to use `critical` or `nitpick`; the prompt enforces the canonical labels directly.

## Output shape (R7)

Return this structure regardless of Copilot's raw output format:

```
Status: CLEAN | FINDINGS | UNAVAILABLE | ERROR
Findings:
  - severity: blocker | major | minor | nit
    file: <path>
    line: <number or range>
    description: <one sentence>
Raw: <Copilot's full response, JSON or markdown>
```

Status semantics (R7a):

| Status | Condition |
| --- | --- |
| `CLEAN` | Copilot responded with exactly "No findings." |
| `FINDINGS` | Copilot returned one or more findings |
| `UNAVAILABLE` | `copilot --version` failed before invocation |
| `ERROR` | Binary returned non-zero exit code OR output is unparseable |

### Severity normalization (R7b)

Apply before returning. Map any non-canonical labels:

| Copilot output | Canonical |
| --- | --- |
| `critical` | `blocker` |
| `nitpick` | `nit` |
| any other | coerce to nearest or flag in description |

All four canonical severities (`blocker`, `major`, `minor`, `nit`) pass through unchanged.

## Safety and working-dir constraint (R8, R9)

`--allow-all-tools` permits the Copilot CLI to read, edit, and execute within the working directory. This is a real threat surface.

- The caller MUST supply `working_dir` pointing to the target repo or worktree.
- This skill MUST enforce that constraint. Never run `copilot` in `/`, `~`, the workspace root, or any directory containing secrets or credentials.
- Agents MUST NOT waive this constraint even on operator request, unless the operator explicitly waives R8 for a single named call.

## Error states

| Condition | Action |
| --- | --- |
| `copilot --version` fails | Return `Status: UNAVAILABLE`; surface stderr; stop |
| Binary exits non-zero | Return `Status: ERROR`; surface stderr; stop |
| Output unparseable | Return `Status: ERROR`; include raw in `Raw:` field; stop |
| Model not available | Return `Status: ERROR`; do not retry with a different model |

## Rules

- One repo per invocation (DN3). Do not fan out across directories.
- Do not chain reviews across multiple directories in one call.
- Do not return raw Copilot markdown without parsing to the R7 structure (DN5).
- Do not bake a specific Copilot CLI version assumption in. Detect, then use (DN4).
- Do not advise the caller on which severity threshold to fail at — that is the caller's policy (DN2).
- Do not install, update, or upgrade Copilot CLI (C3).
- Do not retry with a different model on first failure (C4).
