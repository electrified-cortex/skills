---
name: agent-optimizer
description: >-
  Spec for the agent-optimizer skill — design rationale, layered architecture,
  pruning philosophy, empirical findings, and platform references.
---

# Agent Optimizer — Spec

Design rationale and reference for the agent-optimizer skill. This file is the
spec companion — it contains the *why* behind the optimization strategy, the
empirical evidence, and the full reasoning that agents must not carry per-turn.

## Credit

Architecture informed by:
- Vercel's agent eval findings showing compressed indexes outperform both
  baseline and skill-only setups
  ([source](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals))
- Anthropic's Claude Code documentation on persistent vs on-demand context
  ([source](https://docs.anthropic.com/en/docs/claude-code/skills))
- GitHub's documentation on repo-wide vs path-specific instruction mechanisms
  ([source](https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot))

## Purpose

Agent files (`CLAUDE.md`, `.agent.md`, `AGENTS.md`) are loaded into the system
prompt and sent on every API call. Every token in an agent file is a per-turn
cost — paid on every single interaction, not just at session start. This makes
agent files the most expensive real estate in the entire agent context window.

The common failure mode is treating the agent file as a manual or biography
instead of a kernel. Vercel's evals exposed this directly: a compact 8KB docs
index in `AGENTS.md` outperformed both baseline and skill-based setups because
it removed decision ambiguity and told the agent where to retrieve the right
material.

The agent-optimizer skill exists to audit agent files and produce actionable
recommendations for reducing per-turn cost while preserving or improving
behavioral quality.

## Scope

This spec governs the agent-optimizer skill. The skill operates on agent
definition files across any platform (VS Code Copilot, Claude Code, custom
orchestrators). It does NOT modify files directly — it produces analysis and
recommendations.

### In Scope

- Audit of agent file content, structure, and token cost
- Classification of content by loading frequency and purpose
- Recommendations for content placement across layers
- Compression-aware optimization (interoperates with compression skill)
- Post-compaction recovery pattern design
- Anti-pattern detection and reporting

### Out of Scope

- Direct file modification (the skill recommends; humans or other skills apply)
- Writing new agent files from scratch
- Runtime agent behavior testing
- Platform-specific system prompt internals
- Precise tokenizer-level counting

## Definitions

- **Agent file**: The file loaded into the system prompt on every API call.
  `CLAUDE.md` for Claude Code. `.agent.md` for VS Code Copilot. The always-on
  file.
- **Always-on context**: Content that persists across nearly every turn. The
  agent file is the primary source. Anthropic: "CLAUDE.md content is
  persistent." GitHub: repo-wide instructions "apply to all requests made in
  the context of a repository."
- **Per-turn cost**: Tokens sent on every interaction. Agent file content pays
  this cost. Estimated as characters / 4.
- **Kernel**: The mental model for what an agent file should be. A kernel
  enforces invariants, schedules retrieval, and dispatches specialized work.
  Everything else is userland.
- **Compaction**: Context window reset by the platform. The agent file survives;
  conversation context does not.
- **Behavioral fidelity**: The degree to which optimized agent behavior matches
  the original. Optimization must not degrade this.

## The Core Design Principle

### Normative

The agent file is not a general handbook.

It should contain only:
1. **Identity and stance** — what the agent is for, in one tight paragraph
2. **Global invariants** — rules that are almost never wrong
3. **Routing rules** — when to delegate, load a skill, or read another doc
4. **Compact knowledge index** — pointers to where deeper knowledge lives

Anything procedural, situational, lengthy, or domain-specific must move out.

### The Pruning Test

A line belongs in the always-on file only if at least one is true:
- It prevents expensive recurring mistakes
- It is relevant to a large share of requests
- It routes the agent toward the right next context
- Its absence would regularly cause bad decisions before retrieval happens

Everything else should move out. Treat each added line in the root file as
rent paid forever.

## The Four-Layer Architecture

### Normative

The skill classifies agent file content into four layers based on loading
frequency and scope.

#### Layer 1 — Always-On Core (per-turn)

The agent file itself. Sent every API call. Must be small enough that paying
for it every turn is justified.

Contains:
- Identity and role boundaries that must persist
- Global invariants that are almost always correct
- Routing rules that determine when to load other materials
- A compact index of where deeper instructions live

Target size: the smallest set of instructions that should persist across
nearly every turn. Benchmark: under 500 tokens.

#### Layer 2 — Conditional Procedural Modules (skills)

Loaded only when a specific type of work is being performed. Zero cost until
invoked.

Anything that smells like "steps," "workflow," "audit," "generate," "review,"
"publish," "migrate," or "debug" belongs here.

Each skill should answer:
- When to use it
- Inputs expected
- Decision criteria
- Steps to follow
- Required outputs
- What to flag as uncertainty

The agent file only says *when* to invoke them — not their content.

#### Layer 3 — Retrieval Targets (docs, indexes, references)

The part most people miss. Content removed from the agent file still needs a
fast path to the agent. Vercel's finding: a compressed index inside the
always-on file outperformed relying on the model to realize it should invoke
a skill.

The agent file should not hold the full architecture guide. It should hold a
minimal retrieval map pointing to where deeper knowledge lives:
- Architecture docs
- Convention docs
- Build/test commands
- Subsystem indexes
- Skill paths

This gives persistent awareness without persistent cost.

#### Layer 4 — Scoped Overrides (platform-dependent)

Narrower files for narrower contexts. Where supported:
- Root `AGENTS.md` = universal behavior + global routing
- Subdirectory `AGENTS.md` = local conventions
- `.instructions.md` with `applyTo` = path-specific guidance
- Skill files = optional procedural payload

This keeps the root file skeletal and moves local conventions to the relevant
subtree.

## Empirical Evidence

### Informational

**Vercel agent evals:** A compressed 8KB docs index in `AGENTS.md` beat both
baseline and skill-based setups. The index didn't contain the full docs — it
contained a compact map that pointed to them. Skills only helped when the agent
decided to use them; the persistent index removed that decision ambiguity.

**Anthropic docs:** Explicit distinction between persistent (`CLAUDE.md`) and
on-demand (skill bodies that "load only when used"). This is the foundational
split the optimization exploits.

**GitHub docs:** Repo-wide instructions apply broadly; path-specific
instructions narrow context to matching files. Custom agents use subagents
with their own context windows so specialized work doesn't clutter the main
context.

## What Does Not Belong In The Always-On File

### Normative

Unless they are tiny, these must move out:
- Long philosophy/personality prose
- Detailed workflow steps
- Examples beyond one or two miniature examples
- Exhaustive coding standards
- Subsystem documentation
- Long command references
- Migration guides
- Troubleshooting trees

These are all classic skill or doc content.

## Token Cost Model

### Normative

Tokens ≈ characters / 4 (approximation — never claim exact counts).

Cost formulas:
- Per-turn cost = Layer 1 size × number of turns
- Skill cost = Layer 2 size × number of invocations (0-N)
- Retrieval cost = Layer 3 size × number of reads
- Total session cost = per-turn + skill + retrieval

Example (100-turn session):
- Current: 1,800 tokens × 100 = 180,000 tokens
- Optimized: 400 × 100 + 1,500 × 2 reloads = 43,000 tokens
- Savings: ~137,000 tokens (76% reduction)

Projections must state assumptions.

## Compression Interoperation

### Normative

Optimization (moving content between layers) and compression (reducing tokens
within a layer) are distinct concerns.

Workflow: optimize first → compress each layer independently.
- Layer 1 = Ultra compression (highest density, per-turn)
- Layer 2 manifests = Full compression
- Layer 3 skills = per skill convention

The agent-optimizer recommends placement. The compression skill handles
token reduction within layers. The optimizer must never apply compression
itself.

## Post-Compaction Recovery

### Normative

Optimization MUST preserve post-compaction recovery. An optimized agent that
cannot recover after compaction is a failed optimization.

Requirements:
- Layer 1 MUST contain explicit instruction to re-read the manifest after
  compaction
- The reload instruction MUST reference the manifest by file path (relative
  to agent file location)
- The manifest MUST be self-contained enough to restore operating context

## Platform Considerations

### Descriptive

- **Claude Code**: CLAUDE.md as user message, re-injected after compaction.
  File reading via Read tool. Skills in `.claude/skills/`. Hooks: SessionStart
  (startup/compact matchers), PreCompact, Stop, PreToolUse, PostToolUse.
- **VS Code Copilot**: `.agent.md` as system prompt, constant per-turn cost.
  File reading via `read_file`. Skills discovered via frontmatter.
  Path-specific `.instructions.md` with `applyTo`.
- **Custom orchestrators**: Behavior varies. The four-layer model is
  platform-agnostic but reload mechanics differ.

Recommendations are platform-agnostic. Platform-specific mechanics are
implementation details.

## Hook-Based Context Injection

### Descriptive

Platforms with lifecycle hooks enable a more aggressive optimization tier
where the infrastructure handles context loading instead of the agent file.

**SessionStart hooks** can read manifest files and inject them as
`additionalContext` — the agent arrives with full operating context already
loaded without any file read instruction in the agent file. The same hook
with a `compact` matcher re-injects context after compaction automatically.

**Reminders** (where available) inject periodic context — fleet status,
pending tasks, blocked items — on schedule rather than baking it into
always-on cost.

**Subagent dispatching** gives specialized work its own context window,
keeping the main agent's context clean.

When hook-based injection is available:
- No "read manifest on startup" instruction needed in Layer 1
- No "re-read after compaction" instruction needed in Layer 1
- Layer 1 target drops to ~200-300 tokens
- The agent file becomes pure kernel: identity, invariants, routing index

This is the most aggressive optimization available. The skill should mention
it as a bonus recommendation when the platform supports hooks. The
post-compaction recovery constraint (Layer 1 must contain reload instruction)
is relaxed when hooks guarantee injection.

## Anti-Patterns

### Normative

The skill must flag these explicitly when found:
- Biography-style agent files
- Manifesto-style principle dumps
- Procedural checklists embedded in root
- Giant coding standards in root
- Duplicated rules in multiple sections
- Weak "be helpful / be thoughtful / be careful" filler
- Skill content embedded directly in agent file
- Doc content embedded directly in agent file
- Unclear delegation or retrieval triggers
- No compact index to deeper material

## The Core Tension

### Descriptive

There is a real tradeoff:
- Too much moved out → agent fails to retrieve what it needs
- Too much kept in → bloated persistent context

Vercel's finding suggests the compromise: not "tiny file with no map" but
**small persistent map + deferred retrieval**. That is the current best
pattern.

## Constraints

- Must not modify files directly
- Must not claim exact token counts
- Must not recommend removing safety-critical content from Layer 1
- Must not recommend optimization that breaks post-compaction recovery
- Must state all assumptions in savings projections
- Must flag ambiguous classifications rather than guessing
- Behavioral fidelity is a hard constraint

## Defaults and Assumptions

- Token estimation: characters / 4
- Default session length: 100 turns
- Default compaction events: 1-2 per session
- Default Layer 1 target: under 500 tokens
- If no compression tier specified, recommend Ultra for Layer 1, Full for
  manifests

## Error Handling

- Agent file cannot be read → report error, do not guess
- Agent file has no clear identity → flag as critical
- Agent file has no routing/index → flag as structural gap
- Classification is ambiguous → include both options in Risks
- Manifest already exists → analyze both, recommend merge strategy

## Precedence

- Safety-critical placement (Layer 1) overrides token savings
- Post-compaction recovery overrides structural elegance
- Behavioral fidelity overrides compression targets
- This spec governs the SKILL.md — any conflict, spec wins

## Non-Goals

- Automated file modification (recommend only)
- Writing new agent files from scratch
- Runtime behavioral testing
- Precise tokenizer-level counting
- Platform-specific system prompt engineering
