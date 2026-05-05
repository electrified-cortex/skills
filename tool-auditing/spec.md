# Tool Auditing — Spec

Audit tool scripts for completeness and convention compliance.

## Purpose

Verify that tool scripts have companion specs, follow naming conventions,
handle errors, and produce predictable output. Lightweight audit that
haiku-class models can run.

## Scope

### In Scope

- Checking for companion spec file existence
- Verifying script has parameter documentation
- Checking for hardcoded absolute paths
- Verifying error handling patterns
- Checking output format consistency

### Out of scope

- Executing the script (audit is read-only)
- Evaluating script logic correctness
- Performance testing
- Security review (separate skill)

## Definitions

- **Tool script**: a PowerShell or Bash script that provides an operator-facing utility.
- **Tool trio**: the three co-located files that constitute a complete tool — `<stem>.sh`, `<stem>.ps1`, and `<stem>.spec.md`. All three must be present.
- **Companion spec**: the `<stem>.spec.md` file co-located with a tool script that documents its purpose, parameters, and contract.
- **PASS**: all normative checks pass — the script meets conventions.
- **FAIL**: one or more FAIL-level checks fail — the script violates a hard convention.
- **WARN**: one or more WARN-level checks fail — the script is missing recommended practices but not fatally non-conformant.
- **fast-cheap**: a lightweight, fast model class (Haiku-class) sufficient for read-only checklist auditing.

## Requirements

### Audit Checklist

#### Normative

For each tool trio found:

1. **Complete trio exists**: `<stem>.sh`, `<stem>.ps1`, and `<stem>.spec.md` all present in the same directory. FAIL if any missing.
2. **Spec alignment**: companion spec describes this tool and intent aligns with each shell variant's implementation. FAIL if not.
3. **Parameter block**: Script has a `# Usage:` comment block within the first 20 lines. WARN if missing.
4. **No hardcoded paths**: No absolute paths in script. FAIL if found.
5. **Error handling**: Bash has `set -e` or equivalent. PowerShell has `$ErrorActionPreference`. WARN if missing.
6. **Self-documenting**: Comments or parameter descriptions present. WARN if sparse.
7. **No interactive input**: No `Read-Host`, `read -p`, or similar. FAIL if found.
8. **Output format**: Consistent format (markdown/JSON/text). WARN if mixed or unclear.

### Report Format

#### Report Normative

```txt
# Result

PASS | PASS_WITH_FINDINGS | FAIL

| # | Check | Variant | Status | Notes |
|---|-------|---------|--------|-------|
```

## Constraints

- Read-only. Never modify scripts.
- fast-cheap model sufficient for this audit.
- Report only — caller decides remediation.

## Iteration Safety

Do not re-audit unchanged files.
See `../iteration-safety/SKILL.md`.

## Precedence

- tool-writing spec defines what's correct; this skill checks against it.

## Don'ts

- Do not modify any tool script — this audit is read-only in all modes.
- Do not batch-audit multiple tools in a single dispatch invocation unless the skill explicitly supports it.
- Do not infer intent — findings must be grounded in explicit file content.
