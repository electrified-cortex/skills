# OBSERVABILITY — 2026-04-30

**Severity:** LOW (deferred)

**Finding:** Minor gaps only. Qualifier confidence (`yes`/`maybe`) is not
surfaced in the `Assessor selected:` emit line — callers see the selected
topic but not the selection confidence. Self-critique revision trace is not
exposed (final finding is, which is sufficient). Error messages are
functional. The two-tier log+`.optimization/` design provides solid audit
trail — quick scan via log, full detail via reports.

**Action taken:** No change. Optionally add qualifier confidence to
`Assessor selected:` emit. Deferred — low impact on debuggability.
