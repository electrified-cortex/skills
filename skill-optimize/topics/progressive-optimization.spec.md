# Progressive Optimization and Tracking

## Purpose


Ideas for how skill-optimize can track its own work over time, avoid
redundant analysis, and prioritize the highest-impact work first.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Topic prioritization by impact tier

Not all optimization topics have equal expected yield. Topics should be
ordered by impact-to-effort ratio so that partial runs (stopping early)
still capture the highest-value improvements.

Draft impact tier ranking (high to low, to be validated empirically):

**Tier 1 — High impact, often finds issues:**
- DISPATCH (wrong execution pattern wastes every invocation)
- MODEL SELECTION (wrong tier = overpay or underperform on every run)
- WORDING (every call to this skill benefits from better wording)
- DETERMINISM (replacing LLM steps with tools creates permanent savings)

**Tier 2 — Significant when applicable:**
- COMPRESSIBILITY (token savings compound across all future invocations)
- LESS IS MORE (removes overhead from every future model read)
- COMPOSITION (if the skill is too large to reason about efficiently)
- CHAIN OF THOUGHT (for judgment skills, often unlocks latent capability)

**Tier 3 — Valuable but context-dependent:**
- HASH RECORD (only applies if the skill processes the same inputs repeatedly)
- OUTPUT FORMAT (high variance with poorly-specified output)
- EXAMPLES (effective but adds tokens to every invocation)
- SELF CRITIQUE (only for judgment-heavy skills with high accuracy demand)

**Tier 4 — Useful refinements:**
- TOOL SIGNATURES (tool names matter most in large tool registries)
- REUSE (gains only materialize if extracted procedures are widely used)

The optimizer should run tiers in order. A partial run stopping at Tier 2
will have captured the majority of actionable findings.

## Per-topic optimization record (optimization.md)

An `optimization.md` file stored in the skill's directory tracks which
topics have been analyzed, at what topic version, with what result. This
enables skip logic: if a topic file hasn't changed since it was last run
on this skill, skip it.

Proposed structure:

```md
---
skill: <repo-relative skill path>
---

# Optimization Log

## Purpose


| Topic | Topic version | Last run | Model | Findings | Record |
| --- | --- | --- | --- | --- | --- |
| dispatch | 1.0 | 2026-04-20 | sonnet | 1 HIGH | .hash-record/ab/cdef/... |
| wording | 1.0 | 2026-04-20 | sonnet | 0 | .hash-record/ab/cdef/... |
| ...
```

On entry, the optimizer reads this file and computes a hash of the
current topic file for each topic. If the topic hash matches the stored
hash, skip that topic. If not (the topic has been updated), re-run it.

This is the complement to the global hash record: the hash record skips
re-running when the SKILL hasn't changed; the optimization.md skips
re-running when the TOPIC hasn't changed.

Combined:
- Skill unchanged AND topic unchanged → skip (full cache hit)
- Skill changed → re-run all topics
- Skill unchanged, topic changed → re-run only changed topics

## Menu mode

Interactive mode: instead of running all topics, the optimizer presents
a menu of available topics (with their impact tier and last-run date),
lets the operator select which to run, then executes only those.

The menu could show:
- Topic name
- Current topic version
- Last run date (from optimization.md)
- Whether the topic has changed since last run (dirty/clean)
- Estimated cost tier (Haiku/Sonnet/Opus for this topic)

This enables targeted re-analysis: "run just WORDING and CHAIN OF THOUGHT
on this skill" without re-running everything.

## Dogfood: skill-optimize tracks its own optimization

skill-optimize should have its own `optimization.md` — demonstrating that
the tracking system it defines is used on itself. This closes the loop:
any time a topic file is updated, the system knows to re-run that topic
on skill-optimize itself.

The dogfood check: does skill-optimize's optimization.md show that all
topics have been run at least once? If not, the tool is underdeveloped.

## Version-gated topic re-runs

Each topic file should carry a version header (e.g., `version: 1.2`).
The optimization.md stores the version at time of last run. If the stored
version doesn't match the current version, the topic has been updated and
should be re-run — regardless of whether the skill changed.

This decouples two sources of staleness:
1. The skill changed (existing behavior)
2. The optimization criteria changed (new capability from topic update)

Both sources independently invalidate prior findings.

## Progressive depth within a topic

For a single topic, an optimizer could run at increasing depth:
- Quick scan (Haiku, ~5 min context read, obvious signals only)
- Standard analysis (Sonnet, full read, judgment applied)
- Deep review (Opus, adversarial, edge cases)

The optimization.md could record which depth was last used, enabling
targeted depth escalation: "re-run DISPATCH at Opus depth" without
re-running everything at Opus.

This is the per-topic variant of the R12 convergence loop.
