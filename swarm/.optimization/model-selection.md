# MODEL-SELECTION — 2026-05-01

## Findings

**Severity:** MEDIUM
**Finding:** The swarm skill specifies `standard` (sonnet-class) tier for personality dispatches (S5) and the arbitrator (S6), both appropriate. However, the skill provides no guidance to callers on what model tier should execute the host orchestrator itself. The host must: build a self-contained review packet from arbitrary input (judgment-intensive), evaluate trigger conditions inline against inferred problem traits (semantic reasoning), synthesize from the arbitrator's action list into host-voice output with confidence rating (multi-step judgment). A haiku-class host would fail at packet construction and synthesis. The skill's SKILL.md and uncompressed.md are silent on the minimum caller tier.
**Action taken:** Added `## Caller Tier` section to uncompressed.md and a `Caller tier:` line to the SKILL.md Step Sequence preamble stating sonnet-class minimum for the host orchestrator.

---

**Severity:** LOW
**Finding:** The arbitrator dispatch (S6) is correctly tier-justified at `standard`. The task — compare N structured member outputs, filter speculative/duplicate items, produce two-section action list — requires semantic judgment across multiple inputs. Instruction quality is not the barrier. No downgrade opportunity.
**Action taken:** No change. Clean on arbitrator tier.

---

**Severity:** LOW
**Finding:** Personality dispatches (S5) at `standard` are correctly justified. Evidence-citing domain review requires semantic reasoning; haiku-class cannot reliably identify and cite evidence from arbitrary artifacts. Instruction quality is not the barrier here.
**Action taken:** No change. Clean on personality tier.
