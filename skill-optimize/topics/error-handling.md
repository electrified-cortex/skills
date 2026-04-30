# ERROR HANDLING — Executable Assessment

Assess whether the skill explicitly addresses error paths — missing inputs,
malformed data, unexpected states, and out-of-scope inputs.

---

## How to make this assessment

### Step 1 — Check precondition handling

Read `uncompressed.md` Steps 1-2. Does the skill check for required
inputs before proceeding?

Required inputs for skill-optimize:

- `<skill-path>` — the path to the skill being analyzed
- Skill source files: at least `uncompressed.md` or `SKILL.md`

Does Step 1 specify what to do if the skill path doesn't exist or the
source files are absent?

### Step 2 — Check sub-agent error handling

Steps 3a and 4 dispatch sub-agents. What happens if:

- The qualifier returns `TOPIC: none`?
- The qualifier returns a malformed response?
- The Sonnet analysis sub-agent returns an unexpected format?

### Step 3 — Check out-of-scope handling

If the input is not a skill (e.g., a random directory), does the skill
detect and reject it, or does it attempt analysis anyway?

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Precondition handling:**

Step 1 says "Read the skill's source files." No explicit check for what
happens if the source files don't exist. The skill would proceed to Step 2
(read optimize-log — might not exist either), then attempt to qualify
topics on an empty context. This would produce a qualifier result that
says "no applicable topic" or hallucinate findings against missing content.

Missing: an explicit fail-fast check at Step 1: "If no source files found
at `<skill-path>`, emit `ERROR: no skill files found at <path>` and stop."

**Sub-agent error handling:**

Step 3a: `TOPIC: none` case — "If none apply: TOPIC: none" is documented.
But `uncompressed.md` Step 3b doesn't say what to do when the qualifier
returns `none`. The assessor would presumably have nothing to pick. Missing:
"If qualifier returns `TOPIC: none`, check the full topic list manually or
stop with: `No applicable topics found for this skill.`"

Malformed qualifier response: no handling specified. The assessor would
either hallucinate a topic slug or fail silently.

Step 4 sub-agent: unexpected format handling — not specified. The Step 5
recording assumes the finding is in the standard format. If the sub-agent
returns prose instead of the structured block, the log entry would be
malformed.

**Out-of-scope handling:** Not specified. Any directory could be passed.

**Finding: MEDIUM**

Three gaps:

1. No precondition check at Step 1 (missing source files → silent bad analysis)
2. No `TOPIC: none` handling in Step 3b (qualifier finds nothing → undefined)
3. No malformed response handling for sub-agent outputs (Step 3a + Step 4)

These are real error paths, not edge cases.

**Recommendation:**

- Step 1: add "Precondition check: if no source files exist at `<skill-path>`,
  emit `ERROR: no skill files at <path>` and stop."
- Step 3b: add "If qualifier returns `TOPIC: none`, stop and emit
  `No topics applicable for this skill — all already logged or out of scope.`"
- Step 4: add "If the sub-agent response is not in the standard finding
  format, record `ERROR: unexpected analysis format` in the log and stop."
