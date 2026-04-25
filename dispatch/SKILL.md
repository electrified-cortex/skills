---
name: dispatch
description: Decision tree for whether, how, and at what model tier to dispatch sub-agents.
---

# Dispatch

Read once. Terms (`fast-cheap`, `standard`, `deep`, foreground/background, F1–F5) assumed known by any caller. Inline skills don't reference this skill.

## Decision Tree

Apply in order. Stop at first match.

| Condition | Outcome |
| --- | --- |
| Speculative, blocked, or low priority | Defer (record draft, move on) |
| Requires host conversation context | Inline |
| Holds exclusive resource host already owns | Inline (F1) |
| Completable in <~3 host turns | Inline (F2) |
| Result needed this turn, blocking unacceptable | Defer or batch |
| Result needed this turn, blocking acceptable | Dispatch foreground |
| Result can arrive later | Dispatch background |

Default: inline. Dispatch is the exception.

## Model Tier

| Tier | Use for | Risk |
| --- | --- | --- |
| `fast-cheap` | Shallow/mechanical, true zero-context work | Shallow output → re-dispatch higher |
| `standard` | Moderate reasoning. Most common explicit override | — |
| `deep` | Critical-path, max reasoning | Rarely correct as override; consider inline |

Default tier: host's own.

`fast-cheap` pre-pass: appropriate only when work is genuinely zero-scope (mechanical pattern match, format check, extraction). Not appropriate when sub-agent needs judgment, prior context, or chained reasoning.

### Model class mapping (as of 2026-04-24)

Use class names in all skill artifacts. Resolve to a concrete model ID only at dispatch time.

| Class | Concrete model ID |
| --- | --- |
| `fast-cheap` / haiku-class | `claude-haiku-4-5-20251001` |
| `standard` / sonnet-class | `claude-sonnet-4-6` |
| `deep` / opus-class | `claude-opus-4-6`+ |

When Anthropic releases a new model in any class, update this table and refresh the date.

## Subagent Type

Project context (CLAUDE.md, memory index) inherits automatically. Don't hand-feed it.
Conversation context does NOT inherit. Hand-feed everything else the agent needs.

Select narrowest type covering required tool scope. Don't default to maximally permissive.
Type names evolve between releases — treat as examples, verify from current platform docs.

## Well-Formed Prompt

Required:

1. Goal (one sentence, no implicit context)
2. Hand-fed context (prior decisions, operator preferences, file paths absolute, term definitions, prior findings)
3. Output shape (verdict, file path, list format)
4. Scope/length constraints

Checklist:

- [ ] Stranger reading cold knows exactly what to do?
- [ ] Every needed file referenced by absolute path?
- [ ] Every constraint stated?
- [ ] Output described?

Any "no" → prompt not ready.

## Footguns

| Footgun | Mitigation |
| --- | --- |
| F1 — Host-impersonation on shared exclusive resource | Prompt forbids sub-agent from initiating sessions/auth/touching named resource. If work needs it, inline. |
| F2 — Dispatch for trivial work | Apply Q4 — <3 host turns → inline. |
| F3 — Tight-loop micro-dispatches | Aggregate into one dispatch with structured result. If impossible, reconsider dispatch. |
| F4 — Hook-denial escape via dispatch | Never. Treat denial as authoritative; request permission, change approach, or escalate. |
| F5 — Thin-prompt context assumption | Every prompt satisfies Well-Formed Prompt. Hand-feed all context agent can't inherit. |

## When Inline Cost Is Unaffordable

(a) Dispatch with fully hand-fed context prompt, or (b) defer. Don't dispatch incorrectly because inline is expensive.

## Dispatch Install

Requires a companion agent file in your project's agent directory. See `installation.md`.

## Platform Gotchas

**VS Code (GitHub Copilot):** Use `runSubagent` with `agentName: "Dispatch"`. It is blocking — no background dispatch.

## Supplemental

For empirical evidence (context-inheritance tests), anti-pattern walkthroughs, error-handling guidance, and precedence notes: see `supplemental.md` in this skill folder.

## Related

- Agent files: `dispatch/agents/` — ready-to-install Dispatch agent definitions for Claude Code CLI and VS Code.
- Installation: `installation.md` — where to put agent files, VS Code invocation, and what to do if not installed.
