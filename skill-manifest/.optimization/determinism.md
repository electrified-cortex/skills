# DETERMINISM — 2026-05-08

## Findings

### DETERMINISM — HIGH

**Signal:** Subagent executes a fully algorithmic ref walk, but the task is dispatched to
an LLM on every cache miss.

**Reasoning:** Every step in `instructions.uncompressed.md` is deterministic:

- **Ref extraction (Step 1b):** Three explicit pattern rules — backtick-wrapped paths,
  markdown links, and a fixed exclusion list (URLs, anchors, `*/` prefixes). These are
  directly expressible as regex. The instructions ask the LLM to apply enumerated rules,
  not to exercise judgment.
- **BFS walk:** Standard queue/visited algorithm; no ambiguity.
- **Path resolution:** Relative-to-file-dir; deterministic given the rules in 1b.
- **Dedup and sort:** Mechanical data operations.
- **Cache write and JSON output:** Tool calls.

`spec.md` states "An LLM resolves refs from content semantics, not regex alone" — but
`instructions.uncompressed.md` does not ask the LLM to exercise semantic judgment beyond
the three listed patterns. This is a spec/instructions mismatch: either the spec
overstates the LLM requirement, or the instructions underspecify the edge-case judgment
that justifies LLM dispatch. As written, the subagent is executing a script, not making
decisions.

**Recommendation:** Two options for operator decision:

1. **Replace with deterministic tool:** Extract the ref-walk algorithm into a
   `skill-manifest-scan` script (PowerShell or Rust). The script reads `SKILL.md`,
   applies the three ref patterns (regex), resolves paths relative to each file's
   directory, BFS-walks `.md` files up to `depth_limit`, deduplicates, sorts. The
   `dispatch` skill is no longer needed on cache miss; the host calls the tool directly.
   Cache layer unchanged. Token and latency cost of cache miss drops from LLM subagent
   to a fast file-read pass.

2. **If LLM is intentional:** Update `instructions.uncompressed.md` to explicitly state
   when LLM judgment overrides the pattern rules (e.g., "if a backtick token appears
   in a prose sentence and is clearly not a file path, omit it"). This makes the
   semantic judgment requirement visible, documents when the LLM deviates from the
   patterns, and resolves the spec/instructions mismatch. Update `spec.md` to remove
   the "not regex alone" note or narrow it to the specific edge cases.

**Action taken:** pending — structural redesign or spec clarification; requires operator
decision on whether LLM semantic judgment is intended beyond the defined patterns.

---

### DETERMINISM — LOW

**Signal:** Step 1a in `instructions.uncompressed.md` re-enumerates `skill_dir` files
that the host already holds.

**Reasoning:** The host enumerates `skill_dir` direct files in Step 3 of
`uncompressed.md` (to compute the manifest hash via `hash-record/manifest`). The subagent
independently re-enumerates the same directory in Step 1a. The two enumerations apply
identical rules (non-recursive, no dot-files), so results should match — but there is a
narrow race window where a file is created or deleted between the host enumeration and the
subagent's execution. More practically, having the LLM perform a deterministic filesystem
enumeration is unnecessary: the host already has the list and could pass it as an
additional dispatch input (`files=<list>`).

**Recommendation:** Add `files=<space-separated list>` to `<input-args>` in
`uncompressed.md`'s dispatch block. Update `instructions.uncompressed.md` Step 1a to
accept `files` as a provided input parameter and seed `file_set` directly, rather than
re-enumerating the directory. This guarantees host and subagent use the identical file
set and removes one redundant filesystem operation from the LLM's task.

**Action taken:** pending — interface change to the dispatch contract; requires operator
judgment on whether the added parameter complexity is worth the consistency guarantee.
