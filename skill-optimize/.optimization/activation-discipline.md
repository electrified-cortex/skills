# Optimization Report: ACTIVATION DISCIPLINE

**Skill:** skill-optimize
**Date:** 2026-04-30
**Model:** Claude Sonnet 4.6
**Status:** deferred

## Finding

**Severity:** LOW

The skill has no documented activation criteria — no positive triggers, no negative
triggers, no confidence threshold, no activation mode declaration. It is implicitly
"always available" (default mode) without stating this as a design decision.

**Reasoning:** In practice, the skill is specific enough (requires a valid
`<skill-path>`) that over-triggering is unlikely in interactive use. The real risk
is in batch contexts: a coordinator looping over all skills in a directory would
invoke this on every skill indefinitely, re-processing already-clean topics.
Negative trigger documentation ("do not re-invoke topics already logged clean in
this session") would prevent this.

## Recommended action

Add to the skill description or Inputs preamble:

> Activation mode: default (invoke when a skill is identified for review).
> Do not invoke: when the skill is currently under active revision; when all
> topics for the target skill are already logged clean or acted in the current
> session.

## Deferred rationale

The missing documentation does not cause current failures. Will be addressed when
SKILL.md is created — the description block is the natural home for activation
criteria.
