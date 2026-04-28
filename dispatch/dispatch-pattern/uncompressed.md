---
name: dispatch-pattern
description: Canonical envelope for dispatch-skill SKILL.md and uncompressed.md. Reference when authoring or editing any skill that dispatches a zero-context sub-agent. Triggers — write a dispatch skill, update SKILL.md dispatch invocation, refactor compression / hygiene / audit dispatch wording, confirm canonical envelope wording.
---

# Dispatch Pattern

Canonical envelope for dispatch-skill `SKILL.md` and `uncompressed.md` body. Reference when authoring or editing any skill that dispatches a zero-context sub-agent. The envelope (opener + closer) is verbatim; the middle (invocation lines + return shape) varies per skill.

## Envelope

**Opener** — first body line, verbatim:

```text
Without reading `<instructions-file>` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):
```

**Closer** — last body line, verbatim:

```text
NEVER READ OR INTERPRET `<instructions-file>` YOURSELF. Let the sub-agent handle.
```

`<instructions-file>` resolves to the actual instruction file name — almost always `instructions.txt`.

## Middle

Between opener and closer, exactly:

1. **Claude Code** invocation bullet. Format:

   ```text
   **Claude Code:** `Agent` tool. Pass: `"Read and follow <instructions-file> here. Input: <input-signature>"`
   ```

2. **VS Code / Copilot** invocation bullet. Format:

   ```text
   **VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow <instructions-file> in <skill_dir>. Input: <input-signature>")`
   ```

3. **Return shape** line. Format:

   ```text
   Returns: <return-shape>.
   ```

   Examples:

   - markdown-hygiene: `Returns: CLEAN | findings: <abs-path-to-record.md> | ERROR: <reason>.`
   - skill-auditing: `Returns: PATH: <abs-path-to-record.md> on success, ERROR: <reason> on pre-write failure.`

Nothing else between opener and closer. No middle "don't read instructions" reminder — the envelope carries the full force.

## Worked example — markdown-hygiene

```markdown
---
name: markdown-hygiene
description: ...
---

Without reading `instructions.txt` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: <file_path> --filename claude-haiku [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]"`

**VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: <file_path> --filename claude-haiku [--fix] [--source <src> --target <dst>] [--ignore <RULE>[,<RULE>...]] [--force]")`

Returns: `CLEAN` | `findings: <abs-path-to-record.md>` | `ERROR: <reason>`.

NEVER READ OR INTERPRET `instructions.txt` YOURSELF. Let the sub-agent handle.
```

## Why verbatim

Earlier dispatch wording let hosts inline-execute by reading the instructions themselves. That defeats zero-context isolation and leaks sub-agent context into the host. The current envelope was empirically tested across Claude Code, VS Code Copilot, and GitHub Copilot CLI — all three reliably dispatch when this exact wording is used. Paraphrases reintroduce the inline-execution failure mode.

## Reference exemplars

Two skills currently reflect the canonical pattern (use as templates):

- `electrified-cortex/markdown-hygiene/`
- `electrified-cortex/skill-auditing/`

## Related

- `dispatch/` — parent skill (when and why to dispatch).
- `skill-writing/` — overall skill-authoring rules.
- `skill-auditing/` — verifies envelope conformance during audit.
