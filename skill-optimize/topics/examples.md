# EXAMPLES — Executable Assessment

Assess whether the skill's output format or judgment calibration would
benefit materially from 1-3 targeted concrete examples.

---

## How to make this assessment

### Step 1 — Identify format-sensitive outputs

Read the topic procedure files and `uncompressed.md`. What does the skill
produce that has a specific shape?

- Finding format block (`### TOPIC — SEVERITY`)
- Log row format (`| TOPIC | date | model | N | status | action |`)
- Report file format (`.optimization/<slug>.md`)
- Qualifier output format (`TOPIC: / APPLICABLE: / REASON:`)

For each: is the format described only in prose/template, or is there a
concrete filled-in example showing real content?

### Step 2 — Identify judgment-calibration outputs

Where does the skill make a categorization that isn't fully determined
by explicit rules?

- Severity (HIGH / MEDIUM / LOW / CLEAN) — is the boundary between
  categories shown by example, or only described abstractly?
- `applicable: yes | maybe` — is the distinction shown by example?
- Status values (`acted` / `deferred` / etc.) — are real-usage examples
  in the log sufficient, or are new callers likely to miscategorize?

### Step 3 — Assess whether examples would close a real gap

For each format or judgment point identified:
- Would a concrete filled-in example make the output more consistent?
- Is there currently anything a caller could look at as a reference?

Note: the optimize-log itself serves as a calibration reference for
severity/status — real entries are examples of prior outputs. If the
log is populated and visible to the sub-agent, it partly fills the
example gap.

### Step 4 — Produce finding or confirm clean

```
### EXAMPLES — HIGH | MEDIUM | LOW

**Signal:** <which output lacks an example; what ambiguity results>

**Recommendation:** <what a short example should show>
```

---

## Application to skill-optimize

**Format outputs:**

1. **Finding format block** — the template is explicit:
   ```
   ### <CATEGORY> — HIGH | MEDIUM | LOW
   **Reasoning:** ...
   **Recommendation:** ...
   ```
   No concrete filled-in example exists in `uncompressed.md`. The topic
   `.md` files serve as de facto examples — each ends with an actual
   finding applied to the skill itself. A caller running the skill cold
   has those as reference.

2. **Log row** — the optimize-log contains 11 populated rows now. This IS
   the example set. Any caller that reads the log gets concrete rows
   showing the format in use. **Gap closed by existing log.**

3. **Report file** — the `.optimization/` folder now has 11 files. Same
   as above — they serve as format examples. **Gap closed by existing reports.**

4. **Qualifier output** — `TOPIC: <SLUG> / APPLICABLE: yes|maybe / REASON: <1 sentence>`.
   No filled-in example in `uncompressed.md`. The format is simple and
   templated, but "yes vs. maybe" calibration is done only by prose
   description ("yes = direct match; maybe = adjacent, worth exploring").
   A two-line example would help: one "yes" and one "maybe" case.

**Judgment-calibration outputs:**

The severity scale (HIGH / MEDIUM / LOW) is defined with abstract criteria.
Looking at the actual topic `.md` files, each contains an applied finding
— these function as calibration examples. A Sonnet model running analysis
has access to all prior topic `.md` findings in context if the skill passes
them, but the current Step 4 dispatch only passes: source files + topic spec
+ topic `.md`. It does NOT pass prior topic outputs as calibration examples.

**Finding: LOW**

The log and `.optimization/` files provide de facto format examples for
the recording outputs. The main gap is qualifier output calibration ("yes"
vs. "maybe") — a trivial fix. Severity calibration is addressed by the
per-topic `.md` files which show applied examples, though they aren't
explicitly passed to each sub-agent invocation. This is a genuine gap
but LOW priority: Sonnet models parse abstract severity definitions well,
and the self-critique step (just added) provides a review pass that
catches miscalibration.

**Recommendation:** Add two example rows to the qualifier prompt in
`uncompressed.md` to calibrate `yes` vs. `maybe`. Defer severity example
injection into sub-agent context — low payoff given the self-critique gate.
