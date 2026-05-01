# SELF CRITIQUE — 2026-04-30

**Severity:** MEDIUM (acted)

**Finding:** Sonnet topic analysis produced severity ratings and findings
without any within-turn review pass. The same model that wrote the skill was
assessing it — systematic blind-spot risk. No "review your finding" step
existed in the sub-agent prompt or in any topic procedure template. Severity
miscalibration (LOW/MEDIUM confusion) and premature CLEAN calls are the
primary risks.

**Action taken:** Added within-turn self-review instruction to the Sonnet
sub-agent prompt in `uncompressed.md` Step 4 (end of the prompt block):

> "Before finalizing: review your finding. Does it hold under the evidence?
> Is the severity calibrated correctly — not over- or under-rated? If the
> verdict is CLEAN, confirm no signal was missed. Revise before outputting."

No extra dispatch required — within-turn, negligible token overhead.
