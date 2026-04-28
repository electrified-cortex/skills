# Hash-Record Specification

## Purpose

Define a generic content-hash-keyed durable record store. Operations performed on file content (code reviews, hygiene passes, audits, persona reviews) write their results to the store keyed by the content hash. Future invocations of the same operation by the same actor on the same content read the cached result instead of re-running. File changes invalidate the entire hash entry atomically — every record done on the old content is wiped in one operation when the source changes.

The hash-record skill is **infrastructure**. It does not perform reviews or audits. It only stores and retrieves records, and provides cleanup semantics. Consumer skills (code-review, markdown-hygiene, swarm, spec-audit, skill-audit, etc.) write into and read from the store.

## Scope

Applies to any deterministic operation on file content where:

1. The operation's output is a function of the file's content (not of caller-supplied parameters that vary between calls).
2. Skipping the operation when its result already exists for the current content saves work.
3. The operation has a stable identity — operation kind + actor (persona, model, configuration) — that is the lookup key alongside the content hash.

Consolidates what previously lived under `.audit-reports/`, `.code-reviews/`, and any other per-skill cache directory. There is one hash-record store per repository, not per skill.

Does NOT cover operations whose output depends on inputs other than file content (e.g., conversational responses, ephemeral computations). Those are not memoizable and are out of scope.

## Definitions

- **Content hash**: the git blob hash of file content (SHA-1 via `git hash-object`). The canonical key. Universal availability is the reason — every environment that runs this skill has git installed; SHA-256 would require shell allow-listing.
- **Operation kind**: a stable name for the kind of work being recorded. Examples: `code-review`, `markdown-hygiene`, `spec-audit`, `skill-audit`. Lowercase, hyphenated.
- **Model**: the model identifier that performed the operation. Examples: `claude-haiku-4-5`, `claude-sonnet-4-6`, `gpt-5-3-codex`. The model identity is the cache discriminator alongside operation-kind — the same operation by a different model produces a different record.
- **Operator signoff**: a special model identity (`operator-signoff`) representing explicit human review and approval of the content at this hash. A sign-off record under `<hash>/<operation-kind>/operator-signoff.md` declares "operator reviewed this content at this hash and approved." Operation-kind for sign-off records is typically `governance`. See the Transition section for how `operator-signoff` coexists with the existing `.sha256` sidecar mechanism.
- **Record**: the leaf artifact at `.hash-record/<shard>/<hash>/<skill>/<model>.md`. Contains the result of one specific operation by one model on the content identified by the hash. One canonical file per `(hash, skill, model)` tuple.
- **Profile** (consumer-side concept): a named bundle of operation+model requirements that a consumer skill assembles from. Profiles are not stored in hash-record; they are consumer skill state. A profile is a query: "for this hash, do I have records for all the operation+model pairs this profile requires?"
- **Lookup key**: `(content-hash, operation-kind, model)`. The store answers: does a record matching this triple exist?

## Requirements

### Storage Layout

```text
.hash-record/
  <hash[0:2]>/                       # 2-char shard prefix; 256 buckets
    <full-hash>/                     # full 40-char git blob hash
      <skill-name>/
        v<version>/                  # optional; only present if skill has version frontmatter
          <model>.md                 # leaf record — one canonical file per (hash, skill, model)
        v<version>/                  # different version produces a sibling dir
          <model>.md
      <skill-name>/                  # different skill name = sibling
        ...
  <hash[0:2]>/
    ...
```

- **Shard prefix**: the first 2 hex characters of the hash. 256 buckets at the top level, mirroring git's `.git/objects/` layout. Spreads load — at 50k records, average ~200 per bucket. Keeps `ls` fast, prevents any single directory from exploding.
- **Full hash**: the full 40-char git blob hash inside the shard bucket. NEVER truncated for any path component besides the shard prefix.
- **Skill-name folder**: the skill that produced the record (e.g., `code-review`, `markdown-hygiene`, `skill-audit`). Replaces the prior `<operation-kind>` term — operation-kind is now equivalent to skill-name when the consuming skill writes records. Lowercase-hyphenated.
- **Version folder** (`v<version>`): present only when the skill declares a `version` field in its frontmatter. The folder is `v` + the version string verbatim (e.g., `v1.0`, `v2.3.1`). Skills without a version field omit this level — leaf model file sits directly under the skill folder.
- **Leaf record**: `<model>.md` — one canonical file per `(shard, hash, skill, version, model)` tuple. The model identifier is the filename (e.g., `claude-sonnet-4-6.md`, `claude-haiku-4-5.md`). Lowercase-hyphenated; match the canonical model id where possible. There is exactly one file per model; re-running overwrites it.

### Deterministic Model-id Filename Rule

The leaf filename `<model>.md` MUST be **deterministic** — same agent on same content produces the same filename, byte-for-byte, every run, on any machine.

Canonical form: `<vendor>-<class>-<major>-<minor>.md` (lowercase, dash-separated). Examples:

- `claude-haiku-4-5.md`
- `claude-sonnet-4-6.md`
- `claude-opus-4-7.md`
- `gpt-5-3-codex.md`

The vendor prefix may be omitted if the workspace settles on a single vendor (e.g., `haiku-4-5.md`), but the workspace MUST be consistent — never mix `claude-haiku-4-5.md` and `haiku-4-5.md` for records of the same model.

**Forbidden suffixes / qualifiers** in the filename:

- Date or timestamp (e.g., `claude-sonnet-4-6-2026-04-27T19-17-52Z.md`).
- Caller-skill prefix (e.g., `skill-auditing-claude-sonnet-4-6.md`).
- Caller-model qualifier (e.g., `claude-sonnet-4-6-sonnet.md`).
- Sub-version year suffix (e.g., `claude-sonnet-4-6-2025.md`).
- Any non-deterministic component.

The filename is determined SOLELY by the agent's own model identity. Time, caller context, and runtime parameters do NOT affect it.

### Record File Format

Every record file MUST include the following YAML frontmatter as the first content of the file:

```yaml
---
hash: <full git blob hash>            # required, 40-char SHA-1
file_path: <git-relative path>         # required, navigation anchor
operation_kind: <stable name>          # required
model: <model-identifier>              # required
result: <pass|findings|error|skipped>  # required, closed enum
---
```

Field constraints:

- `result` is a **closed enum** with exactly four values: `pass`, `findings`, `error`, `skipped`. Consumers MAY define richer values inside the body, but the frontmatter `result` field MUST be one of these four. `pass` = operation completed cleanly with no actionable findings; `findings` = operation completed and produced actionable items; `error` = operation could not complete; `skipped` = the operation was elected not to run (e.g., trivial-file cap, severity floor filter).
- `model` is the model identifier (e.g., `haiku-4-5`, `claude-sonnet-4-6`). It is an orthogonal field from `operation_kind` — the same operation by a different model produces a different record. The `model` value is also used as the directory segment in the path (see Storage Layout).
- `hash` MUST match the parent directory name. A record whose frontmatter `hash` differs from the directory hash is malformed.
- All required fields MUST be present. A record missing a required field is malformed.

**`file_path` and `file_paths` — repo-relative path rule:**

- **Single-file consumers** MUST use `file_path:` as a single repo-relative path string. The root is the git repository resolved from the target file's location (see Repo Root Resolution). Compute via `git ls-files --full-name <file>` from inside the file's repo, or by stripping `<repo-root>/` from the absolute path.
- **Multi-file consumers** MUST use `file_paths:` as a YAML list of repo-relative path strings — one entry per input source file, sorted lexically.

```yaml
# Correct — single file:
file_path: markdown-hygiene/instructions.uncompressed.md

# Correct — multi-file:
file_paths:
  - skill-auditing/instructions.uncompressed.md
  - skill-auditing/SKILL.md
  - skill-auditing/spec.md
  - skill-auditing/uncompressed.md
```

```yaml
# WRONG (absolute path):
file_path: /abs/path/to/markdown-hygiene/uncompressed.md

# WRONG (directory only, no filename):
file_path: skill-auditing/

# WRONG (singular file_path in a multi-file context):
file_path: skill-auditing/SKILL.md
```

Malformed records are treated as misses by the probe operation (the malformed file is not deleted; janitor handles cleanup). The skill MUST NOT raise on malformed records — it must skip and continue.

After the frontmatter, the body contains operation-specific content (findings list for code-review, lint summary for hygiene, audit verdict for audits, etc.). Record body shape is the consumer skill's responsibility; hash-record only requires the frontmatter shape and field validity.

`file_path` is the **human anchor** — operators reading a record by path can find which source file it pertains to. The hash directory is the system anchor; `file_path` is the navigation aid.

### Repo Root Resolution

Consumer skills MUST resolve the repo root from the **target file's path**, not from CWD. The dispatched agent's CWD is the agent's home repo, not the target file's repo.

```bash
target_dir=$(dirname "<target_file_or_dir>")
repo_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
```

If no `.git/` is found via the walk-up (command exits non-zero), fall back to creating `.hash-record/` adjacent to the target file or directory:

```bash
[ -z "$repo_root" ] && repo_root="$target_dir"
```

- For single-file consumers (e.g., `markdown-hygiene`): `target_dir = dirname(<file_path>)`.
- For multi-file consumers (e.g., `skill-auditing`): `target_dir = dirname(<skill_path>)`.

The resolved `<repo_root>` is then used for all cache path construction and for computing repo-relative `file_path`/`file_paths` values.

### Lookup API

Consumer skills query the store via four operations:

1. **Probe**: given `(hash, skill, version|null, model)`, does a record exist? Returns `{ hit: bool, path: string | null }` — `hit: true` with the absolute path to the record file when present, or `hit: false, path: null` when none exists. The probe is a single `test -f <path>` check on the canonical model-named file. Consumer code MAY use the boolean directly or pattern-match the result; both are first-class.
2. **Read**: given the record path, return the full record content (frontmatter + body).
3. **Write**: given `(hash, skill, version|null, model, record-content)`, write the record at the canonical path (overwriting if it already exists — same input produces same output; re-runs refresh the record). Creates intermediate directories as needed (shard, full-hash, skill, version). Write MUST verify the persisted record by reading back the frontmatter and confirming `hash` and `model` match the input; verification failure is an `error` result.
4. **Invalidate**: given a list of `(path, old-hash, new-hash)` tuples (typically supplied by a pre-commit hook), `rm -rf .hash-record/<old-hash[0:2]>/<old-hash>/` for each entry where `old-hash` differs from `new-hash`. The skill does NOT compute these hashes itself; the caller (hook) supplies them. Invalidate is the only API that mutates outside the called record's directory.

Probe is the cache-hit primitive. Read returns the cached result. Write extends the history. Invalidate is the eager-cleanup callable that hooks plug into.

**Path computation** (shared by Probe and Write):

```text
.hash-record/<hash[0:2]>/<full-hash>/<skill>/[v<version>/]<model>.md
```

The version segment is included when version is non-null and omitted when null. Probe and Write must agree on path computation to ensure every write is findable by a subsequent probe with the same input tuple. The model name is the file leaf — there is no model-named directory.

### File Change Invalidation

When a source file's content changes (its git blob hash changes), every record under the old hash is now stale. Cleanup options:

1. **Lazy** (default): Stale records remain on disk. They will never be looked up because consumers query by current hash. They become inert clutter, addressable only by the janitor skill.
2. **Eager via git pre-commit hook** (optional): An installable git hook detects which files changed in the staged diff, computes their old + new blob hashes, and removes the old hash directory under `.hash-record/<old-hash>/`. The hook is opt-in — installed by the consumer repo, not by hash-record itself.
3. **Manual**: Operator or janitor invokes a hash-record cleanup operation that removes hash directories whose hash is not present in any current file's git blob hash.

The skill MUST support all three modes. The default behavior is lazy; eager is opt-in.

### Consumer Integration

A consumer skill (e.g., code-review) integrates with hash-record by:

1. Computing the content hash of each input file via `git hash-object`.
2. For each operation+model combination it needs (assembled per its profile/configuration), probing the hash-record store.
3. On hit: reading the existing record, no work.
4. On miss: performing the operation, writing the record.
5. Composing the per-operation records into the consumer's higher-level output (e.g., code-review's per-file review = roll-up of code-reviewer-sonnet + devils-advocate-gpt + markdown-hygiene-haiku records).

The consumer never duplicates the storage layout. There are no per-skill caches anywhere except `.hash-record/`.

### Manifest Hash

When a consumer's input is a directory of source files (not a single file), compute a manifest hash as the aggregate cache key:

1. Identify the relevant source files (consumer-defined; typically excludes derived/compressed artifacts such as `SKILL.md` and `instructions.txt`).
2. For each file, run `git hash-object <file>` to get its 40-char blob hash.
3. Build a manifest text — one line per file, sorted lexically by filename: `<filename> <hash>\n`.
4. Run `git hash-object --stdin` on the manifest text. The result is the manifest hash — use it as the consumer's hash-record cache key.

The manifest hash is stable across runs, captures the full source state without git tracking dependencies, and changes the moment any source file changes.

Manifest hashing is **not** a separate sub-skill — it is a short inline procedure consumers run when their input is multi-file. Document the pattern in consumers' instructions; they execute it inline. The manifest hash replaces the single-file blob hash as the first path segment: `.hash-record/<manifest_hash[0:2]>/<manifest_hash>/<skill>/...`.

### Atomicity

- A single record write is atomic at the filesystem level (write to temp file, rename to final). Partial writes are forbidden.
- A hash-directory delete (eager invalidation) is `rm -rf` of the hash directory — atomic enough for the use case (operators may transiently see partial state but no record will ever be half-readable).
- Concurrent writes by different models to the same hash directory are safe (different leaf filenames). Concurrent writes by the same model to the same `(hash, operation-kind, model)` are last-writer-wins — both attempt to write the same canonical file path; the final state is whichever rename completed last.

## Constraints

1. The skill never modifies source files. Read-only on everything except `.hash-record/`.
2. The skill never invokes git commands that mutate state. `git hash-object` (read), `git ls-files -s` (read) only. No `git rm`, no `git commit`.
3. The skill never exposes the hash-record store path as configurable across the repo — `.hash-record/` is the single canonical location at the repo root. Multiple stores in one repo are out of scope.
4. The skill MUST handle missing `.hash-record/` directory by creating it on first write. Probe on missing directory returns miss without erroring.
5. The skill MUST NOT cache results across repository roots. A hash-record in repo A does not satisfy a probe in repo B even if hash and operation match — git blob hashes are global, but the trust boundary is the repo. This constraint is enforced by §3 (non-configurable store path at the repo root) — there is no override mechanism. A consumer cannot point hash-record at a foreign repo's store; the path is computed from the current repo root only.
6. The skill MUST validate input — reject malformed `(hash, operation-kind, model)` tuples (empty strings, path-traversal characters in operation-kind or model names, non-40-char hashes).

## Behavior

### Probe

Compute the candidate path: `.hash-record/<hash[0:2]>/<hash>/<skill>/[v<version>/]<model>.md`. Run `test -f <path>`. If the file exists, return `hit` with the absolute path to that file. If it does not exist, return `miss`.

### Read

Open the record file. Parse frontmatter. Return the full content (frontmatter + body) plus parsed metadata.

### Write

1. Compute the canonical path: `.hash-record/<hash[0:2]>/<hash>/<skill>/[v<version>/]<model>.md`.
2. Create intermediate directories as needed (`mkdir -p` of the parent directory).
3. Write the record to a temp file in the same directory, then atomic rename to the canonical path. If a file already exists at the canonical path, the rename overwrites it — same input produces same output; re-runs refresh the record.
4. Verify the write per Lookup API §3 (read back the frontmatter, confirm `hash`/`operation_kind`/`model` match input). On verification failure, the operation result is `error`.

### Eager Cleanup (delegated to external hook)

The hash-record skill itself does NOT implement eager cleanup. Eager cleanup is the responsibility of an external git hook (typically a pre-commit hook) installed by the consuming repo. The skill exposes one operation that supports this: given an explicit list of `(path, old-hash, new-hash)` tuples, walk the list and `rm -rf .hash-record/<old-hash>/` for each entry where `<old-hash>` differs from `<new-hash>`. The hook is responsible for computing the hashes (using `git diff --cached --no-renames -z --raw HEAD` or equivalent) and supplying the list. This keeps hash-record's command surface narrow (only `git hash-object` and `git ls-files -s`) and pushes git-internals knowledge into the hook layer where it belongs.

A reference hook implementation lives at `electrified-cortex/hash-record/hooks/pre-commit-invalidate.sh` — operators install it per-repo. The reference hook is the canonical approach; alternative implementations are permitted as long as they call hash-record's invalidate operation with a well-formed list.

### Lazy Mode (no cleanup)

Stale records accumulate. The janitor skill (separate, operator-invoked) is the route to bulk cleanup.

## Don'ts

- Don't store records outside `.hash-record/`. The skill owns that directory exclusively.
- Don't truncate the hash in directory names — collision risk.
- Don't create multiple records per model — the model-named file is the single canonical record; re-runs overwrite it.
- Don't expose the storage layout as a parameter — the layout is normative.
- Don't auto-invoke eager cleanup — it's opt-in via git hook or operator command.
- Don't perform operations on behalf of consumers. The skill is storage; consumers compute.
- Don't trust caller-supplied paths or model names that contain `..`, `/`, or shell metacharacters. Reject invalid input.
- Don't truncate the hash for any path component except the 2-char shard prefix. The shard prefix is always exactly the first 2 hex characters; the next path component is always the full 40-char hash. No 6-char prefixes, no other partial hashes anywhere in the layout.
- Don't split records by date or other partition. Hash is the only partition.
- Don't add an index file — the filesystem is the index. `log.md`-style indices are consumer concerns.

## Relationship to Other Skills

- **code-review** (consumer): probes for code-review records before dispatching swarm. Profile defines which operation+actor pairs are required.
- **markdown-hygiene** (consumer): probes for hygiene records before re-running. Auto-runs on markdown writes; cached results skip the work.
- **swarm** (indirect consumer via code-review): each personality dispatch becomes an actor in the hash-record. Convergence findings are reconstructed by reading multiple actors' records for the same hash+operation-kind.
- **spec-audit / skill-audit** (consumer): writes audit records under `<hash>/<operation-kind>/` keyed by auditor identity.
- **janitor** (consumer of cleanup semantics): reads hash-record to identify stale entries (hashes no longer matching any current file) and prunes them on demand.
- **iteration-safety**: the hash-record substrate IS the iteration-safety foundation. "Don't re-pass on unchanged content" is enforced via cache hits.

## Transition (`.sha256` Coexistence)

While the hash-record skill is rolled out, the existing `.sha256` sidecar governance gate remains in place across the workspace. Both signals are simultaneously valid during the transition window. Precedence rules during transition:

1. If a `.sha256` sidecar exists and is fresh (matches the file's current hash), the file is considered governance-approved by that mechanism. Consumer skills continue to gate on `.sha256` freshness.
2. If a current `operator-signoff` record exists in hash-record under the file's git blob hash and operation-kind `governance`, the file is also considered governance-approved.
3. The signals are INDEPENDENT during the transition: either is sufficient. A consumer skill that gates on freshness MAY check either one; it MUST NOT require both.
4. New skills authored after this spec lands SHOULD gate on `operator-signoff` records, not on `.sha256` sidecars. Existing skills are not required to migrate until a separate retirement phase explicitly directs it.

The retirement of `.sha256` is out of scope for this spec — it is a separate phase that requires migration of every gated skill, hook removal, and operator-confirmed cutover. This spec defines only the forward path; the retirement plan is its own deliverable.

## Repository Commit Policy

The `.hash-record/` directory is at the repository root. Whether to commit it to git is a per-repo decision:

- **Committed**: the repo carries a public trust ledger of every audit, review, and operator signoff performed against tracked content. Downstream pullers inherit the trust trail and skip already-done work. Useful for libraries, public skills, and projects where review provenance is a feature.
- **Gitignored**: `.hash-record/` is local cache, never shared. Each clone re-runs reviews. Useful when the cache is large, when results aren't reproducible across actor versions, or when sharing review history is undesirable.

The hash-record skill MUST function identically in both modes. Consumers MUST NOT depend on the cache being committed.

When committed, the records become a deterministic part of the repo history. Operator signoff records, in particular, function as the "this commit was approved" trust signal — replacing or augmenting other governance gates depending on the consuming repo's policy.

## Iteration Safety

Hash-record is the iteration-safety primitive. Re-running a probe on unchanged content always hits cache; re-writing the same `(hash, operation-kind, model)` overwrites the existing record — same input produces the same output, re-runs are idempotent refreshes. Re-pass safety is structural.
