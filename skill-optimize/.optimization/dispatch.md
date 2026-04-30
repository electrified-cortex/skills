# DISPATCH — 2026-04-29

**Severity:** MEDIUM

**Finding:** Step 4 (topic analysis) runs inline in the host context despite
the skill declaring itself a dispatch skill. The analysis is context-independent
and accumulates intermediate findings state that pollutes the host's context
window on every invocation.

**Action taken:** Rewrote Step 4 in `uncompressed.md` to dispatch a
Sonnet-class topic analysis sub-agent. The host passes: all skill source
files + the selected topic spec. The sub-agent returns findings in standard
format. Steps 3b, 5, and 6 remain inline (brief + host context needed).

**Validates:** Architecture Direction in spec.md §"Architecture Direction
(Planned)" — per-topic dispatch agents.
