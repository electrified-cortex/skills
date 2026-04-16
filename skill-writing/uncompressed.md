---
name: skill-writing
description: How to write skills — decision tree for inline vs dispatch, structure, quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

## Decision: Inline or Dispatch?

> "Could someone with no context do this from just the inputs?"
> **Yes** → dispatch. **No** → inline.

**Inline** = needs caller's context, judgment, creative intent.
**Dispatch** = mechanical processing against rules. Use Dispatch agent (zero context).

## Skill Folder Convention

```text
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec (never at runtime)
```

`instructions.txt` present = dispatch skill. Absent = inline.
Never use "SKILL" in any filename except `SKILL.md`.

## Inline Skill

SKILL.md IS the full instruction set. Agent reads and applies directly.

## Dispatch Skill (Routing Card)

SKILL.md = ~10-15 line routing card. `instructions.txt` holds procedure.

Dispatch via Dispatch agent: "Read and follow `instructions.txt`. Input: `<params>`"

Parameters: types, required/optional, defaults. Output format specified.

## Requirements

- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

After writing any .md file, run `markdown-hygiene` (dispatch) before compressing or stamping.
Verify completed skills with `skill-auditing`.

## Related

- `skill-auditing` — verifies skill quality (dispatch, dogfoods itself)
- `compression` — exemplar dispatch pattern
- `spec-writing` — how to write the companion spec
