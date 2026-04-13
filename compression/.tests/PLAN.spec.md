---
title: Compression Benchmark Test Plan Spec
type: test-plan-spec
purpose: Requirements for the benchmark test procedure — what the plan must cover
---

This spec defines the requirements for `.tests/PLAN.md`. The plan is the
procedure document that governs how the compression benchmark suite is executed.

## Scope

The plan must describe a repeatable procedure for compressing a single test
input across multiple models and all three compression tiers (lite, full,
ultra), then analyzing results.

## Required Sections

### 1. Directory Structure

- Document the full `.tests/` directory layout
- Show where inputs, outputs per tier, and results live
- Output files named by model (e.g., `lite/sonnet.md`)

### 2. Test Phases

The procedure must define exactly four sequential phases:

1. **Input Generation** — produce the test input from its spec, then verify the
   input against the spec before proceeding
2. **Compression Runs** — compress the input at each tier for each model in the
   matrix; document every combination as an explicit step
3. **Audit** — run the Spec Auditor on each compressed output to verify tier
   compliance (preserve rules, tier-specific behaviors)
4. **Analysis** — produce a results document with quantitative metrics and
   qualitative findings

### 3. Compression Run Matrix

- Every model × tier combination must be listed as an explicit step
- Each step specifies: input file, tier, model, output path
- No manual intervention — each run uses the skill's standard prompt

### 4. Audit Criteria

Per-tier verification requirements:

- **Lite:** preserve rules respected, filler dropped, grammar intact
- **Full:** shorter synonyms used, fragments allowed, preserve rules intact
- **Ultra:** telegraphic style, abbreviations used, preserve rules intact

### 5. Analysis Requirements

The results document must include:

- Size matrix (word count, line count per output vs baseline)
- Compression ratio (percentage reduction per tier per model)
- Audit verdicts (pass/fail per output)
- Quality notes (meaning loss, preserve violations, style drift)
- Model comparison (rank by compression quality per tier)
- Recommendations with specific decision criteria:
  - Haiku ≈ Sonnet → recommend Haiku as default
  - Local models follow rules → note local-dispatch viability
  - Consistent preserve failures → flag the model

### 6. Model Matrix

- Must include at least: one frontier baseline, one small frontier, one
  external vendor, one local model
- Each model entry specifies: name, type, access method, execution priority
- Priority ordering determines execution sequence (P1 first)

### 7. Success Criteria

- Checkable items (not prose)
- Minimum: frontier models at all tiers + one local attempt
- Results document populated with full comparison
- Default model recommendation documented

## Constraints

- The plan must be self-contained — executable by any agent without additional
  context beyond the referenced skill files
- No hardcoded API keys or credentials
- Output paths must follow the directory structure exactly
- The plan does not include the results — only the procedure for generating them

## Companion

- **Implementation:** `.tests/PLAN.md`
- **Related specs:** `inputs/recipe.spec.md` (test input), `compression/SKILL.spec.md` (compression rules)
