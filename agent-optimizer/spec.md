---
name: agent-optimizer
description: >-
  Spec for the agent-optimizer skill — design rationale, tier philosophy,
  token cost model, and optimization principles.
---

# Agent Optimizer — Spec

Design rationale and reference for the agent-optimizer skill. This file is the
spec companion — it contains the *why* behind the optimization strategy and the
full reasoning that agents must not carry per-turn.

## Purpose

Agent files (CLAUDE.md, .agent.md) are loaded into the system prompt and sent
on every API call. Every token in an agent file is a per-turn cost — paid on
every single interaction, not just at session start. This makes agent files the
most expensive real estate in the entire agent context window.

The agent-optimizer skill exists to analyze agent files and produce actionable
recommendations for reducing per-turn token cost while preserving behavioral
fidelity.

## Scope

This spec governs the agent-optimizer skill. The skill operates on agent
definition files across any platform (VS Code Copilot, Claude Code, custom
orchestrators). It does NOT modify files directly — it produces analysis and
recommendations. Implementation is a separate step.

### In Scope

- Analysis of agent file token cost
- Classification of content by loading frequency
- Recommendations for content placement across tiers
- Compression-aware optimization (interoperates with compression skill)
- Post-compaction recovery pattern design
- Manifest and skill extraction strategies

### Out of Scope

- Direct file modification (the skill recommends; humans or other skills apply)
- Runtime agent behavior testing
- Platform-specific system prompt internals
- Token counting precision (estimates using chars/4 heuristic)

## Definitions

- **Agent file**: The file loaded into the system prompt on every API call.
  CLAUDE.md for Claude Code. .agent.md for VS Code Copilot. The per-turn file.
- **Per-turn cost**: Tokens sent to the model on every interaction. Agent file
  content pays this cost. Measured in tokens (estimated as characters / 4).
- **Session cost**: Tokens loaded once at the start of a session or after
  compaction. Manifest content pays this cost.
- **On-demand cost**: Tokens loaded only when a specific topic arises. Skill
  content pays this cost. May never be loaded in a session.
- **Tier**: A classification of content by its loading frequency and cost
  profile. Three tiers defined below.
- **Manifest**: A Tier 2 document containing full operating context, read once
  at session start and re-read after compaction.
- **Compaction**: Context window reset performed by the platform. The agent file
  survives compaction; conversation context does not.
- **Behavioral fidelity**: The degree to which optimized agent behavior matches
  the original unoptimized behavior. Optimization must not degrade this.

## The Three-Tier Model

### Normative

The skill classifies agent file content into exactly three tiers based on
loading frequency.

#### Tier 1 — Agent File (per-turn)

Content that MUST be in the agent file because it influences behavior on
almost every request.

Requirements for Tier 1 content:
- Identity (who the agent is, 1-2 sentences)
- Prime directive (the single most important behavioral rule)
- Safety guards (loop prevention, permission boundaries, forbidden actions)
- Manifest reload instruction ("read X on session start and after compaction")
- Quick reference (compressed essentials for high-frequency decisions)

Tier 1 target size: 200-500 tokens.

Tier 1 content MUST satisfy ALL of these criteria:
1. Relevant to nearly every interaction
2. Required to survive compaction without re-reading another file
3. Cannot be deferred to a later read without behavioral degradation

#### Tier 2 — Startup Manifest (session cost)

Content loaded once at session start via file read. Stays in conversation
context but NOT in the system prompt. The Tier 1 agent file contains the
instruction to read this file.

Appropriate for Tier 2:
- Full personality and disposition
- Ownership and domain tables
- Delegation model and rules
- Scoring rubric
- Operating principles and guidelines
- Communication rules
- Autonomous action decision tables
- Skill index and cross-references

Tier 2 target size: 1,000-2,000 tokens.

Tier 2 content MUST satisfy ALL of these criteria:
1. Important for correct behavior but not needed on every single turn
2. Can be loaded once and retained in conversation context
3. The agent file contains a reload instruction for post-compaction recovery

#### Tier 3 — Skills (on-demand cost)

Content loaded only when the relevant topic arises. Zero cost until needed.
May never be loaded in a given session.

Appropriate for Tier 3:
- Detailed procedures (startup, shutdown, recovery)
- Compression guidelines and tier details
- Git workflow procedures
- Task pipeline mechanics
- Platform-specific instructions
- Specialized domain knowledge

Tier 3 has no target size — skills are self-contained and vary.

Tier 3 content MUST satisfy ALL of these criteria:
1. Procedural, situational, or domain-specific
2. Not needed unless a specific topic or task arises
3. Self-contained enough to be useful without Tier 1 or Tier 2 context

### Classification Rules

- Content that affects behavior on almost every request → Tier 1
- Content that shapes overall session behavior but not per-turn → Tier 2
- Content that is procedural, situational, or large → Tier 3
- When in doubt between Tier 1 and Tier 2, prefer Tier 2 (cheaper)
- When in doubt between Tier 2 and Tier 3, prefer Tier 3 (cheapest)
- Safety-critical content always stays in Tier 1 regardless of frequency

## Token Cost Model

### Normative

The skill estimates token cost using the heuristic: tokens ≈ characters / 4.

Cost formulas:
- Per-turn cost = Tier 1 size × number of turns
- Session cost = Tier 2 size × number of (re)loads (typically 1-3)
- On-demand cost = Tier 3 size × number of invocations (0-N)
- Total session cost = per-turn + session + on-demand

Example calculation for a 100-turn session:
- Current: 1,800 tokens × 100 turns = 180,000 tokens
- Optimized: 400 tokens × 100 turns + 1,500 × 2 reloads = 43,000 tokens
- Savings: ~137,000 tokens (76% reduction)

### Constraints

- Token estimates are approximations. Actual tokenization varies by model.
- The skill must never claim exact token counts — always "approximately" or "~".
- Savings projections must state assumptions (turns, reloads).

## Optimization Process

### Normative

The skill follows this sequence when analyzing an agent file:

1. **Measure** — Calculate current agent file size in characters and estimated
   tokens.
2. **Classify** — For each section/paragraph, determine which tier it belongs
   to using the classification rules above.
3. **Recommend** — Produce a tier assignment table showing what moves where.
4. **Estimate** — Calculate projected savings with stated assumptions.
5. **Flag risks** — Identify any content where tier assignment is ambiguous or
   where moving it could degrade behavioral fidelity.

### Output Format

The skill produces a structured recommendation with these sections:

1. **Current State** — file path, size, estimated tokens
2. **Tier Assignment Table** — each content block with current location,
   recommended tier, and rationale
3. **Projected Savings** — per-turn reduction, session cost, total over N turns
4. **Risks and Caveats** — behavioral fidelity concerns, ambiguous assignments
5. **Proposed Tier 1** — draft of the minimal agent file
6. **Proposed Tier 2** — draft of the manifest (or delta from existing)

## Compression Interoperation

### Normative

The agent-optimizer skill interoperates with the compression skill but they
are distinct concerns:

- **Optimization** = moving content to cheaper tiers (structural change)
- **Compression** = reducing token count within a tier (textual change)

The recommended workflow:
1. Optimize first (move content to correct tiers)
2. Compress each tier independently using the compression skill
3. Tier 1 should use Ultra compression (highest density, per-turn)
4. Tier 2 should use Full compression (good density, loaded occasionally)
5. Tier 3 follows its own compression conventions

The agent-optimizer skill must never apply compression itself. It recommends
tier placement. The compression skill handles token reduction within tiers.

## Post-Compaction Recovery

### Normative

The optimization strategy MUST preserve post-compaction recovery. This is a
hard constraint — an optimized agent that cannot recover after compaction is
a failed optimization.

Requirements:
- Tier 1 MUST contain explicit instruction to re-read the manifest after
  compaction
- The reload instruction MUST reference the manifest by file path
- The manifest path MUST be relative to the agent file location
- The manifest MUST be self-contained enough to restore full operating context
  without requiring additional reads (though it may reference skills)

## Platform Considerations

### Descriptive

Different platforms handle agent files differently:

- **Claude Code**: CLAUDE.md loaded as user message, re-injected after
  compaction. Supports file reading via Read tool.
- **VS Code Copilot**: .agent.md loaded as system prompt, constant per-turn
  cost. Supports file reading via read_file tool. Skills discovered via
  frontmatter.
- **Custom orchestrators**: Behavior varies. The three-tier model is
  platform-agnostic but reload mechanics may differ.

The skill's recommendations are platform-agnostic. Platform-specific reload
mechanics are implementation details handled during application.

## Constraints

- The skill must not modify files directly
- The skill must not claim exact token counts
- The skill must not recommend removing safety-critical content from Tier 1
- The skill must not recommend optimization that breaks post-compaction recovery
- The skill must state all assumptions in savings projections
- The skill must flag ambiguous tier assignments rather than guessing
- Behavioral fidelity is a hard constraint — optimization must not change
  what the agent does, only where the instructions live

## Defaults and Assumptions

- Default token estimation: characters / 4
- Default session length for projections: 100 turns
- Default number of compaction events: 1-2 per session
- Default Tier 1 target: 200-500 tokens
- Default Tier 2 target: 1,000-2,000 tokens
- If no compression tier specified for output, recommend Ultra for Tier 1,
  Full for Tier 2

## Error Handling

- Agent file cannot be read → report error, do not guess content
- Agent file has no clear identity section → flag as critical finding
- Agent file has no safety guards → flag as critical finding
- Content classification is ambiguous → include in Risks section with both
  possible tiers and rationale for each
- Manifest already exists → analyze both files, recommend merge strategy

## Precedence

- Safety-critical content placement (Tier 1) overrides token savings
- Post-compaction recovery overrides structural elegance
- Behavioral fidelity overrides compression targets
- This spec governs the SKILL.md — any conflict, spec wins

## Non-Goals

- Automated file modification (recommend only)
- Runtime behavioral testing
- Precise tokenizer-level counting
- Platform-specific system prompt engineering
- Agent file creation from scratch (optimization of existing files only)
