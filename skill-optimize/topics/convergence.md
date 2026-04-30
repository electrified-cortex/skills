# CONVERGENCE — Executable Assessment

Assess whether the skill has sufficient multi-pass stopping criteria and
whether the current implementation will reach a stable optimized state
without oscillation or premature convergence.

---

## How to make this assessment

### Step 1 — Check for multi-pass stopping criteria

Does `uncompressed.md` or `spec.md` define when to stop running the
optimizer on a skill?

Look for:

- A hard iteration cap (explicit N)
- A net-new-findings test ("stop when a full pass produces zero new findings")
- A coverage threshold (e.g., "all topics in priority tier 1-2 analyzed")
- An escalation ceiling (Haiku → Sonnet → Opus)

### Step 2 — Check for oscillation risk

Does the topic set contain pairs of topics whose recommendations could
conflict? Pairs to check:

- REUSE (extract) vs. LESS IS MORE (inline — don't add overhead)
- COMPOSITION (split) vs. LESS IS MORE (collapse)
- DISPATCH (dispatch) vs. CONTEXT BUDGET (minimize context)

If conflicting recommendations appear across passes, the skill needs an
explicit deduplication step or a "don't revert prior decisions" guard.

### Step 3 — Check for false convergence risk

Could the optimizer declare convergence while the skill still has real issues?

- Does the log track which topics were analyzed? (If not, duplicates could
  re-surface as "new" findings on later passes.)
- Does the assessor skip already-logged topics?

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Multi-pass stopping criteria:**

Checking `spec.md` R12 (the convergence requirement). Step 2 in
`uncompressed.md`: "If log exists, check which topics have been analyzed.
Skip topics already in the log as `clean`, `acted`, or `rejected`."
This is a per-topic deduplication check. But the skill doesn't define
when the FULL SKILL has converged — there's no "stop after all priority
topics have been covered" or "stop when two consecutive passes return
CLEAN" instruction.

**Oscillation risk:**

REUSE vs. LESS IS MORE is the identified pair in the spec. This skill's
own log has these as separate topics, analyzed separately. No single pass
would recommend both extraction AND inlining the same block — they run
on different topics. The log acts as an implicit deduplication layer:
once a topic is logged as `acted`, the next pass skips it. So if REUSE
said "extract," and LESS IS MORE said "inline," the LESS IS MORE recommendation
would run against the already-acted REUSE change — not the pre-extraction
state. Oscillation risk is LOW given the sequential topic-by-topic model.

**False convergence check:**

The log tracks all analyzed topics with status. The assessor qualifier
skips `clean`/`rejected`/`acted` topics. Coverage of all 29 topics means
convergence. The current log has 13 entries. The remaining 16 topics are
candidates. No false convergence mechanism identified — the skip-logic
is correct.

Missing: **explicit convergence declaration**

There is no instruction telling the operator or the next assessor when the
skill is "done." The log grows until all topics are analyzed, but there's
no output that says "convergence reached — no new findings for N passes."

Finding: LOW

The per-topic skip logic prevents re-analysis and handles most convergence
safely. The missing element is a convergence declaration: an explicit signal
when all priority topics have been covered and no actionable findings remain.
This is meta-information for the operator, not a safety issue.

**Recommendation:** Add to `spec.md` or `uncompressed.md` Step 6 output:
after all tier-1 and tier-2 topics show `clean`/`acted`/`deferred`, emit
a "convergence signal": `Convergence: tier-1+2 topics analyzed — N acted,
M clean, K deferred. Re-run with higher tier model to verify.`
