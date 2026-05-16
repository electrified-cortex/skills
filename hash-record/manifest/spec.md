# Hash-Record Manifest Specification

## Purpose

Compute a **manifest hash** for a set of files. The manifest hash is the cache key used by hash-record consumers whose input is multiple files (skill audits, code review on a directory, anything that bundles multiple sources into a single result).

This is a sub-skill of `hash-record`. It produces a single 40-char git blob hash from a deterministic manifest text built from the input file set. The manifest hash changes the moment any input file's content changes.

Single-file consumers (e.g. `markdown-hygiene` on one `.md`) do NOT need this skill — they inline `git hash-object <file>`. Multi-file consumers (e.g. `skill-auditing` on a skill folder) dispatch this skill to compute their cache key.

## Scope

Applies to any consumer skill whose cache key is a function of multiple files' content. Each input file MUST be:

- Readable as bytes (no directory inputs).
- Stable across the operation (no concurrent writers during the manifest computation).

Does NOT cover single-file inputs (use `git hash-object` inline). Does NOT compute a cache key based on filenames alone — file content is the source of truth.

## Definitions

- **Input file set**: ordered or unordered list of repo-relative file paths the consumer wants to bundle as one cache unit.
- **Manifest text**: deterministic string built from the input file set: one line per file, sorted lexically by repo-relative path, format `<filename> <git-blob-hash>\n`.
- **Manifest hash**: 40-char git blob hash of the manifest text via `git hash-object --stdin`. The cache-key value.

## Requirements

### Input

- `repo_root` (string, required): absolute path to the repository root. Used to compute repo-relative paths for the manifest text.
- `files` (list of strings, required): paths to include. May be absolute or repo-relative — the skill normalizes to repo-relative against `repo_root`. Empty list -> `ERROR: empty file set`.

### Procedure

1. Validate `repo_root` exists and `files` list is non-empty. Otherwise output `ERROR: <reason>` and stop.
2. For each path in `files`:
   - Resolve to repo-relative form (strip `repo_root` prefix; canonicalize separators to `/`).
   - Run `git hash-object <absolute-path>` (Bash). Save 40-char result.
   - Guard: file unreadable or doesn't exist -> `ERROR: missing: <path>` and stop.
3. Sort the (repo-relative-path, blob-hash) pairs lexically by repo-relative path.
4. Build the **manifest text**: one line per pair, format `<repo-relative-path> <blob-hash>\n`. The trailing `\n` after the last line MUST be present (uniform line endings).
5. Pipe the manifest text through `git hash-object --stdin` (Bash). The 40-char output is the **manifest hash**.

### Output

Stdout return (one line):

- `manifest: <40-char-hash>` — success.
- `ERROR: <reason>` — failure.

The skill does NOT write any record file. The manifest hash is consumed by the caller as a cache key.

### Determinism

Same input file set + same content = same manifest hash, byte-for-byte identical, on any machine with `git`. Path separator normalization (always `/`) ensures cross-platform stability. Sorting before serialization removes input-order ambiguity.

## Constraints

- The skill MUST NOT depend on any tool outside `git` (rationale: universal availability — every workspace running this skill has git).
- The skill MUST NOT include file metadata (mtime, mode, size) in the manifest. Content hash is the only signal.
- The skill MUST NOT follow symlinks when resolving file paths — symlinks resolve to their literal path content, not the target.
- The skill MUST NOT cache its own output — manifest computation is fast (one `git hash-object` per file plus one final `--stdin` call); caching would be premature optimization.
- The skill MUST NOT silently skip missing files. Missing input -> `ERROR:` and stop.

## Iteration Safety

This skill has no iteration-safety primitive of its own. The CALLER uses the manifest hash as a cache key against `.hash-record/`. Same input set + unchanged content -> same manifest hash -> caller's cache HIT.

## Don'ts

- Do not accept directory inputs. Caller enumerates files (e.g. via `git ls-files`) and passes the explicit list.
- Do not deduplicate paths. Caller is responsible for input correctness; duplicates would produce duplicate manifest lines, which is a caller bug.
- Do not write output to disk. The manifest hash returns via stdout only.
- Do not invoke any consumer skill or any other hash-record sub-skill.
