# OUTPUT FORMAT — 2026-04-29

**Severity:** MEDIUM

**Finding:** `spec.md ## Output` described writing to a hash-record path
(`.hash-record/<hash>/skill-optimize/v1.0/report.md`). `uncompressed.md`
does not write that file. Full finding text from dispatched sub-agents had
no defined persistent location — only count + status survived.

**Action taken:** Rewrote `spec.md ## Output` section — removed hash-record
path; defined primary return line template (`TOPIC: X | FINDINGS: N | LOG:
path`) and optimize-log entry format (table row + full finding text per topic
in `.optimization/<slug>.md`).
