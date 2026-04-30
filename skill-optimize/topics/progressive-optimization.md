# PROGRESSIVE OPTIMIZATION — Executable Assessment

Assess whether the skill's topic priority ordering is correct and whether
the current tracking infrastructure captures what it needs to.

---

## How to make this assessment

### Step 1 — Compare tier ranking in the spec vs. the topic index

The `progressive-optimization.spec.md` defines a draft impact tier ranking.
The Topic Index in `uncompressed.md` defines the execution order.
Check: are they aligned?

### Step 2 — Check tracking infrastructure

Does the skill's current tracking give enough information to:
- Skip already-analyzed topics? (skip logic)
- Resume after a partial run?
- Identify which tier topics are complete?

### Step 3 — Assess per-topic version tracking

The spec proposes tracking which topic file version was used per analysis.
Does the current log track this? If not, is that a gap?

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Tier ranking comparison:**

Spec (`progressive-optimization.spec.md`) proposed:
- Tier 1: DISPATCH, MODEL SELECTION, WORDING, DETERMINISM
- Tier 2: COMPRESSIBILITY, LESS IS MORE, COMPOSITION, CHAIN OF THOUGHT
- Tier 3: HASH RECORD, OUTPUT FORMAT, EXAMPLES, SELF CRITIQUE
- Tier 4: TOOL SIGNATURES, REUSE

Topic Index in `uncompressed.md` ordering (first 10):
DISPATCH, CACHING, DETERMINISM, COMPOSITION, MODEL SELECTION,
COMPRESSIBILITY, WORDING, LESS IS MORE, REUSE, OUTPUT FORMAT...

The index doesn't use explicit tiers — it's a priority-ordered flat list.
Comparing against the spec's tier ranking: WORDING is in spec Tier 1 but
appears 7th in the index. CACHING (HASH RECORD) is in spec Tier 3 but
appears 2nd in the index. The spec's tier ranking doesn't fully match the
index ordering.

**Is this a problem?** The flat ordered list functions as an implicit
priority ranking. The spec's tier breakdown is a "draft" to be validated
empirically. The index ordering was designed with the same intent. Minor
misalignment between a draft spec and a living index isn't a finding —
the index is the authoritative execution order.

**Tracking infrastructure:**

Current optimize-log.md:
- Tracks topic, date, model, N findings, status, action ✓
- Skips topics already in log as `clean`/`acted`/`rejected` ✓
- Can identify tier completion by comparing log entries to the index ✓
- Does NOT track which version of the topic spec file was used ✗

**Per-topic version tracking gap:**

If a topic spec file changes (e.g., DISPATCH gets new criteria), the log
doesn't know the prior analysis used an older spec. The skip logic would
skip the re-analysis even though the topic changed. For stable, slow-moving
topic specs this is low risk. For actively evolving topics it could produce
stale coverage.

**Finding: LOW**

The tracking infrastructure is functional. The version-tracking gap is real
but low-risk given how slowly topic specs change. The tier misalignment is
a draft-vs-living-doc issue, not a problem.

**Recommendation:** No code change. If topic specs evolve rapidly, add a
`spec-hash` column to the optimize-log to detect when a topic file changes
and re-analysis is warranted. Defer until a topic spec actually changes
between runs.
