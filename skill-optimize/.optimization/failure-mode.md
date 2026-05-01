# Optimization Report: FAILURE MODE

**Skill:** skill-optimize
**Date:** 2026-04-30
**Model:** Claude Sonnet 4.6
**Status:** deferred

## Finding

**Severity:** LOW

The skill handles explicit error cases (no source files found, TOPIC: none, malformed
sub-agent response) but does not document behavior for sparse input — a skill with
minimal source files (e.g., only a SKILL.md, no spec.md or uncompressed.md).

**Reasoning:** The sparse-input case is not a hard failure — the skill degrades
gracefully by reading whatever files exist and proceeding. But the degradation is
undocumented: a caller sending a stub skill with one 3-line SKILL.md will get an
analysis result without knowing that the result quality is lower than for a
fully-specified skill. The skill should either note this limitation or document a
minimum viable input threshold.

## Deferred rationale

Low priority — the primary use case is well-specified skills. Will be addressed
when SKILL.md is created, where a "Limitations" or "Input requirements" note is
the natural location.
