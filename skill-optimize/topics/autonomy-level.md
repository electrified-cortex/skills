# Autonomy Level — Assessment Procedure

## What to assess

Is skill-optimize correctly calibrated on the autonomy spectrum? Does it document
what it will do autonomously vs. what requires confirmation?

## Evidence to check

1. Read `uncompressed.md` — trace every write operation across all steps.
2. Identify: what files does the skill write? Are any of them existing files?
3. Check for any confirmation step before writes.
4. Check whether the skill's description (or spec.md) states its autonomy model.

## Assessment criteria

**Write operations inventory:**

- Step 4: dispatches sub-agent (no writes)
- Step 5a: appends row to `<skill-path>/optimize-log.md` (existing file, append)
- Step 5b: writes `<skill-path>/.optimization/<slug>.md` (new file, create)

**Constructive vs. destructive:**

- Log append = constructive, reversible (delete the appended row)
- Report create = constructive, reversible (delete the new file)
- The skill does NOT modify `uncompressed.md`, `spec.md`, or other source files.
  "Acted" findings are applied by the host agent — the skill only records the
  recommendation.

**Autonomy model documented?**

- Does the skill state: "fully autonomous for all writes — no confirmation needed"?
- Does it clarify that "acted" status means the host makes changes, not the skill?

## Scoring

- **MEDIUM**: Skill modifies existing source files without confirmation step, and
  autonomy model is undocumented — callers cannot safely pipeline it.
- **LOW**: Skill's actual writes are safe (append-only / create-only), but the
  autonomy model is undocumented — callers may incorrectly assume the skill
  makes destructive edits.
- **CLEAN**: Autonomy model is appropriate and documented.

## Current state (2026-04-30)

Writes are append-only (log row) and create-only (report file). No existing source
files are modified by the skill itself. The "acted" label in the log means the host
agent applies changes — the skill is a recommendation engine, not a modifier.

However, this distinction is not stated anywhere in the skill's description or
instructions. A caller reading the skill could reasonably assume it modifies
skill files based on its findings. The autonomy model should be explicitly
documented.

**Finding: LOW** — write operations are safe (append + create only); autonomy
calibration is correct. Gap: the skill does not state its autonomy model or
clarify that "acted" changes are applied by the host, not the skill. Add one
sentence to the description: "Skill is fully autonomous — all writes are new or
append-only. Source file modifications are the caller's responsibility."
