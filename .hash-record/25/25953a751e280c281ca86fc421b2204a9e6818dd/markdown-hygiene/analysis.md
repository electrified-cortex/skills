---
file_path: markdown-hygiene/markdown-hygiene-result/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN]: `HIT` appears 7 times across prose (line 5, line 25), a backtick span (line 21), and four table-cell conditions (lines 38–41).
  Note: All occurrences are output-protocol tokens being defined in the spec; the repetition reflects vocabulary density rather than emphasis collapse, but the count exceeds the threshold.

- SA003 [WARN]: `ERROR` appears 5 times, all inside backtick spans (lines 20, 32, 43, 44).
  Note: Same context as `HIT` — output-token vocabulary used for specification, not emphasis.

- SA013 [WARN] line 55: `## Dependencies` heading introduces a single sentence.
  Note: The single-sentence body could be expressed as a `**Dependencies:**` inline label under Constraints, or the section could be folded into the Procedure section where the dependency is first invoked.

- SA018 [WARN] line 53: "`<filename>` is a bare name with no path separators or `.md` extension — validated before use" — the trailing participial clause "validated before use" is passive voice within a constraint sentence.
  Note: The passive form leaves the agent of validation implicit; the reader cannot tell whether the caller, the script itself, or both are responsible for the check.

- SA037 [WARN] lines 50–53: The Constraints list mixes directive items ("Read-only. No file writes."), an implementation-description item ("Frontmatter parsing is line-based…"), a cross-implementation requirement ("must produce byte-identical stdout"), and a validation rule ("validated before use") without a distinguishing signal between item types.
  Note: Items of different character (prohibitions, implementation notes, cross-implementation requirements) are presented as a flat peer list, which makes it harder for an implementer to distinguish hard constraints from descriptive notes.

- SA038 [FAIL] lines 27–34: The first Output Contract table maps `result: clean` to `clean: <abs-path>` for all cases; the "Special case" sentence immediately following overrides this output to `CLEAN` (no path) when the filename is `report`, creating an apparent contradiction between the two presentations.
  Note: An implementer reading only the first table will produce the wrong output for the `report`+`clean` case. The second full table (lines 36–44) is authoritative and reconciles the two, but the first table is not marked as partial or simplified.
