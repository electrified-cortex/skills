---
name: code-review
description: Tiered code review on a change set — consumer of swarm. Dispatches code-domain personalities via swarm with hash-based caching, graduated L1/L2/L3 levels, conventional-comments findings, permanent .code-reviews/ review files with sign-off lifecycle.
---

Code-review delegates all personality dispatch to `swarm`. Never dispatch personalities directly; never run inline.

Use Dispatch agent (zero context): "Read and follow `instructions.txt` (in this directory). Input: `change_set=<form> level=<L1|L2|L3> [focus=<csv>] [context_pointer=<path>] [disable_inline_personality_generation=<bool>]`"

## Levels

| Level | Model class | Scope |
|---|---|---|
| L1 | haiku-class | All files. Default. |
| L2 | sonnet-class | L2-worthy files only — after L1 resolved. |
| L3 | opus-class | Critical files only — after L2 resolved. One-shot, stamped. |

Tier substitution prohibited. Don't promote until all findings at current level are `FIXED`, `WONT_FIX`, or `WONTNEEDED`.

## Minimum Personality Set

Always in `additional_personalities`:
- Code Reviewer (sonnet-class) — always. Caller-supplied.
- Devil's Advocate — swarm dispatches it (built-in, B6). Don't add it.

Preferred (availability-gated):
- Copilot Reviewer (gpt-class via copilot-cli) — include when `copilot --version` passes. Omit silently if unavailable.

Conditional: language presets by extension + domain personalities when triggered.

## Swarm Call

Per file / pass, call `swarm` with:

- `problem`: file or change set under review.
- `additional_personalities`: Code Reviewer (always) + Code Quality Critic, Test Reviewer, Architect, Operational Readiness, Performance Reviewer + Copilot Reviewer (when available) + language presets (`.ps1/.psm1/.psd1` → PowerShell-reviewer; `.sh/.bash` → Bash-reviewer; `.ts/.tsx` → TypeScript-reviewer).
- `disable_inline_personality_generation`: pass through (default `false`).

Translate swarm synthesis → conventional-comments findings before filing.

## Caching

1. SHA-256 every file (cache key). Git blob hash = provenance only, never cache key.
2. Manifest hash = SHA-256 of sorted-by-path file hashes.
3. Hit → `.code-reviews/files/<hash-6>-L<n>.md` exists → reuse; skip swarm.
4. All cache hits → return immediately; no swarm.

## Conventional Comments Format

```
type: <question|nit|issue|blocking|non-blocking>
file: <path>:<line-or-range>
title: <short summary>
body: <evidence + reasoning + suggested fix>
status: OPEN
```

Every finding requires evidence (snippet/line/quote). No evidence → discard.

## Storage Layout

```
.code-reviews/
├── files/<hash-6>-L<n>.md       # leaf review, one file one level
├── groups/<hash>.md             # composite — N files
├── folders/<hash>.md            # composite — folder/feature
├── manifests/<manifest-hash>.md # hash-of-hashes composite
├── repo/<repo-hash>.md          # whole-repo review
└── log.md                       # chronological index
```

Composite hash = SHA-256 of sorted child hashes (by file path).

## Sign-Off Lifecycle

Finding statuses: `OPEN` → `FIXED <commit>` / `WONT_FIX <annotation>` / `WONTNEEDED`.
`WONT_FIX` requires annotation. Review file sign-off state: `OPEN` or `SIGNED_OFF`. Re-opens on hash change.

## Copilot Ordering

On PRs: Copilot first, then code-review swarm review on top. Copilot Reviewer personality included only when Copilot CLI availability probe passes.

## Calling Agent Rules

- Don't promote level until current level fully resolved.
- Don't bypass cache — cache hits are valid reuse.
- Don't modify change set during a pass.
- Record sign-off so downstream can verify.
- `WONT_FIX` requires annotation.

## Iteration Safety

Don't re-review unchanged files — SHA-256 match = skip.
See `../iteration-safety/SKILL.md`.

## Don'ts

Don't dispatch personalities directly. Don't reinvent dispatch/aggregation. Don't promote early. Don't use git blob hash as cache key. Don't let agents fix or mutate. Don't produce findings without evidence. Don't use bare model names. Don't reference swarm internals by path (R-FM-11) — use skill name only. Don't expire cache on unchanged content. Don't conflate code-review levels with swarm's internal passes.

Related: `swarm`, `spec-auditing`, `skill-auditing`, `dispatch`, `iteration-safety`
