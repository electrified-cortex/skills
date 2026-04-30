# WORDING — Executable Assessment

Assess instruction phrasing, ordering, and structural patterns that
affect how the model interprets and executes the skill.

---

## How to make this assessment

### Step 1 — Scan for guard clause ordering

Find all stop conditions and early exits in `uncompressed.md`. Check:
- Is each stop condition stated before the complex path it guards?
- Example: "If already logged, stop" — does this appear before the
  analysis steps, or after them?

### Step 2 — Check phrasing for determinism

Scan for hedged or conditional prose:
- "you might want to…", "consider whether…", "it may be helpful to…"
- These are implicit judgment calls. Flag and convert to imperatives.

Also scan for passive voice in action steps:
- "The log should be updated" → "Append one row to the log"
- Passive reduces clarity of ownership.

### Step 3 — Check instruction sequencing

For multi-step procedures:
- Is the most common path defined before edge cases?
- Are related concerns grouped?
- Are caveats placed after the action they qualify, not before?

### Step 4 — Check attention positioning

Critical elements (output format, stop conditions, required outputs)
should appear at the beginning or end of each section, not buried
mid-step. Scan Steps 1-6 for any critical requirement that's buried
mid-paragraph.

### Step 5 — Produce finding or confirm clean

```
### WORDING — HIGH | MEDIUM | LOW

**Signal:** <specific lines; what pattern they match>

**Recommendation:** <concrete rewording>
```

---

## Application to skill-optimize

**Guard clause ordering:**

`uncompressed.md` Step 2: "If log exists, read current state..." — the
"early exit if already fully analyzed" check comes in Step 3b assessor
logic. There's no guard clause at the top of the skill saying "if all
topics already logged CLEAN or acted, stop." A caller that re-invokes
the skill on a fully-analyzed skill will proceed through Steps 1-3 before
discovering there's nothing to do. LOW signal — edge case, not common path.

**Phrasing scan:**

- Step 3a: "Invoke a Haiku-class qualifier sub-agent to scan the topic
  list. Pass the topic index..." — imperative, clear. OK.
- Step 3b: "The assessor should prefer..." — hedged. Should be
  "The assessor MUST prefer" or "Pick the first topic that..."
- Step 4: "Dispatch a Sonnet-class topic analysis sub-agent." — imperative. OK.
- Step 5: "Append one row..." — imperative. OK.

One hedged instance: "should prefer" in Step 3b.

**Instruction sequencing:**

Steps 1-6 follow a clean linear path. Edge cases (fallback heuristics,
assess-only mode exit) are placed after the main path. OK.

The Step 4 sub-agent prompt block is large (~30 lines) and critical.
It's placed well — it's the only significant content in Step 4. OK.

**Attention positioning:**

The output contract (what the skill returns to its caller) is defined in
Step 6, at the end. This is correct positioning — it's the last step.
But it's easy to miss because Step 5 also has substantial content.
Acceptable.

**Finding: LOW**

One hedged phrasing in Step 3b ("should prefer") is the only actionable
instance. No attention positioning issues, no misplaced guard clauses.
The overall instruction phrasing is imperative and deterministic.

**Recommendation:** Change "The assessor should prefer" to
"The assessor MUST pick" in Step 3b. Minimal impact — included here
for completeness.
