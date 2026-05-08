# INTERFACE-CLARITY — 2026-05-08

## Assessment: CLEAN (post Tier 2)

Caller/executor split explicit after LESS-IS-MORE fixes:
- Cache: SKILL.md owns probe + write; dispatched agents don't cache
- Orchestration (two-pass policy): SKILL.md; executor receives one tier per dispatch
- context_pointer auto-detect: executor-side (in Pre-dispatch steps)
- Gates + hallucination filter: executor-side
