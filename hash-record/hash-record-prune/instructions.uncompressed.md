# Hash Record Prune

## Dispatch Parameters

- `repo_root` (required): absolute path to the repository root containing `.hash-record/`.
- `--dry-run` (optional): list orphans without deleting. Default: delete.
- `--limit <N>` (optional): maximum hash directories to delete per invocation. Default: unlimited.

## Procedure

Run every step with the named tool. Do not summarize or plan.

1. **Verify store exists.** Use the Bash tool: `test -d "<repo_root>/.hash-record"`. If the directory is absent, output `CLEAN` and stop — nothing to prune.

2. **Collect hash directories.** Use the Bash tool:

   ```bash
   find "<repo_root>/.hash-record" -mindepth 2 -maxdepth 2 -type d \
     ! -name '.prune' ! -name '.*'
   ```

   Each result is a path of the form `<repo_root>/.hash-record/<shard>/<full-hash>`. Extract `<full-hash>` (the basename) from each. If none found, output `CLEAN` and stop.

3. **Build the valid-hash set.** Two strategies — prefer manifest when available:

   - **Manifest-preferred:** For each hash directory, check whether `<repo_root>/.hash-record/<shard>/<full-hash>/manifest.yaml` exists (Bash `test -f`). If it exists, read it with the Read tool. Extract the `file_paths` list. For each path in `file_paths`, run `git hash-object "<repo_root>/<file_path>"` (Bash). Accumulate the resulting hashes into the valid-hash set for this directory.
   - **Full-workspace fallback:** Build once for all hash directories whose manifest is absent. Use the Bash tool:

     ```bash
     cd "<repo_root>" && git ls-files --cached --others --exclude-standard
     ```

     For each file path returned, run `git hash-object "<repo_root>/<file>"` (Bash). Accumulate all hashes. This set covers every hash directory that lacked meta.

   A `<full-hash>` is **valid** if it appears in its effective valid-hash set (manifest-derived or workspace-derived).

4. **Identify orphans.** For each hash directory: if `<full-hash>` is NOT in its effective valid-hash set, mark it as orphaned.

5. **Dry-run path.** If `--dry-run` is set, skip deletion. Output `dry-run: <count>` and stop.

6. **Delete orphans.** For each orphaned hash directory (up to `--limit` if specified), run via Bash:

   ```bash
   rm -rf "<repo_root>/.hash-record/<shard>/<full-hash>"
   ```

   Do NOT follow symlinks. Do NOT delete any path that resolves outside `<repo_root>/.hash-record/`. Stop when `--limit` is reached; remaining orphans are left for the next invocation.

7. **Prune empty shard directories.** After deletions, for each shard directory that now contains no subdirectories, run:

   ```bash
   rmdir "<repo_root>/.hash-record/<shard>" 2>/dev/null || true
   ```

8. **Output result.** Print one line to stdout:
   - If no orphans found: `CLEAN`
   - If dry-run: `dry-run: <count>`
   - If deletions performed: `pruned: <count>`

## Output Format

One line only:

- `CLEAN` — no orphans found.
- `pruned: <count>` — orphans deleted.
- `dry-run: <count>` — orphans found; nothing deleted.
- `ERROR: <reason>` — pre-execution failure (e.g., `repo_root` not found, path-traversal rejected).


