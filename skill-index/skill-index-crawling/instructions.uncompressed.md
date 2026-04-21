# Skill Index Crawling — Agent Instructions

Dispatch skill. You are a haiku-class agent operating in zero context. Your job is to locate the skill that matches a stated need by reading only index nodes — never skill contents, never the filesystem, never ancestor nodes. You produce one output: a crawl report. You modify nothing.

---

## Inputs

- `root` (required): absolute path to the directory containing the starting `skill.index`. This is your working directory for the crawl.
- `need` (required): the agent's stated need as a plain phrase (e.g. `compress text`, `audit cascade`, `build index`).

---

## Outputs

Return a crawl report (see Report Format below). That is your only output. You do not write, modify, or create any file.

---

## Procedure

Follow these steps in order. Stop as soon as a stop condition is met.

### Step 1 — Open the starting node

Open `skill.index` at `root`. If the file does not exist: return outcome `no index here` and stop. If the file exists but cannot be read: return outcome `unreadable node` with the path and stop.

### Step 2 — Parse entries

Parse each line of `skill.index` as one entry in the form `key: keyword, keyword, keyword`:
- Split at the first colon. Everything before the first colon is the entry key. Everything after (trimmed) is the keyword list, split on `, `.
- Malformed lines (no colon, empty key, forbidden characters): record in the crawl report under `inconsistencies` and skip that line. Other entries at the same node remain usable.

### Step 3 — Check the stamp

Open `skill.index.sha256` at the current node's directory. Compute the SHA-256 of the stored bytes of `skill.index`. Compare:
- Match: overlay is trusted for this node (if needed for disambiguation).
- Mismatch or file missing: overlay is untrusted for this node. Record the finding in `inconsistencies`. The raw index is still usable; only overlay-based disambiguation is suppressed at this node.

### Step 4 — Match entries against the need

Case-fold both the `need` phrase and all entry keys and keywords. Declare an entry a Hit when `need` appears as a substring of the entry key or of any of the entry's keywords. Collect all Hits.

### Step 5 — Rank Hits

Apply ranking:
- Self entry (key `.`) or plain leaf entry (key with no trailing `/`) beats a descent-marked entry (key ending in `/`) when ranking is otherwise equal.
- If the overlay is trusted and two or more Hits are tied after the above ranking: consult `skill.index.md` for the tied entries to break the tie. The overlay may only be used to disambiguate among existing Hits — it cannot produce new candidates not already in the raw index.

### Step 6 — Evaluate Hits

- Exactly one Hit survives ranking: proceed to Step 7 with that Hit.
- No Hits at the current node: return outcome `no match` and stop.
- Two or more Hits remain tied after overlay consultation: return outcome `ambiguous` and stop.

### Step 7 — Resolve the Hit

- Hit is a plain leaf (no trailing `/` on key): the skill lives at `<current node directory>/<key>/`. Return outcome `hit` with the resolved path and stop.
- Hit is a self entry (key `.`): the skill lives at the current node's directory. Return outcome `hit` with the path and stop.
- Hit is descent-marked (key ending in `/`): this entry points to a deeper index. Proceed to Step 8.

### Step 8 — Descend

Determine the target path:
- Single-segment key (e.g. `foo/`): target is `<current node directory>/foo/`.
- Multi-segment key / shortcut entry (e.g. `tools/compression/`): walk each segment from the current node's directory. At every step, verify the resolved path does not contain `..` segments, does not use an absolute-path indicator, and does not escape above the invocation root. If any step escapes: record `subtree-escape` in `inconsistencies`, return outcome `subtree-escape` and stop.

Check for a reference loop: if the resolved target directory is already in the ordered set of nodes visited on the current resolution path, return outcome `reference loop` with the full ordered visited sequence and stop.

Otherwise: append the resolved target to the visited set. Open `skill.index` inside the resolved target. If `skill.index` is missing there: record `broken descent` in `inconsistencies` and treat this entry as absent (remove from candidate set at the current node, re-evaluate remaining candidates from Step 6). If `skill.index` exists: make the resolved target the new current node and return to Step 2.

### Combo Entry Handling

A combo entry is a descent-marked entry whose target also has a self entry in its own `skill.index` — meaning the target is simultaneously a skill and a parent of further skills. Handle as follows:
1. Attempt to match as a plain leaf first (as if it had no trailing `/`).
2. If the leaf produces a Hit at the current ranking step, return it.
3. If the leaf does not produce a Hit, descend into the sub-node and re-apply from Step 2.

---

## Entry Type Reference

| Key form | Meaning |
| --- | --- |
| `foo` | Leaf skill at `<current dir>/foo/` |
| `foo/` | Sub-node: descend into `<current dir>/foo/skill.index` |
| `.` | Self entry: the current directory is itself a skill |
| `a/b/c/` | Shortcut entry with descent marker: walk path, open `skill.index` at `c/` |
| `a/b/c` | Shortcut leaf: walk path, skill lives at `c/` — no deeper index to open |

---

## Stop Conditions

| Outcome | Condition |
| --- | --- |
| `hit` | Exactly one Hit survives ranking; resolved path returned |
| `no index here` | `skill.index` absent at the working directory |
| `no match` | Current node produces no Hits |
| `ambiguous` | Two or more Hits remain tied after overlay consultation |
| `reference loop` | Descent would land on a node already in the visited set |
| `subtree-escape` | Shortcut resolution attempts to leave the invocation root's subtree |
| `unreadable node` | `skill.index` exists but cannot be read |
| `broken descent` | Descent target lacks required file; entry treated as absent |

---

## Visited-Node Tracking

Maintain an ordered list of every node visited on the current resolution path. A node is added to the list when you first open its `skill.index`. Track across all descent kinds: direct-child descent, shortcut path-walk endpoint, and combo sub-node descent. Before opening any new node, check whether its directory is already in the list. If it is: reference loop, stop per R17. This list is scoped to the current resolution path from `root` to the current node; it does not persist across separate crawls.

---

## Overlay Trust Rules

- The overlay (`skill.index.md`) is consulted only to break ties among existing Hits after raw-index ranking.
- The overlay is trusted only when its stamp matches the SHA-256 of the current raw index bytes.
- Missing stamp or stamp mismatch: overlay is untrusted for that node; raw index only.
- The overlay never produces new candidates.

---

## Error Handling

- `skill.index` missing at root: outcome `no index here`, stop.
- `skill.index` unreadable: outcome `unreadable node` with path, stop.
- Malformed entry line: record in `inconsistencies`, skip that line, continue.
- Missing stamp: overlay untrusted for that node; record in `inconsistencies`, continue.
- Stamp mismatch: same as missing stamp.
- Broken descent target: record `broken descent` in `inconsistencies`, treat entry as absent, re-evaluate remaining candidates.
- Shortcut path intermediate segment missing: record `broken shortcut path` (identifying first missing segment) in `inconsistencies`, treat entry as absent, continue with remaining candidates.

---

## Crawl Report Format

```
## Crawl Report

need: <stated need phrase>
root: <absolute path>
outcome: hit | no match | ambiguous | reference loop | subtree-escape | no index here | unreadable node

### Hit
key: <entry key>
resolved path: <absolute path to skill directory>
(omit this section when outcome is not hit)

### Visited Nodes
1. <absolute path to node 1>
2. <absolute path to node 2>
...

### Inconsistencies
- <finding type>: <description>
(omit if none)
```

---

## Fail-Fast Rules

- If `root` is not provided or the directory does not exist: stop immediately, return `no index here`.
- If `need` is empty: stop immediately, report the missing parameter.
- Never open files inside a skill's own folder (only `skill.index`, `skill.index.md`, `skill.index.sha256` are permitted reads).
- Never climb above the invocation root.
- Never follow a descent marker that is not explicitly present in the current raw index.

---

## Don'ts

- Do not produce, author, or update any file.
- Do not open skill contents (any file other than the three index artifacts).
- Do not climb above the working directory.
- Do not trust the overlay when its stamp is absent or mismatched.
- Do not follow a shortcut entry out of the invocation root's subtree.
- Do not consult the network.
- Do not cache results across separate crawl runs.
