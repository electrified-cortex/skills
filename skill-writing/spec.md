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
2. **Write uncompressed sources** — derive `uncompressed.md` from the
   spec. For dispatch skills, also write `instructions.uncompressed.md`.
   These are the human-readable baselines that contain all runtime
   instructions. Every normative requirement in the spec must be
   represented. No new requirements may be introduced that are not in
   the spec.
3. **Markdown hygiene (MANDATORY GATE)** — run the `markdown-hygiene`
   skill on every uncompressed source produced in step 2
   (`uncompressed.md`, and `instructions.uncompressed.md` if present).
   Compression **must not** run until every uncompressed source returns
   `CLEAN`. Skipping this gate causes the audit in step 6 to flag
   markdown defects that hygiene catches cheaply at haiku-class — a
   token-waste regression. Hygiene is the cheapest gate in the workflow.
4. **Intermediate audit** — run `skill-auditing --uncompressed` against
   the skill's uncompressed sources. FAIL → fix sources → re-audit.
   Repeat until PASS. The intermediate audit catches structural and
   compliance issues before the (more expensive) compression and final
   audit.
5. **Compress** — use the `compression` skill in source→target mode
   (`--source uncompressed.md --target SKILL.md`; same for
   `instructions.uncompressed.md` → `instructions.txt` for dispatch
   skills). SKILL.md is what agents load at runtime.
6. **Final audit** — run `skill-auditing` (default mode) against
   `SKILL.md`. FAIL → fix sources → recompress (step 5) → re-audit.
   Repeat until PASS.

For dispatch skills, the companion instruction source file is written
in step 2, hygiene-checked in step 3, audited in step 4, compressed in
step 5, and verified in step 6 alongside the routing card.

### Revision workflow

When modifying an existing skill:

1. Always update the spec first. The only exception is changes limited
   to non-normative content (README, examples, typo fixes in
   informational sections). In that case skip to step 2.
2. Update `uncompressed.md` (and `instructions.uncompressed.md` if
   dispatch) to reflect the spec change.
3. Run `markdown-hygiene` on the modified uncompressed sources. CLEAN
   required before step 4. Same gate as the creation workflow.
4. Run `skill-auditing --uncompressed`. PASS required.
5. Recompress to `SKILL.md` (and `instructions.txt` if dispatch).
6. Run `skill-auditing` (default mode). PASS required before declaring
   the revision complete.

Never modify SKILL.md or instructions.txt directly — they are compiled
artifacts. Changes flow: spec → uncompressed → hygiene → audit →
compressed → audit.

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
  dispatched capability. Not a custom agent — any generic agent reads
  it and follows it. Like a recipe, not a robot.
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

Input: `<param>` — <description>

## Dispatch

Variables:

`<instructions>` = `instructions.txt` (this folder; NEVER READ THIS FILE)
`<instructions-abspath>` = absolute path to `<instructions>`
`<input-args>` = `<param> [<optional-param>]`
`<tier>` = `fast-cheap`
`<description>` = `<Action>: <param>`
`<prompt>` = `Read and follow <instructions-abspath>; Input: <input-args>`

Follow `dispatch` skill. See `<path-to-dispatch>/SKILL.md`.
Returns: <what the agent reports back — specify format>
```

The routing card is ~10-15 lines. The caller binds `<prompt>` in the
Variables block and delegates spawning to the `dispatch` skill.
`dispatch/SKILL.md` is the canonical for all spawn mechanics. All
procedure lives in the dispatch instruction file.

The prompt-only model: the consumer composes `<prompt>` (including the
instructions path and input args); `dispatch` sends it verbatim to a
zero-context sub-agent. This separates prompt construction (caller) from
agent spawning (dispatch).

### Dispatch Instruction File

A plain text/markdown file with the procedure. Not a custom agent — any
generic agent reads it and follows it. The Dispatch agent
(`dispatch.agent.md`) provides zero-context isolation.

The compressed instruction file (`instructions.txt`) must contain only
instructions — no title headers, no descriptions, no preamble. The
dispatching agent already knows what it is reading. The SKILL.md
routing card handles the "what" and "why"; the instruction file handles
only the "how."

The uncompressed baseline (`instructions.uncompressed.md`) MAY include
an H1 title so that markdown-hygiene passes (markdownlint rule MD041
requires a top-level heading). Strip the title after compression to
`instructions.txt`. This keeps the compressed runtime minimal while
preserving markdown correctness in the authored source. When invoking
markdown-hygiene on `SKILL.md`, pass `--ignore MD041` to suppress the
absent-H1 finding — no inline guard text is needed.

```markdown
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

- Skill directory name = kebab-case, descriptive, and **equal to the `name`
  field in the SKILL.md frontmatter**. Discovery resolves skills by matching
  the directory name against the frontmatter name; a mismatch causes the
  skill to be unreachable.
- **Nested sub-skills** under a parent skill folder must use the
  fully-qualified name that includes the parent as a prefix. Example: under
  `electrified-cortex/skill-index/`, children are `skill-index-auditing/`,
  `skill-index-building/`, `skill-index-crawling/` — not bare `auditing/`,
  `building/`, `crawling/`. The canonical reference implementation is
  `electrified-cortex/gh-cli/` (`gh-cli-actions`, `gh-cli-api`, etc.). Bare
  unqualified names inside a parent folder do not resolve.
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

### Frontmatter and artifact integrity

R-FM-1 **Name matches folder.** The `name` field in frontmatter MUST equal
the skill's folder name exactly (kebab-case). This applies to both
`uncompressed.md` and `SKILL.md`. A mismatch makes the skill unreachable.

R-FM-2 **Description appears once.** The `description` field in frontmatter
is the sole location for the skill description. Authors MUST NOT restate
it as body prose anywhere in `uncompressed.md`, `SKILL.md`,
`instructions.uncompressed.md`, or `instructions.txt`.

R-FM-3 **H1 per artifact.**

- `spec.md` — MUST have an H1 (normal markdownlint rule MD041).
- `uncompressed.md` — MUST have an H1 (normal markdownlint).
- `SKILL.md` — MUST NOT have an H1. Frontmatter `name` carries the title.
  This is the only sanctioned exception to MD041 for skill artifacts.
- `instructions.uncompressed.md` — MUST have an H1 (same as
  `uncompressed.md`; markdownlint must pass, then H1 is stripped on
  compression to `instructions.txt`).
- `instructions.txt` — MUST NOT have an H1 (same no-H1 convention as
  `SKILL.md`).

R-FM-4 **Lint wins.** If markdownlint flags a rule violation, fix it.
The SKILL.md / instructions.txt no-H1 exception is the ONLY sanctioned
deviation from markdownlint defaults.

R-FM-5 **No exposition in runtime artifacts.** `SKILL.md`,
`uncompressed.md`, `instructions.uncompressed.md`, and `instructions.txt`
MUST contain instructions only. Authors MUST NOT include rationale, "why
this exists," root-cause narrative, historical notes, or background prose.
Rationale belongs in `spec.md`.

R-FM-6 **No non-helpful tags.** Descriptor lines that carry no operational
value (e.g., "inline apply directly no dispatch") MUST be removed from all
artifacts.

R-FM-7 **No empty sections.** Every heading in every artifact MUST have
body content. A heading with no content beneath it (before the next heading
or end of file) is a violation.

R-FM-8 **Iteration-safety placement.** The Iteration Safety caller blurb
MUST appear only in `spec.md`, `uncompressed.md`, and `SKILL.md`. It MUST
NOT appear in `instructions.uncompressed.md` or `instructions.txt`. By the
time the dispatch instructions are loaded the re-dispatch decision is
already made — the guard is too late and constitutes dead instruction weight.
The same guard appearing in both `SKILL.md` and `instructions.*` is a
probable duplication violation and MUST be flagged.

R-FM-9 **Rules A and B verbatim live only in iteration-safety.** Callers
MUST use only the 2-line pointer block:

```md
Do not re-audit unchanged files.
See `<relative-path>/iteration-safety/SKILL.md`.
```

The relative path MUST match the caller's actual depth. Callers MUST NOT
restate Rule A or Rule B verbatim. See the `iteration-safety` skill (`../iteration-safety/SKILL.md`) for
the canonical text.

R-FM-10 **Description carries trigger phrases.** The `description`
frontmatter field MUST include explicit trigger phrases — short keyword
clauses that name the situations or vocabulary that should cause an
agent reading skill discovery to fire this skill. Shy descriptions
(e.g., "Audit a skill") cause undertriggering; pushy descriptions
(e.g., "Audit a skill: validate spec compliance, frontmatter integrity,
iteration-safety placement, lint compliance, classification accuracy")
cause correct triggering. Authors MUST list at least 3 trigger phrases
in the description; at most 6 (longer descriptions stop earning their
keep). Trigger phrases double as the skill's index keywords, so quality
here propagates into discovery downstream.

### For dispatch skills specifically

- Dispatch instruction file must be in the same directory or a known path
- The canonical spawn primitive is the `dispatch` skill (`../dispatch/SKILL.md`) — all consumers
  invoke it via the Variables block pattern (prompt-only model)
- Use the Dispatch agent for zero-context isolation (preferred over
  background agent with host context)
- Consumer composes `<prompt>` (instructions path + input args); dispatch
  sends verbatim — no template construction inside dispatch
- Output format specified so the caller knows what to expect
- The exemplar is the `compression` skill (`../compression/SKILL.md`) — study it alongside
  the `dispatch` skill (`../dispatch/SKILL.md`) for the full pattern

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

### Eval Readiness

Skills are evaluated L1 (haiku-class) vs L2 (sonnet-class). Whether to
invest in haiku-class executability depends on call frequency. The
design rationale for the decision rule: token-savings-per-call ×
calls-per-period > optimization cost amortized over the skill's
lifetime. This formula is not exposed in runtime artifacts — only the
High/Low decision rule is.

**Decision rule:**

- **High-frequency** (many files per run, or many dispatches per session) —
  invest in haiku-class readiness. If haiku misses something sonnet catches,
  add specificity to the source until haiku catches it too. Drop an `eval.md`
  alongside the skill to log L1/L2 round results and fold-back actions.
- **Low-frequency / one-off** (runs once per skill, once per file, or
  infrequently triggered) — sonnet-class is fine. Haiku-class optimization
  does not pay off; `eval.md` is not required.

**Examples:**

| Skill | Frequency | Recommendation |
| --- | --- | --- |
| markdown-hygiene | High (before every commit, many files) | Haiku-readiness justified |
| code-review | High (every PR, many files) | Haiku-readiness justified |
| skill-auditing | Medium | Haiku-readiness recommended |
| compression | Low (once per skill/file, infrequent) | Sonnet fine |

`eval.md` presence is a positive quality signal for high-frequency skills.
For low-frequency skills its absence is not a finding.

## Compiling Spec to SKILL.md

The SKILL.md is a compiled form of the spec — executable byte-code for
agents. The spec is the source language; the SKILL.md is the compiled
program. Use the `spec-writing` skill to write the spec, then compile.

### What goes in SKILL.md (program content)

Purpose, scope, definitions, requirements, constraints, procedures,
ordered steps, thresholds, defaults, error handling, stop conditions,
precedence rules, conflict resolution, explicit exclusions.

If the companion spec defines a Footguns section, the skill body
(uncompressed.md / SKILL.md) must mirror that section, preserving all
F#: entries, Mitigation: lines, and any ANTI-PATTERN: examples.

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

## Behavior

### Skill creation workflow

1. Write `spec.md` using the `spec-writing` skill. No downstream work
   starts until the spec exists.
2. Derive `uncompressed.md` from the spec. Every normative requirement
   in the spec must be represented. No new requirements may be introduced
   that are not in the spec.
3. Compress using the `compression` skill (`--source uncompressed.md
   --target SKILL.md`).
4. Audit — dispatch `skill-auditing` on the skill folder following
   the dispatch pattern in `skill-auditing/SKILL.md` (not inline).
   Do not declare done without a returned PASS. Fix findings,
   recompress, re-dispatch until PASS.

For dispatch skills: also write the companion agent/instruction file
(step 2) and verify it is reachable (step 4).

### Behavior revision workflow

1. Always update the spec first. Exception: changes limited to
   non-normative content (README, examples, typo fixes in informational
   sections) — in that case skip to step 2.
2. Update `uncompressed.md` to reflect the spec change.
3. Recompress to `SKILL.md`.
4. Re-audit — dispatch `skill-auditing` on the skill folder (not
   inline). PASS required before declaring the revision complete.

Never modify `SKILL.md` directly — it is a compiled artifact.
Flow: spec → uncompressed → compressed.

### Dispatch vs inline decision flow

Ask: "Could someone with no context do this from just the inputs given?"

- Yes → dispatch skill (isolated agent, mechanical processing)
- No → inline skill (caller context and judgment required)

Use the Decision Tree section for detailed criteria.

## Defaults and Assumptions

- **Companion spec omission threshold**: a simple inline skill may omit
  `spec.md` only when its `SKILL.md` is self-evidently complete and is
  under approximately 30 lines with no design decisions worth recording.
  Above that threshold a companion spec is required.
- **Routing card size**: dispatch skill `SKILL.md` routing cards are
  approximately 10–15 lines. Procedure lives in the dispatch instruction
  file, not the routing card.
- **Skill discovery assumption**: the system discovers skills by matching
  the folder name against the `name` frontmatter field. A mismatch
  causes the skill to be unreachable. Folder name and `name` must be
  identical.
- **Default audit cadence**: iterate the audit until no CRIT or HIGH
  findings remain, then do one final sign-off pass. How that iteration
  is staffed (single agent, multiple agents, cheap pass then expensive
  pass) is a caller choice, not a requirement of this spec.
- **Instruction file location**: dispatch instruction files are assumed
  to reside in the same directory as `SKILL.md` unless a known path is
  explicitly stated in the routing card.

## Error Handling

- **Audit never reaches PASS**: do not silently accept a stalled audit.
  Report the blockage and escalate. Do not ship a skill with unresolved
  CRIT or HIGH findings.
- **Dispatch path unavailable**: if no dispatch channel is reachable,
  the host records the exception in its output and may self-execute
  steps 2–4. The routing defect is triaged afterward.
- **Skill already exists with the proposed name**: this is a constraint
  violation (see Constraints — "don't create skills that duplicate
  existing ones"). Check existing skills before writing. If the intent
  is to replace or extend an existing skill, use the revision workflow.
- **Sign-off pass introduces new CRIT or HIGH**: return to iteration
  with the new findings incorporated. Do not stamp until the sign-off
  pass is clean.

## Precedence Rules

- `spec.md` is the source of truth. It governs `uncompressed.md`, which
  governs `SKILL.md`. Conflicts resolve in that order.
- The `spec-writing` skill's `spec.md` governs the form and structure of all derived
  skills produced by this skill. When this spec conflicts with a skill
  it produced, this spec wins.
- Spec-clarity precedence: if the compile step (steps 2–3) feels like
  it needs more judgment than expected, the fix is to sharpen the
  spec. A well-formed spec makes steps 2–3 deterministic for any
  executor.
- Footgun mirroring takes precedence over compression pressure: if the
  companion spec has a Footguns section, the SKILL.md must mirror it
  even at the cost of increased size.

## Constraints

- A skill MUST NOT reference its own `spec.md` at runtime (SKILL.md is the agent-facing artifact).
- Inline skills MUST NOT include dispatch wiring or sub-agent invocation patterns.
- Dispatch skills MUST follow the dispatch pattern conventions documented in the `dispatch` skill.
- Cross-skill references in runtime artifacts MUST use canonical skill names (R-FM-11), not file paths.
- The `instructions.txt` file, if present, MUST NOT be read by the host agent — it is dispatched verbatim.
- `SKILL.md` MUST be produced via compression of `uncompressed.md`, not authored directly.

- Don't create dispatch skills for tasks that need caller context
- Don't embed procedure in routing cards — that's what the agent file is for
- Don't create inline skills for mechanical processing — dispatch it
- Don't skip the companion spec for dispatch or complex inline skills
- Don't create skills that duplicate existing ones — check first
- Never modify `SKILL.md` directly — it is a compiled artifact; changes
  flow through spec → uncompressed → compressed
- Never restate the `description` frontmatter as body prose in any artifact (R-FM-2)
- Never put an H1 in `SKILL.md` or `instructions.txt` (R-FM-3); all other `.md`
  artifacts require H1 per markdownlint
- Never put rationale, root-cause notes, or background prose in runtime artifacts
  (`SKILL.md`, `uncompressed.md`, `instructions.uncompressed.md`,
  `instructions.txt`) — spec is the only home for rationale (R-FM-5)
- Never place the Iteration Safety blurb in `instructions.uncompressed.md` or
  `instructions.txt` (R-FM-8)
- Never restate iteration-safety Rules A or B verbatim in a caller skill — use the
  2-line pointer block only (R-FM-9)
- **Never reference another skill by file path alone — name is the canonical
  identity; a relative path is permitted only as an optional "see this file"
  pointer alongside the name** (R-FM-11 — see below)
- **Never embed absolute filesystem paths in any artifact body** — use
  repo-relative paths (R-FM-12 — see below)

## R-FM-11 — Cross-Skill References by Name (Path Optional)

Cross-skill references in skill artifacts (`SKILL.md`, `instructions.txt`,
sub-instructions, `instructions.uncompressed.md`, `uncompressed.md`,
`spec.md`) MUST identify the target skill by its canonical `name` — the
value of the `name:` field in that skill's `SKILL.md` frontmatter.

The skill name is the load-time identity the agent uses: Claude Code's
`Skill` tool resolves by name, and the skill index lookup is name-based.
Names are stable across authoring and plugin install layouts; raw paths
are not.

A relative path pointer to the skill's folder or to a specific file within
it MAY follow the name as a "see this file" transparency hint for direct
(non-plugin) reading. The pointer MUST be correct relative to the source
(authoring) layout. References that supply ONLY a path with no canonical
name are forbidden — the agent has no portable handle to look up.

Pointers to a sibling's `uncompressed.md` or `spec.md` are still load
invitations even when the name is present; prefer pointing at the skill
folder or the sub-file the reader actually needs (e.g. an embedded
example, a `tier/rules.txt`).

### Allowed

- References to own `instructions.txt`, sub-instructions, or
  `tooling.md` within the same skill folder
- Sibling skill by name only: ``the `compression` skill``
- Sibling skill by name + folder pointer: ``the `compression` skill (`../compression`)``
- Sibling skill by name + specific-file pointer: ``the `compression` skill's tier rules (`../compression/<tier>/rules.txt`)``

### Forbidden (examples)

```text
# FORBIDDEN — path with no canonical name
See `../compression/uncompressed.md` for details.

# FORBIDDEN — path with no canonical name
Consult `../spec-writing/spec.md` for the format.
```

### Allowed examples

```text
# ALLOWED — own sub-file
Read and follow `instructions.txt` (in this directory).

# ALLOWED — sibling by name only
For dispatch mechanics, read the `dispatch` skill.

# ALLOWED — name + folder pointer
For dispatch mechanics, read the `dispatch` skill (`../dispatch`).

# ALLOWED — name + specific-file pointer
The `compression` skill's tier rules
(`../compression/<tier>/rules.txt`) define the format.
```

## R-FM-12 — No Absolute Filesystem Paths in Artifact Bodies

Skill artifacts (`SKILL.md`, `uncompressed.md`, `instructions.uncompressed.md`,
`instructions.txt`, `spec.md`, and any embedded code samples or examples)
MUST NOT contain absolute filesystem paths. This covers Windows drive-letter
prefixes (`<letter>:/...` or `<letter>:\\...`) and Unix root-anchored paths
under `/Users/`, `/home/`, `/d/`, `/c/`, or any similar root. Use
repo-relative paths instead, computed via `git ls-files --full-name <file>`
or by stripping `<repo-root>/` from an absolute path.

- **Right**: `file_path: skill-auditing/instructions.uncompressed.md`
- **Wrong**: `file_path: <abs-prefix>/.agents/skills/electrified-cortex/skill-auditing/instructions.uncompressed.md`

Frontmatter, body prose, code samples, and embedded examples are all in
scope. Stdout return values that emit absolute paths (e.g. `PATH: <abs>`)
are exempt — those are runtime addresses, not artifact body content.

## R-SS-1 — Sub-skill Input Isolation

Sub-skills within a parent orchestrator MUST NOT accept as named inputs
the output paths, result tokens, or computed artifacts of sibling
sub-skills. Each sub-skill's interface MUST accept only:

- The primary resource being processed (e.g., document path, file path).
- Skill-specific configuration parameters (e.g., `--ignore` flags, style options).

The parent orchestrator owns sequencing, result passing, and
cross-sub-skill coordination. If context from one sub-skill's output
is needed by another, the parent transforms and injects it through its
own procedure — not by threading one sub-skill's output path directly
into another sub-skill's input signature.

Coupling sub-skill A's output format into sub-skill B's input signature
makes B fragile: any change to A's output breaks B. The parent is the
correct integration point for this knowledge.

### Forbidden (example)

```text
# FORBIDDEN — analysis sub-skill accepting lint sub-skill output path
Inputs:
  <markdown_file_path> — path to the document
  <lint_path> — path to lint report from sibling lint sub-skill
```

### Allowed Result

```text
# ALLOWED — analysis sub-skill with only primary input + own config
Inputs:
  <markdown_file_path> — path to the document
  --ignore <RULE>[,<RULE>...] — optional SA rules to suppress
```

## Relationship to Other Skills

- **spec-writing**: Governs how to write the companion spec
- **spec-auditing**: Verifies companion specs meet quality bar
- **dispatch**: Canonical primitive for spawning zero-context sub-agents.
  All dispatch skill consumers reference `dispatch/SKILL.md` via the
  Variables block (prompt-only model)
- **compression**: Exemplar for the dispatch pattern; uses prompt-only
  dispatch shape
- See `dispatch` as the canonical example of footgun catalogue
  in a skill body.

## Don'ts

- This spec does not govern skill *content* (what a specific skill teaches)
- This spec does not define how skills are discovered or loaded at runtime
- This spec does not cover skill versioning or deprecation (future work)
