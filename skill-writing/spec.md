---
name: skill-writing
description: >-
  Specification for writing skills — the decision framework, structural
  patterns, and quality requirements for creating new skills in the workspace.
type: spec
---

# Skill Writing Specification

## Purpose

Define how to write skills that agents can discover, invoke, and rely on.
A skill is a reusable instruction set that teaches an agent how to perform
a specific capability. This spec governs the creation of new skills and the
audit of existing ones.

## Scope

Applies when creating a new skill or revising an existing one. Covers
structure, classification, quality criteria, and the relationship between
skills and their companion agents.

## Skill Creation Workflow

When creating a new skill, these steps must be followed in this exact
order. No step may be skipped.

1. **Write spec** — use the `spec-writing` skill to write `spec.md` in
   the skill's folder. The spec defines purpose, scope, requirements,
   constraints, and acceptance criteria. The spec is the source of truth
   for everything that follows.
2. **Write uncompressed skill** — derive `uncompressed.md` from the spec.
   This is the human-readable baseline that contains all runtime
   instructions. Every normative requirement in the spec must be
   represented. No new requirements may be introduced that are not in
   the spec.
3. **Compress** — use the `compression` skill in source→target mode
   (`--source uncompressed.md --target SKILL.md`) to produce the
   compressed runtime file. SKILL.md is what agents load at runtime.
4. **Audit** — use the `skill-auditing` skill to verify
   the SKILL.md against the spec. Fix findings, recompress,
   re-audit until the audit returns PASS.

For dispatch skills, the companion agent file must also be written
(step 2) and verified as reachable (step 4).

### Revision workflow

When modifying an existing skill:

1. Update the spec first if the change affects requirements or constraints
2. Update uncompressed.md to reflect the spec change
3. Recompress to SKILL.md
4. Re-audit

Never modify SKILL.md directly — it is a compiled artifact. Changes
flow: spec → uncompressed → compressed.

## Definitions

- **Skill**: A `SKILL.md` file containing instructions an agent follows to
  perform a capability. Loaded at runtime by the host agent.
- **Inline skill**: A skill executed by the host agent directly, using its
  own context and judgment. No dispatch.
- **Dispatch skill**: A skill that bootstraps an isolated subagent to do
  the work. The SKILL.md is a routing card; a dispatch instruction file
  holds the procedure.
- **Dispatch instruction file**: A text file (any name, commonly
  `<name>.md` or `<name>.agent.md`) containing the full procedure for a
  dispatched capability. Not a custom agent — any generic agent (Sonnet,
  Haiku) reads it and follows it. Like a recipe, not a robot.
- **Routing card**: A minimal SKILL.md (~10-15 lines) that tells the host
  agent: what this does, what file to dispatch, what params to pass, what
  to expect back.
- **Companion spec**: A `spec.md` file containing rationale, design
  decisions, audit history, and non-runtime content. Required for dispatch
  skills and complex inline skills. May be omitted only for simple inline
  skills where the SKILL.md is self-evidently complete (under ~30 lines,
  no design decisions worth recording). **Never referenced at runtime** —
  agents read only SKILL.md and dispatch instruction files. The spec exists
  for human review, auditing, and evolution only. Referencing the spec at
  runtime causes context bloat and token waste.
- **Breadcrumb**: A pointer to related skills or help topics at the end of
  a skill or tool output. "Want to know more? Read `help(topic: 'X')`."

## Decision Tree: Inline vs Dispatch

The fundamental question: **does the task require the caller's context?**

### Use inline skill when

- The task requires understanding *why* — creative intent, design context,
  judgment about the current situation
- The agent needs to weave the skill's output into its ongoing work
- The skill teaches a *practice* (how to write, how to think about X)
- Context transfer would cost more than just doing it

**Examples:** spec-writing, skill-writing, agent-writing, communication
guidelines, git discipline, friction protocol.

### Use dispatch skill (skill+agent pair) when

- The task is *mechanical processing* against rules
- The input is self-contained (file path, parameters)
- The agent doesn't need to know what the caller is doing
- The output is a report, verdict, or transformed artifact
- Context isolation is a *benefit* (fresh eyes, no bias)

**Examples:** compression, task verification, build verification, spec
auditing, code review, security review.

### The test

> "If I described this task to someone who just walked in the room with
> no context, could they do it from just the inputs I give them?"
>
> **Yes** → dispatch skill (agent pair)
> **No** → inline skill

## Structure

### Inline Skill

```yaml
---
name: <skill-name>
description: <one-line description>
---

<Direct instructions the host agent follows. Can be as long as needed.
This IS the skill — the agent reads and applies it.>
```

### Dispatch Skill (Routing Card)

```yaml
---
name: <skill-name>
description: <one-line description>
---

# <Skill Name>

<One sentence: what this does.>

Dispatch an isolated agent (use Dispatch agent or Agent tool with no
system context): "Read and follow `<path-to-instruction-file>`. Input:
`<param1> <param2>`"

Parameters:
- `param1` (string, required): <description>
- `param2` (string, optional, default: "X"): <description>

Returns: <what the agent reports back — specify format>
```

The routing card is ~10-15 lines. All procedure lives in the dispatch
instruction file.

### Dispatch Instruction File

A plain text/markdown file with the procedure. Not a custom agent — any
generic agent reads it and follows it. The Dispatch agent
(`dispatch.agent.md`) provides zero-context isolation.

Instruction files must contain only instructions — no title headers,
no descriptions, no preamble. The dispatching agent already knows what
it is reading. The SKILL.md routing card handles the "what" and "why";
the instruction file handles only the "how."

```markdown
# <Capability Name>

## Dispatch Parameters
- `param1` (required): <description>
- `param2` (optional, default: "X"): <description>

## Procedure
1. <step>
2. <step>

## Output Format
<what to return>

## Rules
- <constraint>
```

### Execution Tiers (cost implications)

1. **Dispatch agent (isolated)** — preferred for dispatch skills. The
   `dispatch.agent.md` has no system prompt — zero context overhead.
   Instruction file is the only context loaded. Most cost-efficient.
2. **Background agent (with host context)** — runs with the caller's full
   system prompt. Incurs overhead per turn. Avoid for dispatch skills —
   use Dispatch agent instead.
3. **Inline** — host agent applies directly. No dispatch overhead. Use
   for context-dependent skills only.

## Requirements

### Naming

- Skill directory name = kebab-case, descriptive
- `SKILL.md` = the runtime file (always this exact name)
- `spec.md` = companion spec (always this exact name — no prefix, no
  "SKILL" in the filename). Required for dispatch and complex inline
  skills; may omit for simple inline skills under ~30 lines
- `uncompressed.md` = human-readable baseline (always this exact name)
- Dispatch instruction files: `instructions.txt` or `<name>.md` in
  the same directory
- Never use "SKILL" in any filename except `SKILL.md`

### Content

- **Frontmatter**: `name` and `description` required. Description is used
  for discovery — be specific about what the skill does.
- **Self-contained**: A skill must be usable without reading the spec.
  The spec holds rationale; the skill holds instructions.
- **Concise**: Every line earns its place. Agent-facing, not human-facing.
  Prefer fragments and direct imperatives over prose.
- **Breadcrumbs**: End with pointers to related skills or help topics.
  Agents should always know where to go next.
- **No sensitive data**: No tokens, credentials, or secrets in skill files.

### For dispatch skills specifically

- Dispatch instruction file must be in the same directory or a known path
- Use the Dispatch agent for zero-context isolation (preferred over
  background agent with host context)
- Parameters documented with types, required/optional, and defaults
- Output format specified so the caller knows what to expect
- The exemplar is `compression/SKILL.md` — study it

### Quality criteria (for auditing)

A skill passes audit if:

1. **Classified correctly** — inline vs dispatch matches the decision tree
2. **Self-contained** — usable without the spec
3. **Concise** — no prose that doesn't affect execution
4. **Complete** — all runtime-relevant instructions present
5. **Breadcrumbed** — related skills/topics linked
6. **Paired** (dispatch only) — agent file exists and is reachable
7. **Tested** (dispatch only) — agent can be dispatched and returns
   expected output format

## Compiling Spec to SKILL.md

The SKILL.md is a compiled form of the spec — executable byte-code for
agents. The spec is the source language; the SKILL.md is the compiled
program. Use the `spec-writing` skill to write the spec, then compile.

### What goes in SKILL.md (program content)

Purpose, scope, definitions, requirements, constraints, procedures,
ordered steps, thresholds, defaults, error handling, stop conditions,
precedence rules, conflict resolution, explicit exclusions.

### What stays in spec.md (non-program content)

Design rationale, audit reports, bug histories, extended examples,
anti-pattern catalogs, edge-case walkthroughs, compression guidance,
change history, credits, publication notes.

### Compilation rules

1. Extract program content from spec
2. Strip non-program content
3. Flatten explanation into direct operational rules
4. Compress using `compression` skill (source→target mode)
5. Keep examples only when removing them makes a rule ambiguous
6. Self-containment wins over aggressive compression
7. Correctness wins over brevity

## Constraints

- Don't create dispatch skills for tasks that need caller context
- Don't embed procedure in routing cards — that's what the agent file is for
- Don't create inline skills for mechanical processing — dispatch it
- Don't skip the companion spec for dispatch or complex inline skills
- Don't create skills that duplicate existing ones — check first

## Relationship to Other Skills

- **spec-writing**: Governs how to write the companion spec
- **spec-auditing**: Verifies companion specs meet quality bar
- **compression**: Exemplar for the dispatch pattern

## Don'ts

- This spec does not govern skill *content* (what a specific skill teaches)
- This spec does not define how skills are discovered or loaded at runtime
- This spec does not cover skill versioning or deprecation (future work)
