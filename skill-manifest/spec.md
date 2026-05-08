# skill-manifest — Specification

## Purpose

Produce a deterministic, LLM-derived file list for a skill folder. Given a skill's root
directory, `skill-manifest` reads `SKILL.md`, walks all file references recursively, and
returns the complete set of files required to publish that skill. Results are cached in
`hash-record` keyed by the folder's manifest hash; the LLM scan runs only on cache miss.

Callers (e.g. publish pipelines) use the returned file list to copy exactly the right
files to dist — no more, no less.

## Scope

In scope:

- Accepting a skill folder path as input
- Computing the folder manifest hash via `hash-record-manifest`
- Probing `hash-record` for a cached result
- Dispatching an LLM subagent to walk refs recursively on cache miss
- Storing the LLM result in `hash-record`
- Returning the file list to the caller
- Detecting broken refs (refs that do not resolve to real files)

Out of scope:

- Copying files to dist (caller responsibility)
- Auditing or validating skill content
- Version bumping or git operations
- Scanning the entire skills repo in a single invocation (caller loops over folders)
- Resolving refs across skill repos (single-repo only)

## Definitions

**Skill folder** — a directory containing a `SKILL.md` file. The folder is the unit of
identity for this skill.

**Entry point** — the `SKILL.md` file at the root of a skill folder.

**Ref** — a file path referenced from within a markdown file. Refs appear as backtick-
wrapped paths (e.g. `` `../dispatch/SKILL.md` ``) or as markdown links (e.g.
`[label](../dispatch/SKILL.md)`). An LLM resolves refs from content semantics, not regex
alone.

**File list** — the complete set of file paths (relative to the skills repo root) required
to publish a skill. Includes the entry point, all directly referenced files, and all
transitively referenced files up to the depth limit.

**Manifest hash** — a single 40-char SHA1 hash computed by `hash-record-manifest` over all
files in the skill folder. Serves as the cache key.

**Cache hit** — a `hash-record` entry exists for (manifest-hash, `skill-manifest`).

**Cache miss** — no entry exists; LLM scan must run.

**Broken ref** — a ref that resolves to a path that does not exist on the filesystem.

**Depth limit** — maximum recursion depth for ref walking. Default: 4.

## Requirements

### R-INPUT-1

The skill must accept exactly one required input: `skill_dir` — an absolute or
repo-relative path to a skill folder. A skill folder is any directory that contains a
`SKILL.md` file.

### R-INPUT-2

The skill must accept one optional input: `repo_root` — the absolute path to the skills
repo root. When omitted, defaults to the git repo root containing `skill_dir`.

### R-HASH-1

The skill must enumerate all files directly inside `skill_dir` (non-recursive, excluding
dot-files and directories) and pass them to `hash-record-manifest` to compute the manifest
hash.

### R-HASH-2

The skill must probe `hash-record` with `(manifest_hash, "skill-manifest")` before
dispatching the LLM scan.

### R-CACHE-HIT-1

On cache hit, the skill must return the stored file list without invoking the LLM.

### R-CACHE-MISS-1

On cache miss, the skill must dispatch an LLM subagent to perform the ref walk.

### R-SCAN-1

The LLM subagent must read `SKILL.md` and identify all file refs in the document.

### R-SCAN-2

For each resolved ref that is a `.md` file, the LLM subagent must recurse into that file
and extract its refs. Recursion stops at the depth limit (default 4).

### R-SCAN-3

The LLM subagent must resolve each ref relative to the directory of the file containing
the ref.

### R-SCAN-4

The LLM subagent must include the `SKILL.md` entry point in the file list regardless of
whether it contains any refs.

### R-SCAN-5

The LLM subagent must include every file that exists in `skill_dir` (non-recursive,
excluding dot-files). Files in `skill_dir` are always included regardless of whether they
are referenced.

### R-SCAN-6

The LLM subagent must flag any ref that does not resolve to an existing file as a broken
ref. Broken refs are reported in the output but do not halt the scan.

### R-SCAN-7

The file list must contain no duplicates. Each path appears exactly once.

### R-SCAN-8

All paths in the file list must be relative to `repo_root`.

### R-STORE-1

After a successful LLM scan, the skill must write the result to `hash-record` with
`(manifest_hash, "skill-manifest")` before returning to the caller.

### R-OUTPUT-1

The skill must return a JSON object with the following shape:

```json
{
  "skill": "<folder name>",
  "manifest_hash": "<40-char hash>",
  "files": ["<repo-relative path>", ...],
  "broken_refs": ["<unresolved ref>", ...],
  "cached": true | false,
  "depth_limit": 4
}
```

`broken_refs` is an empty array when no broken refs are found.

## Constraints

### C-1

The skill must not modify any files in `skill_dir` or the skills repo.

### C-2

The skill must not copy files to dist. File copying is the caller's responsibility.

### C-3

The skill must not invoke the LLM scan on cache hit.

### C-4

The skill must not fail hard on broken refs. Broken refs are reported; the file list is
returned with whatever was successfully resolved.

### C-5

The skill must not include files from outside the skills repo root in the file list.

### C-6

Depth limit must not exceed 8. Default is 4.

## Behavior

### Normal flow (cache miss)

1. Resolve `repo_root` (from input or git detection).
2. Enumerate files in `skill_dir` → pass to `hash-record-manifest` → receive
   `manifest_hash`.
3. Probe `hash-record(manifest_hash, "skill-manifest")` → miss.
4. Dispatch LLM subagent with `skill_dir`, `repo_root`, `depth_limit`.
5. LLM walks refs from `SKILL.md` recursively → returns file list + broken refs.
6. Write result to `hash-record`.
7. Return result with `cached: false`.

### Normal flow (cache hit)

1–3. Same as above through probe.
4. Cache hit → read stored file list from `hash-record`.
5. Return result with `cached: true`. No LLM invocation.

### Broken refs

Broken refs are included in `broken_refs[]` in the output. The file list is still
returned. The caller decides whether broken refs are fatal.

### `skill_dir` has no SKILL.md

Exit with `ERROR: no SKILL.md in <skill_dir>`. Do not produce a file list.

### Depth limit reached

Stop recursion at depth limit. Files at deeper levels are not included. No error is
raised; this is expected behavior for deep ref chains.

## Defaults and Assumptions

| Input | Default |
| --- | --- |
| `repo_root` | git repo root containing `skill_dir` |
| `depth_limit` | 4 |

## Error Handling

| Condition | Behavior |
| --- | --- |
| `skill_dir` missing | `ERROR: skill_dir not found: <path>` |
| No `SKILL.md` in `skill_dir` | `ERROR: no SKILL.md in <skill_dir>` |
| `hash-record-manifest` failure | `ERROR: manifest hash failed: <reason>` |
| LLM scan returns error | `ERROR: scan failed: <reason>` — do not write to hash-record |
| `hash-record` write failure | Log warning; still return result to caller |

## Don'ts

- Do NOT include dot-files in the file list.
- Do NOT recurse into subdirectories of `skill_dir` during folder enumeration (step
  R-HASH-1 and R-SCAN-5). Subdirectory files are only included if explicitly referenced.
- Do NOT include files outside the skills repo root.
- Do NOT cache a partial or error result.
- Do NOT run the LLM scan on cache hit.
- Do NOT fail hard on broken refs.

## Section Classification

| Section | Type | Required |
| --- | --- | --- |
| Purpose | Informative | Yes |
| Scope | Normative | Yes |
| Definitions | Normative | Yes |
| Requirements | Normative | Yes |
| Constraints | Normative | Yes |
| Behavior | Normative | Yes |
| Defaults and Assumptions | Normative | Yes |
| Error Handling | Normative | Yes |
| Don'ts | Normative | Yes |
| Known Limitations | Informative | No |

## Known Limitations

### Cache Key Scope

The manifest hash (R-HASH-1) is computed from files directly in `skill_dir`
(non-recursive). The ref walk (R-SCAN-2) extends into files outside `skill_dir` up to
`depth_limit`. If a transitive dependency outside `skill_dir` changes its own refs, the
cached file list becomes stale — the cache key does not detect the external change.
Publish pipelines that trust the cached `files` list may copy an incomplete file set.
Cached `broken_refs` may also be stale: a ref broken at scan time that gets resolved
externally (file created) remains in `broken_refs` on cache hit.

Mitigation: callers can check `cached: true` in the output and re-invoke when transitive
dep accuracy is critical. Cache invalidation can be forced by touching any file directly
in `skill_dir`.
