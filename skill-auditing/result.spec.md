# result.spec.md - skill-auditing result tool

## Purpose

Wraps `hash-record-manifest` for `skill-auditing` and translates a HIT into the cached audit verdict. Host calls `result` to read the on-disk audit-record state — at cache-check time AND at post-execute validation time. Same script, same return shape, both calls.

Read-only.

## Parameters

| Positional | Type | Required | Description |
| ---------- | ---- | -------- | ------------------------------------------- |
| `skill_dir` | string | yes | Absolute path to the skill folder being audited. |

`--help` / `-h` — print usage, exit 0.

The tool hashes ONLY the semantic content files of the skill bundle. Whitelist (in this exact order — order is part of the manifest hash key, do NOT reorder): `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md`. Files that exist are included; files that don't, are skipped. Non-semantic files (stamps, scripts, logs, generated artifacts) are NOT hashed — including them caused indeterminism between pre- and post-dispatch calls when those files mutated mid-run. The result tool delegates manifest computation to `hash-record-manifest` for the cache lookup.

## Procedure

1. Validate `<skill_dir>` is an existing directory. If not -> `ERROR: skill_dir not found: <path>`, exit 1.

2. Look up the semantic-file whitelist in `<skill_dir>` (top-level only, NOT recursive) in this exact order: `SKILL.md`, `instructions.txt`, `spec.md`, `uncompressed.md`, `instructions.uncompressed.md`. Include each file that exists; skip each that does not. Order is part of the manifest hash key — do NOT sort, reorder, or rearrange. At least one MUST be found or -> `ERROR: no semantic content files found in skill_dir`, exit 1.

3. Invoke `hash-record-manifest` (sibling tool — do NOT reimplement) with:
   - `op_kind` = `skill-auditing/v2`. Single canonical op_kind; no compiled/uncompressed split.
   - `record_filename` = `report.md`
   - `files` = the enumerated list (absolute paths).

4. Branch on its stdout:
   - `MISS: <abs-path>` -> emit `MISS: <abs-path>`, exit 0.
   - `ERROR: <reason>` -> emit `ERROR: <reason>`, exit 1.
   - `HIT: <abs-path>` -> read the frontmatter `result:` field of `<abs-path>`:
     - `clean` -> emit `CLEAN: <abs-path>`, exit 0.
     - `pass` -> emit `PASS: <abs-path>`, exit 0.
     - `findings` -> read the body `**Verdict:**` line to determine specific verdict:
       - body contains `FAIL` -> emit `FAIL: <abs-path>`, exit 0.
       - otherwise -> emit `NEEDS_REVISION: <abs-path>`, exit 0.
     - `error` -> emit `ERROR: <abs-path>`, exit 0.
     - any other value -> emit `ERROR: malformed cache record at <abs-path>`, exit 1.

## Output

One line, no trailing whitespace, LF terminator. Forward-slash paths.
See Procedure step 4 for branch logic. This table is authoritative; Procedure step 4 is the implementation.

| Condition | Output | Exit |
| ------------------------------------------------------ | ------------------------------- | ---- |
| HIT, `result: clean` | `CLEAN: <abs-path>` | 0 |
| HIT, `result: pass` | `PASS: <abs-path>` | 0 |
| HIT, `result: findings`, body verdict = NEEDS_REVISION | `NEEDS_REVISION: <abs-path>` | 0 |
| HIT, `result: findings`, body verdict = FAIL | `FAIL: <abs-path>` | 0 |
| HIT, `result: error` | `ERROR: <abs-path>` | 0 |
| MISS | `MISS: <abs-path>` | 0 |
| Argument or runtime error | `ERROR: <reason>` | 1 |

The host:

- `CLEAN: <path>` -> done; audit clean — no findings.
- `PASS: <path>` -> done; cached audit said pass.
- `NEEDS_REVISION: <path>` -> done with findings; caller may dispatch a fix pass.
- `FAIL: <path>` -> done with fail verdict; caller surfaces.
- `MISS: <path>` -> dispatch the skill-auditing executor with `--report-path <path>`.
- `ERROR: <reason>` -> stop, surface reason.

## Constraints

- Read-only. Never writes. Never modifies the target or the cache record.
- Frontmatter parsing is line-based (`^result:` line, first whitespace-separated token after `:`).
- Forward-slash paths. ASCII output.
- Both `result.sh` (Bash) and `result.ps1` (PowerShell 7+); byte-identical stdout.
- Delegates manifest computation entirely to `hash-record-manifest` — no duplication.
- Skill version (`v2`) is hardcoded in the script. Bump version + update script in lockstep when contract changes.

## Don'ts

- **No compiled/uncompressed cache split.** Single canonical `op_kind = skill-auditing/v2`. If both compressed and uncompressed audit sources need their own audit records, they coexist as sibling files inside `<op>/<version>/` (e.g. `report.md` + `uncompressed.md`) — never as parallel `<op>/<version>-compiled/` and `<op>/<version>-uncompressed/` folders.
- **No version dot-subversions.** Version segment is `v<N>` flat integer (cache-bust key). `v2.1` / `v2.0.3` are red flags — surface and revert.

## Dependencies

- `hash-record-manifest` (sibling at `../hash-record/hash-record-manifest/`).

## Examples

```bash
bash result.sh /repo/skills/some-skill
# -> MISS: /repo/.hash-record/ab/abcdef.../skill-auditing/v2/report.md
# -> PASS: /repo/.hash-record/ab/abcdef.../skill-auditing/v2/report.md
# -> NEEDS_REVISION: /repo/.hash-record/ab/abcdef.../skill-auditing/v2/report.md
# -> FAIL: /repo/.hash-record/ab/abcdef.../skill-auditing/v2/report.md

bash result.sh --help
```
