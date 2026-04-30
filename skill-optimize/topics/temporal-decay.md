# TEMPORAL DECAY — Executable Assessment

Assess whether the skill contains content that will become stale as
external versions, model behaviors, or conventions change.

---

## How to make this assessment

### Step 1 — Scan for version-pinned references

Read `uncompressed.md` and `spec.md`. List every:
- Model name or version (e.g., `claude-sonnet-4-6`, `Haiku`, `Sonnet`)
- Tool version or platform requirement
- File paths that assume a specific directory structure
- API endpoint references

### Step 2 — Check for model behavior assumptions

Does any instruction rely on a specific model behaving a certain way?
Example: "this model always returns JSON when..." or "Haiku will
short-circuit on the first match."

### Step 3 — Check environmental assumptions

Does the skill assume specific paths, tool availability, or platform
conventions that could change?

### Step 4 — Produce finding or confirm clean

---

## Application to skill-optimize

**Version-pinned references:**

`uncompressed.md`: references to "Haiku-class" and "Sonnet-class" as
tier labels — not specific model API IDs. These are tier names, not
version pins. The qualifier uses "Haiku" as a tier label; the analysis
uses "Sonnet" as a tier label. If the tier structure changes (e.g.,
Haiku is discontinued), these labels would be stale. LOW risk — tier
labels are more stable than API version strings.

`spec.md`: references to specific model tier names in the requirements
and rationale sections. Same as above.

**Model behavior assumptions:**

Step 3a assumes Haiku will "scan the topic list in order and
short-circuit on first match." This is an instruction, not a behavior
assumption — the short-circuit behavior is commanded, not assumed.
The instruction itself is not dependent on a specific Haiku version's
tendencies. ✓

**Environmental assumptions:**

The skill assumes:
- Skills are stored in a directory with `spec.md`, `uncompressed.md`,
  `SKILL.md` as the standard file names
- An `optimize-log.md` at `<skill-path>/optimize-log.md`
- A `.optimization/` folder at `<skill-path>/.optimization/`

These are internal conventions of the `electrified-cortex/skills/`
structure. They are stable as long as the convention holds.

**"current" references:** None found. No "latest version" references.

**Finding: LOW**

The tier-label references ("Haiku-class", "Sonnet-class") are implicit
version dependencies — if model tiers are restructured, the tier-based
dispatch logic needs updating. This is lower risk than hardcoded API IDs
but worth noting.

**Recommendation:** No change now. If model tiers are reorganized, a
search for "Haiku" and "Sonnet" in the skills files will find all
affected locations. No further mitigation needed for the current tier
structure.
