# Code Review Specification

## Purpose

Define the procedure and output contract for tiered code review on a change
set. Code review surfaces issues, risks, and improvement opportunities in
executable/compilable code so the calling agent can act on them. This spec
governs procedure, tier policy, inputs, outputs, caching, findings format,
sign-off lifecycle, and the boundary between reviewing and fixing.

Code review is a **consumer of `swarm`**. It calls into swarm with code-domain
personalities and additional layers (caching, levels, conventional-comments
format, permanent review files, Copilot ordering, fractal storage) that swarm
does not provide. The multi-personality dispatch is swarm's job; code-review
must not reinvent it.

## Scope

Applies when a calling agent dispatches a code review on executable or
compilable code: source files, build scripts, CI configuration,
infrastructure-as-code manifests.

This is a **dispatch skill** — each review pass runs in an isolated, zero-context
agent. Inline execution is prohibited; it produces shallow, inconsistent results
and allows caller context to bleed into the review judgment.

Does not cover non-code artifacts (specs, skills, documents). Those are
governed by `spec-auditing` and `skill-auditing`, which use a different
tier policy. The difference is normative.

## Definitions

- **fast-cheap** (L1): a cost-optimized model tier (haiku-class) used for L1 review passes.
- **standard** (L2): a capable model tier (sonnet-class) used for L2 review passes.
- **deep** (L3): a high-capability model tier (opus-class) used for L3 review passes. Rare — critical files only.
- **swarm**: the `swarm` skill. Provides multi-personality parallel dispatch, arbitration, and synthesis. Code-review is a consumer.
- **Calling agent**: the agent that invokes code-review. Owns the change set, owns the decision about which findings to act on, owns any subsequent edits.
- **Change set**: the bounded set of code being reviewed. Must be identifiable by file paths, refs, or other stable references.
- **L1 pass**: a fast-cheap review pass dispatched via `swarm`. Surfaces surface-level findings (style, naming, obvious bugs, missing error handling, lint-grade defects). Run by haiku-class model. Uses code-domain personalities.
- **L2 pass**: a deeper review pass dispatched via `swarm`. Surfaces design, correctness, security, and architectural findings. Run by sonnet-class model. Uses code-domain personalities. Only for files flagged as L2-worthy after L1.
- **L3 pass**: a rare, high-depth review dispatched via `swarm`. Run by opus-class model. Used only for critical files after L2 findings resolved. One-shot, stamped sign-off.
- **Finding**: a single reported issue in conventional-comments format (see Conventional Comments Format).
- **Severity / type**: the conventional-comments type label for a finding: `question`, `nit`, `issue`, `blocking`, `non-blocking`.
- **Content hash**: SHA-256 of file content. The canonical cache key. For tracked+unmodified files, the git blob hash is recorded as provenance only; SHA-256 is always used as the cache key.
- **Manifest hash**: SHA-256 computed over the sorted list of content hashes for all files in the review set. Uniquely identifies the composition of a review set.
- **Cache hit**: a `.code-reviews/files/<hash>-L<n>.md` or `.code-reviews/manifests/<hash>.md` file already exists and contains a completed review at or above the requested level.
- **Review file**: the permanent record for a single file review, keyed by `<hash-6>-L<n>.md`. Carries findings and their lifecycle status.
- **Sign-off state**: the lifecycle state of a review file. Values: `OPEN` (findings outstanding), `SIGNED_OFF` (all findings resolved).
- **Finding status**: per-finding lifecycle. Values: `OPEN`, `FIXED <commit-ref>`, `WONT_FIX <annotation>`, `WONTNEEDED`.
- **Audit trail**: the historical record of every finding and annotation, preserved in the review file across iterations.
- **Copilot Reviewer**: a code-domain personality supplied by code-review to swarm via `additional_personalities`. Only included when the Copilot CLI backend is available (availability-gated). Order: let Copilot run first on PRs, then code-review adds the swarm review.

## Requirements

### Minimum Personality Set

Code-review must always pass the following minimum personality set to swarm via
`additional_personalities`:

**Absolute minimum (always included):**
- Code Reviewer (sonnet-class) — generic code review personality. Always present
  in `additional_personalities` for every code-review invocation. Caller-supplied.
- Devil's Advocate is always dispatched by swarm (built-in registry, required: true
  per swarm B6). Code-review does not add it; swarm guarantees it.

**Preferred personality (best-effort, availability-gated):**
- Copilot Reviewer (gpt-class via copilot-cli) — included in `additional_personalities`
  when the Copilot CLI is available. Omitted silently when unavailable. Cross-model
  diversity adds disagreement signal; absence is acceptable.

**Conditional additions (per problem):**
- Language presets appended by detected file extension (PowerShell-reviewer,
  Bash-reviewer, TypeScript-reviewer).
- Domain personalities (Security, Architect, etc.) when triggers match.

### Swarm Consumer Contract

Code-review calls the `swarm` skill for each review pass. The swarm call
must supply:

1. `problem`: the file or change set under review. Form: inline diff, absolute
   file paths, or git ref/range the dispatched agent can resolve.
2. `additional_personalities`: assembled per the Minimum Personality Set above.
   Always includes Code Reviewer (sonnet-class). Includes Copilot Reviewer only
   when the Copilot CLI availability probe passes. Language-specific presets
   appended based on detected extensions. Core supplemental set: Code Quality
   Critic, Test Reviewer, Architect, Operational Readiness, Performance Reviewer.
   Code-review owns these personalities and supplies them; they are not built
   into swarm's registry (per swarm DN20).
3. `disable_inline_personality_generation`: optional. Default `false` (swarm's
   inline Custom Specialist generation is on). Code-review may set `true` when
   the personality set is fully determined by language presets and swarm
   custom generation is not desired.

Swarm returns a host-voice synthesis per pass. Code-review translates the
synthesis into the conventional-comments findings format before persisting to
the review file.

### Hash-Based Caching

Before dispatching any review, code-review must fingerprint the input:

1. Compute a content hash for every file in the review set:
   - If the file is tracked by git and unmodified: record the git blob hash
     (`git ls-files -s` or `git hash-object`) as provenance. Still compute and
     use SHA-256 as the cache key.
   - If the file is untracked or modified: compute SHA-256.
   - Hash source is metadata only. The cache key is always SHA-256.
2. Build a manifest: `{ file_path, content_hash (SHA-256), hash_source (git-blob|sha256) }` per file.
3. Compute the manifest hash: SHA-256 over the sorted list of content hashes.
4. Cache lookup: check `.code-reviews/files/<hash-6>-L<n>.md` for each file
   and each requested level. Check `.code-reviews/manifests/<manifest-hash>.md`
   for composite reviews.
5. On cache hit: reuse the existing review. Do not dispatch swarm for that file or set.
6. On cache miss: dispatch swarm, produce a new review file, write to cache.

A changed file (hash changed) is a cache miss at all levels. Only re-review
the changed file; unchanged siblings reuse cache.

### Levels

Code-review runs in graduated levels. Level N must be fully resolved before
promoting to Level N+1.

| Level | Model class | Scope | Promotion gate |
|---|---|---|---|
| L1 | haiku-class | per-file (fast, distributed) + folder integration at L1 | All L1 findings `FIXED`, `WONT_FIX`, or `WONTNEEDED` |
| L2 | sonnet-class | per-file (only files flagged L2-worthy after L1) + integration review | All L2 findings resolved |
| L3 | opus-class | per-file (only critical files) — one-shot, stamped | Sign-off; no further levels |

Level promotion decisions:

- After L1: select files for L2 by heuristic (e.g., touched auth path, high
  L1 finding density) or operator flag.
- After L2: select files for L3 similarly. L3 is rare.
- Most files stop at L1. Some go to L2. Very few reach L3.

Swarm tier mapping: L1 → haiku-class personalities; L2 → sonnet-class; L3 → opus-class.

### Conventional Comments Format

Findings must use the conventional-comments format. Each finding is:

- `question` — needs clarification; not necessarily wrong.
- `nit` — minor preference; non-blocking.
- `issue` — substantive concern; should be addressed.
- `blocking` — must be fixed before merge / sign-off.
- `non-blocking` — fix when possible; won't gate.

Each finding must carry targeting metadata: file path + line or range + evidence snippet.

Output shape per finding:

```
type: <question|nit|issue|blocking|non-blocking>
file: <path>:<line-or-range>
title: <short summary>
body: <evidence + reasoning + suggested fix>
status: OPEN
```

### Permanent Review Files and Sign-Off Lifecycle

Reviews are permanent records. Review files persist in `.code-reviews/` and
are updated, never discarded.

Each review file contains:

1. Review metadata: reviewer identity (model class + personalities used), level
   applied, file-version hash (SHA-256, 6-char prefix used in filename).
2. Findings list in conventional-comments format, each with current status.
3. Sign-off state: `OPEN` (findings outstanding) or `SIGNED_OFF` (all findings resolved).
4. Host-agent annotations: explanations of why a finding was deferred, accepted,
   or marked `WONT_FIX`.

Finding status lifecycle:

- `OPEN` → `FIXED <commit-ref>` when addressed in a commit.
- `OPEN` → `WONT_FIX <annotation>` when deliberately deferred with rationale.
- `OPEN` or `FIXED` → `WONTNEEDED` when no longer applicable (e.g., code removed).

When all findings in a review file are non-`OPEN`, the review file's sign-off
state transitions to `SIGNED_OFF`. If the file's content hash changes, the
review re-opens and a new review file is created for the new hash.

### Fractal Review Tree (Storage)

Reviews are stored in a fractal tree under `.code-reviews/`:

```
.code-reviews/
├── files/<hash-6>-L<n>.md          # leaf — review of one file at one level
├── groups/<hash>.md                # composite — review of N files as a group
├── folders/<hash>.md               # composite — review of a folder/feature
├── manifests/<manifest-hash>.md    # manifest-level composite (hash-of-hashes)
├── repo/<repo-hash>.md             # top — review of the whole repo at a point in time
└── log.md                          # chronological index: hash, scope, date, verdict, sign-off state
```

Composite-level review hash = SHA-256 of the sorted child content hashes. Same
children → same hash → cache hit. Adding or changing a child changes the
composite hash and invalidates the composite review only; child reviews
with cache hits are reused.

### Copilot Ordering

On PRs: let Copilot run first. Code-review adds the swarm review on top.
Code-review does not compete with Copilot; it augments.

The Copilot Reviewer personality is included in `additional_personalities`
only when the Copilot CLI backend passes its availability gate. If unavailable,
it is silently excluded. This is swarm's availability-gate drop pattern.

### Language-Specific Personality Presets

Code-review detects languages from file extensions in the review set and appends
matching personalities to `additional_personalities`:

- `.ps1`, `.psm1`, `.psd1` → PowerShell-reviewer
- `.sh`, `.bash` → Bash-reviewer
- `.ts`, `.tsx` → TypeScript-reviewer

Additional presets may be added by extending the personality library without
modifying this spec.

### Inputs

Each review invocation must receive:

1. The change set: inline diff text, list of absolute file paths, or git ref/range.
2. The level to run (L1, L2, L3).

Optional:
3. Focus areas (e.g., `security,concurrency`). Reorder priority; do not reduce depth.
4. A context pointer (CLAUDE.md, README, style guide) for local conventions.
5. `disable_inline_personality_generation` flag (default `false`).

### Outputs

Per-pass output (before filing):

- Swarm synthesis translated to conventional-comments findings list.
- Review file written to `.code-reviews/files/<hash-6>-L<n>.md`.
- `log.md` entry appended.

Aggregated output returned to calling agent:

1. `files_reviewed`: list of `{ file_path, hash, level, verdict, cache_hit }`.
2. `manifest_hash`: the manifest hash for this review set.
3. `findings_by_file`: map of file hash → findings list in conventional-comments format.
4. `sign_off_states`: map of file hash → sign-off state per level.
5. `overall_verdict`: `clean`, `findings`, or `error`.

### Calling Agent Obligations

1. Do not promote to the next level until all findings at the current level are resolved.
2. Do not modify the change set during a pass. Edits happen between passes.
3. Record or reference the review output so downstream consumers can verify the review occurred.
4. When annotating a finding `WONT_FIX`, supply an explanation. Unannotated `WONT_FIX` is prohibited.
5. Do not bypass the cache. Cache hits are valid reuse; forcing a re-review on an unchanged file wastes tokens.

## Constraints

1. Code-review must call `swarm` for all personality dispatch. Code-review must not dispatch personalities directly or reinvent the multi-personality dispatch primitive.
2. The model-class tier for each level is fixed: L1 = haiku-class, L2 = sonnet-class, L3 = opus-class. Tier substitution is prohibited.
3. Review agents dispatched via swarm are read-only. They must not commit, push, edit, stage, or mutate any working tree or repository state.
4. Review agents must not fix findings. Reporting and fixing are separate concerns.
5. L3 is dispatched at most once per file per content hash. L3 is the final level; no further levels exist.
6. The smoke → substantive two-pass internal swarm dispatch is swarm's internal concern. Code-review does not manage swarm's internal pass structure.
7. Language-specific presets are selected by detected extension only. Manual override by the calling agent is permitted via `additional_personalities` augmentation.
8. Content hash (SHA-256) is the canonical cache key. Git blob hash is provenance metadata only. Cache keys must not mix hash algorithms.
9. Composite-level hashes are computed as SHA-256 of sorted child SHA-256 hashes. Sort is by file path lexicographically.
10. Findings without evidence citations are prohibited. Every finding must cite a snippet, line reference, or direct quote (inherited from swarm's C4).
11. No bare model names in any skill artifact. Use model class terms (haiku-class, sonnet-class, opus-class).
12. Cross-file path references to sibling skill internals are prohibited (R-FM-11). Refer to `swarm` by skill name only; never reference `swarm/spec.md`, `swarm/uncompressed.md`, or any internal swarm file path.

## Behavior

### Empty Change Set

When the change set is empty, return an empty aggregated result with `overall_verdict: clean` and no swarm invocations.

### Single File

The level-tiered procedure applies regardless of change-set size. A single changed line still goes through L1. Cost is bounded by content; the policy does not change.

### Cache Hit on All Files

When all files in the review set have cache hits at the requested level, return the cached results immediately without invoking swarm.

### Partial Cache Hit

Re-review only cache-miss files. Reuse cache-hit file reviews. Recompute the manifest hash and composite reviews only if any child changed.

### Level Promotion Decision

After L1 resolves, the calling agent decides which files warrant L2. Decision criteria may include: touching sensitive paths, high L1 finding density, or operator flags. Files not promoted stop at L1 — this is the expected and efficient outcome.

### Copilot Integration

On PR workflows: invoke code-review after Copilot has run. Code-review's swarm result includes a Copilot Reviewer personality (when available) alongside code-domain personalities, giving a multi-perspective view on top of Copilot's output.

## Defaults and Assumptions

- Default level: L1.
- `disable_inline_personality_generation`: `false` (swarm's inline Custom Specialist is on).
- Personality set: core code-domain set + language-specific presets for detected extensions + Copilot Reviewer if available.
- Focus areas: none (full review). Focus reorders priority; does not suppress depth.
- Cache expiry: none (reviews are permanent). Cache entries are invalidated only by content hash change.
- Manifest sort: by file path lexicographically.
- Cache storage scope: per-repo `.code-reviews/`.

## Iteration Safety

Do not re-review unchanged files. Cache lookup is the gate; a content-hash match is a valid skip.
See `../iteration-safety/SKILL.md`.

## Error Handling

- Change set cannot be resolved → return `overall_verdict: error` with reason. No swarm invocations.
- Swarm returns error for a file → record error in review file; do not produce findings for that file. Retry is caller's discretion.
- Hash computation fails → treat as cache miss; proceed with review.
- `.code-reviews/` directory missing → create it before writing.
- Copilot availability probe fails → drop Copilot Reviewer from `additional_personalities` for this invocation; proceed without it.

## Precedence Rules

- Swarm governs multi-personality dispatch. Code-review must not override or replicate swarm dispatch logic.
- L3 governs over L2 findings; L2 governs over L1 findings when they conflict on the same point.
- Content hash (SHA-256) governs over git blob hash for cache identity.
- This spec governs over any inline preference expressed by a calling agent. The caller cannot override the tier policy, the cache architecture, or the findings format.

## Don'ts

- Don't dispatch personalities directly — that's swarm's job.
- Don't reinvent multi-personality dispatch or aggregation logic.
- Don't promote to L2 until all L1 findings are resolved.
- Don't use git blob hash as the primary cache key.
- Don't let review agents fix code — reporting and fixing are separate.
- Don't let review agents commit, push, stage, or mutate any state.
- Don't produce findings without evidence citations.
- Don't use bare model names — use haiku-class, sonnet-class, opus-class.
- Don't reference swarm internal files (spec.md, uncompressed.md) — refer by skill name only (R-FM-11).
- Don't expire or delete cache entries when content is unchanged — cache entries are permanent until the hash changes.
- Don't run swarm when all files have cache hits at the requested level.
- Don't include Copilot Reviewer when Copilot CLI is unavailable; let swarm's availability gate drop it.
- Don't conflate code-review levels with swarm's internal pass structure (smoke/substantive). They are orthogonal.

## Relationship to Other Skills

- **swarm**: the dispatch infrastructure code-review delegates all personality dispatch to. Consumer relationship; code-review calls swarm.
- **spec-writing**: defines the meta-rules this spec follows.
- **skill-writing**: governs the structure of SKILL.md, uncompressed, and dispatch instruction file.
- **spec-auditing**: verifies this spec before the derived skill is written.
- **skill-auditing**: verifies SKILL.md and dispatch instruction file match this spec.
- **dispatch**: provides the zero-context bootstrap that swarm uses for each personality. Code-review does not call dispatch directly; swarm does.
- **iteration-safety**: governs the cache-hit skip behavior.
