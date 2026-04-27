# Hash Record Index

## Dispatch Parameters

- `repo_root` (required): absolute path to the repository root containing `.hash-record/`.
- `--max-age-hours <N>` (optional): hours before an existing `.meta.yaml` is considered stale. Default: 24.

## Procedure

Run every step with the named tool. Do not summarize or plan.

0. **Validate input.** If `repo_root` contains `..` or shell metacharacters, output `ERROR: invalid repo_root` and stop.

1. **Verify store exists.** Use the Bash tool: `test -d "<repo_root>/.hash-record"`. If absent, output `CLEAN` and stop — nothing to index.

2. **Collect hash directories.** Use the Bash tool:

   ```bash
   find "<repo_root>/.hash-record" -mindepth 2 -maxdepth 2 -type d \
     ! -name '.prune' ! -name '.*'
   ```

   Each result is a path of the form `<repo_root>/.hash-record/<shard>/<full-hash>`. If none found, output `CLEAN` and stop.

3. **Determine max-age threshold.** Default `--max-age-hours` to 24 if not supplied. Compute the cutoff timestamp: current UTC time minus `<N>` hours.

4. **For each hash directory, decide whether to index:**

   a. Check whether `<hash_dir>/.meta.yaml` exists (Bash `test -f`).
   b. If it exists, read it with the Read tool. Parse the `last_seen` field. If `last_seen` is more recent than the cutoff timestamp, skip this hash directory — it is already up to date.
   c. If `.meta.yaml` is absent or its `last_seen` is at or before the cutoff, proceed to index this hash directory.

5. **Index a hash directory:**

   a. Find all `.md` leaf files beneath the hash directory (excluding `.meta.yaml`). Use the Bash tool:

      ```bash
      find "<hash_dir>" -type f -name "*.md" ! -name ".meta.yaml"
      ```

   b. For each leaf file path, use the Read tool to read the file. Extract the `file_path` field from the YAML frontmatter (lines between the first `---` and second `---`). If the field is absent or the file has no valid frontmatter, skip that file silently.

   c. Collect all non-empty `file_path` values found. Deduplicate. Sort lexically.

   d. If a `.meta.yaml` already exists, also read its current `file_paths` list with the Read tool. Union the existing list with the newly collected paths. Deduplicate. Sort lexically.

   e. If the collected `file_paths` list is empty (no leaf records found with a `file_path` field), skip writing meta for this hash directory. Do not create an empty meta.

   f. Compute the current UTC timestamp in ISO-8601 format (Bash: `date -u +"%Y-%m-%dT%H:%M:%SZ"`).

   g. Write `<hash_dir>/.meta.yaml` using the Write tool with this exact content:

      ```yaml
      file_paths:
        - <path-1>
        - <path-2>
      last_seen: <ISO-8601-timestamp>
      ```

      Replace `<path-N>` with each sorted, deduplicated `file_path` value. Replace `<ISO-8601-timestamp>` with the computed timestamp.

6. **Count.** Track the number of hash directories for which a new `.meta.yaml` was written.

7. **Output result:**
   - If count is 0: output `CLEAN`
   - Otherwise: output `indexed: <count>`

## Output Format

One line only:

- `CLEAN` — no hash directories needed indexing (all recent or store absent).
- `indexed: <count>` — meta files written for `<count>` hash directories.
- `ERROR: <reason>` — pre-execution failure (e.g., `repo_root` not found, path-traversal rejected).

## Rules

- Never modify any leaf `.md` record file. Read-only on all leaf records.
- Never delete any file — overwrite stale `.meta.yaml` in place, never delete and recreate.
- Write ONLY to `.meta.yaml` at the hash-directory level. No other write locations.
- This skill is the sole writer of `.meta.yaml`. No other skill writes meta.
- Merge existing `file_paths` when a `.meta.yaml` already exists — never lose previously indexed paths.
- Skip leaf files with missing or malformed frontmatter silently. Never raise on bad records.
- Do not follow symlinks when walking `.hash-record/`.
- Reject `repo_root` values containing `..` or shell metacharacters.
- Do not write meta for hash directories that have no leaf records with a valid `file_path` field.
