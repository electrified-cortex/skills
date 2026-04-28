# dispatch-pattern spec

## Purpose

Capture the canonical envelope wording for dispatch-skill `SKILL.md` and
`uncompressed.md`. The envelope removes interpretive slack across runtimes
(Claude Code, VS Code Copilot, GitHub Copilot CLI) so the host actually
dispatches instead of inlining.

## Scope

Applies to every skill whose `SKILL.md` directs the host to dispatch a
zero-context sub-agent with an instruction file. Does NOT cover:

- Inline skills (no dispatch).
- Compression of skill bodies (see `compression`).
- The internal mechanics of the dispatched agent (see the target skill's
  `instructions.txt`).

## Version

1.0

## Definitions

**Envelope** — the opener line and closer line of a dispatch-skill
`SKILL.md` body. Verbatim across all dispatch skills.

**Middle** — content between the envelope: invocation lines (one per
runtime) and the return-shape line. Varies per skill.

**Opener** — the first body line:
`Without reading \`<instructions-file>\` yourself, spawn a zero-context, haiku-class sub-agent (in the background if possible):`

**Closer** — the last body line:
`NEVER READ OR INTERPRET \`<instructions-file>\` YOURSELF. Let the sub-agent handle.`

**Instructions file** — the file the dispatched sub-agent reads. Almost
always `instructions.txt` co-located with `SKILL.md`.

## Requirements

1. Every dispatch-skill `SKILL.md` and `uncompressed.md` body MUST begin
   with the Opener (verbatim, including punctuation and backticks).
2. Every dispatch-skill `SKILL.md` and `uncompressed.md` body MUST end
   with the Closer (verbatim, including the all-caps NEVER READ OR
   INTERPRET).
3. The Middle MUST include exactly two runtime invocation bullets:
   - **Claude Code:** `Agent` tool with the literal `prompt` string in
     backticks.
   - **VS Code / Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "...")`
     with the literal prompt string.
4. The Middle MUST include a single return-shape line stating what the
   host receives back (e.g. `Returns: CLEAN | findings: <abs-path> | ERROR: <reason>`).
5. The Middle MUST NOT include a third "don't read instructions" reminder
   between the runtime bullets and the return-shape line. The Opener and
   Closer carry full force; a middle reminder is superfluous and was
   empirically shown to add noise without changing behavior.
6. The instructions file referenced in the envelope MUST exist at the
   path the dispatched agent will resolve (typically `instructions.txt`
   in the skill directory).
7. The model class in the VS Code / Copilot bullet MUST be the same
   model class assumed by the skill (haiku-class for haiku-executable
   skills, sonnet-class for skills that require sonnet).
8. The opener phrase "(in the background if possible)" is intentional —
   it gives VS Code Copilot a graceful off-ramp. Without "if possible",
   VS Code Copilot reports "I don't know how to do background dispatch"
   and choke. The parenthetical lets it dispatch synchronously without
   conflict. Claude Code reads it as `run_in_background: true` when
   feasible. Authors MUST keep the parenthetical wording verbatim;
   removing the qualifier breaks VS Code dispatch; making it
   unconditional ("in the background:") removes the off-ramp.
9. **No recursive dispatch.** The instructions file (read by the
   dispatched sub-agent) MUST NOT direct that sub-agent to dispatch
   another skill. Only the **host** dispatches. Sub-agents may invoke
   **inline** skills (read-only patterns or small in-process procedures)
   but never another `Agent` / `runSubagent` call. Multi-skill
   orchestration belongs in the host. Violation → HIGH.
10. Corollary: any verb in the instructions file like "dispatch X",
    "run X skill", "spawn Y" — when X / Y is a dispatch skill — is a
    rule-9 violation. Subject-matter mentions (e.g. "the X skill
    produces records of this shape") are not violations.

## Constraints

- Verbatim envelope wording. No paraphrase. No reordering.
- No author-introduced reminders inside the envelope.
- No model-name versions in the body (`Claude Haiku 4.5` is the only
  acceptable model literal in the VS Code bullet at v1.0; revisit on
  model-name version bump).
- The envelope is for SKILL.md and uncompressed.md only. The
  instructions file (read by the dispatched agent) does not contain
  the envelope — it contains the procedure.
- **Skills are NOT recursive.** The instructions file does not
  dispatch other skills. If a procedure needs multiple dispatches
  (e.g. compress + then hygiene), that orchestration belongs in the
  HOST that calls the first dispatch — not inside the dispatched
  sub-agent's procedure.

## Reference exemplars

These two skills are the reference exemplars at v1.0:

- `electrified-cortex/markdown-hygiene/SKILL.md`
- `electrified-cortex/skill-auditing/SKILL.md`

Cross-runtime tested: Claude Code, VS Code Copilot, GitHub Copilot CLI.

## Tiered detect-fix-verify loop

For any skill that **detects** problems AND optionally **fixes** them
(markdown-hygiene, skill-auditing fix-mode, future linters, future
formatters), the canonical pattern is a bounded loop orchestrated by
the host:

```text
iteration = 1
loop:
  Pass 1 — Detect (haiku):
    if CLEAN: exit, success.
    if findings: keep the detect-record path, proceed.
  Pass 2 — Fix (sonnet):
    apply explicit Fix instructions from the detect record.
    self-verify byte preservation; on mojibake, REVERT and ERROR.
  if iteration >= 2: exit, surface remaining findings to operator.
  iteration += 1
  goto loop
```

Pass-by-pass:

1. **Pass 1 — Detect (haiku)**: read-only scan. Returns `CLEAN` or
   `findings: <detect-record-path>`. Cheap. Cache HIT short-circuits
   future runs on unchanged content. **CLEAN exits the loop
   immediately.**
2. **Pass 2 — Fix (sonnet)**: super-lightweight executor — reads the
   detect record, applies each explicit `Fix:` instruction to the
   file, **does NOT write a hash record**. Sonnet only fixes; haiku
   owns all record writes. Does NOT read hygiene rules; the detect
   record's `Fix:` lines are imperative and complete. Sonnet is
   required because LLM rewrites can introduce UTF-8 encoding bugs
   (mojibake on em dashes, arrows, smart quotes); haiku has been
   observed mishandling these. Pass 2 MUST self-verify byte
   preservation of non-ASCII characters before exiting. On mojibake:
   REVERT, emit ERROR, exit.
3. **Loop back to Pass 1** on the fixed file. Haiku detect verifies
   cleanliness AND writes the pass-stamp at the new content hash.
   Future invocations on the fixed content HIT cache. Hash records
   are haiku's exclusive domain — sonnet's fix-pass produces no
   record artifact.

**Iteration cap: 2.** If after two full iterations the file still
returns findings on Pass 1, exit and surface to the operator. Do not
loop indefinitely.

Rationale:

- Most files are clean. Pass 1 alone, cached, is the common path.
- Sonnet pays only when fixes are actually needed.
- The loop's natural exit is "Pass 1 returns CLEAN" — which doubles
  as the verify step and writes the durable cache stamp.
- Cap protects against pathological cases where sonnet's fix
  introduces new violations that the next detect catches.

Why not haiku-fix: haiku can detect violations (deterministic pattern
match) but writing files with byte-precise UTF-8 preservation requires
reasoning haiku lacks. Empirical: haiku rewrites have introduced
mojibake on em dashes and arrows. Don't ask haiku to rewrite anything.

The host orchestrates the loop via independent dispatches. The
dispatched sub-agents do not call each other (no recursive dispatch —
see rule 9).

## Lessons

The envelope was discovered empirically. Earlier dispatch wording in
SKILL.md bodies allowed the host enough interpretive room to "just read
the instructions and inline-execute" — defeating the dispatch contract
and leaking sub-agent context into the host. The all-caps closer plus
the "Without reading" prefix together remove that room across all three
tested runtimes. A middle "don't read" reminder added no measurable
benefit and was removed in 2026-04-28 to keep the envelope tight.

## Don'ts

- Don't paraphrase the Opener or Closer.
- Don't add explanatory text inside the envelope.
- Don't reorder the runtime bullets.
- Don't omit the return-shape line.
- Don't reference this spec's `dispatch-pattern/spec.md` from the
  authored skill's runtime artifacts — point to skills by name only.

## Related

- `dispatch/` — parent skill: when and why to dispatch.
- `skill-writing/spec.md` — overall skill-authoring spec; this pattern
  is one of several requirements skill-writing enforces.
- `skill-auditing/spec.md` — auditor verifies envelope conformance via
  Phase 2 / Phase 3 dispatch-skill checks.
