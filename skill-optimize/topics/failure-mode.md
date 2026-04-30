# FAILURE MODE — Executable Assessment

Assess whether the skill documents and handles the ways it can silently
produce wrong output — not runtime errors, but semantic failures.

---

## How to make this assessment

### Step 1 — Identify semantic failure conditions

Read `uncompressed.md`. What could cause the skill to execute without
error but produce a wrong, incomplete, or not-useful result?

Common failure modes to check:
- Insufficient input quality (skill files are too sparse to analyze)
- Conflicting instructions from multiple sources
- Missing tool access (no sub-agent dispatch available)
- Low-confidence judgment producing over-confident output
- Partial completion producing an apparently-complete result

### Step 2 — Check for existing confidence labeling

Does the skill label outputs as uncertain when conditions for certainty
aren't met? Look for:
- "I could not determine" / "insufficient evidence"
- `maybe` vs. `yes` distinction in qualifier
- Any "low confidence" flag in finding output

### Step 3 — Produce finding or confirm clean

---

## Application to skill-optimize

**Potential semantic failure conditions:**

1. **Sparse skill files** — If a skill has only a SKILL.md with 3 lines,
   the sub-agent can't produce grounded findings. The analysis would
   either produce a CLEAN (correct but uninformative) or hallucinate
   findings with no source evidence. No minimum-content guard exists.

2. **Qualifier misclassification** — If the qualifier marks a topic as
   `maybe` and the assessor selects it, but the topic doesn't actually
   apply, the analysis runs on an inapplicable topic. The sub-agent's
   self-critique might catch this ("does this finding hold under the
   evidence?") — a partial guard.

3. **Analysis without dispatch capability** — If the caller has no
   sub-agent dispatch available, the fallback heuristics table kicks in.
   The inline fallback produces a topic selection but the Step 4 analysis
   is still supposed to be dispatched. If dispatch truly isn't available,
   the skill has no inline analysis path — it would halt at Step 4.
   The spec says "never analyze inline" but doesn't define what to do
   if dispatch isn't available.

4. **Finding based on outdated files** — If the host read the skill
   files (Step 1) but they changed before the sub-agent reads them, the
   analysis could be based on stale state. Unlikely in practice (within
   a single session) but possible in slow async workflows.

**Existing confidence handling:**

`APPLICABLE: yes | maybe` surfaces qualifier uncertainty. The `**Reasoning:**`
field forces evidence citation. The self-critique step checks "does this
finding hold under the evidence?" These address runtime judgment quality
but not the sparse-input case.

**Finding: LOW**

Three semantic failure modes, all LOW severity:
- Sparse input → CLEAN result looks correct but is uninformative. LOW.
- No dispatch → skill halts at Step 4. Documented as "dispatch required"
  implicitly. LOW — fallback table handles the assess-only path.
- Analysis on stale files → covered by single-session execution model. LOW.

**Recommendation:** No required change. The sparse-input case could be
addressed by adding: "If source files total fewer than 20 lines, emit
`WARNING: sparse skill — findings may be incomplete.`" Defer.
