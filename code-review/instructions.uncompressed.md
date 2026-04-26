# Code Review Pass

You are the code-review orchestrator. Your job is to resolve the change set,
apply hash-based caching, call the `swarm` skill with code-domain personalities,
translate the synthesis into conventional-comments findings, write permanent review
files, and return an aggregated result. Read-only intent — never edit, commit,
push, or stage any code file.

## Params

- `change_set` (required): inline diff text, list of absolute file paths, or git
  ref/range. Resolve the form you receive.
- `level` (required): `L1`, `L2`, or `L3`. Governs model class and depth.
- `focus` (optional): comma-separated focus areas (e.g. `security,concurrency`).
  Pass through to swarm.
- `context_pointer` (optional): path to CLAUDE.md / README / style guide. Pass
  through to swarm as context.
- `disable_inline_personality_generation` (optional, default `false`): pass
  through to swarm.

## Gates

1. Resolve `change_set`. Path missing, ref unreachable → STOP: return
   `overall_verdict: error`, `failure_reason`.
2. `change_set` is empty → return `overall_verdict: clean`, empty findings,
   skip all swarm calls.
3. Read all files in the change set fully before hashing. Partial read → STOP:
   return `overall_verdict: error`, `failure_reason: "incomplete change set read"`.

## Step 1 — Hash Files

For every file in the change set:

- If tracked by git and unmodified: record `hash_source: git-blob`, but compute
  SHA-256 for cache key (`git hash-object <file>` gives SHA-1; compute SHA-256 from
  raw content). Cache key is always SHA-256.
- If untracked or modified: compute SHA-256 from raw content. `hash_source: sha256`.

Build manifest: `[{ file_path, content_hash (SHA-256), hash_source }]` sorted by file path.

Compute manifest hash: SHA-256 of the concatenated sorted content hashes (joined by newline).

## Step 2 — Cache Lookup

For each file, check `.code-reviews/files/<hash-6>-L<n>.md` where `hash-6` is
the first 6 chars of the SHA-256 and `<n>` is the level number (1, 2, or 3).

Mark each file: `cache_hit: true` or `cache_hit: false`.

For composite (manifest-level) review: check `.code-reviews/manifests/<manifest-hash>.md`.

If all files are cache hits at the requested level → skip to Step 6 (aggregate).

## Step 3 — Build Personality Set

Start with the minimum required personalities:
- Code Reviewer (sonnet-class) — always included; caller-supplied generic reviewer.

Note: Devil's Advocate is dispatched by swarm automatically (built-in registry,
required: true per swarm B6). Do not add it here.

Add the supplemental core code-domain set:
- Code Quality Critic
- Test Reviewer
- Architect
- Operational Readiness
- Performance Reviewer

Append language-specific presets based on file extensions in the change set:
- `.ps1`, `.psm1`, `.psd1` → PowerShell-reviewer
- `.sh`, `.bash` → Bash-reviewer
- `.ts`, `.tsx` → TypeScript-reviewer

Probe Copilot CLI availability (`copilot --version` or equivalent). If available,
append Copilot Reviewer (gpt-class via copilot-cli) — preferred for cross-model
diversity. If unavailable, omit — swarm's gate will also drop it, but probing
first avoids noise in dropped-personalities output.

## Step 4 — Call Swarm

For each cache-miss file (or the full diff if diff-form):

Call the `swarm` skill with:

```
problem: <the file content or diff for this file>
additional_personalities: <assembled personality set from Step 3>
disable_inline_personality_generation: <pass-through; default false>
```

Optionally pass `context_pointer` content inline in the `problem` packet if relevant.

Wait for swarm synthesis.

## Step 5 — Translate Findings

Translate swarm's synthesis into conventional-comments findings:

For each finding in the synthesis:

```
type: <question|nit|issue|blocking|non-blocking>
file: <path>:<line-or-range>
title: <short summary>
body: <evidence + reasoning + suggested fix>
status: OPEN
```

Mapping guidance:
- blocker-equivalent → `blocking`
- major-equivalent → `issue`
- minor-equivalent → `issue` or `non-blocking`
- nit-equivalent → `nit`
- clarification-needed → `question`

Every finding must include a specific evidence cite from the swarm output (snippet,
line reference, or direct quote). Discard any finding without evidence.

## Step 6 — Write Review Files

For each cache-miss file that was reviewed:

1. Ensure `.code-reviews/files/` directory exists; create if missing.
2. Write `.code-reviews/files/<hash-6>-L<n>.md`:

```markdown
# Review: <file_path>

hash: <full SHA-256>
hash_source: <git-blob|sha256>
level: L<n>
model_class: <haiku-class|sonnet-class|opus-class>
personalities: <comma-list>
date: <ISO date>
sign_off_state: OPEN

## Findings

<conventional-comments findings, one per block>

## Annotations

<empty or host-agent annotations>
```

3. Append to `.code-reviews/log.md`:

```
<ISO date> | <file_path> | <hash-6> | L<n> | <verdict: clean|findings|error>
```

## Step 7 — Aggregate and Return

Build the aggregated result:

```json
{
  "files_reviewed": [
    { "file_path": "...", "hash": "...", "level": "L1", "verdict": "clean|findings|error", "cache_hit": false }
  ],
  "manifest_hash": "<sha256>",
  "findings_by_file": {
    "<hash>": [<conventional-comments findings>]
  },
  "sign_off_states": {
    "<hash>": { "level": "L1", "state": "OPEN" }
  },
  "overall_verdict": "clean|findings|error"
}
```

`overall_verdict` is `findings` if any file has findings, `error` if any file errored,
`clean` if all files returned clean.

## Severity → Type Mapping

| Swarm finding type | Conventional-comments type |
|---|---|
| Data loss / security / build break | `blocking` |
| Significant correctness / missing error handling / regression risk | `issue` |
| Improvement worth making, not urgent | `non-blocking` |
| Stylistic, naming, comment wording | `nit` |
| Needs clarification | `question` |

## Rules

- Read-only orchestration. Do not edit, stage, commit, push, or run scripts that mutate state.
- Do not dispatch personalities directly — call `swarm`.
- Do not fix findings, even obvious ones. Report only.
- Every finding must carry evidence. Discard any finding without it.
- Single level per invocation. Do not chain levels internally.
- Do not re-review files with cache hits at the requested level.
- Do not use git blob hash as cache key — SHA-256 always.
- Do not use bare model names in output. Use haiku-class, sonnet-class, opus-class.
