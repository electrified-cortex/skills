# Activation Discipline

## Purpose


Assess whether the skill defines the conditions under which it should be
invoked — and, equally important, the conditions under which it should not.
A skill that is useful is not automatically a skill that should run. Every
invocation has a context cost; a skill that triggers too broadly pollutes
the calling agent's context as reliably as a skill with bloated instructions.

## Parameters

- <skill-path> — path to the skill directory being analyzed (inherited from optimizer invocation)
- <skill-source-files> — all source files from the skill directory (inherited from Step 1)

## Output

Finding in standard format (### CATEGORY — HIGH | MEDIUM | LOW with **Reasoning:** and **Recommendation:**), or CLEAN if no issues apply.

## Why this matters

Most skill optimization focuses on what happens *inside* the skill. But
the outer boundary — when the skill activates at all — determines whether
the skill is net-positive in a workflow. A great skill invoked at the wrong
time is waste. A mediocre skill invoked precisely when it's needed can be
a force multiplier.

Over-triggering is a silent failure mode: the skill appears to work
(it runs, produces output, returns no errors), but it runs on inputs where
it adds no value, consuming context that could have been preserved for
useful work.

## Trigger criteria

A well-designed skill specifies:

- **Positive triggers** — the conditions under which invocation is warranted.
  What input pattern, request type, or context state justifies loading this
  skill? Be specific: "user asks to optimize a skill" is too broad;
  "a SKILL.md file is identified as a candidate for improvement" is specific.

- **Negative triggers** — conditions under which the skill should explicitly
  not run, even if the positive trigger is superficially present.
  Examples: "do not invoke on SKILL.md files that have already been
  optimized in this session," "do not invoke when the skill is under
  active revision."

- **Confidence threshold** — at what level of ambiguity should the skill
  decline rather than attempt? A skill that produces a result on low-confidence
  inputs is often worse than one that surfaces the ambiguity.

## Activation modes

**Default (always available):** The skill runs whenever its trigger
conditions are met, without explicit instruction. Appropriate for
foundational skills that are broadly applicable.

**Opt-in:** The skill only runs when explicitly requested. Appropriate for
expensive, disruptive, or context-heavy skills. Prevents unwanted triggering
in batch contexts.

**Last-resort:** The skill only activates after other approaches have failed.
Appropriate for fallback strategies or escalation paths.

**Guard:** The skill runs pre-emptively before a costly or irreversible
action to verify preconditions. Not triggered by user request — triggered
by the pipeline structure.

The activation mode should be documented in the skill's description.
A skill that doesn't specify its mode will be treated as default by the
calling agent — which may not be correct.

## Over-triggering signals

- The skill is described so broadly that any invocation of its parent
  workflow will match its trigger.
- The skill is invoked as a courtesy ("just in case") rather than because
  its output is actually used.
- The skill runs on every item in a batch but the batch items are not
  actually the skill's intended inputs.
- The skill is called as a pre-check before a task even though the task
  may not involve anything the skill is designed to assess.

## Discoverability tension

Skills with precise activation criteria are harder to discover — a narrow
description may not match how a calling agent phrases its need. The
resolution is not to broaden the trigger criteria but to improve the skill's
description vocabulary (see tool-signatures.spec.md). Accurate triggering
and discoverability are not in tension if the description is well-written.

## Finding criteria

Produce a finding when:

- **HIGH**: The skill has no documented trigger criteria — it can be invoked
  in any context without guidance on when it is appropriate.
- **HIGH**: The skill has broad trigger criteria that would cause it to run
  on inputs where its output provides no value.
- **MEDIUM**: The skill is documented as "default" but its cost profile
  suggests it should be opt-in.
- **LOW**: Positive triggers are defined but negative triggers are absent —
  the skill does not document when not to run.
