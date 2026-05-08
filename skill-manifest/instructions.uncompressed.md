# skill-manifest — Instructions

Produce the complete file list for a skill folder. Walk `SKILL.md` refs recursively.
Store result in `hash-record`. Return JSON.

## Inputs

- `skill_dir` (required): absolute path to skill folder (validated by host).
- `repo_root` (required): absolute path to skills repo root (resolved by host).
- `manifest_hash` (required): 40-char hash computed by host via `hash-record-manifest`.
- `files` (required): comma-separated repo-relative paths of files directly in `skill_dir`, pre-enumerated by host.
- `depth_limit` (optional): max recursion depth. Default: 4. Max: 8.

## Step 1 — Ref walk

Initialize:

- `file_set`: set of repo-relative paths (deduplicated). Start empty.
- `broken_refs`: list of unresolved refs. Start empty.
- `queue`: list of `(file_path, depth)` to process. Start with `(skill_dir/SKILL.md, 0)`.
- `visited`: set of absolute paths already processed.

### 1a — Seed with skill_dir contents

Add all paths from `files` input to `file_set` as repo-relative paths.

### 1b — Walk queue

While queue is not empty:

1. Pop `(file_path, depth)`.
2. If `file_path` is in `visited`: skip.
3. Add `file_path` to `visited`.
4. Read file content.
5. Extract all refs from content:
   - Backtick-wrapped paths: `` `some/path.md` ``
   - Markdown links: `[label](some/path.md)`
   - Ignore URLs (http/https), anchors (#), and refs starting with `*/`.
6. For each raw ref:
   a. Resolve relative to the directory of `file_path`.
   b. If resolved path does not exist: add raw ref to `broken_refs`. Continue.
   c. If resolved path is outside `repo_root`: skip silently.
   d. Add resolved path to `file_set` as repo-relative path.
   e. If resolved path is a `.md` file AND `depth < depth_limit`: enqueue
      `(resolved_path, depth + 1)`.

### 1c — Deduplicate

Sort `file_set` lexicographically. Remove any duplicates.

## Step 2 — Store result

Assemble result JSON:

```json
{
  "skill": "<skill_dir folder name>",
  "manifest_hash": "<manifest_hash>",
  "files": ["<repo-relative path>", ...],
  "broken_refs": ["<unresolved ref>", ...],
  "cached": false,
  "depth_limit": <depth_limit>
}
```

Write to `hash-record(manifest_hash, "skill-manifest")`. On write failure: log warning,
do not stop — still return result.

## Step 3 — Output

Print the JSON to `stdout`. Nothing else.

## Rules

- Never copy files. Return the list only.
- Never invoke the LLM path on cache hit.
- Never include dot-files.
- Never fail hard on broken refs — report and continue.
- Never include files outside `repo_root`.
- Never cache an error or partial result (Step 2 runs only on full success).
- Never recurse into subdirectories of `skill_dir` during Step 4a enumeration.
- Note: Cached results may have stale `files` and `broken_refs` if transitive dependencies
  outside `skill_dir` changed since the last scan.
  The cache key covers `skill_dir` direct files only — external dep changes are not detected.
