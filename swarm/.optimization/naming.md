# NAMING — 2026-05-08

## Findings

### PERSONA-NAME SLUGIFICATION UNDEFINED — MEDIUM

**Severity:** MEDIUM
**Finding:** The hash record path token `<persona-name>` in Step 5 uses "persona" (not "personality" — the canonical Key Terms entry) and has no defined slugification rule. Step 4 defines the slugification for reviewer filenames (lowercased, spaces/apostrophes → hyphens), but no corresponding rule was stated for `<persona-name>` in the hash record path. A mismatch — e.g., writing "Devil's Advocate" vs "devils-advocate" as the directory — would silently break B10 partial recovery.
**Action taken:** Added one sentence after the first `<persona-name>` occurrence in Step 5 of both files: "`<persona-name>` uses the same slugification as the reviewer filename (Step 4): personality name lowercased with spaces and apostrophes replaced by hyphens."

### HIGH VS CRITICAL SEVERITY AMBIGUOUS — MEDIUM

**Severity:** MEDIUM
**Finding:** Step 5 introduced HIGH and CRITICAL severity labels, but the skill only defines "high-severity point" (Key Terms). The relationship between HIGH and CRITICAL was implicit. D6 and E5 both reference "high-severity point" — an implementor can't determine whether a CRITICAL-labeled disagreement triggers D6 Low, or where CRITICAL ranks in E5 truncation priority.
**Action taken:** Extended the `High-severity point` Key Terms entry in both files to explicitly state: covers both HIGH and CRITICAL severity labels; they share the same threshold; HIGH and CRITICAL receive equal truncation priority in E5.
