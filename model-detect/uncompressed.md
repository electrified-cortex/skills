---
name: model-detect
description: Reliably determine own model identity when asked. Priority-ordered detection across config file, system prompt, environment variables, operator instructions, and self-report. Prevents hallucinated version numbers. Triggers - what model are you, what is your model, model identity, detect model, identify model, model version.
---

# Model Detect

## Detection Procedure

Work down this list. **Stop at the first signal found.** Do not blend signals across
levels.

---

### 1. Config File Frontmatter (high confidence)

Check for a `model:` field in your own agent config file.

Common locations:

- `.claude/agents/<your-name>.md` (Claude Code)
- `.agents/agents/<your-name>.md` (custom harness)
- `.copilot/agents/<your-name>.md` or runtime equivalent

If `model:` is present, use that value. **Stop.**

> Note for Claude Code: generic aliases like `model: sonnet` and `model: opus` in
> `.claude/agents/*.md` frontmatter may not resolve correctly depending on runtime version.
> Prefer explicit API identifiers (e.g., `claude-sonnet-4-6`). If the config contains
> a generic alias, report the alias and note the pinned version may differ.

---

### 2. System Prompt Injection (high confidence)

Check if the runtime injected a model identifier into your system prompt or instructions.

Look for patterns such as:

- "You are running as [model]"
- "Model: [identifier]"
- "This instance is [model]"
- Any line that explicitly names or declares a model version

If found, use that value. **Stop.**

---

### 3. Environment Variable (high confidence)

Check for model-identifying environment variables. Common names:

- `ANTHROPIC_MODEL`
- `OPENAI_MODEL_NAME`
- `MODEL_NAME`
- `CLAUDE_MODEL`
- Runtime-specific equivalents

If a value is present, use it. **Stop.**

---

### 4. Operator-Declared Identity (medium confidence)

Scan instruction files in scope for an explicit model declaration. Common locations:

- `CLAUDE.md`
- `copilot-instructions.md`
- `.github/copilot-instructions.md`
- Agent instruction files loaded at session start

Look for declarations like:

- "Model: claude-sonnet-4-6"
- "You are Claude Sonnet 4.6"
- "This instance runs [model]"
- "All Claude instances: [version]"

If found, use that value. Report with **medium confidence**.

---

### 5. Self-Report with Hedge (low confidence)

No external signal available. Use training-time knowledge as a last resort.

**Hedging is mandatory at this level. No exceptions.**

Acceptable response forms:

- "Based on my training, I believe I am [model], but I cannot verify this without an
  external signal."
- "I don't have a reliable external signal to confirm — my self-knowledge suggests I am
  [model]."

Unacceptable at this level:

- "I am [model]." — unhedged, states certainty that does not exist.
- "I am the latest version of [vendor]." — non-specific and unhedged.

---

## Output Format

**Technical contexts** — include the detection source:

- "I am Claude Sonnet 4.6 (source: config file)."
- "I am GPT-4o (source: system prompt)."
- "I believe I am Claude Haiku 4.5, but I cannot verify — no external signal found
  (source: self-report)."

**Conversational contexts** — source may be omitted if it would be awkward, but hedging
rules apply regardless.

## Alias Handling

Some runtimes specify aliases rather than pinned version IDs: `sonnet`, `opus`,
`gpt-4o-latest`. When the signal is an alias:

- Report the alias as-is.
- Note that the underlying pinned version may differ.
- Do NOT expand an alias to a specific version identifier unless a second, confirming
  signal provides the mapping.

**Example:**

> "My config specifies `sonnet` — the exact pinned version may vary by runtime."

## Rules

- Stop at the first signal. Never blend sources from multiple detection levels.
- Never fabricate or guess a version number not supported by a signal.
- Low confidence always means hedged response. No exceptions.
- Aliases are reported as aliases. No expansion without a confirming signal.
