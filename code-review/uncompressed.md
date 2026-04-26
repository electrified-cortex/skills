---
name: code-review
description: Tiered code review on a change set — consumer of the swarm skill. Dispatches code-domain personalities via swarm, caches reviews per content hash, graduated L1/L2/L3 levels, permanent review files with sign-off lifecycle, fractal .code-reviews/ storage.
---

# Code Review

Code-review is a consumer of the `swarm` skill. It never dispatches personalities
directly — swarm handles multi-personality dispatch, arbitration, and synthesis.
Code-review owns the layers on top: hash-based caching, graduated levels (L1/L2/L3),
conventional-comments findings format, permanent review files, fractal storage, and
Copilot ordering.

**Do NOT run code review inline.** Inline execution produces shallow, inconsistent
results and allows caller context to bleed into review judgment.

Use a Dispatch agent (zero context): "Read and follow `instructions.txt` (in this
directory). Input: `change_set=<form> level=<L1|L2|L3> [focus=<csv>] [context_pointer=<path>] [disable_inline_personality_generation=<bool>]`"

## Inputs

| Input | Required | Description |
|---|---|---|
| `change_set` | required | Inline diff text, list of absolute file paths, or git ref/range. Refs require shell access in the dispatched agent. |
| `level` | required | `L1`, `L2`, or `L3`. Governs model class and depth. Defaults to L1 if omitted. |
| `focus` | optional | Comma-separated focus areas (e.g. `security,concurrency`). Reorders priority; does not suppress depth. |
| `context_pointer` | optional | Path to CLAUDE.md, README, or style guide for local conventions. |
| `disable_inline_personality_generation` | optional | Default `false`. Set `true` to suppress swarm's inline Custom Specialist generation. |

## Level Tiers

| Level | Model class | When |
|---|---|---|
| L1 | haiku-class | Default. All files in change set. Fast, distributed. |
| L2 | sonnet-class | Only after L1 fully resolved. Only files flagged L2-worthy. |
| L3 | opus-class | Rare. Only critical files after L2 resolved. One-shot, stamped. |

Tier substitution is prohibited. Do not promote to the next level until all findings
at the current level are `FIXED`, `WONT_FIX`, or `WONTNEEDED`.

## Minimum Personality Set

`additional_personalities` is assembled in tiers for every invocation:

**Absolute minimum (always):**
- Code Reviewer (sonnet-class) — always included. Caller-supplied generic code review personality.
- Devil's Advocate is always dispatched by swarm (built-in, required: true). Don't add it; swarm guarantees it.

**Preferred (best-effort, availability-gated):**
- Copilot Reviewer (gpt-class via copilot-cli) — included when `copilot --version` passes. Omitted silently when unavailable. Cross-model diversity; absence is acceptable.

**Conditional (per problem):**
- Language presets by detected extension.
- Domain personalities (Security, Architect, etc.) when triggers match.

## Swarm Consumer Contract

For each file pass, code-review calls `swarm` with:

- `problem`: the file or change set under review.
- `additional_personalities`: assembled per Minimum Personality Set above. Always
  includes Code Reviewer (sonnet-class). Includes Copilot Reviewer only when CLI
  probe passes. Supplemental core set: Code Quality Critic, Test Reviewer, Architect,
  Operational Readiness, Performance Reviewer. Language presets appended by extension:
    - `.ps1 / .psm1 / .psd1` → PowerShell-reviewer
    - `.sh / .bash` → Bash-reviewer
    - `.ts / .tsx` → TypeScript-reviewer
- `disable_inline_personality_generation`: pass through caller value (default `false`).

Swarm's Devil's Advocate and any other `required: true` personalities are always
dispatched by swarm alongside the code-domain set. Code-review doesn't manage
swarm's internal pass structure (smoke/substantive) — that is orthogonal.

Code-review translates swarm's synthesis into conventional-comments format before
writing to the review file.

## Hash-Based Caching

Before dispatching any review:

1. Compute content hash for every file:
   - Tracked + unmodified: record git blob hash as provenance; still compute SHA-256 for cache key.
   - Untracked or modified: compute SHA-256.
   - SHA-256 is always the cache key regardless of hash source.
2. Build manifest: `{ file_path, content_hash (SHA-256), hash_source }` per file.
3. Compute manifest hash: SHA-256 over the sorted-by-path list of file SHA-256 hashes.
4. Check `.code-reviews/files/<hash-6>-L<n>.md` per file per level.
5. Check `.code-reviews/manifests/<manifest-hash>.md` for composite reviews.
6. Cache hit → reuse; skip swarm for that file. Cache miss → dispatch swarm; write new review file.

A file whose hash changed is a cache miss at all levels for that file. Unchanged
siblings continue to use cache.

## Conventional Comments Format

Every finding must use conventional-comments format:

```
type: <question|nit|issue|blocking|non-blocking>
file: <path>:<line-or-range>
title: <short summary>
body: <evidence + reasoning + suggested fix>
status: OPEN
```

Types:

- `question` — needs clarification; not necessarily wrong.
- `nit` — minor preference; non-blocking.
- `issue` — substantive concern; should be addressed.
- `blocking` — must be fixed before merge / sign-off.
- `non-blocking` — fix when possible; won't gate.

Every finding must cite specific evidence: snippet, line reference, or direct quote.
Findings without evidence are prohibited.

## Permanent Review Files and Sign-Off Lifecycle

Review files are permanent records under `.code-reviews/`. They are updated,
never discarded.

File naming: `.code-reviews/files/<hash-6>-L<n>.md`
Example: `a3f2b9-L1.md`, `a3f2b9-L2.md`

Each review file contains:

1. Metadata: reviewer model class, personalities used, level, file-version SHA-256 (full), date.
2. Findings list in conventional-comments format, each with current status.
3. Sign-off state: `OPEN` or `SIGNED_OFF`.
4. Host-agent annotations: rationale for `WONT_FIX`, risk acceptances, deferred notes.

Finding status lifecycle:

- `OPEN` — not yet addressed.
- `FIXED <commit-ref>` — addressed in a named commit.
- `WONT_FIX <annotation>` — deliberately deferred; annotation required.
- `WONTNEEDED` — no longer applicable (e.g., code path removed).

When all findings in a review file are non-`OPEN`, sign-off state transitions to
`SIGNED_OFF`. If the file's SHA-256 changes, a new review file is created for the
new hash; the prior file is retained as historical record.

## Fractal Review Tree (Storage Layout)

```
.code-reviews/
├── files/<hash-6>-L<n>.md          # leaf — review of one file at one level
├── groups/<hash>.md                # composite — N files reviewed as a group
├── folders/<hash>.md               # composite — folder/feature review
├── manifests/<manifest-hash>.md    # manifest composite (SHA-256 of sorted child hashes)
├── repo/<repo-hash>.md             # top — whole-repo review at a point in time
└── log.md                          # chronological index: hash, scope, date, verdict, sign-off state
```

Composite hash = SHA-256 of sorted-by-path child SHA-256 hashes. Same children
→ same hash → cache hit. A changed child invalidates only the composite reviews
that include it; other composites are unaffected.

## Copilot Ordering

On PR workflows: let Copilot run on the PR first. Then invoke code-review.

Code-review adds the swarm review on top — augmenting, not competing. The Copilot
Reviewer personality is included in `additional_personalities` when the Copilot CLI
backend is available. If unavailable, swarm's availability gate drops it silently
and code-review proceeds without it.

## Procedure (Calling Agent Orchestrates)

1. Resolve `change_set` to files and compute content hashes.
2. Build manifest; compute manifest hash.
3. Cache lookup — skip swarm for any file with an L-matching cache hit.
4. For cache-miss files: call `swarm` with `problem` + `additional_personalities` (level-appropriate) + optional flags.
5. Translate swarm synthesis to conventional-comments findings.
6. Write review files to `.code-reviews/files/<hash-6>-L<n>.md`; append to `log.md`.
7. Return aggregated result to calling agent.
8. After L1 resolved: decide which files warrant L2 (heuristic or operator flag). Repeat steps 1–7 for L2 with only those files. Repeat for L3 if needed.

Empty change set: return `overall_verdict: clean`; no swarm invocations.

## Aggregated Output

Returned to the calling agent after all passes for a level:

| Field | Description |
|---|---|
| `files_reviewed` | `[{ file_path, hash, level, verdict, cache_hit }]` |
| `manifest_hash` | SHA-256 of sorted child hashes for this review set |
| `findings_by_file` | Map: file hash → conventional-comments findings list |
| `sign_off_states` | Map: file hash → `{ level, state: OPEN|SIGNED_OFF }` |
| `overall_verdict` | `clean`, `findings`, or `error` |

## Calling Agent Rules

- Do not promote to the next level until all findings at the current level are resolved.
- Do not bypass the cache. Cache hits are valid; forcing re-review on unchanged files wastes tokens.
- Do not modify the change set during a pass. Edits happen between passes only.
- Record or reference review output so downstream consumers can verify the review occurred.
- When marking a finding `WONT_FIX`, supply an explanation. Unannotated `WONT_FIX` is prohibited.

## Iteration Safety

Do not re-review unchanged files. Content hash match is the skip gate.
See `../iteration-safety/SKILL.md`.

## Error Handling

| Condition | Behavior |
|---|---|
| Change set cannot be resolved | Return `overall_verdict: error` with reason. No swarm. |
| Swarm returns error for a file | Record error in review file; no findings for that file. Retry is caller's discretion. |
| Hash computation fails | Treat as cache miss; proceed. |
| `.code-reviews/` missing | Create directory before writing. |
| Copilot availability probe fails | Drop Copilot Reviewer from `additional_personalities`; proceed. |

## Don'ts

- Don't dispatch personalities directly — that's swarm's job.
- Don't reinvent multi-personality dispatch or aggregation logic.
- Don't promote to L2 until all L1 findings are resolved.
- Don't use git blob hash as the primary cache key — SHA-256 is always the key.
- Don't let review agents fix code — reporting and fixing are separate concerns.
- Don't let review agents commit, push, stage, or mutate any state.
- Don't produce findings without evidence citations.
- Don't use bare model names — use haiku-class, sonnet-class, opus-class.
- Don't reference swarm internal files by path (R-FM-11) — refer to the `swarm` skill by name only.
- Don't expire or delete cache entries when content is unchanged.
- Don't run swarm when all files have cache hits at the requested level.
- Don't conflate code-review levels with swarm's internal pass structure (smoke/substantive). They are orthogonal.

## Footguns

F1. **Computing SHA-256 wrong** — always hash the file's raw byte content; never the path or metadata. Mitigation: use `git hash-object --stdin` or equivalent.

F2. **Using git blob hash as cache key** — git blob hashes differ from SHA-256; using them breaks cache identity across untracked/tracked transitions. Cache key is always SHA-256.

F3. **Promoting to L2 before L1 resolves** — burns expensive tokens on findings that L1 would have caught. Gate strictly.

F4. **Dispatching personalities directly** — bypasses swarm's arbitration and synthesis; produces raw multi-voice output that code-review can't use. Always call swarm.

F5. **Copilot Reviewer in additional_personalities when unavailable** — swarm drops it via availability gate, but explicitly including it when the CLI is known-unavailable adds noise to dropped-personalities synthesis output. Probe first.

F6. **Treating composite hash as a simple concatenation** — SHA-256 of sorted child hashes, not path+hash concatenation. Sort is by file path lexicographically.

F7. **Forgetting Devil's Advocate** — swarm always dispatches it (required: true) regardless of `additional_personalities`. No action needed; just don't expect to suppress it.

## When to Use

Reviewing a change set of executable or compilable code: source files, build scripts,
CI configuration, infrastructure-as-code manifests.

For non-code artifacts (specs, skills, docs), use `spec-auditing` or `skill-auditing` —
they use a different tier policy.

## Related

`swarm`, `spec-auditing`, `skill-auditing`, `dispatch`, `compression`, `iteration-safety`
