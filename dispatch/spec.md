# dispatch spec

## Purpose

Define the runtime decision an agent makes when considering whether and how to dispatch a sub-agent. Replaces tribal knowledge with an explicit decision tree, model tier table, footgun list, and well-formed-prompt template.

This skill governs five artifacts:

- `spec.md` (this file): the normative specification. Audited but never loaded at runtime.
- `uncompressed.md`: the human-readable source for the runtime card. Edited by `--fix` mode.
- `SKILL.md`: the compiled runtime card (compressed from `uncompressed.md`). Loaded by every caller.
- `supplemental.md`: optional read for nuance. Empirical evidence, anti-pattern walkthroughs, error handling, precedence rules, subagent-type dimensions. Not loaded by default; agents fetch it on demand when the runtime card is insufficient.
- `installation.md`: agent file installation instructions. Read when the host environment requires setup before dispatch can function.

## Scope

Applies to any calling agent with access to a sub-agent dispatch primitive. Primitives in scope:

- **Claude Code `Agent` tool** — standard dispatch via the `Agent` tool with a `subagent_type` parameter.
- **CLI dispatch** — dispatch via an external CLI tool such as `claude -p` or `copilot`; used when the `Agent` tool is unavailable or when parallel CLI invocations are required.

Covers the choice to dispatch, the parameters of dispatch, and the boundary between inline execution and delegation.

Does NOT cover:

- Transport internals of the `Agent` tool or how Claude Code marshals the dispatch.
- How to design a custom subagent type or write its agent file.
- How to author a skill or write a spec (`skill-writing`, `spec-writing`).
- Inter-agent communication via Telegram, MCP, or other channels.
- Non-dispatch delegation patterns (writing tasks to a queue for other agents to claim).

This skill is a **runtime** skill, not an authoring skill. Cross-references are one-way: authoring skills (`skill-writing`) reference `dispatch`; `dispatch` does not reference them back.

## Definitions

**Calling agent** (or **host**): the agent currently executing that is considering dispatch. Owns the operator conversation, holds in-memory state, pays the inline-token cost for any work it does not delegate.

**Dispatched agent** (or **sub-agent**): the agent spawned by the host via the dispatch primitive. Runs as a child process, completes its task, returns a single result.

**Subagent type**: the named class of sub-agent the host requests. Platform-defined; names evolve between releases. The conceptual term "subagent type" (with a space) refers to this category in prose; the literal token `subagent_type` (with an underscore) is only the parameter name in the dispatch tool's schema.

**Foreground dispatch**: host blocks until dispatched agent returns.

**Background dispatch**: host fires the dispatch and continues; receives a notification on completion. In Claude Code: `run_in_background: true` on the `Agent` tool.

**Project context**: disk-resident files Claude Code loads automatically — primarily the `CLAUDE.md` hierarchy walked from cwd upward, plus project memory index.

**Conversation context**: in-memory turn history the host has accumulated since session start.

**Inherited context**: context arriving in the dispatched agent's system prompt automatically.

**Hand-fed context**: context the host explicitly composes into the dispatch prompt.

**fast-cheap**: cost-optimized model tier for shallow, mechanical, true zero-context work (Haiku-class on Anthropic).

**standard**: capable default tier for moderate reasoning (Sonnet-class on Anthropic). Most common explicit override.

**deep**: highest-reasoning tier (Opus-class on Anthropic). Rare as explicit override; consider inline.

**Model override**: the `model` parameter on the dispatch.

**Tool scope**: tools a given subagent type may call.

**Footgun**: a documented failure mode where an obviously sensible-looking dispatch produces a damaging or wasteful result.

## Requirements

### Runtime card (`SKILL.md` / `uncompressed.md`)

R1. Must present the decision tree as a single table. Conditions evaluated in order; first match wins. Outcomes limited to: Defer, Inline, Dispatch foreground, Dispatch background, Defer-or-batch.

R2. Must present the model tier table with three rows: `fast-cheap`, `standard`, `deep`. Each row: use-case + risk. Must explicitly note that `fast-cheap` pre-pass is appropriate only for true zero-context work.

R3. Must state that **project context inherits automatically** and **conversation context does not**. Empirical evidence lives in `supplemental.md`, not the runtime card.

R3a. The Model Tier section must present ONE consolidated table with four columns: Tier, Used for, Class description, Minimum model. Each row covers one tier (`fast-cheap`, `standard`, `deep`) and includes its class description (haiku-class, sonnet-class, opus-class) and concrete minimum model name. This is the ONE sanctioned location for bare model names — all other skills use class names only. Must include an instruction to update the table when Anthropic releases a new model in any class.

R4. Must include a Well-Formed Prompt section listing the four required components (Goal, Hand-fed context, Output shape, Scope/length constraints) and a four-item checklist.

R5. Must enumerate footguns F1–F5 as a table with two columns only: footgun name + mitigation. No "why" prose. Rationale lives in this spec and may be expanded in `supplemental.md`.

R6. Must instruct on subagent-type selection at minimum:

- Project context inherits; don't hand-feed.
- Conversation context does not inherit; hand-feed everything else.
- Select narrowest type covering required tool scope.
- Type names evolve; treat known names as examples.

R7. Must state the inline-cost-unaffordable fallback: (a) dispatch with fully hand-fed prompt, or (b) defer.

R8. Must point to `supplemental.md` for nuance. Must NOT inline supplemental content.

R9. Must NOT contain:

- Empirical test descriptions (date, method, token examples) — those live in `supplemental.md`.
- Anti-pattern walkthroughs — `supplemental.md`.
- Error-handling tables — `supplemental.md`.
- Precedence rules prose — `supplemental.md`.
- Subagent-type dimension prose — `supplemental.md`.
- "Why it is a footgun" rationale — this spec only.
- Cross-references to authoring skills (`skill-writing`, `spec-writing`).

### Supplemental (`supplemental.md`)

R10. Must present empirical claims about context inheritance in the canonical form: "Empirical (DATE, METHOD): CLAIM." Both the conversation-context-not-inherited and project-context-inherited claims must be present with date stamps.

R11. Must include at least one explicit anti-pattern walkthrough prefixed with the literal token `ANTI-PATTERN:`. The example shows (a) a plausible dispatch decision, (b) what goes wrong, (c) the correct decision.

R12. Must provide error-handling guidance covering: ambiguous decision tree, footgun fires, incoherent output, inline cost unaffordable.

R13. Must enumerate precedence rules: consuming-skill domain pattern governs over general guidance; empirical fact governs over expectation; correctness over throughput.

R14. Must enumerate subagent-type dimensions (tool scope, system prompt size, default model) with current Claude Code examples flagged as non-stable.

### Boundary

R15. Cross-references are one-way. `dispatch` is referenced by authoring skills (`skill-writing`, `spec-writing`) and by runtime callers; `dispatch` itself references only `dispatch/agents/` (companion artifacts). The runtime card and supplemental must NOT reference authoring skills.

R16. Use role-agnostic language. Terms "Curator," "Worker," "Overseer," or any project-internal role name must not appear. Canonical labels: "host," "dispatched agent," "calling agent."

## Constraints

C1. `SKILL.md` (compiled runtime) must not exceed approximately 3000 bytes. Skim-friendly under load is the priority.

C2. `uncompressed.md` is the source the auditor edits in `--fix` mode. It must be a tight reference card, not exposition. Auditor's "too much why" / "essay not reference card" / "prose conditionals" findings apply.

C3. `supplemental.md` has no byte cap but must remain a single file. If it grows beyond ~6000 bytes, split contents into `supplemental/<topic>.md` files referenced from a `supplemental.md` index.

C4. The runtime card must not enumerate the current Claude Code subagent_type list as if stable. Names appear as examples only and must signal evolution.

C5. The runtime card must not embed project-internal procedural detail.

C6. The runtime card must not recommend a single subagent type as a universal default.

C7. The runtime card must remain answerable end-to-end without reading `supplemental.md`. Supplemental is for nuance, not load-bearing instructions.

## Behavior

B1. Decision tree appears at top of runtime card before any other section.

B2. Layered structure: decision tree → tier table → subagent type → prompt → footguns → fallback → pointer to supplemental → related artifacts.

B3. Every empirical claim in `supplemental.md` is anchored: "Empirical (DATE, METHOD): CLAIM."

B4. Footgun rows in the runtime card do not require the literal token `Mitigation:` inline; the table column header replaces it. Anti-pattern blocks in `supplemental.md` use the literal token `ANTI-PATTERN:`.

B5. Cross-references one-way (per R15).

## Defaults and Assumptions

D1. Default for "is this work worth dispatching at all" is **inline**. Dispatch is the exception.

D2. Default model for a dispatch where the host has not specified one is the host's own model.

D3. Default for foreground vs background when the host is in a long-poll loop or has any responsiveness obligation is **background**.

D4. Default for empirical claims this skill cannot verify is "unverified" labeling.

## Error Handling

Operational error-handling rules (what to do when things go wrong at runtime) live in `supplemental.md`. The spec governs what content must be present there:

E1. Decision tree no clear outcome → default inline + file feedback. No "guess."

E2. Footgun fires → revise decision before retry.

E3. Output incoherent → inspect prompt for missing hand-fed context (F5).

E4. Inline cost unaffordable → (a) hand-feed and dispatch, or (b) defer.

## Precedence Rules

P1. Correctness over throughput.

P2. Empirical fact over expectation.

P3. Consuming skill's domain procedure governs over this skill's general guidance.

P4. Role-agnostic language over project-specific clarity.

(Operational text for these rules lives in `supplemental.md` per R13.)

## Don'ts

DN1. Do not enumerate every Claude Code subagent_type with a stability guarantee.

DN2. Do not include a tutorial in the runtime card.

DN3. Do not include implementation detail of how Claude Code transports a dispatch.

DN4. Do not include role-specific language.

DN5. Do not embed memory references or host-private artifacts in normative text.

DN6. Do not introduce a default subagent type, default model, or default foreground/background mode beyond D1–D3.

DN7. Do not duplicate content from authoring skills. Reference and stop. (And do not reference them from this skill — see R15.)

DN8. Do not create a "quick reference" block separate from the decision tree. The decision tree IS the quick reference.

DN9. Do not include claims about subagent behavior without an empirical anchor or "unverified" label.

DN10. Do not extend the skill scope to non-dispatch delegation patterns.

DN11. Do not move runtime instructions into `supplemental.md`. Supplemental is for nuance only; the runtime card must stand alone.

DN12. Do not move spec rationale into `supplemental.md`. Spec rationale lives in the spec.

## Platform Gotchas

The skill is written primarily against the Claude Code runtime. Other environments that read and apply this skill may have structural differences. Platform gotchas are normative deviations from the general model — not suggestions.

### VS Code (GitHub Copilot)

PG1. **No background dispatch.** VS Code has no background agent primitive. There is no `run_in_background` equivalent. Every dispatch in VS Code is foreground — the host blocks until the sub-agent returns. References to "background dispatch" in the runtime card and default D3 do not apply; use foreground dispatch and manage responsiveness inline.

PG2. **Different dispatch primitive.** The dispatch tool in VS Code is `runSubagent`, not the `Agent` tool. The parameter for naming the agent is `agentName` (not `subagent_type`). All runtime card guidance about dispatch applies to `runSubagent`; translate parameter names accordingly.

PG3. **All dispatch is blocking.** In VS Code, `runSubagent` is always synchronous — the host blocks until the sub-agent returns, even when multiple sub-agents appear to be fired in parallel. There is no true parallel execution; concurrent `runSubagent` calls serialize. Callers who interpret "Dispatch background" from the decision tree must fall back to foreground and account for the blocking cost inline.

PG4. **Context inheritance is unverified in VS Code.** The empirical claims about project-context inheritance (in `supplemental.md`) are anchored to Claude Code. Whether VS Code/Copilot's `runSubagent` inherits project context is unverified. Treat context as NOT inherited and hand-feed it explicitly.

## CLI Dispatch Mode

CLI dispatch is a dispatch pattern that invokes an external CLI tool (`claude -p`, `copilot`, or any deterministic read-only CLI — see CDR7 for qualification criteria) as the backend instead of the `Agent` tool. It is the authoritative fallback when the `Agent` tool is unavailable and is the sanctioned path for parallel CLI invocations.

### When to Use CLI Dispatch (CDR1–CDR4)

CDR1. A calling agent **must** use CLI dispatch when the `Agent` tool is unavailable in its execution context — specifically when the calling agent is itself a dispatched sub-agent and the `Agent` tool does not appear in its available tool list.

CDR2. A calling agent **must** use CLI dispatch when it requires parallel invocations of an external CLI tool (`claude -p`, `copilot`, etc.) and the `Agent` tool is either unavailable or structurally inappropriate for the invocation shape.

CDR3. A calling agent **should** use CLI dispatch when the work is heavy enough that keeping it in the parent's conversation context would materially increase token cost or context noise. CLI dispatch runs out-of-band and its output is fed back as a discrete result, not as inline turns.

CDR4. A calling agent **must not** use CLI dispatch as a substitute for the `Agent` tool when the `Agent` tool is available and the task fits a standard sub-agent shape. The `Agent` tool is cheaper and better-integrated when accessible.

### Supported CLI Dispatch Backends (CDR5–CDR7)

CDR5. `claude -p "<prompt>"` **shall** be treated as the primary CLI dispatch backend for Claude Code contexts. It invokes Claude Code CLI in stateless print mode: the prompt is the complete input, standard output is the complete result, and no session state persists between invocations.

CDR6. `copilot <args>` **shall** be treated as a supported CLI dispatch backend. All invocation framing, flag assembly, and output parsing for `copilot` dispatch **must** follow the `copilot-cli` skill. CLI dispatch does not override `copilot-cli` sub-skill routing.

CDR7. The CLI dispatch pattern is generically applicable to any read-only, deterministic CLI tool. A CLI tool qualifies as a valid dispatch backend only if: (a) it has been verified or documented by the calling agent to produce deterministic output for a given input, (b) it does not mutate the working tree or any persistent state, and (c) its output is parseable as a discrete result.

### Read-Only Enforcement (CDR8–CDR11)

CDR8. CLI dispatch **must not** invoke any CLI tool that mutates the working tree, modifies tracked or untracked files, runs side-effecting shell commands, or alters persistent state external to the invocation.

CDR9. Read-only enforcement **must** be achieved by at least one of the following methods (in descending preference):

- **Permission policy**: the calling agent's tool permissions restrict the CLI invocation to read-only operations (e.g., the calling agent's `Bash` tool is restricted to a command allowlist that excludes write-capable commands, and `Edit`/`Write` tools are absent from the tool list).
- **Prompt instruction**: the dispatch prompt explicitly instructs the CLI tool to perform no mutations and return only analysis or text output.
- **Wrapper enforcement**: a wrapper script invokes the CLI tool with flags that strip or disable dangerous operations before the subprocess runs.

CDR10. A calling agent **must not** rely on the CLI tool's default behavior to be read-only. At least one explicit enforcement method from CDR9 **must** be applied per invocation.

CDR11. If none of the enforcement methods in CDR9 can be applied for a given CLI tool, that tool **must not** be used as a CLI dispatch backend.

### Working-Directory Contract (CDR12–CDR14)

CDR12. CLI dispatch **shall** inherit the calling agent's working directory by default. The dispatched CLI process **must** resolve paths relative to the calling agent's cwd unless an explicit override is provided.

CDR13. To override the working directory, the calling agent **must** pass an explicit `--cwd <path>` flag (or equivalent for the target CLI) or wrap the invocation in a shell command that sets the directory before calling the CLI. Implicit directory changes via unrelated environment state **must not** be used.

CDR14. Permission inheritance (PreToolUse hooks, allowed paths, sandbox policy) applies to the CLI invocation at the point it is launched. The calling agent's active permission context governs. If the calling agent lacks permission to access a path, the CLI dispatch to that path **must not** be attempted.

### Parallelism (CDR15–CDR17)

CDR15. Multiple CLI dispatch calls **may** be issued in parallel using a background-capable invocation primitive appropriate to the platform (e.g., `run_in_background: true` on the `Bash` tool in Claude Code), or via an orchestrator-level concurrency primitive. Each invocation **must** be independent — no shared mutable state, no ordering dependency between parallel calls.

CDR16. When parallel CLI dispatch calls are used, the calling agent **must** aggregate their outputs after all calls complete before returning a result to the operator or to the parent agent. Partial results **must not** be forwarded as if complete.

CDR17. For Claude Code, the aggregation pattern **shall** be: (a) issue all parallel CLI calls with `run_in_background: true` on the `Bash` tool, (b) collect each call's stdout as a discrete output (per CDRC3), (c) parse and merge outputs according to the task's output shape specification, (d) return the merged result. On platforms without background dispatch (see PG1), use a sequential or platform-equivalent foreground pattern.

### CLI Dispatch Don'ts (CDRDN1–CDRDN5)

CDRDN1. Do not use CLI dispatch for trivial tasks where the `Agent` tool is available. The `Agent` tool provides better context inheritance, structured tool use, and lower overhead. CLI dispatch is for the cases in CDR1–CDR3.

CDRDN2. Do not pass mutable references through CLI dispatch. The read-only invariant (CDR8–CDR11) forbids any CLI invocation that could modify state. A dispatch prompt that says "edit the file and save it" violates CDR8.

CDRDN3. Do not dispatch a CLI tool without a scope-limiting prompt. Every CLI dispatch **must** include explicit scope constraints: what to analyze, what output shape to return, and what the CLI tool **must not** do. An unconstrained prompt risks unbounded output and enforcement bypass.

CDRDN4. Do not treat CLI dispatch output as inherently trustworthy. Output **must** be validated against the expected output shape before being forwarded or acted upon. Malformed or overlong output from a CLI tool is an error condition.

CDRDN5. Do not use CLI dispatch expecting it to inherit conversation context automatically. CLI backends are stateless and do not inherit conversation context (as defined in `## Definitions`); all required context **must** be hand-fed in the dispatch prompt (per CDRC2). CLI dispatch does not circumvent context isolation — it enforces it.

### CLI Dispatch Constraints (CDRC1–CDRC3)

CDRC1. CLI dispatch invocations **must** be stateless. The CLI tool **must not** rely on or produce session state, persistent cache, or inter-invocation side channels.

CDRC2. The dispatch prompt passed to a CLI backend **must** be self-contained: it **must** include all context required for the CLI tool to produce a correct result without access to the calling agent's conversation history.

CDRC3. CLI dispatch output **must** be captured to a variable or file before being parsed or forwarded. Streaming output directly into downstream logic without capture is prohibited.

### CLI Dispatch Examples

The following examples are normative illustrations of correct CLI dispatch invocation patterns.

**Example — `claude -p` dispatch (foreground, read-only analysis):**

```bash
# Invoke Claude Code CLI in print mode with a scope-limiting prompt.
# Permission policy: no Edit/Write tools available in this shell context.
claude -p "Analyze the following diff for security issues. Return a markdown list of findings. Do not modify any files.\n\n$(git diff HEAD~1 HEAD -- src/auth.ts)"
```

**Example — `claude -p` dispatch (parallel, background via `run_in_background`):**

```text
# Invoke two independent CLI calls in background (Claude Code: run_in_background: true on Bash tool).
# Each call is stateless; outputs are captured to separate files before aggregation.
# Call 1 (background): analyze auth module
#   Bash(command: "claude -p '...' > /tmp/result_auth.txt", run_in_background: true)
# Call 2 (background): analyze session module
#   Bash(command: "claude -p '...' > /tmp/result_session.txt", run_in_background: true)
# After both complete, read captured outputs (per CDRC3) and merge before returning.
#   Bash(command: "cat /tmp/result_auth.txt /tmp/result_session.txt")
```

**Example — `copilot` dispatch (via copilot-cli skill):**

```bash
# Route through the copilot-cli skill for flag assembly and output parsing.
# See: copilot-cli skill for operation routing (review / ask / explain).
# Direct invocation example for reference only — sub-skill owns actual invocation.
gh copilot ask "What does the authenticate() function in src/auth.ts do?"
```

Cross-reference: `copilot-cli` skill for operation routing, flag assembly, and output parsing rules.

## Section Classification

| Section | Type | Normative? |
| --- | --- | --- |
| Purpose | Context | No |
| Scope | Boundary | Yes |
| Definitions | Reference | Yes |
| Requirements (R1–R16 incl. R3a) | Normative spec | Yes |
| Constraints (C1–C7) | Normative spec | Yes |
| Behavior (B1–B5) | Normative spec | Yes |
| Defaults and Assumptions (D1–D4) | Normative spec | Yes |
| Error Handling (E1–E4) | Normative spec | Yes |
| Precedence Rules (P1–P4) | Normative spec | Yes |
| Don'ts (DN1–DN12) | Normative spec | Yes |
| Platform Gotchas (PG1–PG4) | Normative deviation | Yes |
| CLI Dispatch Mode (CDR1–CDR17, CDRC1–CDRC3, CDRDN1–CDRDN5) | Normative spec | Yes |
| CLI Dispatch Examples | Normative illustration | Yes |
