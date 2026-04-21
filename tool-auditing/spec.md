---
name: tool-auditing
description: >-
  Spec for auditing tool scripts — verify companion spec exists, script
  follows conventions, parameters documented, output predictable.
---

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

### Out of Scope

- Executing the script (audit is read-only)
- Evaluating script logic correctness
- Performance testing
- Security review (separate skill)

## Requirements

### Audit Checklist

#### Normative

For each tool script found:

1. **Companion spec exists**: `<name>.spec.md` in same directory. FAIL if missing.
2. **Parameter block**: Script has a param/usage block at top. WARN if missing.
3. **No hardcoded paths**: No absolute paths in script. FAIL if found.
4. **Error handling**: Bash has `set -e` or equivalent. PowerShell has `$ErrorActionPreference`. WARN if missing.
5. **Self-documenting**: Comments or parameter descriptions present. WARN if sparse.
6. **No interactive input**: No `Read-Host`, `read -p`, or similar. FAIL if found.
7. **Output format**: Consistent format (markdown/JSON/text). WARN if mixed or unclear.

### Report Format

#### Report Normative

```txt
# Tool Audit: <script-name>

- Status: PASS | FAIL | WARN
- Companion spec: YES/NO
- Checks: X/7 passed

| # | Check | Status | Notes |
|---|-------|--------|-------|
```

## Constraints

- Read-only. Never modify scripts.
- Haiku-class model sufficient for this audit.
- Report only — caller decides remediation.

## Precedence

- tool-writing spec defines what's correct; this skill checks against it.
