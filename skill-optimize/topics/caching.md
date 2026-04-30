# CACHING (HASH RECORD) — Executable Assessment

Assess whether the skill correctly applies a hash record for caching, and
whether the chosen iteration-tracking approach is sound.

---

## How to make this assessment

### Step 1 — Identify the caching mechanism

Read `uncompressed.md` and `SKILL.md`. Look for:

- Any reference to `.hash-record/` or hash manifest procedure
- Any reference to `optimize-log.md` or similar iteration log
- Any "already done" check at entry (cache probe, log read, status check)
- Any output write to a cache path

Classify what you find:

| Observed | Classification |
| -------- | -------------- |
| `.hash-record/<hash>/` path in instructions | Content-addressed cache (hash record) |
| Log file with topic rows and status fields | Iteration log (topic-level tracking) |
| No caching or checking mechanism | No cache |
| Probe + emit PATH on hit | Hash record with correct short-circuit |

### Step 2 — Assess fit for the skill's purpose

A hash record caches the *entire skill output* keyed to input file
contents. It is correct when:

- The skill produces a deterministic, reusable result given the same inputs
- The skill is expensive (multi-LLM, large file sets)
- Callers want to avoid re-running on unchanged inputs

An iteration log tracks *which sub-tasks have been completed*. It is
correct when:

- The skill is stateful across calls (each call advances progress)
- Different topics/sub-tasks are analyzed separately
- The caller wants to resume where it left off, not replay the whole run

Ask: does the skill need a hash record, an iteration log, or both?

- **Both** — if the skill has expensive per-topic analysis AND callers want
  to skip the whole skill when inputs haven't changed
- **Log only** — if per-invocation progress tracking is the core need
- **Hash only** — if the skill produces a single reusable report
- **Neither** — if the skill is cheap and called at most once per session

### Step 3 — Check for conflicts

Look for contradictions between:

- The spec's stated caching requirements (e.g., R5 hash-record mandate)
- The instructions file's actual implementation

A spec that mandates a hash record while the instructions use only a log
is a conflict. A spec that has not been updated to reflect the log approach
is a conflict. Both are findings.

### Step 4 — Assess idempotency

Separate question: if the cache or log were absent, would running the
skill twice on the same inputs cause problems?

Signals of non-idempotency:

- Duplicate log rows appended on every run without deduplication check
- Findings re-emitted even when status is already `acted` or `clean`
- Files written without checking if already written

### Step 5 — Produce finding or confirm clean

**Finding format:**

```md
### HASH RECORD — HIGH | MEDIUM | LOW

**Signal:** <what you observed>

**Reasoning:** <why the current approach is wrong or conflicted>

**Recommendation:** <specific change>
```

**Severity:**

- HIGH — spec/instructions conflict causing incorrect behavior; or no
  caching on an expensive, repeatedly-called skill
- MEDIUM — partial mismatch; spec says one thing, instructions say another,
  but behavior is still reasonable
- LOW — idempotency gap that won't cause errors but could cause duplicates

**Confirm clean when:** caching approach matches the skill's usage pattern,
spec and instructions are aligned, and the skill is idempotent.

---

## Application to skill-optimize

**Observed caching mechanisms:**

- `spec.md` R5: mandates hash-record manifest procedure — "compute a
  manifest hash... probe the cache at `.hash-record/...`"
- `uncompressed.md` Step 2: checks `optimize-log.md` for prior topic work
- The old Behavior section (now replaced) also described hash-record entry

**Assessment:**

The spec still contains R5 (hash-record mandate). The instructions now use
an optimize-log for iteration tracking. These are not contradictory in
intent — they serve different purposes — but the spec does not reflect the
new design.

**Finding:** MEDIUM

R5 requires a full hash-record cache probe on every entry. The current
`uncompressed.md` uses only the optimize-log (per-topic tracking). For a
skill designed for iterative single-topic passes, the optimize-log approach
is correct. A full hash-record would short-circuit on unchanged inputs
even if new topics are pending analysis — which defeats the iteration model.

**Recommendation:**

1. Update R5 in spec.md to reflect the new design: replace the hash-record
   mandate with the optimize-log approach as the primary tracking mechanism.
   Note that a hash-record could optionally be added as a full-skip cache
   for callers who want "same inputs = skip entirely," but the default is
   the log.
2. Clarify in uncompressed.md that the optimize-log is the authoritative
   iteration state, and a hash-record full-cache is optional (not default).

**Idempotency:** The optimize-log check in Step 2 excludes topics already
marked `clean`/`acted`/`rejected`. This makes the skill idempotent at the
topic level. No idempotency finding.
