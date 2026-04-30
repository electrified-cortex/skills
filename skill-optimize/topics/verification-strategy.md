# VERIFICATION STRATEGY — Executable Assessment

Assess whether the skill defines what counts as correct — what it treats
as ground truth, how it checks claims, and what confidence level attaches
to different outputs.

---

## How to make this assessment

### Step 1 — Identify must-verify vs. can-assume

For each claim the skill produces:
- **Must verify** — finding severity, action recommendation, finding text
- **Can assume** — that the skill files exist (checked at Step 1), that
  the log format is valid (written by the skill itself)

Does the skill distinguish these, or does it treat all outputs equally?

### Step 2 — Check primary source usage

For every finding: does the analysis read the actual skill files, or
does it rely on summaries or cached state?

- Sub-agent in Step 4 receives all source files directly ✓ or ✗?
- Qualifier in Step 3a receives "one-line descriptions only" ✗

### Step 3 — Check confidence labeling

When the skill is uncertain, does it surface the uncertainty?
Signals: `APPLICABLE: yes | maybe` in qualifier output is a confidence
indicator. Does the downstream flow treat `maybe` differently?

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Must-verify outputs:**

1. **Finding severity** — must be grounded in specific content from
   the source files. The finding template requires `**Reasoning:**
   <grounded in specific content>`. Sub-agent receives all source files. ✓
2. **Action recommendation** — modifies skill files. Must be correct or
   the skill degrades. The reasoning field covers this. ✓
3. **CLEAN verdict** — implies no issues found. The self-critique step
   ("confirm no signal was missed") guards the CLEAN case. ✓

**Primary source usage:**

Step 4 dispatch passes "all skill source files (from Step 1)." The
sub-agent reads the actual files. Primary source. ✓

Step 3a qualifier receives "one-line descriptions only" — secondary
source (not the full spec). But the qualifier only classifies applicability,
not the finding itself. A weaker evidentiary standard is acceptable for
classification. The actual finding is always done on primary source. ✓

**Confidence labeling:**

`APPLICABLE: yes | maybe` — the qualifier surfaces confidence. Step 3b
assessor tie-breaking prefers `yes` over `maybe`. The downstream analysis
always runs on primary source regardless of the qualifier confidence
level — a `maybe` gets the same quality analysis as a `yes`. ✓

**Unverified claims:** The skill reads optimize-log.md and trusts its
content without validation. If the log is corrupted or manually edited,
the skip logic would silently apply to incorrect data. This is an accepted
limitation — logs are machine-written and operator-editable by design.

**Finding: CLEAN**

The verification strategy is sound: must-verify outputs use primary
sources, confidence is labeled at the qualifier level, the self-critique
step guards CLEAN verdicts. The only unverified trust point (the log)
is a documented accepted limitation.
