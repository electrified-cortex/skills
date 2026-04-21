# Skill Index

Root skill for the skill-index toolkit. Governs a family of sub-skills that together let agents discover available skills by reading compact index nodes rather than walking the filesystem.

## What This Skill Covers

The skill-index toolkit produces and validates a cascading, tree-structured index of skills present in a directory hierarchy. An index node placed in an agent's working directory is the agent's complete discovery surface for that directory and its descendants. The agent reads the node; it does not traverse the filesystem.

The toolkit is decomposable into three sub-skills:

- `skill-index-building` — creates and updates the three artifacts at each indexed directory: `skill.index` (raw index), `skill.index.md` (metadata overlay), `skill.index.sha256` (integrity stamp).
- `skill-index-crawling` — reads an existing cascade to locate a skill matching an agent's stated need without opening skill contents.
- `skill-index-auditing` — validates an existing cascade and returns a rebuild-needed signal when the cascade is stale or structurally broken.

## Core Concepts

**Artifact triple.** Every indexed directory holds three files: `skill.index` (plain text, deterministic, the authoritative record), `skill.index.md` (human/agent-facing descriptions, LLM-authored), and `skill.index.sha256` (SHA-256 hex digest of `skill.index`'s stored bytes).

**Index node.** A `skill.index` file. Each line is one entry: `key: keyword, keyword, keyword`. Entries reference direct children by default; multi-segment shortcut entries (curator-added) reference deeper descendants. Every node is self-contained — it references only descendants within its own subtree.

**Cascade.** The directed acyclic graph formed by index nodes and the entries they reference. Self-contained. No cycles.

**Leaf skill.** Any directory containing a skill manifest file. The unit of discovery.

**Combo node.** A directory that is simultaneously a leaf skill and a parent of further leaf skills. Emits a self entry (key `.`) in its own `skill.index` and is marked as combo in its parent's `skill.index`.

**Integrity stamp.** SHA-256 hex digest of the raw index's exact stored bytes. The stamp is not updated until its metadata overlay is refreshed for the same raw index content. This prevents consumers from trusting a stale overlay.

**Drift.** When a metadata overlay no longer corresponds to its raw index, detected by stamp mismatch.

## Key Rules

- The toolkit does not load, execute, or validate skill contents — only their presence.
- Raw index content is authoritative over overlay content at all times.
- The cascade graph must be acyclic. The auditor enforces this; the crawler terminates loops at consumption time.
- Dot-prefixed directories are skipped by default. An explicit allow-list of bare directory names overrides the skip for those names only.
- Symlinks are not followed by default.
- Index files must not use a markdown extension (`.md`).
- The toolkit does not require network access or elevated privileges.

## Footguns

F1: Stamp updated before overlay refresh.
Mitigation: Enforce spec R18. Only update the stamp once the overlay has been refreshed for the new raw index. R21 is the only exception (no overlay exists yet).

F2: Combo node treated as a pure leaf.
Mitigation: Enforce spec R4, R9–R12. A combo node must emit a self entry and enumerate its manifest-bearing subdirectories. Traversal is not suppressed.

F3: Dot-folder allow-list misused as path expression.
Mitigation: Enforce spec C7. Allow-list entries are bare directory names only — no globs, paths, or regexes.

F4: Shortcut entry escapes the subtree.
Mitigation: Enforce spec R33. Shortcut entry keys must not use `..` segments or absolute paths. Target must remain within the current node's subtree.

F5: Curator shortcuts form a cycle.
Mitigation: Enforce spec R34. The auditor tracks visited nodes on each resolution path and flags any revisit.

F6: Builder erases curated shortcuts on rebuild.
Mitigation: Enforce spec R36. The builder preserves curator-added shortcut entries verbatim across all runs.

## Sub-Skill Invocation

All three sub-skills are dispatch skills — invoke each via a Dispatch agent (zero context) with `instructions.txt` in the respective sub-skill directory.

- Builder: `skill-index-building/instructions.txt`
- Crawler: `skill-index-crawling/instructions.txt`
- Auditor: `skill-index-auditing/instructions.txt`

## Don'ts

- The toolkit does not load, execute, validate, or audit skill contents.
- The toolkit does not govern skill naming, structure, or authoring — see `skill-writing`.
- The toolkit does not version or archive prior index states.
- The toolkit does not replace filesystem walks for every use case — it provides a cached cascading directory for consumers that prefer compact lookup.
- The toolkit does not define the metadata overlay's content schema — that is `skill-index-building`'s concern.

## Related

- `skill-index-building` — produces the three artifacts per indexed directory
- `skill-index-crawling` — reads the cascade to locate a skill
- `skill-index-auditing` — validates the cascade and triggers rebuilds
- `skill-writing` — governs skill naming, structure, and authoring
