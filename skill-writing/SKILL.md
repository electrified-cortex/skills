---
name: skill-writing
description: How to write skills — decision tree for inline vs dispatch, structure, quality criteria.
---

# Skill Writing

Create skills agents can discover, invoke, rely on.
Never reference `spec.md` at runtime. Minimize tokens.

Workflow: never skip steps.
1. Spec first — write `spec.md` via `spec-writing` skill.
2. Write `uncompressed.md` from spec (human-readable baseline).
3. Compress — `compression` skill, source→target: `--source uncompressed.md --target SKILL.md`.
4. Audit — use `skill-auditing` skill to verify, fix findings, recompress, re-audit until PASS.
5. Final sign-off — run `skill-auditing` one more time after PASS. Issues → back to step 4.
Dispatch skills: also write companion agent file.
Revising: update spec → update uncompressed.md → recompress → re-audit. Never modify SKILL.md directly — it's a compiled artifact.

Decision (inline vs dispatch): "Could someone with no context do this from just the inputs?" Yes → dispatch. No → inline.
Inline: needs caller's context, judgment, creative intent.
Dispatch: mechanical processing against rules. Use Dispatch agent (zero context).

Folder convention:
```text
skill-name/
├── SKILL.md            ← compressed runtime (what agents load)
├── instructions.txt    ← dispatch procedure (dispatch skills only)
├── uncompressed.md     ← human-readable baseline
└── spec.md             ← normative spec (never at runtime)
```
`instructions.txt` present = dispatch skill. Absent = inline.
Never use "SKILL" in any filename except `SKILL.md`.

Inline: SKILL.md IS full instruction set. Agent reads and applies directly.
Dispatch (routing card): SKILL.md = ~10-15 lines. `instructions.txt` holds procedure.
Dispatch via Dispatch agent: "Read and follow `instructions.txt`. Input: `<params>`"
Parameters: types, required/optional, defaults. Output format specified.

Requirements:
- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

After writing any .md file, run `markdown-hygiene` (dispatch) before compressing or stamping.
Verify completed skills with `skill-auditing`.

Related:
- `spec-writing` — write spec first (step 1)
- `compression` — compress uncompressed.md to SKILL.md (step 3)
- `skill-auditing` — verify skill quality (step 4, dispatch, dogfoods itself)
