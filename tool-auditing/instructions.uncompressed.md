# Tool Auditing

## Procedure

**Hard prohibition:** do NOT author scripts (`.ps1`, `.sh`, `.py`, etc.), helper files, or any file other than `<report_path>`. Trio members are read-only. Use Read/Bash/Grep only for inspection.

1. **Resolve the trio** from `tool_path`:
   - Derive `<stem>`:
     - filename ends with `.spec.md` -> stem = filename minus `.spec.md`
     - filename ends with `.sh` -> stem = filename minus `.sh`
     - filename ends with `.ps1` -> stem = filename minus `.ps1`
     - other -> `ERROR: unsupported tool extension`, stop.
   - `<dir>` = `dirname(tool_path)`.
   - `sh_path` = `<dir>/<stem>.sh` (may not exist)
   - `ps1_path` = `<dir>/<stem>.ps1` (may not exist)
   - `spec_path` = `<dir>/<stem>.spec.md` (may not exist)

2. **Trio-first short-circuit**: evaluate Check 1 immediately. If Check 1 FAILs, skip Checks 2-8. Write the report with `result: fail`, body containing only the Check 1 row + a Findings block enumerating each missing member with its Fix. Return `done`.

3. **Run Checks 2-8** against the resolved trio (all three members guaranteed present). Levels: FAIL (blocking) or WARN (non-blocking). Check 2 is trio-level (one row). Checks 3-8 are **per-variant** — one row per shell variant; since Check 1 passed, both `.sh` and `.ps1` exist, so Checks 3-8 always produce exactly two rows each.

   **Check 1 — Complete trio exists** (FAIL, evaluated in step 2):
   - PASS if all three of `<stem>.sh`, `<stem>.ps1`, and `<stem>.spec.md` exist in `<dir>`.
   - FAIL otherwise. Fix: list each missing member. For a missing shell variant: "create `<stem>.<ext>` with parity to `<existing>.<other-ext>` per spec." For a missing spec: "create `<stem>.spec.md` with Purpose / Parameters / Output Contract / Constraints sections."

   **Check 2 — Spec describes THIS tool and intent aligns with implementation** (FAIL, trio-level):
   - Read the spec and EACH existing shell variant.
   - PASS if ALL of the following hold:
     - Spec references the tool by `<stem>`, full filename, or unambiguous title (e.g. spec for stem `result` mentions `result` in title or first paragraph).
     - Spec has a `## Purpose` (or equivalent intent-statement) section describing what the tool does.
     - Spec's described purpose is coherent with what each existing shell variant actually implements — inputs, outputs, side effects, and core behavior match. Minor wording divergence is OK; semantic divergence is not (e.g. spec says "read-only" but a shell writes; spec says "takes one arg" but a shell takes two; spec describes a different tool entirely; spec describes only the `.sh` and the `.ps1` does something different).
   - FAIL if any condition fails. Fix: name the specific divergence — `spec describes <X> but <variant> does <Y>`, or `spec missing Purpose section`, or `spec appears to describe a different tool (mentions <other-name>)`, or `spec covers only .sh; .ps1 implements different behavior`. Imperative: align spec to scripts (or fix scripts to match spec, whichever is correct).

   **Checks 3-8 — per shell variant** (run separately for each of `sh_path`, `ps1_path`; both are present when Check 1 passes):

   **Check 3 — Parameter / usage block at top** (WARN):
   - PASS if the script has a `# Usage:` line within the first 20 lines.
   - WARN otherwise. Fix: add a `# Usage: <script-name> <args>` comment block at the top.

   **Check 4 — No hardcoded absolute paths** (FAIL):
   - PASS if the script has no Windows drive-letter paths (`<letter>:[/\\]`) or POSIX root paths (`/Users/`, `/home/`, `/d/`, `/c/`, `/mnt/`).
   - FAIL otherwise. Fix: replace each absolute path with a parameter, env var, or repo-relative computation. List each offending line.

   **Check 5 — Error handling** (WARN):
   - Bash: PASS if `set -e` (or `set -o errexit`) appears in first 30 lines.
   - PowerShell: PASS if `$ErrorActionPreference` is set in first 30 lines.
   - WARN otherwise. Fix: add appropriate error-handling preamble.

   **Check 6 — Self-documenting** (WARN):
   - PASS if comment-line ratio is at least 1 comment per 10 lines OR the `# Usage:` block has parameter descriptions.
   - WARN otherwise. Fix: add comments explaining the major logical blocks.

   **Check 7 — No interactive input** (FAIL):
   - PASS if no `Read-Host`, `read -p`, `read -r` (without `<<<` or pipe), or `Get-Credential` patterns appear.
   - FAIL otherwise. Fix: replace interactive input with arguments or env vars.

   **Check 8 — Consistent output format** (WARN):
   - Inspect the script's stdout-producing patterns (`echo`, `printf`, `Write-Output`, `[Console]::Out.Write`, `Write-Host`).
   - PASS if a single output mode is used (markdown, JSON, plain text, key-value).
   - WARN if mixed (e.g. `Write-Host` + `Write-Output`, or JSON + plain text). Fix: name the chosen mode and convert all stdout to it.

4. **Determine verdict** (after trio short-circuit OR after running Checks 2-8 across all variants):
   - All checks PASS across the trio -> `pass`
   - Any FAIL anywhere (Check 1, Check 2, or any per-variant FAIL-level check) -> `fail`
   - Only WARNs (no FAIL) -> `pass-with-findings`

5. **Write report** at `<report_path>` (overwrite if present):
   - `mkdir -p $(dirname <report_path>)`
   - Frontmatter (open `---`, close `---`):
     - `file_paths:` — YAML list, **repo-relative paths** to ALL existing trio members (sh / ps1 / spec). **"Repo-relative" means: paths relative to the git repo that owns the cache record being written.** Resolve via `git -C <dir-containing-the-target-files> rev-parse --show-toplevel` and strip that prefix from each absolute path. The same repo root governs the cache directory layout (`<repo-root>/.hash-record/...`), so the report's `file_paths:` and the cache location are always under the same root.
     - `operation_kind: tool-auditing`
     - `model:` MUST be one of `haiku-class`, `sonnet-class`, or `opus-class` — the executor's tier in semantic terms. NEVER write a literal model identifier (e.g. `claude-sonnet-4-6`) — model ids drift; class labels are stable cache keys.
     - `result: pass | pass-with-findings | fail`
   - Body opens with `# Result` H1, then verdict word, then a single checks table covering trio-level checks AND per-variant checks (the `Variant` column distinguishes shell-specific rows; `-` for trio-level):

     ```text
     # Result

     <PASS | PASS_WITH_FINDINGS | FAIL>

     | # | Check | Variant | Status | Notes |
     | --- | --- | --- | --- | --- |
     | 1 | Complete trio exists | - | PASS / FAIL | <notes> |
     | 2 | Spec describes this tool, intent aligns | - | PASS / FAIL | <notes> |
     | 3 | Parameter/usage block | sh | PASS / WARN | <notes> |
     | 3 | Parameter/usage block | ps1 | PASS / WARN | <notes> |
     | 4 | No absolute paths | sh | PASS / FAIL | <notes> |
     | 4 | No absolute paths | ps1 | PASS / FAIL | <notes> |
     | 5 | Error handling | sh | PASS / WARN | <notes> |
     | 5 | Error handling | ps1 | PASS / WARN | <notes> |
     | 6 | Self-documenting | sh | PASS / WARN | <notes> |
     | 6 | Self-documenting | ps1 | PASS / WARN | <notes> |
     | 7 | No interactive input | sh | PASS / FAIL | <notes> |
     | 7 | No interactive input | ps1 | PASS / FAIL | <notes> |
     | 8 | Consistent output format | sh | PASS / WARN | <notes> |
     | 8 | Consistent output format | ps1 | PASS / WARN | <notes> |

     ## Findings

     - Check 2 FAIL: spec Purpose says "read-only verification" but `result.sh` writes report at `<report_path>`
       Fix: update spec Purpose to describe write behavior, or remove the write.
     - Check 4 FAIL `result.ps1` line 42: hardcoded absolute path (drive-letter prefix)
       Fix: replace with `$BASE_DIR` from caller environment.
     - Check 5 WARN `verify.ps1`: `$ErrorActionPreference` not set
       Fix: add `$ErrorActionPreference = 'Stop'` near the top.
     ```

     When Check 1 passes, both shell variant rows are always present (sh + ps1 guaranteed).

6. **Scrub absolute paths from the entire report — frontmatter `file_paths`, Notes columns, Findings, ALL prose.** This includes paths quoted as evidence from the audited source, even when citing line numbers. Forbidden tokens: any Windows drive-letter path (`<letter>:[/\\]`), any POSIX root-anchored path (`/Users/`, `/home/`, `/d/`, `/c/`, `/mnt/`, `/tmp/`, `/var/`). When citing evidence that contains such a path, describe it abstractly ("hardcoded drive-letter path on line N", "POSIX root path under `/Users/`") rather than quoting the literal path. The report body MUST be safe to share publicly. Use **repo-relative paths** (relative to the git repo root identified in step 5) for any path referenced in Findings.

7. **Return** the literal string `done` on success. On any failure, return `ERROR: <reason>`.
