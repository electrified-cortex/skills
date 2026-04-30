# REUSE — Executable Assessment

Assess whether the skill contains procedure blocks that could be extracted
as sub-skills, converted to tools, or replaced with existing primitives.

---

## How to make this assessment

### Step 1 — Read skill as a program

Read `uncompressed.md` and identify discrete procedure blocks. For each:
- What are its inputs and outputs?
- Is it self-contained (no dependency on surrounding state)?
- Does it appear in other skills or is it likely to?

### Step 2 — Check for extraction candidates

For each multi-step block:
- Does the same block appear in 2+ skills, or will it?
- Is it long enough that duplication adds overhead? (>5 lines = likely yes)
- Is it stable enough to be a shared dependency without versioning pain?

### Step 3 — Check for tool conversion candidates

For each LLM step:
- Is the output fully determined by the input (no judgment required)?
- Is it scriptable (file hash, line count, format check)?
- Would a tool be faster, cheaper, and more reliable?

### Step 4 — Check for dispatch adoption

Does the skill spawn sub-agents without using the `dispatch` skill?
If yes: finding — adopt dispatch as the spawning primitive.

### Step 5 — Produce finding or confirm clean

```
### REUSE — HIGH | MEDIUM | LOW

**Signal:** <which block; where it appears or will appear>

**Recommendation:** <extract/convert/adopt or defer with rationale>
```

---

## Application to skill-optimize

**Procedure blocks in `uncompressed.md`:**

1. **Steps 1-2** — Read skill files, read optimize-log. Standard file I/O.
   No special procedure, no reuse candidate.
2. **Step 3a** — Haiku qualifier dispatch. Spawning mechanics are inline
   (not using a `dispatch` skill). The prompt template is embedded directly.
3. **Step 4** — Sonnet analysis dispatch. Same — inline spawning, embedded
   prompt template.
4. **Step 5** — Write log row + write `.optimization/` report. Standard
   file writes. No reuse candidate.
5. **Step 6** — Emit output line. Trivial.

**Dispatch skill adoption check:**

Steps 3a and 4 dispatch sub-agents inline rather than using the `dispatch`
skill. Looking at the actual dispatch mechanism: the skill passes files +
prompt to a sub-agent. In this system (VS Code Copilot / Claude Code
context), "dispatch" is a conceptual pattern — the `dispatch.skill` would
govern when to spawn a sub-agent vs. run inline. The skill's Step 4 was
already updated (DISPATCH topic finding) to dispatch a Sonnet sub-agent
rather than run inline.

Is there a `dispatch` sub-skill in the skills library that should be
adopted here? Looking at the skill index — `dispatch` is a TOPIC within
skill-optimize, not a standalone skill primitive the skill should depend on.
The dispatch skill topic assesses whether this skill uses dispatch correctly,
it doesn't provide a spawning API to import.

**Reuse across skills check:**

The topic analysis sub-agent prompt (Step 4) is specific to skill-optimize's
domain (analyzing skills against optimization topics). It's not a generic
pattern other skills would import. The qualifier prompt (Step 3a) is also
specific — it scans a skill-optimize topic index.

**Finding: CLEAN**

No extraction or tool conversion candidates. The procedure blocks are either
trivial (file I/O, single-line emits) or skill-specific (domain prompts that
wouldn't generalize). No circular dependencies. No dispatch primitive exists
to adopt — the DISPATCH topic covers this domain as an assessment, not an API.
