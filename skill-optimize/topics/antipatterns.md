# ANTI-PATTERNS — Executable Assessment

Assess whether systemic failures are present — ones no primary topic fully
owns, or ones emerging from topic interaction. Primary topics own their
domains; this topic catches what falls through.

**Activation gate:** Only produce findings for systemic anti-patterns.
Cross-topic tensions and per-topic foot guns below are reference material —
they do not generate findings on their own.

---

## How to make this assessment

### Step 1 — Check for required context

Before running, confirm available context:

- Topic set being applied to this skill ✓
- Prior findings / changelog ✓ (optimize-log.md)
- Any prior optimize log ✓

Without all three, this topic cannot meaningfully run.

### Step 2 — Review the cross-topic tension set for systemic patterns

Read the prior findings in optimize-log.md. Look for:

1. **LESS IS MORE vs. EXAMPLES oscillation** — Did the log show LESS IS
   MORE removing content that EXAMPLES would require?
2. **COMPRESSIBILITY vs. OUTPUT FORMAT** — Did either conflict with the
   other in their recommendations?
3. **REUSE vs. LESS IS MORE** — Did REUSE recommend extraction while LESS
   IS MORE would inline the same block?
4. **Topic interaction producing a regression** — Any finding where acting
   on Topic A created a condition that Topic B would now flag?

### Step 3 — Check for validation theater

Does any finding in the log recommend a self-check without external
observable criteria? This is validation theater (IACDM antipattern 1).
Flag if found.

### Step 4 — Produce finding or confirm clean

Only produce a finding if a systemic pattern is present that no primary
topic addressed.

---

## Application to skill-optimize

**Prior findings review (from optimize-log):**

Checking 16 analyzed topics for cross-topic tensions:

- COMPRESSIBILITY + OUTPUT FORMAT: Output format was fixed (spec.md Output
  section rewritten). No compression vs. format conflict detected.
- REUSE + LESS IS MORE: REUSE confirmed CLEAN (no extractable blocks). No
  oscillation risk — the two topics never produced opposing recommendations.
- COMPOSITION + COMPRESSIBILITY: Both deferred to SKILL.md creation. They
  converged on the same root fix, not opposing recommendations. No conflict.
- CONVERGENCE fix (Step 6 convergence signal) + LESS IS MORE: The Step 6
  addition adds ~5 lines. LESS IS MORE would not flag 5 lines as bloat.
  No conflict.

**Validation theater check:**

The self-critique instruction added (SELF CRITIQUE finding) says: "does this
finding hold under the evidence? Is the severity calibrated correctly?"
This asks the model to verify against evidence in the source files — not
open-ended self-assessment. Observable criteria: the source files. Not
validation theater. ✓

**Systemic anti-patterns?**

No oscillation between primary topics found. No validation theater.
No topic interaction that produced a regression. The multiple deferred
LOW findings (COMPOSITION, MODEL SELECTION, EXAMPLES, PROGRESSIVE OPTIMIZATION)
all defer to the SAME downstream fix (SKILL.md creation). This is a
healthy dependency chain, not a systemic anti-pattern.

Finding: CLEAN

No systemic anti-patterns present. Primary topics covered their domains
without oscillation or conflict. Deferred findings converge on a single
known root cause (SKILL.md creation).
