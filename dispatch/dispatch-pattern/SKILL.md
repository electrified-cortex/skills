---
name: dispatch-pattern
description: Canonical envelope for dispatch-skill SKILL.md and uncompressed.md. Reference when authoring or editing any skill that dispatches a zero-context sub-agent. Triggers — write a dispatch skill, update SKILL.md dispatch invocation, refactor compression / hygiene / audit dispatch wording, confirm canonical envelope wording.
---

# Dispatch Pattern

Canonical envelope for dispatch-skill SKILL.md and uncompressed.md. Reference this spec when authoring a new dispatch skill or refactoring an existing one. The envelope is verbatim; the middle (invocation, params, return shape) varies per skill.

Spec: `spec.md` (same directory). Spec governs.

## Envelope (verbatim)

**Opener (line 1 of body)**:

```text
Without reading `<instructions-file>` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):
```

**Closer (last body line)**:

```text
NEVER READ OR INTERPRET `<instructions-file>` YOURSELF. Let the sub-agent handle.
```

`<instructions-file>` = `instructions.txt` for most dispatch skills.

## Middle (varies)

Between the opener and closer:

- One bullet per runtime — Claude Code (Agent tool) and VS Code / Copilot (runSubagent) — with the literal dispatch invocation including all parameters.
- One line stating the return shape (e.g. `Returns: PATH: <abs-path-to-record.md> on success, ERROR: <reason> on pre-write failure.`).

Nothing else. No middle reminder lines like "Don't read instructions.txt yourself" — the opener and closer carry the full force.

## Reference exemplars

The two reliable, cross-runtime-tested exemplars at time of authoring:

- `electrified-cortex/markdown-hygiene/SKILL.md`
- `electrified-cortex/skill-auditing/SKILL.md`

When in doubt, copy structure from one of those.

## Related

- `dispatch/` — the parent skill: when and why to dispatch.
- `skill-writing/spec.md` — author-facing rules for writing dispatch skills.
- `skill-auditing/spec.md` — auditor-facing rules for verifying dispatch skills.
