# Markdown-Hygiene Eval

Records the validation regime for markdown-hygiene. Two layers: deterministic shell tools (verify, result) with byte-equal cross-shell parity, plus an end-to-end host-orchestrated flow dogfooded against real workspace files.

## Architecture under test

- **Host** (`SKILL.md` / `uncompressed.md`): orchestrates result-check -> dispatch -> result-check (post-execute) -> iterate.
- **Executor** (`instructions.txt` / `instructions.uncompressed.md`): runs verify, scans remaining rules, writes report at caller-supplied `<report_path>`, returns `done`.
- **Result tool** (`result.{sh,ps1}` / `result.spec.md`): wraps `hash-record-check` and translates HIT into the cached verdict (`CLEAN` / `findings: <path>` / `MISS: <path>` / `ERROR`).
- **Verify tool** (`verify.{sh,ps1}` / `verify.spec.md`): deterministic mechanical-rule pre-pass. Covers MD009, MD010, MD012, MD041, MD047. Output is consumed verbatim by the executor.

## Test infrastructure

Fixtures + eval suite at `.tests/verify/`:

| File | Rule triggered | Expected output |
| --- | --- | --- |
| `clean.md` | none | `CLEAN` |
| `trailing-spaces.md` | MD009 | violation pair |
| `tabs.md` | MD010 | violation pair |
| `blanks.md` | MD012 | violation pairs |
| `no-frontmatter-no-h1.md` | MD041 | violation pair |
| `no-trailing-newline.md` | MD047 | violation pair |

Each fixture has a companion `<name>.expected.txt` containing byte-comparable expected stdout.

`verify.test.sh` and `verify.test.ps1` run every fixture against the respective shell, diff stdout vs `.expected.txt`, exit 0 on all-pass / 1 on any fail.

## Validation runs

### Cross-shell parity (verify)

`verify.sh` and `verify.ps1` produce byte-identical stdout on every fixture. Confirmed via in-place diff. 6/6 PASS in both shells.

### Cross-shell parity (result)

`result.sh` and `result.ps1` produce byte-identical stdout on real workspace files (tested on `result.spec.md`, `SKILL.md`, `instructions.txt`, and others). Result delegates to `hash-record-check` which already has its own cross-shell parity test in `hash-record/hash-record-check/`.

### End-to-end dogfood

Pick any `.md` file in the workspace and run the host orchestration:

1. `bash result.sh <file>` -> `MISS: <report_path>` (first run, no cache yet).
2. Dispatch the executor (haiku-class) with `--report-path <report_path>`.
3. Executor returns the literal string `done`.
4. `bash result.sh <file>` again -> `CLEAN` or `findings: <report_path>`.
5. On `findings`, host iterates: dispatch fix pass (sonnet-class), re-enter at step 1.

A successful run leaves a hash-record entry under `<repo-root>/.hash-record/<sh>/<hash>/markdown-hygiene/report.md` with valid frontmatter (`file_path` repo-relative, `operation_kind`, `result: pass | findings`) and a body that opens with `# Result`.

## Eval invariants

- Verify output is deterministic. Same input bytes -> same output bytes, every time, every shell.
- Result tool output is deterministic and matches `hash-record-check`'s 40-character lowercase git hash output.
- Executor returns ONLY `done` or `ERROR: <reason>`. Verbal compliance is irrelevant — disk truth (the report at `<report_path>`) is the source of truth, validated by post-execute result.
- ASCII-strict output everywhere. No Unicode arrows, em-dashes, or curly quotes in tool stdout or report bodies.
- Report `file_path` is repo-relative, never absolute. Pre-commit hook backstops abs-path leaks.

## Status

Architecture: shipped.
Cross-shell parity: green.
Test fixtures: 6/6 PASS in both shells.
End-to-end dogfood: green on real workspace files.

## Pending

- Verify per-rule pass/fail/unsure status reporting (task #34) — extend output contract so verify reports every rule it knows about, not just failures. Eval suite + test fixtures expand to validate the new contract.
- Universal pattern propagation (#32, #33) — same host-owns-cache + preflight-twice shape applies to skill-auditing once `hash-record-manifest` ships as a deterministic tool (#29).
