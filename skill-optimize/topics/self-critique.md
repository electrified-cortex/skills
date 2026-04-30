# SELF CRITIQUE — Executable Assessment

Assess whether the skill includes a verification pass for its own judgment
outputs. For assessment-heavy skills, a within-turn self-review reduces
severity miscalibration and premature "clean" calls.

---

## How to make this assessment

### Step 1 — Identify judgment outputs

Read the topic procedure files. What verdicts or ratings does the analysis
step produce?

- Severity rating: HIGH / MEDIUM / LOW / CLEAN
- Finding text: the specific issue identified
- Action recommendation: what to change

These are judgment outputs — they carry risk if wrong.

### Step 2 — Check for existing verification pass

Does any step in `uncompressed.md` or the topic procedure instruct the
model to review its own finding before writing it?

Signals that a review pass exists:
- "Review: does this finding hold under the evidence?"
- "Check: is the severity calibrated correctly?"
- A separate "verify" step after the finding is drafted
- Explicit instruction to reconsider a clean verdict before finalizing

### Step 3 — Assess the cost/benefit tradeoff

Self-critique adds token cost within the same turn. Is this skill's error
cost high enough to justify it?

Consider:
- What happens if a finding is wrong? (unnecessary change, missed issue)
- Is the skill downstream-trusted without independent verification?
- Are the topic criteria explicit enough that a review pass would actually
  catch miscalibration?

### Step 4 — Produce finding or confirm clean

```
### SELF CRITIQUE — HIGH | MEDIUM | LOW

**Signal:** <what outputs lack a review pass>

**Reasoning:** <downstream risk; cost/benefit of adding a review step>

**Recommendation:** <where to add the review instruction>
```

---

## Application to skill-optimize

**Judgment outputs from the Sonnet topic analysis:**

1. **Severity rating** (HIGH / MEDIUM / LOW / CLEAN) — if miscalibrated,
   either triggers unnecessary changes (false alarm) or misses a real issue.
2. **Finding text** — if wrong, the action taken records a misleading
   rationale.
3. **Action recommendation** — if wrong, the skill's own output becomes a
   defect in the file it's supposed to improve.

**Existing verification pass?**

Looking at the topic procedure format: each topic `.md` file ends with
"Produce finding or confirm clean" with a template. There is no explicit
"review your finding before writing it" instruction in the template or in
`uncompressed.md` Step 4.

The Sonnet analysis prompt (Step 4 in `uncompressed.md`) says "follow the
procedure in `<topic>.md` and produce a finding" — no self-review step.

**Downstream trust:** The skill writes its findings to `.optimization/` and
the log. Currently there is no adversarial review agent checking the
assessor's verdict. The Curator reads the log; it's essentially trusted
output.

**Finding: MEDIUM**

The skill produces judgment outputs (severity ratings, findings) without a
within-turn review pass. Given that it's self-assessing its own files, there's
a systematic blind-spot risk — the same model that wrote the skill is assessing
it. A within-turn review instruction adds minimal tokens but would catch
severity miscalibration (common: flagging LOW as MEDIUM) and prevent "clean"
calls where a real issue was overlooked.

**Recommendation:** Add a verification step to the Sonnet topic analysis
prompt in `uncompressed.md` Step 4:

After the initial finding is drafted, append:
> "Review: does this finding hold under the evidence in the files? Is the
> severity calibrated correctly (not over- or under-rated)? If there is a
> 'CLEAN' verdict, confirm no signal was missed. If recalibration is needed,
> revise before producing the final output."

This is within-turn — no extra dispatch, negligible cost overhead.
