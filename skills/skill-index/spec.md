# Skill Index Specification

## Changelog

- R8 removed: pure leaf skills do not receive their own index node. Index nodes exist at the invocation root and every directory on the path down to each leaf skill's parent. A combo node (manifest + descendants) retains its own index because it is also a parent.
- R9 updated: no longer references the deleted R8; self entry requirement stands for combo nodes only.
- Definitions: "Self entry" narrowed to combo nodes.

Normative specification of the skill-index toolkit. This document defines requirements only. All implementation detail (tool invocation, scripting language, file names, directory layout, command flags, output formats, integration points) lives in derived documents (SKILL.md, companion sub-skills, companion tools).

This skill is a **root skill**. It defines the contract for a small family of companion skills and tools that together form the skill-index toolkit. The two canonical sub-skills are the **builder** (creates and updates index artifacts; see `skill-index-building`) and the **crawler** (consumes index artifacts; see `skill-index-crawling`). Every sub-skill or sub-tool must conform to this spec.

---

## Purpose

Ensure agents are aware of the skills available to them.

An agent that reads an index node placed in its working directory must, from that one artifact, either (a) know exactly what skills are directly available at that point in the tree, or (b) know how to navigate the index cascade to locate skills available deeper in the tree — without traversing the full filesystem, loading full skill contents, or guessing at what exists.

The toolkit delivers this awareness by producing a consistent, cheap-to-regenerate, tree-structured index of skills present in a directory hierarchy. An index node placed inside an agent's folder is the agent's discovery surface.

---

## Scope

Applies to any directory tree that contains one or more leaf skills. A leaf skill is any directory containing a skill manifest file. The toolkit produces, maintains, and validates index artifacts across the tree. It does not modify skill contents. It does not execute skills. It does not decide which skills an agent should use.

---

## Definitions

- **Skill tree** — a directory hierarchy containing zero or more leaf skills.
- **Leaf skill** — a directory whose presence is signaled by a skill manifest file. Its folder is the unit of discovery.
- **Skill manifest** — the canonical per-skill runtime file whose presence marks a directory as a leaf skill. Its name is fixed by the `skill-writing` spec (or equivalent external convention) and treated as a given by this spec.
- **Index node** — a plain-text index file at a directory level enumerating referenced descendants: sub-nodes (directories that themselves contain at least one leaf skill) and leaf skills. The common case references direct children; a node may also reference deeper descendants via shortcut entries per R33.
- **Raw index** — the mechanically-generated, deterministic form of an index node. Its content depends only on the presence and names of children.
- **Metadata overlay** — a derived artifact accompanying a raw index, providing human- or agent-facing descriptive content (short descriptions, tags, classifications) not present in the raw index itself.
- **Integrity stamp** — a content hash over a raw index, written by the auditor after a PASS. Signals both that the raw index is structurally valid and that the metadata overlay (if present) was in sync at time of audit. Absence of a stamp means "unaudited since last build," not "raw index content is stale." The auditor's verdict determines whether a build-cycle is needed; stamp absence alone does not.
- **Change manifest** — the output returned by a run of the index toolkit summarizing which index nodes were created, updated, or unchanged.
- **Root node** — the index node at the directory where the toolkit was invoked. Serves as the entry point for downstream consumers.
- **Cascade** — the property that each index node is self-contained: it references only descendants within its own subtree, never ancestors or siblings, and the resulting graph is acyclic (forward reference to R34, which mandates acyclicity).
- **Drift** — the state in which a metadata overlay no longer corresponds to its raw index. Detected by integrity stamp mismatch.
- **Self entry** — an index-node entry that represents the current directory itself. Applies only to combo nodes (a directory that is simultaneously a leaf skill and a parent of further leaf skills). Distinct from an entry for a child. Pure leaf skills — directories with a manifest but no descendant leaf skills — do not receive an index node and therefore do not have a self entry.
- **Combo node** — a directory that is simultaneously a leaf skill (its manifest is present) and a sub-node (it contains at least one descendant leaf skill). A combo node is represented as a self entry in its own index node and as a sub-node-style entry in its parent's index node.
- **Refreshed overlay** — a metadata overlay whose content was generated against a specific raw index and has passed whatever validation that toolkit applies (for example, a compression pass) within the same build step.
- **Shortcut entry** — an entry whose key is a relative path traversing more than one segment. Resolves to a manifest-bearing or index-bearing descendant deeper than a direct child. Enables a node to surface a high-frequency skill or skip a pass-through intermediate layer without requiring an index at every level.
- **Phantom index** — an index file that exists within the invocation root's subtree but is not reachable, directly or transitively, from the root node's cascade. A file nothing points at.
- **Reference loop** — a cycle in the cascade graph. Resolving the entries of one node leads, through one or more shortcut entry resolutions or sub-node descents, back to a node already visited on the same resolution path.

---

## Requirements

### Discovery and Structure

R1. The toolkit must discover leaf skills by the presence of a skill manifest within a directory.

R2. The toolkit must produce an index node at every directory on the path from the invocation root down to each discovered leaf skill's parent.

R3. Each index node's entries must reference descendants within its own subtree. A direct-child entry is the default form; a shortcut entry (multi-segment relative path) is also permitted per R33. References to ancestors, siblings, or targets outside the current node's subtree are prohibited.

R4. Each index node must classify every entry as exactly one of three kinds: a leaf skill, a sub-node, or a combo node. The raw representation of each kind (markers, sigils, separate sections) is fixed by derived documents; this spec requires only that the three be distinguishable from one another.

R5. The invocation root must produce an index node even when no leaf skills exist beneath it. In that case the node enumerates zero children.

R6. An index node must be a plain text artifact. Binary formats are prohibited.

R7. The direct-child portion of a raw index must be deterministic: identical tree input must produce byte-identical direct-child output. Curator-added shortcut entries per R33 are preserved verbatim across builder runs and are not subject to this determinism rule.

### Self Entries and Combo Nodes

R8. Reserved. Pure leaf skills (directories that have a skill manifest but no descendant leaf skills) must not receive their own index node. Index nodes exist at the invocation root and every directory on the path down to each leaf skill's parent; pure leaves are not on that path as parents. A combo node is not a pure leaf (it has descendants) and is not affected by this rule.

R9. When a directory is a combo node, its own index node must contain a self entry representing that directory. The self entry must be distinguishable from entries for children.

R10. When a directory is a combo node, its own index node must also enumerate its manifest-bearing subdirectories as children.

R11. When a directory is a combo node, its entry in its parent's index node must be classified as combo per R4.

R12. A combo node's manifest-bearing subdirectories must be traversed for indexing. The presence of the parent's own manifest does not suppress that traversal.

### Separation of Raw and Derived Content

R13. Raw index content and metadata overlay content must reside in separate artifacts.

R14. A raw index must be regeneratable purely from filesystem structure, with no dependence on prior state or overlays.

R15. A metadata overlay must not be required for an agent to consume the raw index. Overlays enrich discovery; they do not gate it.

### Integrity and Drift Detection

R16. Each raw index should have an associated integrity stamp written by the auditor after a PASS. A missing stamp is not an error condition in itself — it means the index has not yet been audited since the last build. The auditor's fail-fast check (R3 of `skill-index-auditing`) will report the absence and trigger a rebuild-needed verdict, prompting the host to run builder → auditor in sequence.

R17. The stamp must be generated over the raw index's content, not over its filename or metadata.

R18. The integrity stamp must not be written until the auditor runs and returns PASS over the raw index and its accompanying overlay. The builder's write of a refreshed overlay is the precondition for a valid audit; the auditor's PASS is the precondition for the stamp. This two-step sequence (builder then auditor) replaces the prior single-step builder-writes-all model.

R19. When the raw index is regenerated and its content matches the prior version (byte-for-byte identical), the builder performs no writes for that node. If a stamp was already present from a prior audit, it remains valid and need not be re-written.

R20. Drift must be detectable by comparing the current raw index's content hash against its stored integrity stamp. A mismatch means the raw index changed since the last audit pass.

R21. Reserved. The prior no-overlay exception (stamp may be written immediately when no overlay exists for a node) is superseded by R18's two-step builder→auditor model. The auditor validates whatever state is present; if no overlay exists for a node, the audit still runs over the raw index and writes the stamp on PASS.

### Tool Behavior

R22. A toolkit run must be idempotent: running it repeatedly over an unchanged tree must produce no writes beyond the first successful run.

R23. A toolkit run must return a change manifest describing which nodes changed, which were unchanged, and which (if any) are in a drifted state (see Definitions: Drift).

R24. The toolkit must not modify any file outside its own artifact classes (raw indexes, integrity stamps, metadata overlays it owns).

R25. The toolkit must not modify skill manifests or any content belonging to leaf skills.

R26. The toolkit must support a full-rebuild mode that regenerates all artifacts regardless of prior state.

R27. In full-rebuild mode, the builder regenerates all raw indexes and overlays regardless of prior state. Stamps are not written by the builder even in full-rebuild mode — the host agent must invoke the auditor after the builder completes, and only the auditor's PASS triggers stamp writes.

### Composition

R28. The skill-index toolkit is decomposable into distinct sub-skills or sub-tools covering raw generation, metadata derivation, and consumption. Every such component must conform to this spec.

R29. A consumer of a raw index must be able to do so without loading, invoking, or depending on any metadata overlay or sub-tool.

### Traversal Defaults

R30. The toolkit must skip dot-prefixed (hidden) directories by default.

R31. The toolkit must permit an explicit allow-list of dot-prefixed directory names that are traversed in spite of the R30 skip. The allow-list is a plain list of bare directory names (no globbing, no paths, no relative prefixes).

R32. The toolkit must not follow symlinks by default. Following symlinks, if ever enabled, must be an explicit opt-in.

### Shortcut Entries and Structural Integrity

R33. An entry whose key traverses more than one path segment is a shortcut entry. A shortcut entry must resolve to a manifest-bearing directory (when classified as leaf or combo per R4) or an index-bearing directory (when classified as sub-node per R4), located within the current node's subtree. Shortcut entries must not reach above the current node and must not leave the invocation root's subtree. At any single node, no two entries may resolve to the same target directory — whether both are direct-child entries, both are shortcuts, or one of each.

R34. The cascade graph — the directed graph formed by index nodes and the entries they reference — must be acyclic. Resolving entries, whether via direct children, shortcut entries, or sub-node descents, must not return to any node already visited on the same resolution path. The auditor is the primary enforcer per its loop-detection requirement (see `skill-index-auditing`). The crawler must terminate any resolution path that revisits a node. The builder does not generate shortcut entries and therefore cannot introduce cycles via its own operations; builders that preserve curator shortcuts per R36 are not required to re-verify acyclicity at write time, as the auditor owns structural verification.

R35. An index file present within the invocation root's subtree that is not reachable from the root node's cascade (directly or transitively) is a phantom index. The toolkit must report phantom indexes in the change manifest. Their presence alone does not invalidate the cascade — they are janitorial signals, comparable to orphan stamps or orphan overlays.

R36. The builder's mechanical output populates only direct-child entries. Shortcut entries per R33 are curator-added. When the builder runs over a node containing curator-added shortcut entries — in either incremental mode or full-rebuild mode (R26) — it must preserve them: the preserved entries appear in the same raw index file as the regenerated direct-child entries, sorted together per the builder's sort rule, with the shortcut entries' keys and keywords unchanged. The builder must record in its change manifest any preserved shortcut whose target cannot be resolved against the current filesystem; repair or removal of a broken shortcut is a curator decision, not a builder decision. Structural validation of preserved shortcuts (R33 resolution, R34 acyclicity) is the auditor's responsibility, not a build-time gate.

---

## Constraints

C1. The toolkit must not invent, infer, or generate leaf-skill content. It only indexes what already exists.

C2. The toolkit must not use file timestamps, file sizes, or path strings as staleness indicators. Only content-hash comparison is authoritative: the builder compares computed hash of the new raw index against the hash of stored bytes; the auditor validates against the stored stamp.

C3. Metadata overlays must not contradict or override the raw index they describe.

C4. The toolkit must not require network access.

C5. The toolkit must not require elevated privileges.

C6. Index nodes must not use a markdown extension (`.md`) or any filename that invites markdown interpretation.

C7. Derived documents that supply the R31 allow-list must not extend its form beyond bare directory names. Derived documents may populate or empty the list; they may not introduce globs, paths, regexes, or other matching rules.

---

## Behavior

### Invocation

B1. When invoked at a directory, the toolkit must treat that directory as the invocation root and restrict all operations to the subtree rooted there.

B2. When invoked at a directory containing no leaf skills and no descendant leaf skills, the toolkit must still produce a root node (enumerating zero children). The builder produces the raw index and overlay; the auditor writes the stamp after a PASS.

### Mismatch

B3. When the toolkit detects a raw index whose content no longer matches its integrity stamp, it must report the node as drifted in the change manifest.

B4. When the toolkit detects an integrity stamp with no corresponding raw index, it must report the orphaned stamp in the change manifest and must not silently delete it.

B5. When the toolkit detects a metadata overlay with no corresponding raw index, it must report the orphan in the change manifest.

### Write Discipline

B6. The toolkit must write a raw index only if its computed content differs from what is currently stored, or when full-rebuild mode is in effect.

B7. The integrity stamp must be written by the auditor sub-skill, not by the builder. The auditor writes the stamp only on a PASS verdict, after validating the raw index and overlay. On any non-PASS verdict, the stamp is not written (and not deleted). The overlay-sync precondition (R18) is enforced at build time; the stamp confirms the auditor's post-build sign-off, not the overlay's freshness in isolation.

---

## Defaults and Assumptions

D1. Discovery depth defaults to unbounded. A maximum depth limit, if offered, must be explicit and off by default.

D2. The R31 allow-list is empty by default. Each consuming environment supplies its own list of dot-prefixed directory names to traverse.

D3. Metadata overlay content (per-skill descriptions, keyword lists, classifications) is assumed to require language-model processing to produce. It is not mechanically derivable from directory structure alone. The raw index remains purely mechanical; the overlay is the LLM-authored surface. This assumption is informational; R13 and R14 are the normative anchors.

---

## Error Handling

E1. If a directory is unreadable, the toolkit must report the directory in the change manifest and continue processing siblings.

E2. If a skill manifest is unreadable or malformed in a way that still permits directory-level detection of a leaf skill, the toolkit must still emit the leaf entry and flag the manifest condition in the change manifest.

E3. If a raw index cannot be written, the toolkit must leave the prior raw index (and its stamp) untouched and report the write failure.

E4. The toolkit must never leave an index node in a partially written state.

E5. If the change manifest itself cannot be produced, the toolkit must emit a non-zero exit signal and must not silently succeed.

---

## Precedence Rules

P1. Raw index content takes precedence over metadata overlay content. An overlay that contradicts its raw index is invalid.

P2. The integrity stamp is an auditor sign-off, not a builder freshness marker. Its absence after a build means "unaudited since last build," not "needs rebuild." A stamp present but mismatching the current raw index bytes means the index changed since the last audit — a rebuild-needed condition detectable by the auditor.

P3. Filesystem-observed structure takes precedence over any cached prior state.

---

## Footguns

F1: Builder writes the stamp, bypassing the auditor.
Description: The builder implementation writes `skill.index.sha256` as part of its own artifact output, before any audit runs.
Why: A stamp written by the builder — before the cascade is structurally validated — is not a sign-off artifact; it is a freshness marker. Every build run then re-stamps unnecessarily, and the stamp loses its meaning as a post-audit confirmation.
Mitigation: The builder must not write the stamp. Only the auditor writes the stamp, and only on PASS per R22 of `skill-index-auditing`.

F2: Combo node treated as a pure leaf.
Description: A directory that is both a skill and a parent of other skills is marked only as a leaf, and its manifest-bearing subdirectories are skipped.
Why: Skills hidden beneath a combo node become undiscoverable through the index. Consumers that see only the leaf marker never descend.
Mitigation: Enforce R4 (three-way distinction), R9–R11 (combo node representation in both its own index and its parent's), and R12 (traversal not suppressed).

F3: Dot-folder allow-list misused as a path expression.
Description: Derived documents extend the allow-list with glob patterns, paths, or regexes to cover more directories.
Why: The allow-list is a minimal escape hatch for specific hidden directories that actually house skills (for example, a `.agents` folder). Turning it into a path-matching mini-language invites unbounded traversal and defeats the hidden-folder skip.
Mitigation: Enforce C7.

F4: Shortcut entry escapes the subtree.
Description: A curator-added shortcut entry uses `..` segments or an absolute path, reaching a target outside the current node's subtree.
Why: A node that points outside its subtree breaks cascade self-containment. Consumers can no longer reason about a node's scope from the node alone; a hand-edit at one level silently inflates another level's responsibility.
Mitigation: Enforce R33. Shortcut entries must stay within the current node's subtree.

F5: Curator shortcuts form a cycle.
Description: Two curated shortcut entries, each at a different node, reach into each other's subtree in a way that a resolution walk can loop.
Why: Consumers expecting a finite cascade loop indefinitely or repeat work; auditors miss the cause if they only check per-entry resolution without graph-level tracking.
Mitigation: Enforce R34 (acyclic cascade graph). The auditor must detect cycles by tracking visited nodes on each resolution path.

F6: Builder erases curated shortcuts on rebuild.
Description: The builder runs over a node with curator-added shortcuts and overwrites the whole file with mechanical direct-child-only output.
Why: Curated knowledge is lost silently. A rebuild should refresh the mechanical portion without destroying curator intent.
Mitigation: Enforce R36. Builder preserves curator shortcut entries across rebuilds.

---

## Don'ts

N1. The toolkit does not load, execute, validate, or audit skill contents.

N2. The toolkit does not govern skill naming, skill structure, or skill authoring. Those concerns belong to `skill-writing` and related specs.

N3. The toolkit does not version or archive prior index states.

N4. The toolkit does not replace filesystem walks for every use case. It provides a cached, cascading directory of skills for consumers that prefer compact text lookup over traversal.

N5. The toolkit does not define the metadata overlay's content schema. A companion spec or sub-skill (for example, `skill-index-building`) defines what goes into an overlay; this spec only defines that one exists and how it relates to the raw index.
