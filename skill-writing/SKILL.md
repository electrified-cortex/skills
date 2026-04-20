---
name: skill-writing
description: >-
  How to write skills — decision tree for inline vs dispatch, structure,
  quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

Workflow: Never skip steps.

1. Spec first — write `spec.md` using `spec-writing` skill. Defines what skill does, requirements, constraints, acceptance criteria.
2. Write uncompressed — write `uncompressed.md` derived from spec. Human-readable baseline.
3. Compress — use `compression` skill (source→target: `--source uncompressed.md --target SKILL.md`). SKILL.md is compressed runtime agents load.
4. Audit — use `skill-auditing` to verify. Fix findings, recompress, re-audit until PASS.

Dispatch skills: also write companion agent file.
Revising: update spec (if change affects requirements or constraints) → update `uncompressed.md` → recompress → re-audit. Never modify `SKILL.md` directly — it's a compiled artifact.

Decision: Inline or Dispatch?

"Could someone with no context do this from just the inputs?" Yes → dispatch. No → inline.

Inline = needs caller's context, judgment, creative intent.
Dispatch = mechanical processing against rules. Use Dispatch agent (zero context).

Folder Convention:

```text
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec (never at runtime)
```

`instructions.txt` or `<name>.md` present = dispatch skill. Absent = inline.
Never use "SKILL" in any filename except `SKILL.md`.

Inline: SKILL.md IS full instruction set. Agent reads and applies directly.

Dispatch (routing card): SKILL.md = ~10-15 lines. `instructions.txt` holds procedure.
Dispatch via Dispatch agent: "Read and follow `instructions.txt`. Input: `<params>`"
Parameters: types, required/optional, defaults. Output format specified.
Dispatch instruction file must be in the same directory or a known path.
Instruction files must contain only instructions — no title headers, no descriptions, no preamble.

Requirements:
- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

After writing any .md file, run `markdown-hygiene` (dispatch) before compressing or stamping.
Verify completed skills with `skill-auditing`.

Footgun Mirroring: If companion spec has `Footguns` section, mirror it in `uncompressed.md`/`SKILL.md`.
- Preserve all F#: entries, Mitigation: lines, and any ANTI-PATTERN: examples
- Canonical ref: `dispatch-strategy` skill

Related:
- `spec-writing` — write spec first (step 1)
- `compression` — compress `uncompressed.md` to `SKILL.md` (step 3)
- `skill-auditing` — verify skill quality (step 4, dispatch, dogfoods itself)
