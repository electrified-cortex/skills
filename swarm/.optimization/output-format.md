# OUTPUT-FORMAT — 2026-05-08

## Findings

### ARBITRATOR CRITICALITY COLLAPSE — HIGH

**Severity:** HIGH
**Finding:** The arbitrator produces two structurally distinct sections (Obvious actions / Critical actions) with different operational meaning per `specs/arbitrator.md`. Step 8's synthesis template collapsed both into a single `Summary` field. Callers cannot distinguish blocking-severity findings from consensus-but-not-blocking ones without re-reading raw arbitrator output — which the skill explicitly forbids passing to the caller.
**Action taken:** Replaced `Summary` with two explicit fields: `Critical actions` (items blocking shipping or requiring architectural change) and `Findings` (remaining consensus findings). Applied to required fields list and template block in both SKILL.md and uncompressed.md.

### DROPPED PERSONALITIES CONFLATION — MEDIUM

**Severity:** MEDIUM
**Finding:** Single `Dropped personalities` field conflated two distinct categories: availability-gated drops (reviewer could not run — lens never applied) and non-contributing dispatches (reviewer ran but returned empty or timed out — per B4). Different diagnostic implications; D6 Low confidence signal is buried in the same bucket as backend-unavailable drops.
**Action taken:** Split into `Unavailable personalities` (probe-failed, availability gate) and `Non-contributing personalities` (empty output/timeout). Updated B4 in both files to reference `Non-contributing personalities` field by name.

### ACTIVE PERSONALITIES FIELD ABSENT — MEDIUM

**Severity:** MEDIUM
**Finding:** Synthesis output included `Dropped personalities` but no `Active personalities` field. Callers cannot audit which reviewers contributed, especially for generated personas (not in registry, not cached, not in any index). A caller cannot assess coverage, verify scope, or target a re-run with `personality_filter` without knowing who ran.
**Action taken:** Added `Active personalities` as required synthesis output field: name (model-class) for each; generated personas tagged with "(generated)". Applied to required fields list and template block in both files.
