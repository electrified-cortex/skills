# COMPRESSABILITY — skill-auditing

Date: 2026-05-01
Model: Claude Sonnet 4.6
Status: pending

## Findings

### Finding 1 — MEDIUM

**Signal:**

```md
`<instructions>` = `instructions.txt` (NEVER READ)
`<instructions-abspath>` = absolute path to `<instructions>`
```

**Reasoning:** Two lines to arrive at one value. `<instructions>` is never used directly — it only serves to define `<instructions-abspath>`. The indirection adds a line with no runtime benefit.

**Proposal:**

```md
`<instructions-abspath>` = absolute path to `instructions.txt` (NEVER READ)
```

---

### Finding 2 — MEDIUM

**Signal:**

```md
`<tier>` = `standard` — audit requires judgment; fast-cheap models miss nuances
```

**Reasoning:** The em-dash clause is explanatory documentation, not a runtime instruction. Rationale belongs in spec, not the runtime doc.

**Proposal:**

```md
`<tier>` = `standard`
```

---

### Finding 3 — MEDIUM

**Signal:**

```md
## Inline result check (post-execute)

Run `result` again directly.
Branch on `stdout`.
```

**Reasoning:** Section header adds navigational overhead for two lines. Can append inline after the dispatch block.

**Proposal:** Drop the section header; append to dispatch block:

```md
Follow `dispatch` skill. See `../dispatch/SKILL.md`.
Should return: `PASS: <path>` | `NEEDS_REVISION: <path>` | `FAIL: <path>` | `ERROR: <reason>`
Run `result` again; branch on `stdout`.
```

---

**Action taken:** No change yet. Net savings ~4 lines. All three are safe to apply together.
