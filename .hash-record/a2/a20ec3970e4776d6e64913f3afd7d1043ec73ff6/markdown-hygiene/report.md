---
operation_kind: markdown-hygiene
result: pass
file_path: markdown-hygiene/spec.md
---

# Result

lint: clean
analysis: pass: .hash-record/a2/a20ec3970e4776d6e64913f3afd7d1043ec73ff6/markdown-hygiene/analysis.md

## Skipped Advisories

- SA028 [WARN] line 22/35 — "Never modifies the target file." duplicated across Lint Executor and Analysis Executor sections. Skipped: each executor section is intentionally self-contained; the constraint is load-bearing at both locations and removing one would require cross-section reading.

- SA028 [WARN] line 112/198–199 — "The dispatch primitive receives only `<prompt>` — it does not perform template substitution." duplicated across Dispatch Surface and Host Iteration Loop sections. Skipped: intentional architectural emphasis; the closing paragraph restates the constraint for readers who enter via the Requirements section without reading Dispatch Surface.

- SA028 [WARN] line 128/180 — Fix pass prompt reproduced verbatim in both Dispatch Surface and Requirements sections. Skipped: Requirements section must be self-contained for implementers; removing the duplicate would require cross-referencing Dispatch Surface to understand the prompt shape.

- SA036 [WARN] line 128 — Fix pass prompt uses four coordinating conjunctions in a single instruction. Skipped: the prompt is intentionally dense and self-contained for dispatch; it cannot be split across multiple prompts and the branching logic (lint fixes vs. advisory handling) must remain in one dispatch call.

- SA037 [WARN] line 19 — Lint Executor list mixes action items with a constraint item. Skipped: the constraint item ("**Never** modifies the target file.") is visually distinct from action items by its opening word and sentence structure; adding a "Constraints:" sub-label introduces structural overhead without meaningful clarity gain.

- SA037 [WARN] line 31 — Analysis Executor list mixes action items with a constraint item. Skipped: same rationale as line 19.
