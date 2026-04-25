---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

Dispatch (Dispatch agent, zero context):
"Read and follow `instructions.txt` (in this directory).
Input: `file_path=<path>`"

`file_path` (required): absolute path to .md file
`--source X --target Y` (optional): read X, fix, write to Y. No git check.

Modes: `--source/--target` → source untouched;
default → in-place if tracked+clean;
fallback → `.fixed` alongside.

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

If `markdownlint` CLI or VS Code extension is available, use it directly instead of dispatching. See `tooling.md` (co-located).

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Target-kind is derived at runtime from the actual target file path.

Verdict mapping (markdown-hygiene → audit-reporting frontmatter): `CLEAN → PASS`, `FIXED → PASS_WITH_FINDINGS`, `PARTIAL → NEEDS_REVISION`.

Report path is computed internally using the audit-reporting path shape.

## Known Gotchas

MD060 (no auto-fix): `|---|---|` → must be `| --- | --- |`. markdownlint CLI
does not auto-fix this rule. Generated tables commonly produce the wrong form.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

Related: `compression` (run hygiene after compressing),
`skill-auditing` (includes hygiene check), `spec-writing`
