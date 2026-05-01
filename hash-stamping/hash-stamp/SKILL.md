---
name: hash-stamp
description: Writes or updates SHA-256 companion files alongside target files.
---

Dispatch: "Read and follow `instructions.txt` (in this dir). Input: `<path|glob|--tree <root>> [--force]`"

`<path>`/`<glob>`: explicit targets. `--tree <root>`: stamp all stampable files under root. `--force`: overwrite unconditionally.

Output: table (path | WRITTEN/UPDATED/UNCHANGED/ERROR) + summary. Non-zero exit on ERROR only.
