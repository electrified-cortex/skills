---
name: agent-optimizer
description: >-
  Audit and optimize an agent file, CLAUDE.md, AGENTS.md, or similar always-on
  instruction file for token efficiency, routing clarity, and retrieval-first
  design.
---

# Agent Optimizer

## Purpose

Optimize an agent file so that its always-on contents are limited to the
smallest set of instructions that should persist across nearly every turn.

This skill treats the target agent file as expensive persistent context. Its
job is to reduce permanent token load while preserving or improving behavioral
quality.

## Core Principle

The agent file is not a general handbook.

The agent file should contain only:
- Identity and role boundaries that must persist
- Global invariants that are almost always correct
- Routing rules that determine when to load other materials
- A compact index of where deeper instructions live

Anything procedural, situational, lengthy, or domain-specific should usually
be moved out of the always-on file.

## Use This Skill When

- An `AGENTS.md`, `CLAUDE.md`, or similar file feels too large
- An agent file contains too much prose, policy, workflow detail, or subsystem
  knowledge
- The user wants to reduce token usage or persistent context load
- The user wants a clean split between always-on instructions and conditional
  skills/docs
- A repo is accumulating agent guidance without a clear structure
- An agent seems to underperform because its root instructions are bloated or
  unfocused

## Do Not Use This Skill When

- The task is to write a brand new agent file from scratch
- The target file is already intentionally minimal and the real problem is
  missing supporting skills/docs
- The user only wants wording polish without structural changes

## Inputs

Expected:
- The target always-on file

Optional:
- Related skill files
- Linked docs, spec files, or subsystem instruction files
- Stated platform assumptions about how agent context is loaded

If supporting materials are missing, audit using the target file alone.

## Mental Model

Treat the always-on agent file as a kernel.

The kernel should:
- Define stable behavior
- Define stable constraints
- Route to the right deeper material
- Stay small enough that paying for it every turn is justified

Treat everything else as conditional payload.

## Classification Framework

For each meaningful section, paragraph, or rule in the target file, classify
it into exactly one bucket.

### Bucket A: Keep In Always-On Agent File

Keep content only if at least one is true:
- It prevents costly recurring mistakes
- It is relevant to a large share of requests
- It defines core role, stance, or universal boundaries
- It routes the agent toward the correct next source of truth
- Its absence would frequently cause bad decisions before retrieval happens

### Bucket B: Move To Skill

Move content if it is:
- Procedural or step-by-step
- Review-oriented, generation-oriented, or audit-oriented
- Conditional on task type
- Useful only when a certain type of work is being performed

Examples: spec writing, spec auditing, code review workflows, migration
playbooks, publishing checklists, debugging sequences, incident handling,
release procedures.

### Bucket C: Move To Doc Or Indexable Reference

Move content if it is:
- Explanatory or reference-heavy
- Architecture-heavy or command-heavy
- Subsystem-specific
- Too long to justify always-on cost
- Useful as knowledge but not as default behavior

### Bucket D: Remove

Remove content if it is:
- Filler ("be helpful," "be thoughtful," "be careful")
- Duplicated across sections
- Aspirational but not behavioral
- Redundant with platform defaults
- Not clearly tied to any decision the agent makes

## Rules

### Rule 1: Persistent Context Is Expensive Real Estate

Every line in the always-on file is paid per turn. Budget accordingly.
Benchmark: under 500 tokens for the agent file.

### Rule 2: Procedures Do Not Belong In The Always-On File

Step-by-step workflows, audit checklists, review sequences — all skill
content. The agent file should say *when* to invoke them, not contain them.

### Rule 3: A Compact Index Beats Embedded Content

Vercel's evals showed a compressed docs index outperformed both baseline and
skill-only setups. The agent file needs a fast retrieval map, not the full
material.

### Rule 4: Skills Must Be Discoverable

If a skill exists but the agent file gives no signal about when to use it,
the skill may never fire. Routing rules in the agent file are critical.

### Rule 5: Scoped Files Beat Root Bloat

Where the platform supports it, move local conventions into scoped files
(subdirectory `AGENTS.md`, `.instructions.md` with `applyTo`). Keep the root
file universal.

### Rule 6: Safety Content Stays In Layer 1

Loop prevention, permission boundaries, forbidden actions — these are
non-negotiable always-on content regardless of token cost.

### Rule 7: Post-Compaction Recovery Is A Hard Constraint

The agent file must contain a reload instruction for any manifest or
startup context. An optimized agent that cannot recover after compaction
is a failed optimization.

### Rule 8: Identity Must Survive Any Reset

Core identity (who the agent is, what it must never do) must be in the
always-on file. This is the one content type that cannot be deferred.

### Rule 9: Treat Every Always-On Line As Rent

Assume each line costs money and attention forever. If a line does not earn
its keep, move or remove it.

## Audit Procedure

### Step 1: Identify The Target Type

Determine what the file is functioning as:
- Root agent file
- Scoped agent file
- Sub-agent file
- Skill masquerading as an agent file
- Doc masquerading as an agent file

If the file is mixing roles, note that explicitly.

### Step 2: Segment The File

Break the file into meaningful units:
- Title and intro/purpose
- Identity
- Behavior rules
- Constraints
- Workflows
- Examples
- References
- Domain knowledge
- Subsystem notes

### Step 3: Classify Each Unit

For each unit, assign one action:
- **Keep** — stays in always-on file
- **Move to Skill** — becomes a skill or joins an existing one
- **Move to Doc** — becomes a reference doc or manifest section
- **Remove** — filler, duplication, or non-behavioral content
- **Rewrite and Keep** — correct placement but needs compression

Do not leave sections unclassified.

### Step 4: Find Biggest Offenders

Call out the highest-cost problems:
- Long procedural checklists
- Embedded domain knowledge blocks
- Personality essays
- Exhaustive coding standards
- Sections that could be a one-line routing rule

### Step 5: Propose Target Structure

Show the recommended layout:
- What stays in the agent file (with draft if possible)
- What becomes skills (with names and paths)
- What becomes docs/manifests
- What gets removed
- Estimated token savings with stated assumptions

### Step 6 (Optional): Draft The Optimized Agent File

If requested, produce a draft minimal agent file that satisfies Layer 1
requirements: identity, invariants, routing rules, compact index, safety
guards, and manifest reload instruction.

## Pruning Tests

Apply these tests to any content whose classification is unclear.

### The Turn Test

Ask: "Would the agent regularly make a bad decision on a typical turn
without this content already loaded?"

If no → it probably does not belong in the always-on file.

### The Routing Conversion Test

Ask: "Can this long instruction be replaced by a short rule that points to
a skill or doc?"

If yes → do that.

### The Scope Test

Ask: "Is this truly universal, or is it local to a task, domain, or
directory?"

If local → move it out.

### The Actionability Test

Ask: "Does this text change agent behavior, or does it merely sound good?"

If it only sounds good → remove it.

## Output Requirements

Produce output in this structure:

### 1. Verdict

State in a few sentences:
- Whether the file is too large, too mixed, or acceptably minimal
- The main architectural issue
- The overall optimization direction

### 2. Findings Table

For each major section:

| Section | Current Purpose | Classification | Reason |
| --- | --- | --- | --- |
| Identity | Agent role | Keep | Core, per-turn relevant |
| Delegation model | Workflow rules | Move to Skill | Procedural |
| Git workflow | Process steps | Move to Skill | Step-by-step |

### 3. Persistent Context Offenders

List the worst always-on offenders first — the biggest wins.

### 4. Proposed Structure

Show recommended layout with file paths and estimated sizes.

### 5. Savings Projection

Per-turn reduction, total over N turns, stated assumptions.

## Anti-Patterns

Flag these explicitly when found:
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

## Success Criteria

The skill succeeds when the resulting always-on file:
- Is clearly smaller or sharper
- Has a single coherent purpose
- Contains mostly invariants and routing
- Avoids loading procedural and domain-heavy material by default
- Makes it easier to retrieve specialized instructions only when needed

## Compression Interoperation

Optimization (moving content between layers) and compression (reducing tokens
within a layer) are distinct. The recommended workflow:

1. Optimize first — tier placement
2. Compress each layer independently using the `compression` skill
3. Layer 1 = Ultra compression (highest density, per-turn)
4. Manifests = Full compression
5. Skills = per skill convention

This skill recommends placement. The compression skill handles token reduction.

## Advanced: Hook-Based Context Injection

Platforms with lifecycle hooks can automate context loading entirely, making
the agent file even smaller.

**SessionStart hooks** can read manifest files and inject them as
`additionalContext` — the agent arrives with full operating context already
loaded, zero file reads needed. The same hook with a `compact` matcher
re-injects context after compaction automatically.

**Reminders** can inject periodic context (fleet status, pending tasks,
blocked items) on schedule rather than baking it into always-on cost.

**Subagent folders** give specialized work its own context window, keeping
the main agent's context clean.

When hook-based injection is available, the agent file shrinks further:
- No "read manifest on startup" instruction needed — hooks handle it
- No "re-read after compaction" instruction needed — hooks handle it
- The agent file becomes pure kernel: identity, invariants, routing index
- Target: ~200-300 tokens

This is the most aggressive optimization tier. Mention it as a bonus
recommendation when the platform supports hooks.

## Precedence

Safety placement (Layer 1) > token savings.
Post-compaction recovery > structural elegance.
Behavioral fidelity > compression targets.
Spec (`spec.md`) governs this file.
