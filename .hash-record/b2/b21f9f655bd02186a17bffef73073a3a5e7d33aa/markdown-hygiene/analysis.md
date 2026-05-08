---
file_path: messaging/SKILL.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA003 [WARN] line 135: `DON'T` appears 8 times in the Don'ts section.
  Note: High repetition of a single ALL CAPS word across a list may indicate the list structure itself is carrying the emphasis load; the ALL CAPS form could be redundant.

- SA009 [WARN] line 17: Several Concepts list items span two or three sentences.
  Note: The `Signal file`, `Name claim`, and `Status` entries each contain three sentences; multi-sentence list items suggest these concepts may read more clearly as short sections or definition paragraphs.

- SA010 [WARN] line 58: `stderr` appears in plain prose without backticks.
  Note: `stderr` is a shell/OS stream identifier; the adjacent `post` and flag names on the same line are backtick-wrapped, making the unformatted `stderr` inconsistent.

- SA010 [WARN] line 114: `stderr` appears in plain prose without backticks.
  Note: Same term and same context as above; both occurrences in the Draining section treat `stderr` as plain prose while surrounding technical terms are formatted.

- SA015 [WARN]: Document exceeds 400 words and contains zero markdown headings.
  Note: Section labels such as `Registering:`, `Posting:`, `Monitoring:`, `Draining:`, `Constraints:`, and `Don'ts:` are plain-text lines rather than ATX headings; a reader navigating by heading outline or rendered anchor links would find no structure.

- SA018 [WARN] line 58: "All 4 flags required." uses passive voice in a directive sentence.
  Note: The agent-facing instruction could be rephrased actively, e.g. "Provide all 4 flags."

- SA018 [WARN] line 96: "Drain-to-quiescence loop (inner `loop`) required; ensures nothing stranded." uses passive voice.
  Note: Both "required" and "stranded" rely on implied copula; the sentence reads as a constraint but is framed passively rather than as an imperative.

- SA018 [WARN] line 131: "Single reader per inbox — concurrent drains unsupported." uses passive voice.
  Note: "Unsupported" frames the constraint as a system property rather than a directive; an active form such as "Do not run concurrent drains" would be more direct in an instruction document.

- SA035 [WARN] line 112: "Exits 0 even if files skipped." states action before gate condition.
  Note: Gate-first form would be "If files are skipped, exits 0 regardless."

- SA035 [WARN] line 114: "Archives files even if unparsable; failure on stderr." states action before gate condition.
  Note: Gate-first form would be "If a file is unparsable, archives it anyway; reports failure on stderr."
