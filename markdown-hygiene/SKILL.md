---
name: markdown-hygiene
description: Fix all markdownlint violations in a .md file. Zero errors gate. Dispatch skill.
---

Dispatch (Dispatch agent, haiku-class, zero context):
"Read and follow `instructions.txt` (in this directory).
Input: `file_path=<path>`"

`file_path` (required): absolute path to .md file
`--source X --target Y` (optional): read X, fix, write Y. No git check.
`--ignore <RULE>[,<RULE>...]` (optional): suppress rule codes this run. Example: `--ignore MD041` for skill files with intentionally absent H1.

Modes: `--source/--target` → source untouched;
default → in-place if tracked+clean;
fallback → `.fixed` alongside.

Returns: CLEAN (0 errors), FIXED (errors→0), or PARTIAL (unfixable remain).

Run after compression, before stamping, before committing .md files.

If `markdownlint` CLI or VS Code extension available, use directly instead of dispatching. See `tooling.md` (co-located).

Output:
Follows `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (target-kind), frontmatter requirements, .gitignore check before writing. Target-kind derived at runtime from target file path.
Verdict mapping: `CLEAN → PASS`, `FIXED → PASS_WITH_FINDINGS`, `PARTIAL → NEEDS_REVISION`.
Report path computed via audit-reporting path shape.

Iteration Safety:
Don't re-audit unchanged files. See `../iteration-safety/SKILL.md`.

Related: `compression` (run hygiene after compressing), `skill-auditing` (includes hygiene check), `spec-writing`
