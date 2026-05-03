# INTERFACE-CLARITY — 2026-05-01

## Findings

### Finding 1 — MEDIUM

**Signal:** `--uncompressed` is listed as an optional flag with no description anywhere in SKILL.md. A caller cannot determine what it does, what files it affects, or whether it changes verdict criteria.

**Reasoning:** A caller who guesses wrong will either miss a needed audit mode or trigger unintended behavior.

**Recommendation:** Add inline description: "`--uncompressed` — audit against source files (`uncompressed.md`, `instructions.uncompressed.md`, `spec.md`) instead of compiled artifacts (`instructions.txt`)."

**Action taken:** No change yet.

---

### Finding 2 — MEDIUM

**Signal:** The `--fix` precondition "only after NEEDS_REVISION verdict" is a parenthetical in the input declaration, not a formal precondition. No indication of what happens if violated.

**Reasoning:** Callers scan input declarations to understand constraints. A parenthetical reads as a usage note, not a hard constraint enforced by the skill.

**Recommendation:** Add formal annotation: "`--fix` — REQUIRES: prior verdict is `NEEDS_REVISION`. Violating this returns `ERROR: precondition not met`."

**Action taken:** No change yet.

---

### Finding 3 — LOW

**Signal:** `"Follow dispatch skill. See ../dispatch/SKILL.md"` and `"NEVER READ"` on `instructions.txt` are internal plumbing details embedded in the caller-facing interface document.

**Reasoning:** A caller invoking this skill doesn't operate dispatch — the skill does. Exposing the dispatch dependency forces callers to reason about a second skill they didn't intend to use. "NEVER READ" belongs only in executor-internal context.

**Recommendation:** Remove dispatch reference from caller-visible SKILL.md or move to an `## Implementation Notes` section marked as non-caller-facing. Remove "NEVER READ" from SKILL.md.

**Action taken:** No change yet.
