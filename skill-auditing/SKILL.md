---
name: skill-auditing
description: Audit skill for quality, classification, cost, compliance w/ spec. Triggers: audit skill, check quality, review compliance, validate structure.
---

Apply `../markdown-hygiene` w/ `--fix` to all `.md` files in target skill folder—parallel where supported. Hygiene runs w/ fix—clean before audit every time. Findings→`.hash-record/<file-hash>/markdown-hygiene/claude-haiku.md` records, separate from audit body.

Then spawn zero-context haiku subagent (background if supported):

**Claude Code:** `Agent` tool. Pass: `"Read and follow instructions.txt here. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]"`

**Copilot:** `runSubagent(model: "Claude Haiku 4.5", prompt: "Read and follow instructions.txt in <skill_dir>. Input: skill_path=<path> --filename claude-haiku [--fix] [--uncompressed]")`

Returns: `PATH: <abs-path-to-record.md>` (success) or `ERROR: <reason>`.

Non-haiku: see `../hash-record/filenames.md` for canonical `--filename` value.

Don't read/interpret `instructions.txt`—delegate to subagent.
