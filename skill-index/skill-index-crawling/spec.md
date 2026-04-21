---
name: skill-index-crawling
description: >-
  Specification for the consumer half of the skill-index toolkit — how an agent
  opens, reads, and descends a skill-index cascade to locate a skill without
  walking the filesystem.
type: spec
---

# Skill Index Crawling Specification

Normative spec for the consumer. The crawler uses existing index artifacts to locate a skill. It is read-only; see Don'ts. Conforms to the root `skill-index` spec.

---

## Purpose

Let an agent locate the skill that matches its need by reading only index nodes — never skill contents, never the raw filesystem, never ancestor nodes.

---

## Scope

Applies to any agent that holds a working directory containing a `skill.index` artifact, or a pointer to such a directory. Covers parsing, matching, descent, and stop conditions.

---

## Definitions

- **Crawler** — the actor performing operations defined by this spec.
- **Artifact triple** — the three files the builder emits at each indexed directory: `skill.index` (raw), `skill.index.md` (overlay), `skill.index.sha256` (stamp).
- **Current node** — the `skill.index` at the crawler's current indexing position.
- **Overlay** — the optional `skill.index.md` accompanying the current node.
- **Stamp** — the `skill.index.sha256` accompanying the current node.
- **Entry** — a single line of the current node, in the form `key: keyword, keyword, keyword`.
- **Entry key** — the portion of an entry before the first colon.
- **Descent marker** — a trailing `/` on an entry key, signalling that a deeper `skill.index` exists inside the target directory.
- **Self entry** — an entry whose key is `.`, signalling that the current directory itself contains a skill.
- **Combo entry** — an entry whose key carries a descent marker AND whose corresponding target emits a self entry in its own `skill.index`. The target is both a skill and a sub-node. A combo entry in the crawler's view corresponds to a *combo node* in the root spec's terminology — same structural concept, viewed from the parent index.
- **Shortcut entry** — an entry whose key is a relative path traversing more than one segment (e.g. `skills/compression/` or `vendor/bar/baz/`). Resolves to a descendant deeper than a direct child. A shortcut entry without a trailing descent marker resolves to a leaf skill at the path's end; one with a trailing descent marker resolves to a deeper `skill.index`. Per root spec R33, a shortcut entry's key must not ascend out of the invocation root's subtree (no `..` segments, no absolute paths).
- **Hit** — an entry whose key or keywords satisfies the match rule against the agent's stated need.
- **Match rule** — the case-insensitive containment check defined in R7.
- **Crawl report** — the structured result the crawler returns to its caller, containing the hit (if any), the path of nodes visited, and any inconsistencies observed.

---

## Requirements

### Locating the Current Node

R1. The crawler must resolve the current node by opening `skill.index` in its working directory. If no such file exists, the crawler must return a crawl report with outcome "no index here" and stop.

R2. The crawler must not walk the filesystem searching for a `skill.index` above or below its working directory.

### Parsing

R3. The crawler must parse each line of `skill.index` as a single entry. Malformed lines must be recorded in the crawl report and skipped.

R4. The crawler must split each entry at the first colon: the portion before the colon is the entry key, the portion after is the keyword list. The keyword list splits on `, `.

R5. The crawler must recognize a self entry (key is exactly `.`) and treat it as a candidate for the current directory's own skill.

R6. The crawler must recognize a descent marker (key ending in `/`) and treat such an entry as a candidate for downward traversal, not as a leaf skill.

R6a. The crawler must recognize a shortcut entry (key containing more than one path segment). When descending via a shortcut entry, the crawler must walk the relative path from the current node to reach the target. A shortcut entry without a descent marker resolves to a leaf skill at the path's end; a shortcut entry with a descent marker resolves to a deeper `skill.index`. R6a is a sub-rule elaborating R6 — shortcut entries are a specialization of the descent-recognition rule.

R6b. When walking a shortcut path, the crawler must verify that no resolved segment ascends above the invocation root and that the key contains no `..` segment and no absolute-path indicator. A shortcut whose resolved target lies outside the invocation root's subtree must be recorded in the crawl report as `subtree-escape` and must not be followed. This applies to every step of the walk, not only the final target.

### Matching

R7. The crawler must declare an entry a Hit when, after case-folding both sides, the agent's stated need appears as a substring of the entry key or of any of the entry's keywords. No other match rules apply.

R8. When two or more entries are Hits within the same node, the crawler must prefer a self entry or a plain leaf over a descent-marked entry, on the grounds that a leaf resolves in one step.

R9. The crawler must consult the overlay only to disambiguate between Hits whose ranking under R8 is tied. The overlay must not produce new candidates that are not already Hits against the raw index.

### Descent

R10. When the best candidate at the current node is a descent-marked entry, the crawler must resolve the target per R6a (and, for shortcut entries, R6b) and open that target's `skill.index`. The crawler then re-applies this procedure at the newly opened node. R10 delegates all resolution mechanics to R6a/R6b; it does not redefine them.

R11. Each descent lands on exactly one new node, regardless of how many path segments the shortcut traversed. The crawler re-evaluates from that new node.

R11a. The crawler must track the set of nodes it has visited on the current resolution path. If a descent would land on a node already visited, the crawler must halt per R17 (reference loop stop condition). Loop detection prevents unbounded walks through curated shortcuts. R11a is a sub-rule elaborating R11 — the single-new-node invariant guarded against cycle violations.

R12. The crawler must handle a combo entry as a leaf first.

R13. When the combo entry's leaf does not produce a Hit, the crawler must descend into its sub-node and re-apply this procedure there.

### Stop Conditions

R14. The crawler must stop and return the hit as its crawl report outcome as soon as exactly one Hit survives ranking at a node.

R15. The crawler must stop and return outcome "no match" when the current node produces no Hits.

R16. The crawler must stop and return outcome "ambiguous" when two or more Hits remain tied after overlay consultation.

R17. The crawler must stop and return outcome "reference loop" when a descent step (direct, shortcut, or combo sub-node) would revisit a node already present on the current resolution path per R11a. The crawl report must include the ordered sequence of visited nodes.

R18. The crawler must stop and return outcome "subtree-escape" when a shortcut resolution under R6b attempts to leave the invocation root's subtree. The crawl report must identify the offending entry and the segment at which escape was detected.

---

### Numbering Convention

Rules use integer IDs. A letter suffix (e.g. `R6a`, `R11a`) marks a sub-rule that elaborates the integer parent — R6a elaborates R6 (descent-marker recognition specialized to shortcuts); R6b elaborates R6 (subtree-escape guard on shortcut path-walks); R11a elaborates R11 (single-new-node invariant guarded by loop detection). Parent and sub-rule are jointly binding; a conforming implementation satisfies both.

---

## Constraints

C1. The crawler must not access the network.

C2. The crawler must not modify any index artifact.

C3. The crawler must not open any file within a skill's folder while crawling.

C4. The crawler must not descend into a path that is not the target of a descent marker at the current node.

C5. The crawler must not produce, author, or update any file.

---

## Behavior

B1. The crawler's sole output is the crawl report. All reported inconsistencies (missing stamp, stamp mismatch, malformed entry, broken descent) are entries in that report, not side effects.

B2. When the stamp is missing, or when it is present but disagrees with the SHA-256 of the raw index's current stored bytes (overlay-stamp drift), the crawler must downgrade the overlay to untrusted for the current node: the overlay is not consulted for disambiguation at this node. Missing and mismatched stamps receive identical treatment; both are recorded in the crawl report.

B3. A malformed entry is recorded and skipped; other entries at the same node remain usable.

---

## Defaults and Assumptions

D1. Keyword and key matching is case-insensitive by default.

D2. Keyword order within an entry is unordered.

D3. The current node is authoritative for its directory; prior crawls are not cached between runs.

---

## Error Handling

E1. `skill.index` missing at the working directory: return outcome "no index here" and stop.

E2. `skill.index` unreadable: return outcome "unreadable node" with the path and stop.

E3. Descent target lacks a `skill.index`: record "broken descent" in the crawl report and treat that child as absent from the current node's candidate set.

E4. Overlay drift (stamp mismatch or stamp missing): downgrade the overlay per B2 and continue.

E5. When walking a shortcut path, if any intermediate directory in the path does not exist on disk, the crawler must record `broken shortcut path` in the crawl report (identifying the first missing segment) and treat the entry as absent from the current node's candidate set. The crawler does not halt; resolution proceeds with remaining candidates at the current node.

E6. When walking a shortcut path, if the final target directory exists but lacks a `skill.index` (for a shortcut entry carrying a descent marker) or lacks any skill manifest (for a shortcut entry without a descent marker), treat per E3 — record `broken descent` and continue.

---

## Precedence Rules

P1. Raw index is authoritative over overlay for entry identity, descent markers, and self entries.

P2. Leaf Hits take precedence over descent-marked Hits when ranking is otherwise equal.

P3. Current-node data takes precedence over any cached prior crawl.

---

## Footguns

F1: Overlay consulted before ranking against raw index.
Description: The crawler suggests a candidate that appears in the overlay but has no corresponding entry in the raw index.
Why: The overlay is human-authored prose and may outlive the entry it describes. Only the raw index is authoritative.
Mitigation: Always compute Hits against the raw index first. The overlay is consulted only to disambiguate ties among Hits that already exist.

F2: Stamp mismatch ignored.
Description: The crawler trusts overlay text that no longer corresponds to the current raw index.
Why: When the stamp does not match the current raw index bytes, the overlay was authored for a different index and its descriptions may be wrong.
Mitigation: On stamp mismatch, downgrade the overlay to untrusted for that node per B2. Do not consult it for disambiguation at that node.

F3: Crawler climbs or scans outside the working directory.
Description: The crawler searches parents, siblings, or deep subtrees for a `skill.index` beyond the one at its working directory.
Why: The entire point of the toolkit is to avoid filesystem walks. A crawler that wanders reintroduces the cost it exists to eliminate.
Mitigation: Only open a `skill.index` at the working directory, and only descend via descent markers explicitly present in the current node.

F4: Shortcut entry escapes the invocation root's subtree.
Description: A malformed or malicious shortcut entry uses `..` segments or an absolute-path indicator, reaching a target outside the invocation root's subtree.
Why: Every path outside the subtree is invalid per root spec R33; reading one exposes the crawler to arbitrary filesystem content.
Mitigation: Enforce R6b at every step of every shortcut walk. Record as `subtree-escape` and halt per R18.

F5: Cycle detection skipped on non-shortcut descents.
Description: The crawler tracks visited nodes only when walking shortcut paths, not on direct-child or combo descents.
Why: A cycle can form through any descent kind — direct, shortcut, or combo sub-node. Tracking only one path kind is a silent gap.
Mitigation: Enforce R11a on every descent step regardless of kind. Halt per R17 on revisit.

---

## Don'ts

N1. The crawler does not produce, author, or update any artifact (see C5).

N2. The crawler does not open skill contents.

N3. The crawler does not climb above the working directory.

N4. The crawler does not trust the overlay when its stamp is absent or does not match the current raw index content (per B2).

N5. The crawler does not follow a shortcut entry out of the invocation root's subtree (per R6b, R18).
