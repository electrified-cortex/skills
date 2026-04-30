# COMPOSITION — Executable Assessment

Assess whether the skill is structured at the right granularity — not too
monolithic, not over-split. Focus on whether any single invocation loads more
context than it needs, or whether related operations should be grouped.

---

## How to make this assessment

### Step 1 — Map the invocation paths

Read the skill inputs and steps. How many distinct paths can a caller take?

- Path A: `<topic>` provided — skip assessor, go direct to Step 4
- Path B: no topic — assessor pass (Steps 3a-3b), then Step 4
- Path C: `assess-only` mode — Steps 1-3b only, stop

Each path loads the full instruction file regardless. Note what each path
actually needs vs. what it's forced to load.

### Step 2 — Check for sub-procedure bundling

Does the skill combine multiple independently invokable operations that
share no state between them? Signals:

- Multiple modes (e.g., `assess-only` vs. full analysis) that could be
  separate entry points
- Long topic index table that all paths must scan even when a topic is
  pre-selected
- Sub-agent prompt templates that the host reads and passes through but
  doesn't execute itself

### Step 3 — Check for routing layer opportunity

If the skill has grown a large index (many topics, long descriptions), a
routing layer could let callers load only the relevant topic procedure
rather than the full menu.

Current structure: `uncompressed.md` embeds the full topic index as a
fallback heuristic table AND embeds the sub-agent prompts AND contains the
host orchestration logic — all in one file.

### Step 4 — Apply context efficiency test

For each invocation path, estimate: what fraction of `uncompressed.md` is
actually used?

- Direct topic invocation: Steps 1, 2, 4, 5, 6 + the topic spec. The
  assessor block (Step 3), fallback heuristic table, and topic index are
  loaded but not used.
- Assessor path: everything is potentially relevant, but the topic index
  is only scanned once, not iterated.

If a significant section is loaded but never used on the most common path,
that's a partitioning opportunity.

### Step 5 — Produce finding or confirm clean

**Finding format:**

```md
### COMPOSITION — HIGH | MEDIUM | LOW

**Signal:** <what is bundled; which paths load unused content>

**Reasoning:** <context efficiency impact; E = I₀/C estimate>

**Recommendation:** <specific partitioning or routing change>
```

**Severity:**

- HIGH — most invocations load <30% relevant content; clear split available
- MEDIUM — common path loads 40-60% relevant content; split would help
- LOW — most content is relevant to most paths; minor restructuring only

---

## Application to skill-optimize

**Invocation paths:**

- **Direct** (topic provided): Steps 1, 2, 4, 5, 6. Loads everything but
  skips all of Step 3. The Haiku dispatch prompt, fallback heuristics table
  (~40 lines), and topic index (~30 lines) are in context but unused.
- **Assessor** (no topic): All steps. Full file is relevant.
- **assess-only**: Steps 1-3b. Step 4 prompt template (~30 lines) unused.

**Topic index table:** 30 rows × 3 columns, embedded in `uncompressed.md`
as a fallback heuristic. On the direct path (most common in dogfood loop),
the whole table loads and nothing is read from it.

**Sub-agent prompts:** Two prompt templates embedded inline — the Haiku
qualifier prompt (~10 lines) and the Sonnet topic analysis prompt (~20
lines). On assess-only path, the analysis prompt is unused. On direct path,
the qualifier prompt is unused.

**Verdict:** The skill is a dispatcher by design — the host is intentionally
thin, with real work dispatched. The COMPRESSIBILITY finding already flagged
SKILL.md as the fix for the "host loads too much" problem. That addresses
the same root cause as a COMPOSITION split would.

Finding: LOW

The unused-content-per-path issue is real but the appropriate fix is a
SKILL.md compressed surface (already identified in COMPRESSIBILITY), not
a structural split. Splitting the assessor path from the direct path would
create two nearly-identical entry points sharing most of the same files.
The topic index and fallback table do belong in `uncompressed.md` for the
assessor fallback path — they're not orphaned, just conditionally used.

**Recommendation:** No structural change. The SKILL.md compressed surface
(from COMPRESSIBILITY) collapses unused content for the host. If the topic
library grows beyond ~40 topics, revisit: a routing layer over sub-skills
(one per topic tier) becomes justified at that scale.
