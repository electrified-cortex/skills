---
name: hash-stamping
description: SHA-256 integrity stamp suite. Verify stamp drift or write/update stamps. Triggers — verify stamp, check integrity, detect drift, update sha256, stamp this file, hash mismatch.
---

# Hash Stamping

Suite of two dispatch skills for managing SHA-256 integrity stamps alongside tracked artifacts.

## Sub-skills

- **`hash-stamp-audit/`** — verify stamps, detect drift. Use when checking whether a file has changed since its last stamp (e.g., triggering an audit, pre-merge check, CI gate).
- **`hash-stamp/`** — write or update `.sha256` companions. Use after editing any stamped file.

## Stamp Policy

Stamp files that agents load and act upon where silent drift could cause incorrect behavior. Common candidates: skill files (`SKILL.md`, `instructions.txt`, `spec.md`), agent definition files (`CLAUDE.md`), `skill.index`, and automation scripts. Do not stamp logs, temp files, generated outputs, or code (git covers those).

## Dispatch

Each sub-skill is a dispatch skill. Pass its `instructions.txt` to a Dispatch agent (zero context) rather than reading it yourself.
