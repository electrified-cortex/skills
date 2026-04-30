# DISPATCH — Executable Assessment

Assess whether the skill uses the right execution pattern: dispatch (isolated
sub-agent context) or inline (runs in the host agent's context). Wrong
choice in either direction is a structural defect — harder to fix than most
other categories.

---

## How to make this assessment

### Step 1 — Identify the execution pattern

Read `SKILL.md` and `uncompressed.md`. Determine:

- Does the skill invoke a sub-agent (Dispatch pattern) or run inline in
  the host context?
- If dispatched: who dispatches it, and what is the sub-agent's scope?
- If inline: does it run entirely in the host, or does it dispatch sub-steps?

Look for these specific indicators:

| Indicator | Implies |
| --------- | ------- |
| `runSubagent(...)` or equivalent in instructions | Dispatch pattern |
| SKILL.md names itself a "dispatch skill" | Dispatch pattern (intended) |
| Instructions are a procedure the host executes directly | Inline |
| Instructions contain `dispatch` skill or sub-skill reference | Dispatch |
| Instructions modify shared session state (memory, operator comms) | Inline required |

### Step 2 — Check for pattern/implementation mismatch

A skill can claim to be a dispatch skill (in its spec or SKILL.md) but
implement its steps inline. This is a mismatch.

Signals of mismatch:

- SKILL.md or spec.md says "dispatch skill" but `uncompressed.md` describes
  steps the host executes directly
- The skill dispatches sub-steps but the primary analysis still runs inline
  in the host context — partial dispatch, full context pollution
- The skill has no SKILL.md dispatch invocation but the spec intends dispatch

### Step 3 — Assess whether the current pattern is correct

**For inline skills — ask: should this be dispatched?**

Fire a DISPATCH finding if ALL of the following are true:

- The procedure has 5+ distinct steps with intermediate state (findings,
  file reads, analysis results) that accumulate in context
- The work is context-independent — no shared session state needed
- The instruction file is large (>50 lines) and loads fully on every call

Do NOT fire if:

- The skill is brief (< 5 steps, < 20 lines of instructions)
- The skill must write to or read from shared session state
- Dispatch overhead would dominate the actual work

**For dispatch skills — ask: is the dispatch scope correct?**

Fire a DISPATCH finding if:

- The skill claims dispatch but does significant work inline before the
  dispatch call (pre-filtering, state building, context accumulation)
- The dispatch boundary is wrong — too coarse (one giant sub-agent doing
  everything) or too fine (dispatching trivial single-step operations)
- The fallback for unavailable dispatch is missing

### Step 4 — Check tool call vs. text substitution opportunities

Scan the instructions for tool calls. For each one, ask:

1. Does the tool interact with external state (filesystem, network, time)?
   If yes → keep it.
2. Does the tool compute something the model can derive inline from
   context? If yes → candidate for replacement.
3. Is the tool call reused across many skills, centralizing logic to
   prevent drift? If yes → keep it.

Fire a LOW finding (tool call replacement) when a tool call's behavior
could be replaced by a 2-3 line inline instruction with no loss of
reliability or correctness.

### Step 5 — Produce finding or confirm clean

**Finding format:**

```md
### DISPATCH — HIGH | MEDIUM | LOW

**Signal:** <what you observed in the skill>

**Reasoning:** <why the current pattern is wrong>

**Recommendation:** <specific change — e.g., "Wrap Steps 4-6 in a
dispatched sub-agent. Pass [list] as inputs. Return findings record.">
```

**Severity:**

- HIGH — pattern mismatch that causes context pollution every invocation
  or blocks architectural evolution
- MEDIUM — partial mismatch or tool call replacement with moderate gain
- LOW — tool call replacement with minor gain, or pattern is fine but
  could be marginally improved

**Confirm clean** (emit no finding) when:

- The skill is inline and brief — dispatch overhead would be wasteful
- The skill is dispatched with the correct scope
- All tool calls interact with external state or centralize shared logic

---

## Application to skill-optimize

Running this assessment against `skill-optimize` (self):

**Observed pattern:** Hybrid. The spec declares skill-optimize "a dispatch
skill." `uncompressed.md` implements:

- Steps 1-2: inline (read files, check log) — correct, host context needed
- Step 3a: dispatches a Haiku qualifier — correct scope
- Steps 3b-6: inline (assessor decision, topic analysis, log update,
  output) — potentially misaligned with the dispatch declaration

**Signal:** The assessor step (3b) and topic analysis (Step 4) run inline
in the host. For a skill that may analyze a 29-topic index with large spec
files, Step 4 alone loads the topic spec + skill files and produces
structured findings — all accumulating in the host context.

Severity: **MEDIUM**

The qualifier dispatch (Step 3a) is correctly scoped. The mismatch is in
Step 4 (topic analysis): this step is the core work, is context-independent
(no shared state needed), and produces intermediate findings that pollute
the host. As topic specs grow in size, inline analysis compounds the
context cost.

**Recommendation:** Extract Step 4 (topic analysis) into a dispatched
sub-agent per topic. The host passes: skill source files + the selected
topic spec. The sub-agent returns the findings record. Steps 3b, 5, and 6
(assessor decision, log update, output) remain inline — they are brief and
need the host context.

This aligns with the Architecture Direction in spec.md §"Architecture
Direction (Planned)" which already anticipates per-topic dispatch agents.
The finding validates that direction as a MEDIUM-priority architectural
improvement, not just a future optimization.
