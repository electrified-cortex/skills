# ITERATION SAFETY — Executable Assessment

Assess whether the skill's loops have hard caps, state tracking, and
explicit stopping criteria to prevent runaway token spend.

---

## How to make this assessment

### Step 1 — Enumerate all loops in the skill

Read `uncompressed.md`. Identify every iterative pattern:
- Explicit loops (repeat N times, while-condition)
- Implicit loops (re-invoke instructions, "repeat for each topic")
- Convergence loops (run until stable)
- The outer loop: the operator re-invokes the skill across sessions

### Step 2 — Check for hard iteration caps

For each loop: is there an explicit maximum N?
- "Repeat up to 3 times" — explicit cap. ✓
- "Repeat until stable" — no cap. ✗ Flag.
- "For each topic" — bounded by the topic list length. Effectively capped.

### Step 3 — Check for state tracking

Does each loop track what it changed in previous iterations?
- If the loop can revisit the same finding, can it detect and avoid it?
- If the loop re-runs the qualifier, does it skip already-analyzed topics?

### Step 4 — Check for oscillation guard

Is there any mechanism to detect if the loop is cycling between two states?

### Step 5 — Produce finding or confirm clean

---

## Application to skill-optimize

**Loops in `uncompressed.md`:**

1. **Per-invocation outer loop** — the operator re-invokes the skill
   across sessions. One topic per invocation by design. Not a loop in
   the traditional sense — each invocation is independent. The log
   tracks state across invocations (skip logic). State tracking: ✓.

2. **Qualifier loop (Step 3a)** — "Scan the topic list in order. Return
   the FIRST that applies. Short-circuit: stop at first match." This is
   a bounded scan over the unanalyzed topic list. Not a re-invocation
   loop. Terminates on first match or at list end. Hard bound: topic
   count. ✓

3. **Multiple candidates** — "To find a second candidate, run another
   qualifier starting from the topic after the previously returned slug."
   This is an optional second dispatch. No iteration cap specified, but
   the default path is one qualifier call per invocation. The "second
   candidate" instruction has no explicit cap.

4. **No convergence loop inside a single invocation** — the skill is
   designed as one-topic-per-invocation. No within-turn re-analysis loop.

**State tracking:** The optimize-log + skip logic handles cross-invocation
state. Within a single invocation, there's no state-carrying loop.

**Oscillation risk:** Low. The outer "loop" is human-gated (operator
re-invokes). The only automatic iteration is the qualifier scan (bounded).

**Finding: LOW**

The "second candidate" qualifier instruction has no explicit cap. In
practice it's an optional second call — unlikely to run away. But adding
a bound ("run at most one additional qualifier call") would be more precise.
No other unsafe loops detected.

**Recommendation:** Add explicit cap to the "second candidate" instruction:
"Run at most one additional qualifier call per invocation." Trivial change;
prevents ambiguity about how many qualifier passes are allowed.
