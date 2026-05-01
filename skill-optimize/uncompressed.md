# Skill Optimize — Execution Instructions

Prerequisite: audit the target skill using `../skill-auditing/SKILL.md`

## Inputs

Required:

- `<skill-path>` — path to the skill directory (contains SKILL.md,
  spec.md, uncompressed.md, etc.)

Optional:

- `<topic>` — specific topic category slug (e.g. `dispatch`, `caching`).
  If provided, skip the assessor and analyze that topic directly.
- `<mode>` — `assess-only` (pick next topic, no analysis) | default
  (assess then analyze)

---

## Step 1 — Read Skill Source Files

Read the following files from `<skill-path>` in order. Read all that exist
before forming any opinion. Do not analyze yet.

1. `spec.md` — purpose, requirements, contract
2. `uncompressed.md` — full instructions
3. `SKILL.md` — compressed runtime instructions
4. `instructions.txt` — if present
5. `instructions.uncompressed.md` — if present

If none of these exist, stop: `ERROR: no skill source files found at <skill-path>`.

---

## Step 2 — Check the Optimize Log

The optimize log is at `<skill-path>/optimize-log.md`.

If it exists, read it. The log records which topics have been analyzed,
when, and what was found. Use it to:

- Skip topics already marked `clean` or `rejected`
- Pick up from where the last session left off
- Avoid repeating analysis the owner already reviewed and decided on

If no log exists, proceed — this is the first pass.

**Log format:**

```markdown
# Optimize Log: <skill-name>

## Topics Analyzed

| Topic | Date | Model | Findings | Status | Action |
| ----- | ---- | ----- | -------- | ------ | ------ |
| DISPATCH | 2026-04-29 | Sonnet | 1 | pending | — |
| CACHING  | 2026-04-29 | Sonnet | 0 | clean   | No change. |
```

Status values:

- `pending` — finding exists, not yet reviewed by owner
- `acted` — skill was changed based on this finding
- `deferred` — finding reviewed, owner chose not to act yet
- `rejected` — finding reviewed and does not apply
- `clean` — no findings for this topic

Action values: free-text one-line summary of what was done (or `—` if none).

---

## Step 2a — Pre-flight Audit Check

Run `pwsh result.ps1 <skill-path>` from the `skill-auditing/` directory.
Note the verdict. Proceed regardless — this is informational only.

---

## Step 3 — Assessor Pass

Goal: pick the best topic to analyze next.

Skip this step if `<topic>` was explicitly provided. First verify
`<skill-optimize-root>/topics/<topic>.md` exists. If not found, stop:
`ERROR: topic file not found at topics/<topic>.md`. Then go to Step 4.

**Assessor model:** Sonnet-class (standard). The assessor makes the final
pick — it does not read topic specs itself. It reads qualifier signals and
decides.

### 3a — Qualifier Dispatch (Haiku-class, batched)

Dispatch one Haiku-class qualifier agent. Give it:

- All skill source files (from Step 1)
- The ordered candidate topic list — all unanalyzed topics not in the log
  as `clean`/`rejected`/`acted`, sorted by natural priority tier. Priority
  order: tier 1 (structural) — DISPATCH, CACHING, DETERMINISM, COMPOSITION,
  MODEL-SELECTION; tier 2 (stylistic) — COMPRESSIBILITY, WORDING,
  LESS-IS-MORE, REUSE, OUTPUT-FORMAT; tier 3 — all remaining. Full topic
  list: read from `topics/` directory.
- One-line descriptions only — not full topic specs

Prompt:

```text
Read the skill files below.
Scan the following topic list in order.
Return the FIRST topic that applies to this skill.
Short-circuit: stop at the first match.

Format:
TOPIC: <SLUG>
APPLICABLE: yes | maybe
REASON: <one sentence>

If none apply: TOPIC: none
```

One dispatch call. One result. Move to 3b.

To find a second candidate (after acting on the first), run at most one
additional qualifier call, starting from the topic after the previously
returned slug. Do not chain more qualifier calls in a single invocation.

### 3b — Assessor Decision

Review qualifier results. From topics marked `yes` or `maybe`, pick the
single topic most likely to yield a HIGH finding.

If qualifier returned `TOPIC: none`, stop and emit:
`No applicable topics found — all topics already logged or none apply to this skill.`

Tie-breaking priority:

1. `yes` over `maybe`
2. Structural before stylistic (DISPATCH, CACHING, DETERMINISM before WORDING, COMPRESSIBILITY)
3. Shorter topic spec (faster analysis, same expected yield)
4. Default: DISPATCH → CACHING → DETERMINISM → INTERFACE CLARITY → LESS IS MORE

Emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>`

If in `assess-only` mode, stop here.

**Fallback — inline qualification (no dispatch available):**

Skip 3a. Read the skill and use these heuristics directly:

| Signal | First topic |
| ------ | ----------- |
| Expensive or repetitive work, no log/cache mechanism | HASH RECORD |
| Spawns sub-agents or calls external tools | DISPATCH |
| Steps that could be regex / file check / git command | DETERMINISM |
| Contract (inputs/outputs) not documented | INTERFACE CLARITY |
| Description is vague or similar to neighboring skills | TOOL SIGNATURES |
| Instructions are very long relative to task scope | LESS IS MORE |
| Makes judgment calls with no review step | SELF CRITIQUE |
| No output schema; output format varies | OUTPUT FORMAT |
| Iterates or loops with no hard cap | ITERATION SAFETY |
| External version references / model name pinned | TEMPORAL DECAY |
| Default | DISPATCH |

---

## Step 4 — Topic Analysis (Dispatched)

Dispatch a Sonnet-class topic analysis sub-agent. This step runs in an
isolated context — do not execute topic analysis inline in the host.

**Pass to the sub-agent:**

- All skill source files (from Step 1): spec.md, uncompressed.md, SKILL.md,
  instructions.txt, and any others that exist
- The selected topic spec file:
  `<skill-optimize-root>/topics/<topic-slug>.spec.md`
- The executable topic assessment file (if it exists):
  `<skill-optimize-root>/topics/<topic-slug>.md`
- Instruction: "Read the skill files and the topic spec. Apply the topic
  assessment. Return findings in the standard format, or confirm clean."

**Sub-agent prompt:**

```md
You are a skill optimizer running a focused topic analysis.

Topic: <SLUG>

Skill files:
<attach all source files>

Topic spec:
<attach topic spec>

<If executable topic .md exists:>
Topic assessment guide:
<attach topic .md>

Apply the topic assessment criteria to this skill.
Produce findings in this format, or confirm clean:

### <CATEGORY> — HIGH | MEDIUM | LOW

**Reasoning:** <grounded in specific content from the skill files>

**Recommendation:** <concrete, actionable>

Severity:
- HIGH: clear benefit, direct evidence, minimal downside
- MEDIUM: likely benefit, context-dependent
- LOW: minor or edge-case gain

If no finding applies, respond: CLEAN

Flag any finding that would apply universally (not just this skill) as:
audit-candidate: <description>

Before finalizing: review your finding. Does it hold under the evidence?
Is the severity calibrated correctly — not over- or under-rated? If the
verdict is CLEAN, confirm no signal was missed. Revise before outputting.
```

**Collect the sub-agent's response.** If the response is CLEAN, record it
as `clean` in the log. If findings are returned, record them.

If the response is not in the standard finding format (missing `### CATEGORY`
heading or `**Reasoning:**` field), record `ERROR: unexpected analysis format`
in the log and stop. Do not attempt to parse or use a malformed response.

---

## Step 5 — Record Results

**5a — Append one row** to `<skill-path>/optimize-log.md`:

| `<TOPIC>` | `<today's date>` | `<model>` | `<N findings>` | `<status>` | `<one-line action summary>` |

Status: `acted` | `deferred` | `rejected` | `clean` | `audit-candidate`

If the log does not exist, create it using the header format from Step 2.

**5b — Write report file** to `<skill-path>/.optimization/<topic-slug>.md`:

```md
# <TOPIC> — <date>

**Severity:** HIGH | MEDIUM | LOW

**Finding:** <what was observed>

**Action taken:** <what changed, or "No change."> 
```

If clean: write a single line `CLEAN — no findings.` instead.

---

## Step 6 — Output

Emit a one-line summary as the final output:

```text
TOPIC: <TOPIC-SLUG> | FINDINGS: <N> | LOG: <repo-relative path to optimize-log.md>
```

If all tier-1 and tier-2 topics in the log show `clean`, `acted`, or
`deferred`, also emit a convergence signal:

```text
CONVERGENCE: tier-1+2 topics complete — <N acted>, <M clean>, <K deferred>
Next: re-run with higher model tier to verify.
```

Then stop. The caller decides whether to run again.
