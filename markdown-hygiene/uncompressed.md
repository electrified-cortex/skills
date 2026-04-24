---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

# Markdown Hygiene

Dispatch (Dispatch agent, zero context):
"Read and follow `instructions.txt` (in this directory).
Input: `file_path=<path> result_file=<path>`"

- `file_path` (required): Absolute path to .md file
- `result_file` (required): Absolute path for report
- `--source X --target Y` (optional): Read X, fix,
  write to Y. No git check.

Modes: `--source/--target` → source untouched;
default → in-place if tracked+clean;
fallback → `.fixed` alongside.

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

If `markdownlint` CLI or VS Code extension is available, use it directly instead of dispatching. See `tooling.md` (co-located).

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Target-kind is derived at runtime from the actual target file path.

Verdict mapping (markdown-hygiene → audit-reporting frontmatter): `CLEAN → PASS`, `FIXED → PASS_WITH_FINDINGS`, `PARTIAL → NEEDS_REVISION`.

Caller must compute `result_file` using the audit-reporting path shape before dispatch.

## Iteration Safety

Two rules exist to prevent wasted-work loops where an agent runs repeated
hygiene passes against the same file with no content change between runs.

Rule A — Fix before re-check: If a hygiene pass produces findings (FIXED
or PARTIAL result), apply those fixes — or surface them for author action
— before running another hygiene pass against the same file. Running
another pass without acting on prior findings is forbidden.

Rule B — Never re-check unchanged content: "Never re-audit a file that
has not been modified since the previous audit, period, full stop." If
the file's content is unchanged since the last hygiene verdict, the
result is deterministic and a re-pass is wasted work.

The caller must verify, before dispatching a follow-up hygiene pass, that
the target file has changed since the previous pass completed. If the file
is unchanged, the prior verdict stands and re-dispatch is forbidden.

Related: `compression` (run hygiene after compressing),
`skill-auditing` (includes hygiene check), `spec-writing`
