---
name: skill-writing
description: >-
  How to write skills — decision tree for inline vs dispatch, structure,
  quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

## Workflow

When creating a new skill, follow this order. Never skip steps.

1. **Spec first** — write `spec.md` using the `spec-writing` skill. The
   spec defines what the skill does, its requirements, constraints, and
   acceptance criteria.
2. **Write uncompressed** — write `uncompressed.md` derived from the
   spec. This is the human-readable baseline.
3. **Compress** — use the `compression` skill (source→target mode:
   `--source uncompressed.md --target SKILL.md`). The SKILL.md is the
   compressed runtime agents load.
4. **Audit** — use `skill-auditing` skill to verify. Fix
   findings, recompress, re-audit until PASS.
5. **Final sign-off** — run `skill-auditing` one more time
   after PASS. Issues → fix and repeat from step 4.

For dispatch skills, also write the companion agent file (see Dispatch
Skill section).

When revising an existing skill: update spec first → update
uncompressed.md → recompress → re-audit. Never modify SKILL.md directly
— it is a compiled artifact.

## Decision: Inline or Dispatch?

> "Could someone with no context do this from just the inputs?"
> **Yes** → dispatch. **No** → inline.

**Inline** = needs caller's context, judgment, creative intent.
**Dispatch** = mechanical processing against rules. Use Dispatch agent
(zero context).

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

Dispatch via Dispatch agent: "Read and follow `instructions.txt`.
Input: `<params>`"

Parameters: types, required/optional, defaults. Output format specified.

## Requirements

- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

After writing any .md file, run `markdown-hygiene` (dispatch) before
compressing or stamping.
Verify completed skills with `skill-auditing`.

## Related

- `spec-writing` — write the spec first (step 1 of workflow)
- `compression` — compress uncompressed.md to SKILL.md (step 3)
- `skill-auditing` — verify skill quality (step 4, dispatch, dogfoods itself)
