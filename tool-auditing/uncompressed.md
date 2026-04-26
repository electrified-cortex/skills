# Tool Auditing — Uncompressed Reference

Audit tool scripts for completeness and convention compliance. Lightweight — haiku-class models can run it.

## Purpose

Verify that tool scripts have companion specs, follow naming conventions, handle errors, and produce predictable output. Read-only audit; caller decides remediation.

## Scope

**In scope:**
- Checking for companion spec file existence
- Verifying script has parameter documentation
- Checking for hardcoded absolute paths
- Verifying error handling patterns
- Checking output format consistency

**Out of scope:**
- Executing the script (audit is read-only)
- Evaluating script logic correctness
- Performance testing
- Security review (separate skill)

## Definitions

- **Tool script:** a PowerShell or Bash script in the `tools/` directory that provides an operator-facing utility.
- **Companion spec:** the `<name>.spec.md` file co-located with a tool script that documents its purpose, parameters, and contract.
- **PASS:** all normative checks pass.
- **FAIL:** one or more FAIL-level checks fail — the script violates a hard convention.
- **WARN:** one or more WARN-level checks fail — missing recommended practices but not fatally non-conformant.

## Audit Checklist (per script)

| # | Check | Level | Criterion |
|---|-------|-------|-----------|
| 1 | Companion spec exists | FAIL | `<name>.spec.md` in same directory |
| 2 | Parameter block present | WARN | param/usage block at top of script |
| 3 | No hardcoded absolute paths | FAIL | no Windows-drive or POSIX-rooted absolute paths in script |
| 4 | Error handling present | WARN | Bash: `set -e` or equivalent; PowerShell: `$ErrorActionPreference` |
| 5 | Self-documenting | WARN | comments or parameter descriptions present |
| 6 | No interactive input | FAIL | no `Read-Host`, `read -p`, or similar |
| 7 | Consistent output format | WARN | one mode: markdown/JSON/plain text |

## Report Format

```markdown
# Tool Audit: <script-name>

- Status: PASS | FAIL | WARN
- Companion spec: YES/NO
- Checks: X/7 passed

| # | Check | Status | Notes |
|---|-------|--------|-------|
```

## Output

Report follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and `.gitignore` check before writing any report. Targets are `tools/**` -> target-kind is `tool`.

Verdict mapping (tool-auditing -> audit-reporting frontmatter): `PASS -> PASS`, `FAIL -> FAIL`, `WARN -> PASS_WITH_FINDINGS`.

## Iteration Safety

Do not re-audit unchanged files. See `../iteration-safety/SKILL.md`.

## Constraints

- Read-only. Never modify scripts.
- haiku-class model sufficient for this audit.
- Report only — caller decides remediation.

## Precedence

- `tool-writing` spec defines what is correct; this skill checks against it.

## Don'ts

- Do not modify any tool script — this audit is read-only in all modes.
- Do not batch-audit multiple tools in a single dispatch invocation unless the skill explicitly supports it.
- Do not infer intent — findings must be grounded in explicit file content.

## Related

- `tool-writing` — conventions this audit enforces
- `skill-auditing` — analogous audit for skill files
- `spec-auditing` — analogous audit for spec files
