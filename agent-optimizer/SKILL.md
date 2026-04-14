---
name: agent-optimizer
description: >-
  Analyze agent files for per-turn token cost and recommend content placement
  across three tiers: agent file (per-turn), manifest (session), skills
  (on-demand). Compression-aware. Preserves post-compaction recovery.
---

Analyze agent file → classify content → recommend tier placement → estimate savings.

## Tiers

Three tiers by loading frequency:

**Tier 1 — Agent File (per-turn cost)**
Sent every API call. Target: 200–500 tokens. Only content that influences almost every request.

Must contain:
- Identity (1–2 sentences)
- Prime directive (single paragraph)
- Safety guards (loop prevention, permission boundaries, forbidden actions)
- Manifest reload instruction (path, "read on start + after compaction")
- Quick reference (compressed high-frequency essentials)

Criteria: relevant to nearly every interaction AND must survive compaction AND cannot be deferred.

**Tier 2 — Manifest (session cost)**
Read once at session start, re-read after compaction. Target: 1,000–2,000 tokens.

Appropriate: personality, ownership tables, delegation model, scoring rubric, operating principles, communication rules, autonomous action tables, skill index.

Criteria: shapes session behavior AND loadable once AND agent file contains reload instruction.

**Tier 3 — Skills (on-demand cost)**
Loaded when topic arises. Zero cost until needed. May never load.

Appropriate: detailed procedures, compression guidelines, git workflows, task pipeline mechanics, platform-specific instructions, domain knowledge.

Criteria: procedural/situational/domain-specific AND not needed unless topic arises AND self-contained.

## Classification Rules

Content affects almost every request → Tier 1.
Content shapes session behavior, not per-turn → Tier 2.
Content is procedural, situational, or large → Tier 3.
Doubt between Tier 1 and 2 → prefer Tier 2 (cheaper).
Doubt between Tier 2 and 3 → prefer Tier 3 (cheapest).
Safety-critical → always Tier 1 regardless.

## Process

1. **Measure** — file size in chars, estimated tokens (chars / 4).
2. **Classify** — each section/paragraph → tier using classification rules.
3. **Recommend** — tier assignment table: content block, current location, recommended tier, rationale.
4. **Estimate** — projected savings. State assumptions (turns, reloads). Default: 100 turns, 1–2 compactions.
5. **Flag risks** — ambiguous assignments, behavioral fidelity concerns.

## Output Format

```
## Current State
File: <path> | Size: ~N tokens

## Tier Assignment
| Content Block | Current | Recommended | Rationale |
| --- | --- | --- | --- |
| Identity | Tier 1 | Tier 1 | Per-turn relevant |
| Delegation model | Tier 1 | Tier 2 | Session-level, not per-turn |
| Git workflow | Tier 1 | Tier 3 | Procedural, situational |

## Projected Savings
Per-turn: ~X → ~Y tokens (Z% reduction)
Over 100 turns: ~N tokens saved
Assumptions: <stated>

## Risks
- <ambiguous assignment with both options>
- <behavioral fidelity concern>

## Proposed Tier 1
<draft minimal agent file>

## Proposed Tier 2
<draft manifest or delta>
```

## Compression Interoperation

Optimization (move content between tiers) and compression (reduce tokens within tier) are distinct.

Workflow: optimize first → compress each tier independently.
Recommended compression: Tier 1 = Ultra, Tier 2 = Full, Tier 3 = per skill convention.
This skill recommends placement. The `compression` skill handles token reduction.

## Post-Compaction Recovery

Hard constraint. Optimized agent MUST recover after compaction.

- Tier 1 MUST contain reload instruction with manifest file path
- Path MUST be relative to agent file location
- Manifest MUST be self-contained for full context restoration

Optimization that breaks post-compaction recovery = failed optimization.

## Token Estimation

Heuristic: tokens ≈ characters / 4. Always approximate — use "~" or "approximately."
Never claim exact counts. State assumptions in all projections.

## Constraints

- Do not modify files — recommend only
- Do not remove safety-critical content from Tier 1
- Do not break post-compaction recovery
- Behavioral fidelity is a hard constraint — what the agent does must not change
- Flag ambiguous assignments; do not guess

## Precedence

Safety placement (Tier 1) > token savings.
Post-compaction recovery > structural elegance.
Behavioral fidelity > compression targets.
Spec (`spec.md`) governs this file.
