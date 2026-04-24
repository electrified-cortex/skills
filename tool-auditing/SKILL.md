---
name: tool-auditing
description: >-
  Audit tool scripts for companion spec, conventions, error handling.
  Lightweight — fast-cheap model can run it.
---

# Tool Auditing

Verify tool scripts follow conventions. Dispatch with fast-cheap model.

## Checklist (per script)

1. Companion spec (`<name>.spec.md`) in same dir — FAIL if missing.
2. Parameter/usage block at top of script — WARN if missing.
3. No hardcoded absolute paths (e.g., `D:\...`, `/home/...`) — FAIL if found.
4. Error handling: Bash `set -e` (or equivalent); PowerShell `$ErrorActionPreference` — WARN if missing.
5. Self-documenting: parameter descriptions or leading comments — WARN if sparse (fewer than one comment per logical block).
6. No interactive input (`Read-Host`, `read -p`, `Get-Credential`) — FAIL if found.
7. Consistent output format (markdown / JSON / plain text, one mode) — WARN if mixed or unclear.

## Report

```markdown
# Tool Audit: <script-name>

- Status: PASS | FAIL | WARN
- Companion spec: YES/NO
- Checks: X/7 passed

| # | Check | Status | Notes |
|---|-------|--------|-------|
```

Read-only. Report only — caller decides remediation.

## Output

Output follows the `audit-reporting` skill at `../audit-reporting/SKILL.md`. Apply its path shape (including target-kind), frontmatter requirements, and .gitignore check before writing any report. Targets are `tools/**` → target-kind is `tool`.

Verdict mapping (tool-auditing → audit-reporting frontmatter): `PASS → PASS`, `FAIL → FAIL`, `WARN → PASS_WITH_FINDINGS`. The internal `## Report` body may keep `WARN`; the YAML frontmatter `verdict` field must use audit-reporting vocabulary.

## Iteration Safety

Root cause: consecutive audits against an unchanged script waste work and can loop.

**Rule A — Fix before re-audit.** If verdict is FAIL or WARN, caller must resolve findings (fix or dispatch fix) before re-auditing the same script. Re-auditing without acting on prior findings is forbidden.

**Rule B — Never re-audit unchanged content.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." Verify the script has changed before dispatching a follow-up audit. If unchanged, the prior verdict stands; re-dispatch is forbidden.

Related: `tool-writing`, `skill-auditing`, `spec-auditing`
