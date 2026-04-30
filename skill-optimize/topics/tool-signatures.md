# TOOL SIGNATURES — Executable Assessment

Assess whether the tool calls, sub-skill names, and parameter descriptions
used in this skill are precise enough to avoid selection errors at runtime.

---

## How to make this assessment

### Step 1 — Enumerate all tool/sub-skill references

Read `uncompressed.md`. List every:
- Named tool or function called by the skill
- Sub-skill dispatched by name
- Parameter passed to a dispatched call

### Step 2 — Check name precision

For each name: is it semantically precise? Could a routing agent confuse it
with something else?

Generic red flags: "run", "process", "handle", "analyze", "check", "do"
without a direct object.

### Step 3 — Check parameter documentation

For each dispatched call: are inputs documented with types, constraints, and
examples? Or are they described with "the path", "the topic", "the result"?

### Step 4 — Check for disambiguation

If multiple sub-skills are dispatched, can the host clearly distinguish when
to use each? Does the dispatch logic name the criteria?

### Step 5 — Produce finding or confirm clean

```
### TOOL SIGNATURES — HIGH | MEDIUM | LOW

**Signal:** <which names/descriptions are weak>

**Reasoning:** <what selection error could occur>

**Recommendation:** <specific wording improvement>
```

---

## Application to skill-optimize

**Dispatches in `uncompressed.md`:**

1. **Haiku qualifier call** — dispatches with the topic list and the
   skill path as context. The prompt says "iterate in order, return FIRST
   applicable." The output contract is:
   `TOPIC: <SLUG> / APPLICABLE: yes|maybe / REASON: <1 sentence>`.
   Input parameters: implicit (passed in context). No parameter names
   documented in the call instruction.

2. **Sonnet topic analysis call** — dispatches with: the topic's `.md`
   procedure file, the topic's `.spec.md`, the skill's `uncompressed.md`,
   and the instruction "follow the procedure in `<topic>.md` and produce
   a finding." Output contract: the Finding format defined in the topic file.
   Input parameters: implicit (file paths described in prose).

**Sub-skill topic names** (used as dispatch targets):
DISPATCH, HASH-RECORD, DETERMINISM, INTERFACE-CLARITY, LESS-IS-MORE,
OUTPUT-FORMAT, COMPRESSIBILITY, COMPOSITION, MODEL-SELECTION, TOOL-SIGNATURES,
SELF-CRITIQUE, EXAMPLES, WORDING. All names are semantically precise —
each refers to a distinct optimization dimension with no overlap risk.

**Assessment:**

The dispatch calls use implicit parameter passing via context rather than
named parameters. This is a deliberate design: the skill dispatches
sub-agents that read the files directly, not function calls with typed
parameters. In this model, "parameter documentation" is the file structure
itself, not argument names.

The topic names are precise. The qualifier prompt output contract is explicit
(structured line format). The analysis dispatch is clear: "read these three
files, follow the procedure in one of them."

No selection errors are likely because:
1. Only one qualifier is dispatched (no ambiguity)
2. Only one analysis sub-agent is dispatched per invocation
3. Topic names in the index are unique and semantically distinct

**Finding: CLEAN**

No tool signature issues. The parameter-passing model (context-injection
rather than named args) is appropriate for a sub-agent dispatch pattern and
doesn't create selection errors.
