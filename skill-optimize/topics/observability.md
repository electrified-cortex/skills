# OBSERVABILITY — Executable Assessment

Assess whether the skill produces enough signal to be debuggable and
trustworthy — decision transparency, intermediate state, error context.

---

## How to make this assessment

### Step 1 — Check decision transparency

For every verdict or categorization the skill produces, is there a
rationale trace in the output?

- Finding severity with `**Reasoning:**` field — traceable ✓
- Assessor topic selection — emits `Assessor selected: <SLUG> — <reason>` ✓
- `TOPIC: none` result — what reasoning led to that? (just says "none apply")

### Step 2 — Check intermediate state surfacing

For multi-step skills: does the output surface enough intermediate state?

- Qualifier output is intermediate state. Is it exposed to the caller?
- Step 4 sub-agent output — is it passed through or only the summary?

### Step 3 — Check error context quality

For the error messages in the skill: are they diagnostic or generic?

Review every `ERROR:` message defined in the skill.

### Step 4 — Check audit log sufficiency

Can the optimize-log be used to reconstruct what happened without re-running?

What's in the log: topic, date, model, N findings, status, action. ✓
What's NOT in the log: which source files were read, what the actual
finding text was (those live in `.optimization/`).

### Step 5 — Produce finding or confirm clean

---

## Application to skill-optimize

**Decision transparency:**

- Finding format: `**Reasoning:** <grounded in specific content>` — callers
  can verify the finding. ✓
- Assessor emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>` ✓
- TOPIC: none — no reasoning trace for why none applied. Minor gap.
- Self-critique pass: the model's review is not exposed in the output.
  If the model revised a finding during the review pass, the caller can't
  see what was revised. Low priority — the final finding is what matters.

**Intermediate state:**

- Qualifier output format (`TOPIC: / APPLICABLE: / REASON:`) — structured
  but the host may not surface it to the caller. The `Assessor selected:` emit
  is the only intermediate state that reaches the caller. If the qualifier
  returned `maybe` and the assessor chose it, the caller sees only the
  selection, not the `maybe` qualifier. Low observability of the selection
  confidence. Minor gap.

**Error context quality:**

Current error messages in `uncompressed.md`:
- `ERROR: no skill source files found at <skill-path>` — includes path. ✓
- `No applicable topics found — all topics already logged or none apply` — not
  marked as ERROR. Fine as a terminal state.
- `ERROR: unexpected analysis format` (just added) — minimal but actionable.
  Could be more specific: which format was expected? What was received?

**Audit log sufficiency:**

optimize-log.md: topic, date, model, findings count, status, action. ✓
`.optimization/<slug>.md`: full finding text, reasoning, action. ✓

Two-tier storage is well-designed for observability: quick scan via log,
deep detail via reports.

**Finding: LOW**

Minor gaps: qualifier confidence level not surfaced to caller; self-critique
revision trace not exposed. Neither materially impacts debuggability given
the full finding text is in `.optimization/` reports. Error messages are
functional. The two-tier log+report design is solid for audit.

**Recommendation:** No required change. Optionally: add qualifier confidence
(`yes`/`maybe`) to the `Assessor selected:` emit line for better caller
visibility. Defer.
