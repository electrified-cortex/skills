# Hash Record Index

## Dispatch Parameters

- `repo_root` (required): absolute path to the repository root containing `.hash-record/`.

## Procedure

Run every step with the named tool. Do not summarize or plan.

1. **Validate input.** If `repo_root` contains `..` or shell metacharacters, output `ERROR: invalid repo_root` and stop.

2. **Verify store exists.** Use the Bash tool: `test -d "<repo_root>/.hash-record"`. If absent, output `CLEAN` and stop — nothing to index.

3. **Collect hash directories.** Use the Bash tool:

   ```bash
   find "<repo_root>/.hash-record" -mindepth 2 -maxdepth 2 -type d \
     ! -name '.prune' ! -name '.*'
   ```

   Each result is a path of the form `<repo_root>/.hash-record/<shard>/<full-hash>`. If none found, output `CLEAN` and stop.

4. **For each hash directory, decide whether to index:**

   a. Find all `.md` leaf files beneath the hash directory (excluding `.manifest.yaml`). Use the Bash tool:

      ```bash
      find "<hash_dir>" -type f -name "*.md" ! -name ".manifest.yaml"
      ```

   b. For each leaf file path, use the Read tool to read the file. Extract the `file_path` field from the YAML frontmatter (lines between the first `---` and second `---`). If the field is absent or the file has no valid frontmatter, skip that file silently.

   c. Collect all non-empty `file_path` values found. Deduplicate. Sort lexically.

   d. If a `.manifest.yaml` already exists, read its current `file_paths` list with the Read tool. If the existing list matches the collected paths exactly (same set), skip this hash directory — it is already up to date.

   e. If the collected `file_paths` list is empty (no leaf records found with a `file_path` field), skip writing manifest for this hash directory. Do not create an empty manifest.

   f. Union the existing `file_paths` (if any) with the newly collected paths. Deduplicate. Sort lexically.

   g. Write `<hash_dir>/.manifest.yaml` using the Write tool with this exact content:

      ```yaml
      file_paths:
        - <path-1>
        - <path-2>
      ```

      Replace `<path-N>` with each sorted, deduplicated `file_path` value.

5. **Count.** Track the number of hash directories for which a new `.manifest.yaml` was written.

6. **Output result:**
   - If count is 0: output `CLEAN`
   - Otherwise: output `indexed: <count>`

## Output Format

One line only:

- `CLEAN` — no hash directories needed indexing (all up to date or store absent).
- `indexed: <count>` — manifest files written for `<count>` hash directories.
- `ERROR: <reason>` — pre-execution failure (e.g., `repo_root` not found, path-traversal rejected).

## Rules

- Never modify any leaf `.md` record file. Read-only on all leaf records.
- Never delete any file — overwrite outdated `.manifest.yaml` in place, never delete and recreate.
- Write ONLY to `.manifest.yaml` at the hash-directory level. No other write locations.
- This skill is the sole writer of `.manifest.yaml`. No other skill writes manifest.
- Merge existing `file_paths` when a `.manifest.yaml` already exists — never lose previously indexed paths.
- Skip leaf files with missing or malformed frontmatter silently. Never raise on bad records.
- Do not follow symlinks when walking `.hash-record/`.
- Reject `repo_root` values containing `..` or shell metacharacters.
- Do not write manifest for hash directories that have no leaf records with a valid `file_path` field.
