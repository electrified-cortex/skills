# dispatch spec

## Purpose

Define the invocation contract for spawning a zero-context sub-agent.

This skill governs three artifacts:

- `spec.md` (this file): the normative specification. Audited but never loaded at runtime.
- `uncompressed.md`: the human-readable source for the runtime card. Edited by `--fix` mode.
- `SKILL.md`: the compiled runtime card (compressed from `uncompressed.md`). Loaded by every caller.

## Scope

Applies to any calling agent with access to a sub-agent dispatch primitive. Primitives in scope:

- **Claude Code `Agent` tool** — dispatch via the `Agent` tool with a `subagent_type` parameter.
- **VS Code / Copilot `runSubagent`** — dispatch via the `runSubagent` tool with an `agentName` parameter.

Covers: input parameters, model derivation, runtime invocation, fallback, and return passthrough.

Does NOT cover:

- Transport internals of the dispatch primitives.
- How to design a custom subagent type or write its agent file.
- How to author a skill or write a spec (`skill-writing`, `spec-writing`).
- Inter-agent communication via Telegram, MCP, or other channels.
- Non-dispatch delegation patterns (writing tasks to a queue for other agents to claim).
- Workflow patterns for consuming skills that call dispatch (result checks, iteration loops, hash-record integration — see the consuming skill's own spec and `supplemental.md §Hash-Record Integration`).

This skill is a **runtime** skill, not an authoring skill. Cross-references are one-way: authoring skills reference `dispatch`; `dispatch` does not reference them back.

## Definitions

**prompt**: verbatim prompt sent to the sub-agent.

**description**: short run label shown by the host.

**tier**: model cost tier — `fast-cheap`, `standard`, or `deep`.

**model-override**: optional concrete model string or alias; bypasses tier lookup when set.

**concrete-model**: the resolved model string passed to the dispatch primitive.

**fast-cheap**: cost-optimized tier (Haiku-class).

**standard**: capable default tier (Sonnet-class).

**deep**: highest-reasoning tier (Opus-class).

**fallback**: behavior when the named Dispatch agent type is unavailable.

**passthrough**: returning the sub-agent's output verbatim without modification.

**Calling agent** (or **host**): the agent currently executing that is considering dispatch.

**Dispatched agent** (or **sub-agent**): the agent spawned by the host via the dispatch primitive.

## Requirements

### Input

R1. The runtime card must define four inputs: `prompt`, `description`, `tier`, `model-override`.

- `prompt` — verbatim prompt sent to the sub-agent.
- `description` — short run label.
- `tier` — `fast-cheap` | `standard` (default) | `deep`.
- `model-override` (optional) — concrete model string or alias; bypasses tier lookup.

### Derived

R2. The runtime card must define: `concrete-model` = `model-override` if set, else derived from `tier` via the tier table.

### Process

R3. The runtime card must include the process note: if `prompt` instructs the sub-agent to read a file, do not read that file inline — the sub-agent does.

### Runtime Sections

R4. The runtime card must contain two separate runtime sections: **Claude Code** and **VS Code / Copilot**. Each section must:

- Present a three-row tier-to-model alias table (rows: `fast-cheap`, `standard`, `deep`; columns: Tier, Class, `model` value).
- Show the invocation syntax for that platform.

R5. Claude Code model aliases must be:

| Tier | Class | `model` value |
| ---- | ----- | ------------- |
| `fast-cheap` | haiku-class | `haiku` |
| `standard` | sonnet-class | `sonnet` |
| `deep` | opus-class | `opus` |

R6. VS Code / Copilot model aliases must use full model names:

| Tier | Class | `model` value |
| ---- | ----- | ------------- |
| `fast-cheap` | haiku-class | `Claude Haiku 4.5` |
| `standard` | sonnet-class | `Claude Sonnet 4.6` |
| `deep` | opus-class | `Claude Opus 4.6` |

Must include a note to update the table when Anthropic releases a new model.

### Fallback

R7. The runtime card must define fallback: when the "Dispatch" agent type is unavailable, omit `subagent_type` / `agentName` and continue. Behavior is identical to when the agent is installed; the agent adds context isolation and performance. Notify the host after completion.

### Return

R8. The runtime card must instruct the caller to return the sub-agent's output verbatim (passthrough).

### Boundary

R9. Cross-references are one-way. `dispatch` is referenced by authoring skills and callers; `dispatch` itself does not reference authoring skills.

R10. Use role-agnostic language. Project-internal role names must not appear. Use: "host," "dispatched agent," "calling agent."

## Constraints

<!-- C3 and C6 were intentionally removed during trim. Numbering gaps are not missing content. -->

C1. `SKILL.md` (compiled runtime) must not exceed approximately 3000 bytes. Skim-friendly under load is the priority.

C2. `uncompressed.md` is the source the auditor edits in `--fix` mode. It must be a tight reference card, not exposition.

C4. The runtime card must not enumerate the current Claude Code `subagent_type` list as if stable. Names appear as examples only and must signal evolution.

C5. The runtime card must not embed project-internal procedural detail.

C7. The runtime card must remain answerable end-to-end without reading any supplemental file.

## Defaults and Assumptions

D1. Default for "is this work worth dispatching at all" is **inline**. Dispatch is the exception.

D2. Default model for a dispatch where the host has not specified one is the host's own model.

D3. Default for foreground vs background when the host is in a long-poll loop or has any responsiveness obligation is **background**.

## Precedence Rules

P1. Correctness over throughput.

P2. Empirical fact over expectation.

P3. Consuming skill's domain procedure governs over this skill's general guidance.

## Don'ts

<!-- DN8 was intentionally removed during trim. DN9 follows DN7 directly — this is correct. -->

DN1. Do not enumerate every Claude Code `subagent_type` with a stability guarantee.

DN2. Do not include a tutorial in the runtime card.

DN3. Do not include implementation detail of how Claude Code transports a dispatch.

DN4. Do not include role-specific language.

DN5. Do not embed memory references or host-private artifacts in normative text.

DN6. Do not introduce a default subagent type, default model, or default foreground/background mode beyond D1–D3.

DN7. Do not duplicate content from authoring skills. Reference and stop. (And do not reference them from this skill — see R9.)

DN9. Do not include claims about subagent behavior without an empirical anchor or "unverified" label.

DN10. Do not extend the skill scope to non-dispatch delegation patterns.

DN11. Do not move runtime instructions into `supplemental.md`. Supplemental is for nuance only; the runtime card must stand alone.

DN12. Do not move spec rationale into `supplemental.md`. Spec rationale lives in the spec.

DN13. DO NOT DISPATCH SKILLS — read them. The skill itself tells you when (and how) to dispatch. Skills are content the calling agent loads and applies inline; only `<prompt>` is dispatched. Treating a skill name or path as if it were a runnable unit (e.g. "dispatch the `markdown-hygiene` skill") is invalid.

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
| Requirements (R1–R10) | Normative spec | Yes |
| Constraints (C1–C7) | Normative spec | Yes |
| Defaults and Assumptions (D1–D3) | Normative spec | Yes |
| Precedence Rules (P1–P3) | Normative spec | Yes |
| Don'ts (DN1–DN12) | Normative spec | Yes |
| Platform Gotchas (PG1–PG4) | Normative deviation | Yes |
| CLI Dispatch Mode (CDR1–CDR17, CDRC1–CDRC3, CDRDN1–CDRDN5) | Normative spec | Yes |
| CLI Dispatch Examples | Normative illustration | Yes |
