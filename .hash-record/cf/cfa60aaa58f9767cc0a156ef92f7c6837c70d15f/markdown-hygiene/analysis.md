---
file_path: skill-manifest/instructions.uncompressed.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA009 [WARN] line 82: Last item in the Rules list contains two sentences.
  Note: The cached-results caveat spans two sentences; multi-sentence list items often read more clearly as a dedicated section or inline paragraph.

- SA010 [WARN] line 71: `stdout` appears as plain prose without backticks.
  Note: `stdout` is a technical I/O descriptor and follows the same backtick convention as the other identifiers in this document.

- SA013 [WARN] line 23: Heading "### 1a — Seed with skill_dir contents" introduces only a single sentence.
  Note: A single-sentence section is a candidate for inline presentation as `**1a — Seed with skill_dir contents:**` rather than a standalone heading.
  Skipped: 1a/1b/1c are parallel sub-sections; flattening 1a while keeping 1b and 1c as headings would break structural consistency.

- SA014 [SUGGEST]: Multiple `never` directives in the Rules section are unemphasized.
  Note: Seven consecutive "Never …" items carry no visual emphasis; in an instruction document these are the strongest constraints and are candidates for emphasis on the keyword.
  Skipped: Adding bold to all 7 "Never" items in a dense instruction file adds visual noise without clarity benefit; sentence-initial position already signals imperative tone.

- SA037 [WARN] line 82: The Rules list mixes seven imperative "Never …" command items with one observational/descriptive item (the cached-results caveat).
  Note: The final bullet describes a behavior rather than issuing a command, so it does not share the same nature as its siblings; a distinguishing signal (e.g., a "Note:" prefix or a separate paragraph) would clarify the shift.
