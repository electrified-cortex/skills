# CACHING — 2026-05-08

## Findings

### EARLY GATE — HIGH

**Severity:** HIGH
**Finding:** Cache check sat at the end of Step 1, after full packet assembly (LLM work). The manifest hash only requires file contents — a deterministic file-read operation. All LLM packet-assembly work was wasted on every cache hit.
**Action taken:** Moved cache gate to top of Step 1 in SKILL.md, uncompressed.md, and spec.md. File list extraction + hash computation now happen before any packet assembly. LLM work only runs on cache miss.

### CACHE KEY SCOPE — HIGH

**Severity:** HIGH
**Finding:** `personality_filter` was not included in the full-result cache key (`vN/report.md`). A filtered run (e.g., one reviewer) could return as a cache hit for a subsequent unfiltered run, silently returning a partial synthesis.
**Action taken:** Added `filter_hash` = SHA-256 of sorted `personality_filter` list to the full-result path: `v1/<filter_hash>/report.md`. Per-persona paths are unaffected (already disambiguated by persona name). Updated SKILL.md, uncompressed.md, and spec.md.

### CACHE WRITE ORDERING / B10 BROKEN — HIGH

**Severity:** HIGH
**Finding:** Per-persona results were both written at Step 8 (after synthesis). B10 partial recovery assumed per-persona results existed from interrupted runs — but nothing was ever written before synthesis, making B10 inert for the failure modes it was designed to handle.
**Action taken:** Updated Step 5 in SKILL.md and uncompressed.md to write each built-in persona result immediately as its dispatch completes. Step 8 now writes only the full report. Updated spec.md to match.

### VERSION vN UNDEFINED — MEDIUM

**Severity:** MEDIUM
**Finding:** `vN` was a literal placeholder throughout all three files. No concrete current value defined. Independent implementations would choose version strings arbitrarily, causing cache misses or stale hits.
**Action taken:** Defined current version as `v1` in all three files. Added explicit bump condition: persona prompts, selection criteria, arbitrator procedure, or hash algorithm changes require a bump. Wording/formatting do not.

### B10 NOT WIRED INTO STEP SEQUENCE — MEDIUM

**Severity:** MEDIUM
**Finding:** B10 was only visible in the Behavior section. Step 1 cache miss path said "continue" with no forward pointer to B10. Implementors following only the step sequence would re-dispatch all personalities on miss, ignoring any partial cache.
**Action taken:** Added B10 forward pointer directly in the Step 1 miss path in SKILL.md and uncompressed.md: "Cache miss: before proceeding to Step 2, check for existing per-persona results per B10."

### CONCURRENT RUN IDEMPOTENCY — LOW

**Severity:** LOW
**Finding:** No guard against two concurrent runs writing to the same full-result path. Second write would silently overwrite the first.
**Action taken:** Added write-before-check in Step 8 (SKILL.md and uncompressed.md) and spec.md: if `v1/<filter_hash>/report.md` already exists, skip the write.
