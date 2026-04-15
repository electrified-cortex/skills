---
name: skill-writing
description: How to write skills — decision tree for inline vs dispatch, structure, quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.

## Core Principle: Tight Context, Minimal Tokens

Every skill loads into an agent's context window. Wasted tokens = wasted
money + degraded performance. Never reference `spec.md` at runtime — specs
are for human review only.

## Decision: Inline or Dispatch?

> "Could someone with no context do this from just the inputs?"
> **Yes** → dispatch. **No** → inline.

**Inline** = needs caller's context, judgment, creative intent.
Writing, communication, discipline, practices.

**Dispatch** = mechanical processing against rules. Input self-contained.
Compression, verification, auditing, code review.

## Skill Folder Convention

```
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec with rationale (never at runtime)
```

`instructions.txt` present = dispatch skill. Absent = inline skill.
Never use "SKILL" in any filename except `SKILL.md`.

## Inline Skill Structure

SKILL.md IS the full instruction set. Agent reads and applies directly.

## Dispatch Skill Structure (Routing Card)

SKILL.md = ~10-15 line routing card. `instructions.txt` holds procedure.

Dispatch via isolated agent (Dispatch agent, zero context): "Read and
follow `instructions.txt`. Input: `<params>`"

Parameters documented with types, required/optional, defaults.
Output format specified.

## Execution Tiers

1. **Dispatch agent (isolated)** — zero context overhead. Preferred.
2. **Background agent (host context)** — full system prompt per turn. Avoid.
3. **Inline** — host applies directly. For context-dependent skills only.

## Requirements

- Frontmatter: `name` + `description` (discovery)
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, fragments OK, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

## Quality Audit Checklist

1. Correctly classified (inline vs dispatch)
2. Self-contained
3. Concise (no execution-irrelevant content)
4. Complete (all runtime instructions present)
5. Breadcrumbed (valid related links)
6. Paired (dispatch: `instructions.txt` exists)
7. Testable (dispatch: agent returns expected format)

## Related

- `skill-auditing` — verifies skill quality (dispatch pair, dogfoods itself)
- `compression` — exemplar dispatch pattern
- `spec-writing` — how to write the companion spec
