# EVALUATION HARNESS — Executable Assessment

Assess whether the skill has a mechanism to verify that optimizations
actually improve it and don't introduce regressions.

---

## How to make this assessment

### Step 1 — Check for benchmark inputs

Does the skill or its repo have any defined test cases — known-good skills
to produce CLEAN verdicts, known-bad skills to produce specific findings?

### Step 2 — Check for regression guard

Is there any mechanism to detect if a recent change caused the skill
to produce worse output on a previously-passing case?

### Step 3 — Assess evaluatability

Is the skill's output structured enough to score automatically?
The optimize-log + `.optimization/` report format is structured. But
scoring "is this finding correct" is itself a judgment call, not a
deterministic check.

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Benchmark inputs:** None exist. There's no `test-cases/` folder in the
skill root, no known-good or known-bad skill references defined.

**Regression guard:** None. When `uncompressed.md` is modified (as this
dogfood loop has done), there's no automated check that the modified
skill still produces correct outputs on known inputs.

**Evaluatability:** The skill output is structured — log rows and `.optimization/`
report files have defined schemas. Correctness checking for "is this finding
correct?" requires a judge (either human or adversarial agent), not a
deterministic test. But coverage checking (does the skill analyze the expected
topics? does it produce output in the correct format?) is automatable.

**This is the dogfood limit:**

Skill-optimize is currently being dogfooded manually — the assessor (this
session) IS the evaluation harness. Each iteration is a human-in-the-loop
eval run. This is correct for early-stage development. The lack of an
automated harness is expected and not a defect at this stage.

**Finding: LOW (deferred)**

No automated evaluation harness exists. This is intentional at the current
stage — manual dogfood is the harness. The path to a formal harness requires:
1. A set of test skills with documented expected findings
2. A scoring rubric (did the skill find what it should?)
3. A runner that can execute skill-optimize against the test set

This is the evaluation-harness.spec.md's "dogfood vision" — still ahead.

**Recommendation:** Create a `test-cases/` folder under the skill root with
2-3 minimal skills at known quality levels (one clean, one with a known
DISPATCH finding, one with a known WORDING issue). Defer until the skill
stabilizes further.
