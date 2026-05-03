---
name: hash-record-rekey
description: Re-key a stale hash-record entry after a file's content changes. Finds the old record under any blob hash, moves it to the new hash path via git mv. Triggers — rekey hash-record, move stale hash record, update hash record after lint, refresh hash-record key, phase 4A rekey, hash-record-rekey.
---

Invoke directly via Bash or PowerShell — no agent dispatch.

```bash
bash rekey.sh <file_path> <op_kind> <record_filename>
pwsh rekey.ps1 <file_path> <op_kind> <record_filename>
```

Pass `--help` / `-h` to print usage.

**Arguments** (all required, positional):

- `file_path` — absolute path to the changed file (new content, not yet committed).
- `op_kind` — operation kind, e.g. `markdown-hygiene` or `skill-auditing/v2`. May contain `/`.
- `record_filename` — leaf filename, e.g. `claude-haiku.md`. No path separators or `..`.

**Output** (stdout, one line):

| Line | Meaning | Exit |
| --- | --- | --- |
| `REKEYED: <abs-path>` | Record moved to new hash path. | 0 |
| `CURRENT: <abs-path>` | Hash unchanged; no move needed. | 0 |
| `NOT_FOUND: ...` | No record for this op_kind/record_filename. | 0 |
| `AMBIGUOUS: <n> ...` | Multiple records found; manual resolution required. | 1 |
| `ERROR: <reason>` | Argument or runtime error. | 1 |

Moves at the **record-file level** (`git mv` of the individual `<record_filename>`). Creates the target parent directory before moving. Leaves the old hash directory if other records remain there.

**Script locations** (relative to this folder):

- `rekey.sh` — Bash implementation.
- `rekey.ps1` — PowerShell 7+ implementation.

Full CLI contract: `spec.md`. Usage guide: `instructions.txt`.

Related: `hash-record`, `hash-record-check`, `hash-record-prune`
