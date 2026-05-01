---
file_path: markdown-hygiene/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA009 [WARN] line 62: The `fixed: <report_path>` nested list item spans three sentences.
  Note: The item reads "fixes applied to target file. Restart from Step 2. Count as a fail iteration; after the 3rd, stop and return..." — multi-sentence list items can reduce scannability.

- SA014 [SUGGEST] line 66: The word "never" appears twice unemphasized in an instruction sentence.
  Note: "never written to any record file, never returned to the caller" — prohibition words like "never" are often more legible when emphasized in instruction documents.

- SA027 [WARN] document-level: The word "Step" appears in every Step heading (## Step 1 through ## Step 6).
  Note: The numbering already implies sequence; repeating "Step" in each heading title adds no disambiguation.

- SA028 [WARN] line 22, 29, 64: The list item "`ERROR: <reason>` — stop, surface reason." appears verbatim in three separate list contexts.
  Note: Verbatim repetition of a full clause across steps signals a candidate for a shared convention note or cross-reference rather than inline repetition.

- SA035 [WARN] line 62: Action (restart) is stated before the gate condition (3rd iteration).
  Note: "Restart from Step 2. Count as a fail iteration; after the 3rd, stop and return..." — stating the gate condition first ("If this is the 3rd fail iteration, stop and return...; otherwise, restart from Step 2") may make branching logic easier to parse.
