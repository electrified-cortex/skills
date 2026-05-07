---
file_paths:
  - hash-record/hash-record-check/check.ps1
  - hash-record/hash-record-check/check.sh
operation_kind: tool-auditing/v2
model: haiku-class
result: pass
---

# Result

PASS

| # | Check | Variant | Status | Notes |
| --- | --- | --- | --- | --- |
| 1 | Complete trio exists | - | PASS | check.ps1, check.sh, and check.spec.md all present. |
| 2 | Spec describes this tool, intent aligns | - | PASS | check.spec.md references tool by stem `check`, describes Purpose section, intent aligns with implementation: both variants probe cache, output HIT/MISS, read-only. |
| 3 | Parameter/usage block | sh | PASS | Usage comment present at line 2-3 in check.sh. |
| 3 | Parameter/usage block | ps1 | PASS | Usage comment present at line 2-3 in check.ps1. |
| 4 | No absolute paths | sh | PASS | No hardcoded Windows or POSIX root-anchored paths. |
| 4 | No absolute paths | ps1 | PASS | No hardcoded Windows or POSIX root-anchored paths. |
| 5 | Error handling | sh | PASS | set -e present at line 4 in check.sh. |
| 5 | Error handling | ps1 | PASS | $ErrorActionPreference = 'Continue' set at line 18 in check.ps1. |
| 6 | Self-documenting | sh | PASS | Usage section with parameter descriptions. Comment ratio adequate. |
| 6 | Self-documenting | ps1 | PASS | Usage section with parameter descriptions. Comment ratio adequate. |
| 7 | No interactive input | sh | PASS | No Read-Host, read -p, or Read-Credential patterns. |
| 7 | No interactive input | ps1 | PASS | No Read-Host, read -p, or Read-Credential patterns. |
| 8 | Consistent output format | sh | PASS | Single output mode: plain text (HIT:/MISS:/ERROR:). |
| 8 | Consistent output format | ps1 | PASS | Single output mode: plain text (HIT:/MISS:/ERROR:). |
