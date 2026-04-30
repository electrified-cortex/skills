# COMPRESSIBILITY — Executable Assessment

Assess whether the skill's instruction file is tighter than it needs to
be. Match instruction style to the actual cognitive demand of the task.

---

## How to make this assessment

### Step 1 — Identify cognitive demand type

Read the skill's purpose and steps. Classify each step:

- **Deterministic** — file reads, log writes, format checks, rule
  application. Optimal form: tables, decision trees, minimal prose.
- **Probabilistic / judgment** — assessments, ranking, scoring. Optimal
  form: criteria with why-context. Some prose load-bearing.
- **Creative** — generation, synthesis. Optimal form: intent + examples.
  Why-context may matter more than steps.

Mismatch between cognitive demand and instruction style = finding.

### Step 2 — Scan for prose in deterministic steps

For each step that is deterministic (rule application, file I/O, log
writing), count the prose-to-rule ratio. If the step has paragraphs of
explanation for a mechanical operation, that's overhead.

Signals:

- "The log records which topics have been analyzed, when, and what was
  found. Use it to: (three-item bulleted list)" — this is background
  context the model doesn't need to parse a log. A one-line format spec
  does the same job.
- Multiple nested conditions described in prose when a table would suffice.

### Step 3 — Check for duplicate format specifications

If the same format (log header, output schema, field list) appears more
than once in the instruction file, that's duplication overhead.

Every format spec should appear once — in the most authoritative location
— and be referenced elsewhere rather than repeated.

### Step 4 — Check for SKILL.md existence

The SKILL.md surface is the compressed runtime version of the instructions.
Without it, every invocation must load the full verbose file.

If SKILL.md doesn't exist, this is a compressibility finding —
the compression work hasn't been done yet. The finding recommends
creating SKILL.md by stripping orientation prose, collapsing inline
sub-agent prompts to references, and condensing the topic index.

### Step 5 — Check for partitioning opportunity

If the instructions cover multiple distinct sub-procedures (e.g.,
assessment path + topic analysis path), could they be separate sub-skills
that are dispatched independently? If so, each invocation only loads the
relevant sub-skill's context.

### Step 6 — Produce finding or confirm clean

**Finding format:**

```md
### COMPRESSIBILITY — HIGH | MEDIUM | LOW

**Signal:** <where the overhead is — section name, pattern>

**Reasoning:** <what cognitive demand is present; why prose is overhead
vs. load-bearing>

**Recommendation:** <specific compression strategy>
```

**Severity:**

- HIGH — most of the instruction file is prose overhead; decision trees
  or tables would replace it; SKILL.md doesn't exist for a complex skill
- MEDIUM — one significant section is over-specified relative to its
  cognitive demand; OR duplicate format specs; OR SKILL.md missing for a
  moderately complex skill
- LOW — minor prose overhead in one or two steps; SKILL.md missing for
  a simple skill

---

## Application to skill-optimize

**Cognitive demand classification:**

- Step 1 (read files): deterministic. A list of paths. Clean.
- Step 2 (check log): deterministic — read and parse. Has 1 paragraph of
  context + log format example + status values list. The paragraph is
  borderline load-bearing (explains the WHY for skipping analyzed topics).
  The format block is necessary. The status values list is useful lookup.
  Judgment: acceptable for a new-caller experience.
- Step 3 (assessor): judgment. The Haiku prompt is load-bearing. The
  tie-breaking rules are deterministic — would benefit from tighter form.
  The fallback table is a large inline heuristic for an infrequent path.
- Step 4 (topic analysis): dispatch. The sub-agent prompt is load-bearing.
  Large, but necessary.
- Step 5 (log update): deterministic. Has the log header format AGAIN —
  same format block from Step 2, this time for the create-if-not-exists
  branch.
- Step 6 (output): 1-line format template. Clean.

**Duplicate format block:** The log header format appears in both Step 2
(reading the log) and Step 5 (creating the log). One reference, one
authoritative location.

**SKILL.md:** Does not exist. This is a skill that dispatches sub-agents,
has embedded prompts, and a topic index table. The full instructions are
verbose. Every invocation loads ~300 lines of instruction prose, including
sub-agent prompts that the host reads but doesn't execute directly.

Finding: MEDIUM

Two issues:

1. **SKILL.md missing.** The compressed surface hasn't been created.
   Every invocation loads the full verbose `uncompressed.md` — including
   the full sub-agent prompt templates (which the host passes through but
   doesn't need to reason about itself), the large topic index table, and
   the orientation prose. A SKILL.md would strip these to references
   and keep only the host's decision logic.

2. **Duplicate log format.** The log header/format appears in both Step 2
   and Step 5. Remove the format block from Step 5; replace with "If no
   log exists, create it with the header format in Step 2."

**Recommendation:**

- Create SKILL.md: host-only instructions (routing, log check, dispatch
  calls, output line). Sub-agent prompts become "dispatch as specified in
  uncompressed.md Step 3a/4." Topic index becomes a single-column slug
  list.
- In Step 5, remove the duplicate format block; add cross-reference to
  Step 2.
