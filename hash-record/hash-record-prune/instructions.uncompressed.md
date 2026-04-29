# Hash Record Prune

## Dispatch Parameters

- `repo_root` (required): absolute path to the repository root containing `.hash-record/`.
- `--dry-run` (optional): list orphans without deleting. Default: delete.
- `--limit <N>` (optional): maximum hash directories to delete per invocation. Default: unlimited.

## Procedure

Run every step with the named tool. Do not summarize or plan.

1. **Validate `repo_root`.** Reject immediately if `repo_root` contains `..` or any shell metacharacter (`` ` ``, `$`, `(`, `)`, `{`, `}`, `;`, `|`, `&`, `>`, `<`). Output `ERROR: invalid repo_root` and stop. Then use the Bash tool: `test -d "<repo_root>/.hash-record"`. If absent, output `CLEAN` and stop.

2. **Collect hash directories.** Use the Bash tool:

   ```bash
   find "<repo_root>/.hash-record" -mindepth 2 -maxdepth 2 -type d \
     ! -name '.prune' ! -name '.*' \
     ! -path "<repo_root>/.hash-record/.*/*"
   ```

   Each result is a path of the form `<repo_root>/.hash-record/<shard>/<full-hash>`. Extract `<full-hash>` (the basename) from each. If none found, output `CLEAN` and stop.

3a. **Determine validity — manifest records.** For each hash directory, check whether `<repo_root>/.hash-record/<shard>/<full-hash>/manifest.yaml` exists (Bash `test -f`). If it exists, re-derive the manifest hash:

   1. Read `manifest.yaml` with the Read tool. Extract the `file_paths` list.
   2. For each path in `file_paths`: check if the file exists under `repo_root` (Bash `test -f "<repo_root>/<path>"`). If missing, mark this hash directory ORPHANED and stop processing it.
   3. Run `git hash-object "<repo_root>/<path>"` (Bash) for each found file. Collect (repo-relative-path, blob-hash) pairs.
   4. Sort pairs lexically by repo-relative path.
   5. Build manifest text: one `<path> <blob-hash>` line per pair, each ending with `\n` (including the final line).
   6. Write the manifest text to a temp file and run `git hash-object <tempfile>` (Bash). If the result equals `<full-hash>`, mark VALID; otherwise mark ORPHANED.

3b. **Determine validity — non-manifest records.** Build once for all hash directories whose `manifest.yaml` is absent. Use the Bash tool:

   ```bash
   git -C "<repo_root>" ls-files --cached --others --exclude-standard
   ```

   Filter out paths that start with `.worktrees/`. Also exclude submodule paths: run `git -C "<repo_root>" submodule foreach --quiet 'echo $displaypath' 2>/dev/null` to list submodule paths and exclude any file entry that matches a submodule path. For each remaining path, run `git hash-object "<repo_root>/<file>"` (Bash). A `<full-hash>` is **valid** if it appears in this set; otherwise ORPHANED.

4. **Identify orphans.** Collect all hash directories marked ORPHANED in steps 3a/3b.

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
