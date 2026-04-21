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
4. Audit — use `skill-auditing` to verify. Audit flags any markdown issues. Fix findings, recompress, re-audit until PASS.

Dispatch skills: also write companion agent file.
Revising: always update spec first (exception: non-normative changes — README, examples, typo fixes — skip to step 2) → update `uncompressed.md` → recompress → re-audit. Never modify `SKILL.md` directly — it's a compiled artifact.

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
Naming: folder name must equal `name` frontmatter field (mismatch = unreachable). Nested sub-skills must use fully-qualified names with parent prefix (e.g., `skill-index-auditing/` not `auditing/`). Canonical ref: `gh-cli/` (`gh-cli-actions`, `gh-cli-api`).

Inline: SKILL.md IS full instruction set. Agent reads and applies directly.

Dispatch (routing card): SKILL.md = ~10-15 lines. `instructions.txt` holds procedure.
Dispatch via Dispatch agent: "Read and follow `instructions.txt`. Input: `<params>`"
Parameters: types, required/optional, defaults. Output format specified.
Dispatch instruction file must be in the same directory or a known path.
Compressed `instructions.txt` = only instructions; no title/description/preamble. `instructions.uncompressed.md` MAY carry an H1 so markdown-hygiene passes (MD041); strip the title after compression.

Requirements:
- Frontmatter: `name` + `description`
- Self-contained: no spec dependency at runtime
- Concise: agent-facing, every line earns its place
- Token-efficient: no prose, no rationale, no redundancy
- Breadcrumbs: end with related skills (verified, not stale)
- No secrets

Verify completed skills with `skill-auditing` (step 4).

Footgun Mirroring: If companion spec has `Footguns` section, mirror it in `uncompressed.md`/`SKILL.md`.
- Preserve all F#: entries, Mitigation: lines, and any ANTI-PATTERN: examples
- Canonical ref: `dispatch-strategy` skill

Related:
- `spec-writing` — write spec first (step 1)
- `compression` — compress `uncompressed.md` to `SKILL.md` (step 3)
- `skill-auditing` — verify skill quality (step 4, dispatch)
