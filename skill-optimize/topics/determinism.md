# DETERMINISM — Executable Assessment

Assess whether any LLM-dependent step in the skill could be replaced with
a deterministic tool, script, or structured algorithm — and whether any
steps that ARE deterministic are being handled by an LLM unnecessarily.

---

## How to make this assessment

### Step 1 — Enumerate the skill's steps

Read `uncompressed.md` step by step. For each step, classify:

| Step type | LLM needed? | Tool candidate? |
| --------- | ----------- | --------------- |
| Reads files and passes them to LLM | No (file read = deterministic) | Yes (file read tool) |
| Pattern matches / grep / presence check | No | Yes (grep, regex) |
| Counts or enumerates artifacts | No | Yes (filesystem ops) |
| Sorts, filters, normalizes | No | Yes (data transform) |
| Makes judgment / weighs evidence | Yes | No |
| Interprets ambiguous prose | Yes | No |
| Applies a fully-specified rule | No | Yes (rule engine) |

### Step 2 — Check each LLM-dependent step

For each step using LLM:

1. Is the logic fully specifiable as a rule? If yes → deterministic
   replacement candidate.
2. Is the input unbounded and variable? If yes → LLM probably needed.
3. Would an exhaustive rule set be required to handle edge cases? If yes
   → LLM probably needed.

**High-value replacement candidates:**

- Log file parsing (read a table, extract rows by status field)
- Topic list construction (filter out log entries, sort by tier)
- File existence checks (does `optimize-log.md` exist?)
- Manifest hash computation (file hash = deterministic)
- Status field classification (`acted` / `clean` / `pending`)

### Step 3 — Assess the hybrid pattern

Even when a step has a deterministic core, the input detection may still
need LLM judgment. Look for:

- Steps where the LLM detects intent but then executes a mechanical rule
  → good hybrid candidate
- Steps where the LLM does both detection AND execution → split candidate
- Steps where the LLM re-reads large files to answer a simple structural
  question → tool candidate

### Step 4 — Filter for realistic, high-recurrence replacements

Apply the conservative test: only recommend a deterministic tool when:

- The step recurs across many invocations (not a one-off)
- The latency or token cost is meaningful
- A concrete, scoped tool (not "write a script") can be specified

### Step 5 — Produce finding or confirm clean

**Finding format:**

```md
### DETERMINISM — HIGH | MEDIUM | LOW

**Signal:** <step name/description that is over-LLM'd>

**Reasoning:** <why this is deterministic and what the cost is>

**Recommendation:** <specific tool or operation — what it reads, what it
returns, how it replaces the LLM step>
```

**Severity:**

- HIGH — core step using LLM for pattern matching / enumeration on every
  invocation; clear deterministic alternative
- MEDIUM — step mixes LLM judgment with deterministic work; split would
  save tokens
- LOW — minor optimization; LLM works fine but a tool would be cleaner

**Confirm clean when:** LLM is used only for steps requiring genuine
judgment, and deterministic work is already handled by tools.

---

## Application to skill-optimize

**Observed LLM-dependent steps in uncompressed.md:**

1. Step 2 — Check optimize log: reads the log file. This is a file read +
   table parse. Currently described as "check for prior work" — an LLM
   reads the file and determines which topics are done.

2. Step 3a — Qualifier dispatch: builds the ordered candidate list by
   excluding log entries. The exclusion logic (filter rows by status) is
   purely deterministic.

3. Step 3b — Assessor decision: picks the topic from qualifier results.
   This is genuine judgment. LLM needed.

4. Step 4 — Topic analysis (now dispatched): genuine judgment. LLM needed.

5. Step 5 — Update log: append a row. Deterministic write.

6. Step 6 — Output: emit a formatted line. Deterministic format.

**Findings:**

DETERMINISM: LOW

Steps 2 and 5 (log read and log write) describe deterministic file
operations but do not specify tool calls — the model reads and writes the
log inline. In isolation this is a LOW finding: the log is small, the
operation is cheap, and one-off file I/O doesn't warrant a dedicated tool.

However, as the iterate-until-converged pattern grows (dozens of passes),
the log read/write pattern recurs every invocation. Flag as `audit-candidate`:
if this skill is run in a tight loop by a coordinator agent, a deterministic
log-read tool would reduce token cost per iteration.

**Confirm clean on:** Steps 3b (assessor judgment), Step 4 (topic analysis
dispatch — already addressed in DISPATCH topic).

**audit-candidate:** Log table parse (read optimize-log.md, return array
of `{topic, status}` rows) — suitable for promotion to a deterministic
tool if skill-optimize is used in high-frequency iteration loops.
