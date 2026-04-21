---
name: skill-index
description: >-
  Root skill for the skill-index toolkit — a cascading per-directory index
  system that lets agents discover skills by reading compact index nodes
  rather than walking the filesystem.
---

# Skill Index

Root of the skill-index toolkit. Three sub-skills: `skill-index-building` (produce artifacts), `skill-index-crawling` (consume cascade to locate a skill), `skill-index-auditing` (validate cascade, signal rebuild-needed).

**Artifact triple per directory:** `skill.index` (raw, authoritative) | `skill.index.md` (overlay, LLM-authored) | `skill.index.sha256` (SHA-256 of raw bytes)

**Core rules:**
- Raw index authoritative over overlay
- Cascade graph must be acyclic; auditor enforces
- Dot-folders skipped by default; bare-name allow-list overrides
- Symlinks not followed by default
- Index files must NOT use `.md` extension
- Toolkit does not open, execute, or audit skill contents

**Combo node:** directory that is simultaneously a leaf skill and a sub-node parent; emits self entry (`.`) in own index, marked combo in parent index; traversal not suppressed.

**Stamp discipline:** stamp not updated until overlay is refreshed for the same raw index bytes (R18). Exception: no overlay exists yet (R21).

All three sub-skills are dispatch skills — invoke each via Dispatch agent (zero context) using `instructions.txt` in the sub-skill directory.

Related: `skill-index-building`, `skill-index-crawling`, `skill-index-auditing`, `skill-writing`
