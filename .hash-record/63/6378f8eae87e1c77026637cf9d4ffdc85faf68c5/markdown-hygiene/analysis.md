---
file_path: skill-auditing/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA028 [WARN] line 94 and 151: phrase "the sweep does not stop on the first finding" appears verbatim in both the Requirements list (item 2) and the Behavior section opening paragraph.
  Note: Duplicate phrasing across sections is likely a copy-paste artifact; one instance could be removed or paraphrased.

- SA028 [WARN] line 151 and 186: phrase "All findings are collected before a verdict is assigned" appears verbatim in both the Behavior intro paragraph and the Audit Steps intro paragraph.
  Note: Same observation as above — both paragraphs open with essentially the same sentence.

- SA014 [SUGGEST] line 50: "they do not block a seal" — "do not" unemphasized in a normative document.
  Note: Consider bold or rephrasing to strengthen the constraint signal.

- SA014 [SUGGEST] line 138: "must never be modified by the auditor" — "never" unemphasized.
  Note: Consider bold for "never" to reinforce the constraint.

- SA014 [SUGGEST] line 176: "the auditor never modifies any file" — "never" unemphasized in a constraint bullet.
  Note: Consider bold for "never."

- SA014 [SUGGEST] line 182: "The auditor never performs recompression" — "never" unemphasized.
  Note: Consider bold for "never."
