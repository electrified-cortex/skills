# LESS-IS-MORE — 2026-05-08

## Findings

### Two-Pass Policy Paragraph in Executor File — HIGH

**Finding:** "One skill per invocation. Each pass is separate dispatch. Smoke always runs before substantive. Two-pass policy applies regardless of change-set size — no size threshold permitting single-pass review. Single-Adversary Mode is explicitly exempt: it is intentionally one pass." in instructions.txt is caller-policy governance. The executor receives a single dispatch for one tier. They don't orchestrate pass order.

**Action taken:** Removed entirely from instructions.txt. Added `## Orchestration` section to SKILL.md: "Smoke always runs before substantive. Two-pass policy applies regardless of change-set size — no single-pass shortcut. Single-Adversary Mode is explicitly exempt: one pass only, no `prior_findings`."

### Empty Change Set Redundancy — MEDIUM

**Finding:** "Empty change set: skip all passes; return empty-result aggregate." duplicated Gate #3's already-explicit handling.

**Action taken:** Removed from instructions.txt. Gate #3 is sufficient.

### SARIF Mapping in Executor File — MEDIUM

**Finding:** "SARIF mapping: critical/high → error, medium → warning, low/info → note." is integration metadata for downstream tooling. The dispatched executor doesn't produce SARIF — callers do. Wrong file.

**Action taken:** Removed from instructions.txt. Added "SARIF severity map: `critical`/`high` → error, `medium` → warning, `low`/`info` → note." to SKILL.md and uncompressed.md Returns section.

### Rule 4 Prior Findings Gate — MEDIUM

**Finding:** "Smoke pass must NOT receive `prior_findings`. If it arrives anyway, ignore and proceed." duplicated the substance of Gate condition + `prior_findings` parameter description. Triple redundancy.

**Action taken:** Removed from Rules section. Covered by: parameter description ("smoke and single-adversary must not receive this") and procedure step 3 ("No prior_findings").

### Opening Line — LOW

**Finding:** "Read change set, produce findings report. Read-only: never edit, commit, push, stage." restates the frontmatter description and the Rules section.

**Action taken:** Removed.
