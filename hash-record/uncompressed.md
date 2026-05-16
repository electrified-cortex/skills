---
name: hash-record
description: Content-hash-keyed durable record store — one substrate for caching audit, review, and hygiene results. Probe / Read / Write / Invalidate / Rekey / Prune / Index API. Triggers - cache result, look up cached record, hash-record store.
---

# Hash Record

Stores records of operations performed on file content, keyed by the content's git blob hash. Consumer skills (code-review, markdown-hygiene, spec-audit, skill-audit) call into this as their cache substrate. The same operation by the same model on the same content is never re-run.

## Storage layout

```text
.hash-record/
  <hash[0:2]>/                       # 2-char shard (256 buckets, like .git/objects/)
    <full-hash>/                     # full 40-char git blob hash
      <skill-name>/
        v<version>/                  # optional — skipped if skill has no version frontmatter
          <model>.md                 # leaf record — one canonical file per (hash, skill, model)
```

Shard prefix is always exactly 2 chars. Full hash is always 40 chars. Never truncate elsewhere.

## Lookup API

| Operation | Input | Output | Purpose |
| --- | --- | --- | --- |
| Probe | `(hash, skill, version\|null, model)` | `{ hit: bool, path: string\|null }` | Cache check |
| Read | record path | full record content (frontmatter + body) | Return cached result |
| Write | `(hash, skill, version\|null, model, content)` | new record path | Append a fresh record |
| Invalidate | `[(path, old-hash, new-hash)]` | count of dirs deleted | Eager cleanup (hook-driven) |

Path computation (Probe + Write must agree):

```text
.hash-record/<hash[0:2]>/<full-hash>/<skill>/[v<version>/]<model>.md
```

Version segment included when version is non-null; omitted otherwise. Model name is the file leaf — no model-named directory.

## Record file format

Every record opens with this YAML frontmatter:

```yaml
---
hash: <full git blob hash>
file_path: <git-relative path>
operation_kind: <skill name>
model: <model-identifier>
result: pass | findings | error | skipped
---
```

`result` is a closed enum. `model` is orthogonal to `operation_kind` — together they form the cache discriminator. Body content is the consumer's responsibility; hash-record only validates frontmatter shape.

## Behaviors

- **Probe path computation** is deterministic from input. Probe runs `test -f <path>` on the model-named file; if it exists, return hit with the absolute path. Otherwise miss. No directory listing or sort needed.
- **Write** creates intermediate directories as needed. Atomic temp-file rename; overwrites any existing record at the canonical path — same input produces same output, re-runs are idempotent refreshes. Verifies persisted record by reading back the frontmatter `hash` and `model`. Verification failure produces an `error` result.
- **Invalidate** is hook-driven. The skill does not compute hashes itself. Caller (typically a pre-commit hook) supplies the list of `(path, old-hash, new-hash)` tuples; hash-record removes the matching `<old-hash[0:2]>/<old-hash>/` directories.
- **Malformed records** (missing required fields, hash mismatch with parent dir) are treated as misses; janitor handles cleanup. Never raise on malformed.

## Constraints

- Read-only on source files. Never modifies anything except `.hash-record/`.
- No git mutations. Reads only: `git hash-object`, `git ls-files -s`. No `git rm`, no `git commit`.
- Per-repo store. The `.hash-record/` path is non-configurable — always at the repo root. Trust boundary is the repo.
- Reject input with path-traversal characters or 40-char-hash mismatches.
- Never truncate hash for any path component except the 2-char shard prefix.

## Manifest Hash

When input is a directory (not a single file), compute an aggregate cache key:

1. Identify source files (consumer-defined; skip derived artifacts like `SKILL.md`, `instructions.txt`).
2. Run `git hash-object <file>` on each — collect `(filename, blob-hash)` pairs.
3. Sort pairs lexically by filename. Write one `<filename> <hash>` line per pair.
4. Pipe that manifest text through `git hash-object --stdin`. Result = manifest hash; use as the hash-record key.

Manifest hash is stable, dependency-free, and invalidates on any source change.

## Don'ts

- Don't store records outside `.hash-record/`.
- Don't truncate hash anywhere except the 2-char shard.
- Don't create multiple records per model — one model-named file per `(hash, skill, model)` tuple; re-runs overwrite it.
- Don't expose the storage layout as a parameter.
- Don't auto-invoke eager cleanup — it's opt-in via hook or operator.
- Don't perform consumer operations. Hash-record stores; consumers compute.

## Transition (`.sha256` coexistence)

While hash-record rolls out, existing `.sha256` sidecar gates remain in place. Both are simultaneously valid governance signals:

- `.sha256` fresh = governance-approved.
- `operator-signoff` record under `<hash>/governance/operator-signoff.md` also = governance-approved.
- Either is sufficient during the transition. Consumers MUST NOT require both.
- New skills SHOULD gate on `operator-signoff` records. Existing skills don't migrate until a separate retirement phase.

## Repo commit policy

`.hash-record/` may be committed (public trust ledger) or gitignored (local cache). Per-repo decision. Hash-record functions identically in either mode.

Related: `code-review`, `swarm`, `skill-auditing`, `spec-auditing`, `markdown-hygiene` (all consumers).
