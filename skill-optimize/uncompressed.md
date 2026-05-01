# Skill Optimize — Execution Instructions

Prerequisite: audit the target skill using `../skill-auditing/SKILL.md`

## Inputs

Required:

- `<skill-path>` — path to the **target skill being analyzed** (not
  this skill's own directory). Contains SKILL.md, spec.md, uncompressed.md, etc.

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

The optimize log is at `<skill-path>/optimize-log.md` — written into the target skill's own directory.

If it exists, read it. Any topic with any log entry (any status) is excluded
from candidate selection in Step 3a — the host subtracts the full logged set
from the `_index.md` list before sending candidates to the qualifier.

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

- `qualified` — qualifier ran; verdict + reasoning in Action field. Awaiting assessor pick.
- `pending` — analyzer ran, finding exists, not yet reviewed by owner
- `acted` — skill was changed based on this finding
- `deferred` — finding reviewed, owner chose not to act yet
- `rejected` — finding reviewed and does not apply
- `clean` — no findings for this topic

Action values: free-text one-line summary of what was done (or `—` if none). For `qualified` rows: `yes — <reason>` / `maybe — <what would tip it yes or no>` / `no — <reason>`.

---

## Step 2a — Pre-flight Audit Check

Run `pwsh result.ps1 <skill-path>` from the `skill-auditing/` directory.
Note the verdict. Proceed regardless — this is informational only.

---

## Step 2b — Explicit Topic Guard

If `<topic>` was explicitly provided AND the optimize log exists AND the log
contains a row for `<topic>` with status `clean`, `acted`, or `rejected`:

```md
SKIP: <topic> already <status> — pass --force to re-analyze
```

Stop. Pass `--force` to bypass this guard and re-run the analysis.

---

## Step 3 — Assessor Pass

Goal: pick the best topic to analyze next.

Skip this step if `<topic>` was explicitly provided. First verify
`<skill-optimize-root>/topics/<topic>.md` exists. If not found, stop:
`ERROR: topic file not found at topics/<topic>.md`. Then go to Step 4.

### 3a — Candidate Selection (Host, mechanical)

No model needed. Host does this deterministically:

1. Read `topics/_index.md` — the fixed priority-ordered topic list
2. Remove any topic already present in the optimize-log (any status, including `qualified`)
3. Take the top 3 remaining in order

If fewer than 3 unlogged topics remain, use however many there are.
If none remain, stop and emit:
`No unqualified topics remaining — all topics logged.`

### 3b — Qualifier Dispatch (Haiku-class)

Dispatch one Haiku-class qualifier agent. Give it:

- All skill source files (from Step 1)
- The 3 candidate topics from 3a, with one-line descriptions only (not full specs)

Prompt:

```text
For each topic below, assess whether it applies to this skill.

Format (one line per topic):
TOPIC: <SLUG> | APPLICABLE: yes | no | maybe | REASON: <one sentence>

For `maybe`: the reason must explain what would tip it to yes or no.
For `no`: one sentence explaining why it does not apply.

Return a result for every topic. Do not skip any.
```

One dispatch call. Log all 3 results immediately as `qualified` rows (Step 5a).

### 3c — Assessor Decision (Sonnet-class host)

Read all `qualified` rows in the log where Action starts with `yes` or `maybe`.
Pick the single topic most likely to yield a HIGH finding for this specific skill.

If no `yes` or `maybe` rows exist, stop and emit:
`No applicable topics found — all qualified topics returned no.`

Tie-breaking (when expected yield is unclear):

1. `yes` over `maybe`
2. Structural before stylistic
3. Shorter topic spec (faster analysis, same expected yield)

Emit: `Assessor selected: <TOPIC-SLUG> — <one-line reason>`

If in `assess-only` mode, stop here.

**Fallback — inline qualification (no dispatch available):**

Skip 3b. Read `topics/_index.md` for the priority order, then read the skill
and assess each of the top 3 candidates yourself using the same yes/no/maybe
criteria. Log them as `qualified` and proceed to 3c.

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

**5a — Append rows** to `<skill-path>/optimize-log.md`:

| `<TOPIC>` | `<today's date>` | `<model>` | `<N findings>` | `<status>` | `<one-line action summary>` |

After 3b (qualifier): append one row per qualified topic immediately:
- Status: `qualified`
- Model: Haiku-class
- Findings: `—`
- Action: `yes — <reason>` / `maybe — <what would tip it>` / `no — <reason>`

After 4 (analyzer): update the selected topic's row — change status from `qualified` to the
final status: `pending` | `acted` | `deferred` | `rejected` | `clean` | `audit-candidate`

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
