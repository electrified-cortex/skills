# Observability

Assess whether the skill produces enough signal for humans and downstream
agents to understand what it did, why it decided what it decided, and
what to do next.

## Why observability matters in skills

A skill that produces the right answer with no trace is a black box.
When it produces the wrong answer, there is no way to debug it. When it
produces the right answer in a surprising way, there is no way to verify
it. When it is called in a pipeline, downstream callers can't adapt to
unexpected outcomes if they can't see the reasoning.

Observability is distinct from OUTPUT FORMAT (which defines the schema)
and SELF CRITIQUE (which improves accuracy). Observability is about
surfacing enough internal signal to make the skill debuggable and
trustworthy over time.

## Dimensions of observability

**Decision transparency** — Does the output explain why key decisions
were made? "No finding for DISPATCH" is less observable than "No finding
for DISPATCH — skill is a 3-step inline procedure where dispatch overhead
would dominate; current inline pattern is correct." A reviewer can verify
the second; they can only trust the first.

**Intermediate state surfacing** — For multi-step skills, does the output
surface enough intermediate state to verify correctness? A findings
report that shows only conclusions is less observable than one that
includes the reasoning that led to each conclusion.

**Error context** — When a skill fails, does it surface enough context
to diagnose the failure? `ERROR: file not found` is less observable than
`ERROR: expected SKILL.md at skills/my-skill/SKILL.md — directory exists
but file is absent.` The second version immediately points to the fix.

**Boundary conditions** — Does the skill report when it encountered and
handled an edge case, or does it silently fall through to a default? If
the model decides to treat a missing optional input as "empty" rather than
missing, that's a decision worth surfacing.

## Output as audit log

For skills that run repeatedly (optimization passes, audits, pipeline
stages), the output should function as an audit log entry — sufficient
to reconstruct what the skill did without re-running it. This means:

- Source files included in the analysis (already covered by the manifest
  in the hash record)
- Model tier used (already in the findings header)
- Date and version (already in the frontmatter)

What's often missing: the reasoning behind "no findings." A null result
is less trustworthy without explanation. "No CHAIN OF THOUGHT finding —
skill is deterministic; reasoning elicitation would add cost with no
quality benefit" is more auditable than a missing section.

## The observability floor

Minimum observable output for a findings-type skill:
- One sentence per category with no finding, explaining why
- One sentence of reasoning per finding, grounded in the skill content
- Error messages that include enough context to diagnose without re-running

Below this floor, the skill's output is not auditable.

## Trade-off with COMPRESSIBILITY and LESS IS MORE

More observability = more tokens. This is a genuine tension. Resolution:
observability content belongs in the output, not the instructions. The
instructions can be minimal; the output is allowed to be verbose when
transparency demands it. Don't sacrifice observability to hit a token
target.

A findings record that is 20% longer because it explains null categories
is correctly designed. A findings record that omits null-category
reasoning to save tokens is under-observable.

## Finding criteria

Produce a finding when:
- **HIGH**: The skill produces verdicts or recommendations with no
  supporting reasoning — output cannot be audited.
- **HIGH**: Error messages are non-diagnostic — they tell the caller that
  something failed but not what or why.
- **MEDIUM**: Null results (categories with no finding) are omitted with
  no explanation — reviewer cannot confirm the assessment was made.
- **MEDIUM**: Multi-step reasoning is collapsed into a single conclusion
  without intermediate checkpoints.
- **LOW**: Boundary condition handling is silent — the skill falls
  through to defaults without noting that it did so.

Do not produce a finding when the skill's purpose is inherently simple
(single-step, single-output) and the output is self-evidently auditable
without additional explanation. Not every skill needs verbose reasoning —
only skills where the model exercises judgment that a reviewer would want
to verify.
