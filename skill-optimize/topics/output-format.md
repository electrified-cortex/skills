# OUTPUT FORMAT — Executable Assessment

Assess whether the skill specifies its output format explicitly enough to
produce consistent, parseable results. Two outputs to check: the primary
return line and the secondary findings content (if any).

---

## How to make this assessment

### Step 1 — Identify all outputs

Read `uncompressed.md`. List every output the skill produces:

1. **Primary return** — the final stdout line the caller receives
2. **Secondary outputs** — files written, records created, log entries
3. **Sub-agent outputs** — if the skill dispatches, what does the
   sub-agent return and how does the host use it?

### Step 2 — Check primary return format

Is the primary return format:

- Explicitly templated in the instructions? (e.g., `` `TOPIC: X | FINDINGS: N | LOG: path` ``)
- Or described in prose ("return a line describing the topic and count")?

Template → pass. Prose → finding.

### Step 3 — Check secondary output formats

For each file the skill writes:

- Is the write operation described with enough detail that the model
  would produce the same structure on every invocation?
- Is the path deterministic (not dependent on runtime state the model
  might format differently)?

### Step 4 — Check sub-agent output contract

If the skill dispatches sub-agents, ask:

- What format does the sub-agent return?
- Is that format specified in the dispatch prompt (not just in the sub-agent)?
- How does the host consume the sub-agent response? Is there a parsing step?

A sub-agent returning free-form text that the host is supposed to structure
is a variance risk. The dispatch prompt should specify the return format.

### Step 5 — Check for spec/instructions alignment

Does the spec's "Output" section match what the instructions actually
produce? Stale spec output descriptions are a common drift point.

### Step 6 — Produce finding or confirm clean

**Finding format:**

```
### OUTPUT FORMAT — HIGH | MEDIUM | LOW

**Signal:** <which output is unspecified or misaligned>

**Reasoning:** <what variance this causes>

**Recommendation:** <specific template or alignment fix>
```

**Severity:**

- HIGH — primary return format unspecified; downstream parsers will break
- MEDIUM — secondary output format unspecified or spec/instructions misalign
- LOW — sub-agent return format under-specified; risk is low because output
  is consumed by a model, not code

---

## Application to skill-optimize

**Primary return:** Step 6 in `uncompressed.md`:

```
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path>
```

Explicit template. **CLEAN.**

**Sub-agent return (Step 4):** The dispatch prompt specifies:

```
### <CATEGORY> — HIGH | MEDIUM | LOW
**Reasoning:** ...
**Recommendation:** ...
...or: CLEAN
```

Explicit format in the prompt. **CLEAN.**

**Secondary output — Findings record:** The spec's `## Output — Findings
Record` section describes writing to:
`.hash-record/<hash[0:2]>/<hash>/skill-optimize/v1.0/report.md`

This is the old hash-record-era output. The current `uncompressed.md`
does NOT write a findings file anywhere. The sub-agent returns findings
as text; the host records only a summary row in the optimize-log. The
full findings text (reasoning + recommendation) has no defined persistent
location.

**Finding: MEDIUM**

The spec's Output section is stale — it describes a hash-record findings
file that is no longer written. The new design returns findings as sub-
agent response text. This creates two problems:

1. The spec is misleading — callers might expect a file they can read back.
2. Detailed findings are ephemeral — after the invocation, only the count
   and status survive in the optimize-log.

**Recommendation:**

1. Update spec.md `## Output — Findings Record` section: remove the
   hash-record path; describe the new design (sub-agent returns findings
   text in-context; host logs summary row in optimize-log).
2. Decision needed: should the optimize-log be extended to include full
   finding text per topic (not just count + status)? Or is in-context
   findings text sufficient (caller acts on it immediately, no persistence
   needed)? The current dogfood loop suggests the latter — findings are
   acted on immediately and logged as "acted." Lean toward: log the full
   finding text in the optimize-log under each topic section.
