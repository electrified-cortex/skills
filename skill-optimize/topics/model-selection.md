# MODEL SELECTION — Executable Assessment

Assess whether each execution role in the skill is using the right model
tier, and whether instruction quality is the real barrier preventing a
cheaper tier.

---

## How to make this assessment

### Step 1 — Identify model roles

Read `uncompressed.md`. List every dispatch point and its assigned tier:

- Host agent (orchestrator)
- Qualifier dispatch (topic selection)
- Topic analysis dispatch (finding generation)
- Any other dispatched roles

### Step 2 — Evaluate each role against tier criteria

For each role:

| Role | Current tier | Task type | Judgment required? | Tier justified? |
| ---- | ------------ | --------- | ------------------ | --------------- |

Task types:
- **Deterministic execution** → Haiku-class candidate
- **Structured judgment** (weighing, comparing, assessing) → Sonnet-class
- **Deep multi-constraint reasoning** → Opus-class (rare)

### Step 3 — Apply the instruction-quality lever

For any role at Sonnet+ tier: ask whether the instructions are explicit
enough that a Haiku could follow them if given the same inputs.

Signal that instructions are the barrier (not cognitive demand):
- Steps use prose conditionals ("if it seems like...", "consider whether...")
  instead of explicit decision trees
- The model must infer criteria that aren't stated
- Output format is described loosely rather than templated

If instructions are the barrier: finding. Tighten instructions to enable
downgrade.

### Step 4 — Check for evaluatability

Is the skill's output structured enough to A/B test across tiers? If yes
and no eval exists, flag it.

### Step 5 — Produce finding or confirm clean

```
### MODEL SELECTION — HIGH | MEDIUM | LOW

**Signal:** <which role; current tier; what the task actually demands>

**Reasoning:** <instruction quality vs. cognitive demand analysis>

**Recommendation:** <specific tier change or instruction tightening>
```

---

## Application to skill-optimize

**Roles identified:**

| Role | Current tier | Task |
| ---- | ------------ | ---- |
| Host (orchestrator) | Sonnet | Routing, log read, dispatch calls, output line |
| Qualifier | Haiku | Scan topic list in order, return first applicable |
| Topic analysis | Sonnet | Assess skill against topic criteria, produce finding |

**Qualifier (Haiku):** Topic is a list scan with short-circuit — "iterate
in order, return FIRST that applies." Output is structured: `TOPIC: <SLUG> /
APPLICABLE: yes|maybe / REASON: <1 sentence>`. The task is essentially a
classification scan over a bounded list. Haiku-class is correct. **CLEAN.**

**Topic analysis (Sonnet):** The task is genuine structured judgment —
reading a skill holistically, applying multi-dimensional assessment criteria,
producing grounded findings with reasoning. The topic specs are reasonably
explicit (they define signals, patterns, and severity criteria), but the
core task requires weighing evidence and forming an assessment. Sonnet-class
is appropriate. **CLEAN.**

**Host (Sonnet):** The host does: read files, check log, dispatch qualifier,
dispatch analyzer, write log row, write report file, emit output line. These
are all deterministic or near-deterministic operations. The only judgment
call is Step 3b (assessor decision — picking the single best topic from
qualifier results). That step has explicit tie-breaking rules. The rest is
mechanical.

**Finding: LOW**

The host is running at Sonnet-class but most of its work is deterministic
file I/O and dispatch calls. The one judgment step (assessor tie-breaking in
Step 3b) has explicit rules and could run on Haiku if the tie-breaking table
were tightened. However, the host and topic analysis are currently bundled
— a host downgrade requires splitting the host from the analysis dispatch,
which SKILL.md creation (from COMPRESSIBILITY) already anticipates. The
path to Haiku host is: create SKILL.md with host-only instructions →
confirm Haiku can follow them → downgrade.

**Recommendation:** No change now. When SKILL.md is created, test host
execution on Haiku. The tie-breaking rules in Step 3b are the only
ambiguous step; if those are made table-driven, the host becomes
fully deterministic and Haiku-eligible.
