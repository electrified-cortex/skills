# Skill Optimize Specification

## Purpose

Define the rules and procedures for optimizing skills via LLM-intelligence
analysis. Where skill-auditing enforces conformance to structural rules
(verifiable by Haiku), skill-optimize performs higher-order assessments that
require judgment — asking "given what this skill is trying to do, is it
structured optimally?" This is Sonnet-class work and cannot be reduced to
a deterministic checklist.

## Design Goal — Intelligence Over Rules

Skill auditing finds rule violations. Skill optimize finds missed
opportunities. The optimizer reads the skill holistically and asks these
(but not not limited to) structural questions:

1. Is the execution pattern (dispatch vs inline) the right choice?
2. Should this skill use a hash record to avoid redundant work?
3. Can any LLM-dependent step be replaced with a deterministic tool?

Each finding must be grounded in the skill's actual content and purpose —
not applied mechanically. A suggestion without a clear reason tied to the
skill's intent is not a valid finding.

## Scope

Applies when analyzing an existing skill for architectural and structural
improvement. The optimizer reads, reasons, and recommends — it does not
modify files and does not gate on pass/fail. Every invocation produces
findings (which may be empty if no improvements apply).

This is a **dispatch skill** — it must run in an isolated agent at
Sonnet-class or higher. `fast-cheap` (haiku-class) is not permitted;
the assessments require judgment.

## Version

1.0

Bump when optimization categories, output schema, or assessment logic
change in a way that invalidates prior records.

## Definitions

- **Optimization finding**: A concrete, reasoned suggestion to improve the
  skill's architecture or structure. Each finding belongs to exactly one
  category.
- **Category**: One of DISPATCH_PATTERN, HASH_RECORD, or DETERMINISM
  (see Behavior).
- **Dispatch skill**: A skill that invokes a sub-agent (Dispatch pattern)
  to perform its work in an isolated context.
- **Inline skill**: A skill whose instructions execute directly in the
  host agent's context without spawning a sub-agent.
- **Hash record**: A content-addressed cache (`.hash-record/`) used to
  avoid re-running expensive operations on unchanged inputs.
- **Deterministic step**: A step whose output is fully determined by its
  inputs with no LLM reasoning required — e.g., file hashing, regex
  extraction, git commands, file presence checks.
- **Severity**: Confidence-weighted impact of the finding —
  HIGH (strong signal, clear benefit), MEDIUM (likely benefit, context
  dependent), or LOW (minor or edge-case benefit).

## Requirements

1. The optimizer **must** read all available skill source files before
   producing any finding: `spec.md`, `uncompressed.md`, `SKILL.md`,
   `instructions.txt`, and `instructions.uncompressed.md` if present.
2. The optimizer **must** evaluate all three optimization categories
   (DISPATCH_PATTERN, HASH_RECORD, DETERMINISM) for every invocation.
3. Each finding **must** include: category, severity, reasoning (grounded
   in the skill's content), and a concrete recommendation.
4. The optimizer **must** produce no finding for a category when no
   meaningful improvement applies — empty categories are valid and
   preferred over low-confidence suggestions.
5. The optimizer **must** cache results using the hash-record manifest
   procedure: compute a manifest hash over the skill's source files,
   probe the cache, and on a hit return `PATH: <existing-record>` and
   stop. On a miss, write the findings record before returning.
6. The optimizer **must** return exactly one final stdout line in the
   form `PATH: <abs-path-to-record.md>` on success or
   `ERROR: <reason>` on failure. This line **must** be last, at column 0,
   with no indentation, quoting, or list-marker prefix.
7. Findings **must** be grounded in evidence from the skill files.
   Assertions not traceable to specific content in the files are not
   valid findings.
8. The optimizer **must not** modify any skill file. It is strictly
   read-only.
9. Severity **must** be assigned honestly: HIGH requires a clear,
   direct benefit with minimal downside; MEDIUM requires a likely but
   context-dependent benefit; LOW is reserved for edge cases or minor
   gains.
10. The optimizer **must** respect the single-worktree scope for hash
    record reads and writes — it must not enumerate other worktrees.
11. The record body **must not** contain absolute filesystem paths.
    All paths in the body **must** be repo-relative.

## Constraints

- **One skill per invocation**: each invocation optimizes exactly one
  skill; multi-skill runs are separate invocations.
- **Read-only**: the optimizer never writes to skill files. It writes
  only to the hash-record.
- **Sonnet or higher required**: Haiku is not permitted for this skill.
  The caller is responsible for model selection.
- **No fabrication**: findings must be grounded in the actual skill
  content. Generic suggestions not tied to the specific skill are not
  permitted.
- **No absolute paths in record body**: paths in the findings record must
  be repo-relative.

## Behavior

The optimizer executes as a single-pass analysis with no hard-gate phases.

### Entry and Cache Check

On entry, identify the skill source files (`spec.md`, `uncompressed.md`,
`SKILL.md`, `instructions.txt`, `instructions.uncompressed.md`), compute a
manifest hash using the hash-record manifest procedure, and probe the cache
at `.hash-record/<hash[0:2]>/<hash>/skill-optimize/v1.0/report.md`.

On a cache hit, emit `PATH: <existing-record>` and stop.

On a miss, proceed with the full analysis.

### Pattern 1 — DISPATCH

Assess whether the skill's execution pattern (dispatch vs inline) is the
right choice for its purpose.

**Signal for dispatch (scope isolation needed):**

- The skill performs a long, multi-step procedure that would pollute the
  host agent's context with intermediate state.
- The skill's work is context-independent — it needs no shared state with
  the calling agent.
- The skill's instructions contain a complete executor procedure that would
  consume significant tokens in the host agent.

**Signal for inline (host agent context needed):**

- The skill uses or modifies shared state in the calling agent's session
  (e.g., operator communication context, active task tracking, live memory).
- The skill is a brief procedure (a few steps) where dispatch overhead
  would dominate the work and extra tool calls would just mean more cost.
- The skill writes a file-based artifact that the host agent immediately
  references in the same turn.
- The skill is meant to teach the host agent a behavior pattern — the
  instructions are the behavior, not a program to delegate.

Produce a finding only when the current pattern is a poor fit. A skill
using dispatch correctly (or inline correctly) requires no finding.

### Pattern 2 — HASH RECORD

Assess whether the skill would benefit from a hash record to avoid
redundant processing on unchanged inputs.

**Strong signal for hash record:**

- The skill operates on one or more files and produces a deterministic
  output or verdict given the same files.
- The skill is expensive — it invokes LLMs, runs build tools, or processes
  large file sets.
- The skill is called repeatedly (audit loops, hygiene pipelines, CI).
- The skill already has logic to check "was this already done?" — if so,
  that logic should be formalized as a hash record.

**Weak or no signal:**

- The skill is short and cheap enough that caching provides negligible
  benefit.
- The skill's output depends on external state (network, time, system
  config) that changes independently of the input files.
- The skill is invoked at most once per session.

Produce a finding only when the benefit is clear and the skill lacks a
hash record. If the skill already uses a hash record, verify it is being
applied to the right scope; if misapplied, produce a finding.

### Pattern 3 — DETERMINISM

Assess whether any LLM-dependent step in the skill could be replaced with
a deterministic tool, script, or structured algorithm.

**Signal for deterministic replacement:**

- The step is pattern-matching on well-defined formats (frontmatter,
  regex, YAML structure) where an LLM is used but a parser would suffice.
- The step counts, lists, or enumerates artifacts — pure file-system or
  git operations.
- The step applies a fixed transformation (normalize whitespace, sort
  entries, strip comments) where the rule is fully specified.
- The step checks for the presence or absence of specific strings or
  structures — grep or AST traversal would be cheaper and more reliable.

**Weak or no signal:**

- The step requires semantic understanding that cannot be expressed as
  a fixed rule (e.g., "does this prose convey intent clearly?").
- The step must handle unbounded variation in inputs that would require
  an exhaustive rule set to cover.
- The deterministic alternative would be as expensive or more complex
  than the LLM call.

Produce a finding only when a realistic, concrete tool replacement exists.
Do not suggest vague "use a script instead" findings without specifying
what the script would do.

Be concervative about tool use as it can create unforseen complexity that
an LLM can do on it's own.  Creating one or two useful tools to help with
deterministic processes is probably a win.  Creating a tool for every
excecution is probably an anti-pattern.

### Output — Findings Record

Write findings to `.hash-record/<hash[0:2]>/<hash>/skill-optimize/v1.0/report.md`
with this structure:

```md
---
skill: <repo-relative skill path>
version: 1.0
date: <ISO-8601 date>
file_paths:
  - <repo-relative path to each source file included in manifest>
---

# Skill Optimize Report: <skill name>

## Summary

<1-3 sentence overall assessment.>

## Findings

### <CATEGORY> — <SEVERITY>

**Reasoning:** <grounded in specific skill content>

**Recommendation:** <concrete, actionable>

---
(repeat for each finding)
```

If no findings exist in a category, omit that section entirely. If all
categories have no findings, replace the Findings section with:

```md
## Findings

No optimization opportunities identified.
```

Emit `PATH: <abs-path-to-record>` as the final stdout line.
