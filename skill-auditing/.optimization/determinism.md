# DETERMINISM — skill-auditing

Date: 2026-05-01
Model: Claude Sonnet 4.6
Status: pending

## Findings

### Finding 1 — HIGH

**Signal:** The entire Per-file Basic Checks section consists exclusively of pattern-matching operations with no semantic content: not-empty (file size), frontmatter-where-required (first line `---`), no-absolute-path-leaks (regex), shebang-present (head -1 match).

**Reasoning:** These carry zero judgment requirement. They are explicitly enumerated, have fixed patterns, and run on every file in every audit — token cost is recurring and compounding. LLM execution introduces false negatives (missed paths, approximated matches).

**Recommendation:** Implement `check.ps1` / `check.sh` that:

1. Enumerates all files in `<skill_dir>` recursively (skipping dot-prefixed dirs)
2. Applies all per-file checks via regex / first-line reads
3. Writes a structured findings block to a temp file
4. Instructions consume the pre-computed per-file findings block rather than re-deriving them

---

### Finding 2 — MEDIUM

**Signal:** Several Phase 2/3 checks are purely structural string operations:

- A-FM-1 name matches folder — parse YAML `name:` field, compare to `basename(<skill_dir>)`. String equality.
- A-FM-3 H1 per artifact — presence of `^# ` line per file. Regex.
- A-FM-7 no empty sections — heading immediately followed by another heading or EOF. Regex / line scan.
- A-FS-1 orphan files — enumerate files, subtract known-role list, check for references.
- A-FS-2 missing referenced files — grep for known filename literals, verify via `Test-Path`.

**Reasoning:** All individually cheap but well-defined. Known-role list for A-FS-1 is enumerated in spec. Heading patterns are fixed. LLM handling introduces fragility (A-FS-1 requires tracking all file paths and all reference sites — easy to miss).

**Recommendation:** Extend the pre-check script to also emit findings for A-FM-1, A-FM-3, A-FM-7, A-FS-1, A-FS-2. Computed from file enumeration and regex — no LLM pass required.

---

### Finding 3 — MEDIUM

**Signal:** A-XR-1 cross-reference anti-pattern — "scan SKILL.md, instructions.txt, sub-instructions, and uncompressed.md for any pointer to another skill's `uncompressed.md` or `spec.md`." Violations explicitly enumerated in spec; test is: does any path literal end with `.uncompressed.md` or `.spec.md`.

**Reasoning:** Pure regex scan: `grep -P '\buncompressed\.md\b|\bspec\.md\b'` across target files, filtered to exclude the skill-auditing exception. No semantic judgment involved. LLM can incorrectly decide a reference is "contextual."

**Recommendation:** Add to the pre-check script: scan all runtime artifacts for path-based references ending in `uncompressed.md` or `spec.md`, applying the explicit exception for subject-matter mentions in skill-auditing artifacts.

---

**Action taken:** No change yet. All three findings point to the same action: implement `check.ps1`/`check.sh` pre-check script. Recommend as a single implementation task.
