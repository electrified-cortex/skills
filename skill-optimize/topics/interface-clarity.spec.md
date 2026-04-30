# Interface Clarity

Assess whether the skill clearly defines its invocation contract — what it
needs from callers, what it promises to return, and under what conditions
it will behave as documented.

## The skill as an API

A skill is a procedure with a caller. The caller must know:
- What to provide (inputs, context, files)
- What to expect in return (output structure, path format, error format)
- What can go wrong (preconditions, scope limits)

A skill that doesn't document its interface forces callers to discover it
through trial and error, read the entire skill to infer the contract, or
simply guess. This produces unreliable invocations and hard-to-debug
failures.

## Input specification

The skill should specify:

**Required inputs** — What must be present before the skill can run?
Files, parameters, environment state. Each required input should be named
with enough specificity to validate: "a directory containing at least one
`.md` skill file" is more useful than "a skill path."

**Optional inputs** — What inputs, if provided, change the skill's
behavior? Optional inputs should document their defaults.

**Input format** — What format are inputs expected in? Repo-relative paths
or absolute? YAML or JSON? The SKILL.md description field is the natural
home for this, but an `## Inputs` section in the instructions works too.

## Output specification

The skill should specify:

**Success output** — What does the caller receive on success? The exact
format of `PATH: <path>`, the schema of a findings record, the structure
of a produced file.

**Error output** — What does the caller receive on failure? `ERROR:
<reason>` as the final line (per R6 in the main spec) is the standard.
The skill should confirm it follows this.

**Side effects** — Does the skill produce any outputs beyond the primary
return value? Files written, state changed, external services called?
Side effects should be documented, not assumed.

## Preconditions and postconditions

**Preconditions** — What must be true for the skill to produce correct
results? "The target skill must have a `SKILL.md` file" is a precondition.
The caller is responsible for meeting preconditions; the skill is
responsible for checking them at entry (see error-handling.spec.md).

**Postconditions** — What will be true if the skill succeeds? "A findings
record exists at the emitted path" is a postcondition. Postconditions are
the caller's basis for trusting the output.

## SKILL.md description quality

The SKILL.md `description` field is the primary invocation surface for
automated callers (e.g., a dispatch skill reading available tools). A
description that is too vague ("optimizes skills") or too narrow ("finds
DISPATCH-related issues in SKILL.md files") will cause the skill to be
mis-invoked or missed.

An effective description:
- States what the skill does in action-verb form
- Names the primary input type and output type
- Specifies when to use it vs. when not to
- Is 1-3 sentences maximum

This overlaps with TOOL SIGNATURES (tool description quality) — but TOOL
SIGNATURES applies to tools the skill invokes; INTERFACE CLARITY applies
to the skill's own description as seen by its callers.

## Version compatibility

If the skill version changes in a way that breaks the output format or
renames inputs, the interface has changed. Callers built against the old
interface will break silently. Interface-breaking changes should be versioned
explicitly and the migration path documented.

## Finding criteria

Produce a finding when:
- **HIGH**: The skill has no documented input requirements — callers must
  read the entire skill to know what to provide.
- **HIGH**: The output format is not specified — callers cannot reliably
  parse the result.
- **MEDIUM**: Inputs are partially documented but required vs. optional is
  not distinguished.
- **MEDIUM**: The SKILL.md description is vague enough that automated
  dispatch would likely mis-select this skill.
- **LOW**: Side effects are not documented.
- **LOW**: Preconditions and postconditions are implied but not stated.

Do not produce a finding when the skill is simple enough (single-input,
single-output, self-describing) that documentation would be more verbose
than the skill itself.
