# Context Sensitivity

## Purpose

Assess whether the skill correctly handles variation in its operating
context — different callers, environments, inputs, and task states —
without being either over-hardcoded (only works in one specific setup)
or under-specified (works differently in different contexts with no
documentation).

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## The parameterization spectrum

Skills exist on a spectrum:

**Fully hardcoded** — The skill does exactly one thing, for one type of
input, in one environment. Simple and predictable. Appropriate for skills
that are truly single-purpose. Fragile when the context changes.

**Fully parameterized** — The skill accepts inputs that control its
behavior and adapts accordingly. Flexible and reusable. Requires clear
documentation of parameters and their effects. Over-parameterized skills
become harder to reason about than just writing two specialized skills.

**Implicitly parameterized** — The skill behaves differently in different
contexts but doesn't document how or why. This is the dangerous middle:
the skill seems general but has hidden assumptions that make it brittle
in unexpected ways.

The goal is to be on the right point of this spectrum given the skill's
purpose — not to maximize generality.

## Environmental context sensitivity

Does the skill behave correctly across:

- Different working directories?
- Different git states (clean, dirty, mid-worktree)?
- Different host platforms (Windows vs. Linux)?
- Different tool availability (what if a required tool isn't installed)?

A skill that assumes a specific environment without documenting it is
implicitly hardcoded to that environment.

## Caller context sensitivity

Does the skill produce the same quality of output regardless of who calls
it? Relevant variations:

- Called by a low-context agent vs. a fully-initialized agent
- Called as part of a pipeline (with preceding context) vs. standalone
- Called interactively vs. in batch mode

If the skill's quality degrades significantly in some calling contexts,
that degradation should be documented as a known limitation.

## Input variation handling

Some skills work well on typical inputs but fail silently on edge cases.
The skill should document its operating range: what inputs it is designed
to handle, what inputs are out of scope, and what happens when an out-of-
scope input is provided (see also error-handling.spec.md).

## Context as a behavioral lever

Some skills should explicitly vary their behavior based on context.
Example: a skill that is called in "batch mode" (processing many skills)
vs. "single mode" (focusing on one skill in detail) should document
what changes between modes. If the skill doesn't document behavioral
variants, it will be called in the wrong mode.

## Over-specialization signal

A skill that contains hardcoded paths, hardcoded model names, hardcoded
task IDs, or other repo-specific constants is specialized to a single
deployment. This is a finding when the skill is presented as general-
purpose — the hardcoded values prevent reuse and make the skill misleading
in its apparent scope.

## Under-generalization signal

A skill that was written for one specific case but could easily serve a
broader class of inputs with minor parameterization. The opposite of
over-specialization: the skill is narrow when it could be wide.

## Finding criteria

Produce a finding when:

- **HIGH**: The skill has hardcoded environment-specific constants
  (absolute paths, specific host names) that make it non-portable.
- **HIGH**: The skill behaves differently in different contexts but
  this variation is undocumented — callers can't predict the output.
- **MEDIUM**: The skill's input range is not documented — edge cases
  will produce silent failure or wrong results.
- **MEDIUM**: The skill could serve a broader class with minimal
  parameterization but is unnecessarily narrow.
- **LOW**: Environmental assumptions are implicit — the skill works in
  the author's setup but may not work in other valid setups.

Do not produce a finding when narrow scope is correct for the skill's
purpose — some skills should be highly specialized and that specialization
is appropriate and documented.
