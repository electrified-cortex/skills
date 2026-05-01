---
file_path: markdown-hygiene/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA009 [WARN] line 62: `fixed:` list item spans three sentences ("fixes applied to target file. Restart from Step 2. Count as a fail iteration; after the 3rd, stop and return `findings: <report_path>` to caller instead.").
  Note: A multi-sentence list item may be easier to scan as a short sub-list or a dedicated paragraph.

- SA014 [SUGGEST] line 66: "never" appears twice without emphasis in a directive constraint sentence ("never written to any record file, never returned to the caller").
  Note: Emphasizing each "never" (e.g., **never**) would align with typical instruction-document conventions for prohibitions.

- SA018 [WARN] line 66: Directive constraint uses passive voice ("never written to any record file, never returned to the caller").
  Note: Active phrasing ("do not write it to any record file; do not return it to the caller") would be more direct for an instruction document.

- SA028 [WARN] lines 22 and 29: The bullet "- `ERROR: <reason>` — stop, surface reason." appears verbatim in both Step 2 and Step 3.
  Note: Identical text in sibling steps may diverge silently on future edits; a shared convention label or cross-reference could reduce maintenance risk.

- SA031 [WARN] document-level: Sibling headings mix title case ("Lint", "Analysis", "Aggregate", "Prune") with sentence case ("Result check", "Iteration check").
  Note: Normalizing to one convention (e.g., all title case: "Result Check", "Iteration Check") would improve visual consistency across the heading set.

- SA032 [WARN] document-level: The report artifact is named two ways — `report.md` (literal filename, lines 40 and 74) and `<report_path>` (variable placeholder, throughout). The binding between them is never explicitly stated.
  Note: Adding one line binding `<report_path>` to the `report.md` filename (or stating it in the variable definition) would make the relationship explicit.

- SA036 [WARN] line 61: The host-composed prompt sentence contains three or more coordinating conjunctions ("and fix every FAIL-severity item", "and for each advisory", "either apply the fix or append", "or `clean: <report_path>`").
  Note: Splitting into two or three shorter sub-instructions would reduce parsing load for the host LLM composing the prompt.

- SA038 [FAIL] document-level: Step 5 routes the fix agent's `clean:` return (all skips, no actual fixes applied) to Step 6, but Step 6 defines return instructions only for `clean` and `pass` aggregates — the `fail` aggregate case is unhandled there.
  Note: If a `fail`-aggregate run reaches Step 6 via the `clean:` branch (e.g., fix agent skips all lint FAIL items), no return instruction exists; stating the expected behavior (e.g., "return `findings: <report_path>`") would close the gap.
