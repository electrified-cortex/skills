---
name: skill-index-crawling
description: >-
  Reads an existing skill-index cascade to locate the skill matching an
  agent's stated need — read-only, no filesystem walking.
---

Dispatch (Dispatch agent, zero context): "Read and follow `instructions.txt` (in this directory). Input: `root=<path> need=<phrase>`"

`root` (required): absolute path to starting directory (must contain `skill.index`).
`need` (required): the agent's stated need as a plain phrase.

**Procedure:**
1. Open `skill.index` at `root`. Missing → outcome "no index here", stop.
2. Parse lines: `key: keyword, keyword, keyword`. Malformed → record, skip.
3. Check stamp: SHA-256 of raw bytes vs `skill.index.sha256`. Mismatch/missing → overlay untrusted for this node; record in report.
4. Match (case-insensitive substring): need appears in key or any keyword → Hit.
5. Rank: self entry / plain leaf beats descent-marked. Consult overlay only to break ties among existing Hits (overlay never produces new candidates).
6. Exactly one hit → return it. No hits → "no match". Tied → "ambiguous".
7. Descent-marked hit → resolve target, open its `skill.index`, repeat from step 2. Track every visited node on current path; revisit → "reference loop", stop.
8. Shortcut key (multi-segment): walk path from current node; check no `..` or absolute escapes at every step → else "subtree-escape", stop.
9. Combo entry: try as leaf first; if no hit, descend into sub-node.

**Outcomes:** hit | "no index here" | "no match" | "ambiguous" | "reference loop" | "subtree-escape" | "unreadable node" | "broken descent"

**Crawl report fields:** outcome, hit (key + resolved path), visited (ordered node list), inconsistencies.

Read-only. Never modifies any file. Never opens skill contents. Never climbs above working directory.

Related: `skill-index`, `skill-index-building`, `skill-index-auditing`
