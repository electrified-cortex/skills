# dispatch-setup spec

## Purpose

Define the requirements for correctly configuring the dispatch skill in VS Code (GitHub Copilot) and Cursor. Covers agent file placement, frontmatter requirements, model name format, and IDE-specific constraints.

This skill governs three artifacts:

- `spec.md` (this file): normative specification. Audited but not loaded at runtime.
- `uncompressed.md`: human-readable reference card. Edited by `--fix` mode.
- `SKILL.md`: compiled runtime card. Loaded by callers.

## Scope

Applies to any operator or agent configuring dispatch in VS Code or Cursor. Does NOT cover Claude Code CLI setup (no known problems there). Does NOT cover the runtime dispatch decision tree (`dispatch/SKILL.md`). Does NOT cover sub-agent prompt authoring.

## Definitions

**Host agent**: the model running the active conversation. Reads the `.github/agents/` directory and exposes discovered agents.

**Sub-agent**: an agent dispatched via `runSubagent`. Must be discoverable in the same `.github/agents/` directory.

**Agent file**: an `.md` file in the agent directory with YAML frontmatter that defines `name`, `description`, `model`, and `tools`.

**Model name**: the human-readable string passed as the `model` field. Must use spaces, not slug form.

**Slug**: the API identifier form of a model name (e.g., `claude-sonnet-4-6`). Not valid in VS Code agent file frontmatter.

## Requirements

### Agent File Placement

R1. The dispatch agent file must be placed at `.github/agents/dispatch.agent.md` relative to the project root for VS Code to discover it. `.claude/agents/` is the Claude Code CLI path and is NOT read by VS Code.

R2. Sub-agent files must also reside in `.github/agents/` to be discoverable by VS Code. A sub-agent at `.claude/agents/` will not be found when dispatched via `runSubagent`.

R3. The canonical source file to copy for VS Code is `dispatch/agents/vscode-dispatch.agent.md`. Do not use `claude-dispatch.agent.md` for VS Code.

### Frontmatter Requirements

R4. Every agent file must contain a YAML frontmatter block with at minimum these fields: `name`, `description`, `model`, `tools`.

R5. The `name` field must be a string matching the name used in `runSubagent(agentName: ...)`. Canonical value: `Dispatch`.

R6. The `description` field must be a non-empty string.

R7. The `model` field must use the human-readable model name with spaces (e.g., `Claude Sonnet 4.6`). Using a slug (e.g., `claude-sonnet-4-6`) is not valid and causes silent fallback or an error.

R8. The `tools` field must list every tool the agent needs to complete its tasks. An absent or empty tools field prevents the sub-agent from acting on the required tool scope.

### Model Name Format

R9. Model names in VS Code agent frontmatter use the human-readable space-separated form. Canonical examples:

- `Claude Sonnet 4.6`
- `Claude Haiku 4.5 ` — for shallow/cheap tasks
- `Claude Opus 4.6 ` — for critical/deep tasks

R10. The `model` field in `runSubagent` at call time also accepts the human-readable form. Omitting it defaults to the Copilot default model (typically Sonnet). Do not pass a slug at the call site.

### Context Inheritance

R11. In VS Code, project context (CLAUDE.md, memory) is unverified as inherited. Treat all context as NOT inherited. Every dispatch prompt must hand-feed all required context explicitly.

R12. Conversation context does not inherit in VS Code (consistent with Claude Code behavior). Hand-feed everything the sub-agent needs.

### Dispatch Primitive

R13. The VS Code dispatch primitive is `runSubagent`, not the `Agent` tool. The agent name parameter is `agentName`. `subagent_type` does not apply.

R14. `runSubagent` is always synchronous (blocking). There is no background dispatch in VS Code. References to background dispatch in the parent dispatch skill do not apply in VS Code.

### Cursor

R15. Cursor is assumed to follow the same agent file placement and frontmatter requirements as VS Code. Treat Cursor as VS Code-similar unless verified otherwise. No confirmed differences are currently known; all Cursor guidance is labeled "assumed similar."

## Constraints

C1. The runtime card must not exceed approximately 3000 bytes.

C2. The spec must state WHAT must be present, not HOW to do it step by step. No tutorial prose.

C3. Role-agnostic language throughout. No project-internal role names.

C4. Model name examples must be concrete and current. Do not list slugs as valid.

C5. Cursor guidance must be clearly labeled as unverified where applicable.

## Don'ts

DN1. Do not describe Claude Code CLI setup (out of scope).

DN2. Do not include the parent dispatch decision tree or model tier content (covered by `dispatch/SKILL.md`).

DN3. Do not include the `runSubagent` call syntax as a tutorial — mention it normatively only.

DN4. Do not use project-internal role names (Curator, Worker, Overseer, etc.).

DN5. Do not claim Cursor behavior is verified unless it has been confirmed empirically.

DN6. Do not list `.claude/agents/` as valid for VS Code. It is not.

DN7. Do not omit the tools field guidance — a missing tools field is a common silent failure.
