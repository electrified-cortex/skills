# CHAIN OF THOUGHT — Executable Assessment

Assess whether the skill needs explicit reasoning elicitation to produce
correct verdict quality, and whether the current form provides it.

---

## How to make this assessment

### Step 1 — Identify judgment calls in the skill

Read the topic procedure files and `uncompressed.md`. List every place
where the skill produces a verdict that requires weighing evidence:

- Severity ratings (HIGH / MEDIUM / LOW / CLEAN)
- `applicable: yes | maybe` qualification decision
- Assessor pick (best topic from qualifier results)
- Finding text: does it require multi-signal synthesis?

### Step 2 — Check for existing reasoning elicitation

For each judgment call: does the instruction explicitly ask the model to
reason before concluding?

Signals that reasoning is elicited:

- "Reason through the evidence before producing the finding"
- "Consider X, Y, Z then determine..."
- A structured evidence block before the verdict template

Signals that reasoning is NOT elicited:

- "Produce finding in this format:" — direct output with no reasoning step
- Template with verdict field but no reasoning field
- The self-critique step added in SELF CRITIQUE covers review, but not
  reasoning-before-conclusion

### Step 3 — Assess minimum viable form needed

For each judgment call: what's the minimum reasoning form?

- **Inline justification** in the finding (`**Reasoning:** ...`) —
  already present in the finding template. This IS a form of reasoning
  elicitation: requiring a `**Reasoning:**` field forces the model to
  produce justification inline.
- **Pre-verdict scratchpad**: only if inline reasoning is insufficient.
- **Separate analysis pass**: only if multi-signal synthesis is too
  complex for inline justification.

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Judgment calls:**

1. **Severity** (HIGH / MEDIUM / LOW / CLEAN) — the finding template
   requires `**Reasoning:** <grounded in specific content>`. This forces
   the model to justify the severity inline before the format closes.
   Reasoning is elicited implicitly through the required field. ✓

2. **`APPLICABLE: yes | maybe`** — no reasoning field. Just a structured
   one-line output. For a scanner pass with short-circuit logic, inline
   justification is not needed — the model either sees the signal or
   doesn't. The REASON field provides a one-line rationale. Acceptable. ✓

3. **Assessor pick** (Step 3b) — tie-breaking is handled by an ordered
   priority table, not by judgment. No reasoning step needed. ✓

4. **Finding text** — the `**Reasoning:**` field in the finding template
   requires grounded justification from the skill files. This is the
   most judgment-heavy output. The instruction says "grounded in specific
   content from the skill files" — this is a light reasoning elicitation
   (cite your evidence).

**Assessment:** The finding template already elicits reasoning via the
required `**Reasoning:**` field. The SELF CRITIQUE step (just added)
adds a review pass after conclusion. The combination of:

- Required `**Reasoning:**` field (reason before you close the format)
- Self-critique review ("does this hold under the evidence?")

...covers the chain-of-thought need for this skill's judgment calls.
A separate `<analysis>` block before the finding would be redundant.

**Finding: CLEAN**

Reasoning is already elicited through the required `**Reasoning:**` field
in the finding template, which forces justification inline. The self-critique
step adds a review pass. No additional chain-of-thought scaffolding needed.
