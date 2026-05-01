---
file_path: markdown-hygiene/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA003 [WARN]: CLEAN, FAIL, and WARN each appear 5+ times across the document
  Note: these are technical state identifiers, but all-caps emphasis loses signal value when a term saturates the document; repetition erodes the contrast that makes caps meaningful

- SA006 [FAIL] line 679: single-item list under "Known Gotchas" — only one bullet point
  Note: a single list item is structurally a sentence with a decorative bullet; plain prose carries the same content without the list overhead

- SA009 [WARN] line 601: list item "Hard prohibition on script authoring (executor)" spans 6+ sentences
  Note: multi-sentence list items suggest the content has outgrown a list entry; a dedicated sub-heading would provide clearer structure and aid scanning

- SA009 [WARN] line 608: list item "Fix is NOT done by the executor" spans 3 sentences
  Note: same observation — content with multiple sentences and a named concept may be better served as a section

- SA011 [FAIL] line 210: `**FAIL**` — bold and ALL CAPS applied to the same word
  Note: each emphasis mechanism independently signals strong constraint; stacking them adds no additional weight and introduces visual clutter; one mechanism is sufficient

- SA011 [FAIL] line 211: `**WARN**` — bold and ALL CAPS applied to the same word
  Note: same observation as line 210

- SA011 [FAIL] line 212: `**SUGGEST**` — bold and ALL CAPS applied to the same word
  Note: same observation as line 210

- SA011 [FAIL] line 608: `**Fix is NOT done by the executor.**` — bold-wrapped phrase contains ALL CAPS word NOT
  Note: NOT is already all-caps for emphasis; the enclosing bold phrase stacks signals redundantly

- SA012 [WARN] line 148: "## Requirements" immediately followed by "### Inputs (Host Layer)" at line 150 with no body content between
  Note: a parent heading with no introductory content before its first sub-heading may indicate the parent is a pure container label; an introductory sentence or removal of the parent heading would clarify intent

- SA012 [WARN] line 632: "## Tables" immediately followed by "### Canonical Separator Modes" at line 634 with no body content between
  Note: same observation as line 148

- SA014 [SUGGEST] line 616: "Never suggest installing anything" — sentence-opening capital N, not bold or ALL CAPS
  Note: in a spec document, constraint words benefit from emphasis to strengthen instruction-following adherence

- SA014 [SUGGEST] line 620: "the executor never computes the git blob hash" — lowercase "never" unemphasized
  Note: same observation as line 616

- SA020 [WARN] line 625: Integration section uses a numbered list for four independent trigger occasions; none references a prior item
  Note: numbered lists signal sequential steps; bullet points would better represent a set of independent conditions under which the skill should run

- SA028 [WARN] lines 22 and 35: the sentence "**Never** modifies the target file. Hard prohibition on script authoring." appears verbatim in both the Lint Executor and Analysis Executor sub-sections; the phrase "Hard prohibition on script authoring" recurs again at line 601
  Note: verbatim repetition across sibling sections is typically a copy-paste artifact; consolidating into a shared constraint or cross-referencing one from the other would reduce duplication

- SA028 [WARN] lines 112 and 199: the phrase "does not perform template substitution" appears verbatim twice
  Note: the Dispatch Surface section (line 112) and the Iteration Loop closing paragraph (line 199) both state this constraint; one canonical location with a reference would suffice

- SA031 [WARN] line 369: "### Rules to enforce (Executor)" uses sentence case; all sibling headings under "## Requirements" use Title Case
  Note: mixed heading case within a section reads as unfinished; one style applied consistently improves scannability

- SA032 [WARN]: the dispatched fix agent is referred to as "fix agent" (line 70), "combined fix agent" (line 171), and "fix pass agent" (line 609); "host" and "host LLM" are also used interchangeably throughout
  Note: terminology drift forces readers to infer equivalence; one canonical name per role reduces cognitive overhead

- SA037 [WARN] line 601: the Constraints list mixes bold-labeled constraint descriptions (lines 601–614) with bare imperative sentences (lines 615–621)
  Note: shifting between labeled descriptions and direct imperatives within a single list can cause agents to treat descriptions as commands or commands as descriptions; separating them into distinct groups or sections would clarify which items are directives
