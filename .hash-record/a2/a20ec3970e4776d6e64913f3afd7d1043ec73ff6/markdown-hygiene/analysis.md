---
file_path: markdown-hygiene/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 22: "Never modifies the target file." — "never" is unemphasized in an instruction document.
  Note: The constraint reads as a lowercase sentence opener rather than a deliberate directive signal. Bold or ALL-CAPS on "Never" would make the prohibition visually distinct from the adjacent capability bullets.

- SA014 [SUGGEST] line 23: "always a single detect pass" — "always" is unemphasized in an instruction document.
  Note: The word "always" carries a strong behavioral constraint (no multi-pass lint). Without emphasis it blends into the observation tone of the sentence.

- SA014 [SUGGEST] line 35: "Never modifies the target file." (Analysis Executor) — same as line 22, "never" unemphasized.
  Note: This is a repeated prohibition that appears in both executor sections. Emphasis would reinforce it in both locations.

- SA016 [WARN] line 27: Heading "### Analysis Executor (`markdown-hygiene-analysis/instructions.txt`)" is 64 characters, exceeding the ~60-char guideline.
  Note: The inline path makes the heading long. Moving the path to the section body or shortening the heading text would bring it under the threshold.

- SA018 [WARN] line 6: "The target file is never modified by the executor." — passive voice on a directive sentence in the Purpose section.
  Note: The active form "The executor never modifies the target file." states the same constraint more directly.

- SA018 [WARN] line 7: "Fixes are applied by a separate ad-hoc dispatch at the host orchestration layer" — passive voice on a directive sentence in the Purpose section.
  Note: Rewriting as "A separate ad-hoc dispatch at the host orchestration layer applies the fixes." makes the actor explicit.

- SA027 [WARN] line 150: Sibling headings under "## Requirements" — "### Inputs (Host Layer)" and "### Host Iteration Loop" (line 166) both contain the word "Host".
  Note: With only two siblings, "Host" appearing in every heading is the pattern SA027 flags. Renaming one (e.g. "### Iteration Loop" or "### Inputs") would break the repetition.

- SA028 [WARN] line 22: "Never modifies the target file. Hard prohibition on script authoring." appears verbatim again at line 35 in the Analysis Executor section.
  Note: Identical constraint sentences in adjacent sibling sections suggest a shared constraint note would reduce duplication.

- SA028 [WARN] line 112: "The dispatch primitive receives only `<prompt>` — it does not perform template substitution." appears again at lines 198–199 in the closing paragraph of the Host Iteration Loop section.
  Note: The sentence is a key architectural fact but restating it verbatim in two sections may be intentional for emphasis; if so, a cross-reference would be clearer.

- SA028 [WARN] line 128: Fix pass prompt template is reproduced verbatim at line 180 inside the Combined Fix Dispatch block.
  Note: The duplication exists because the prompt is defined in the Dispatch Surface section and then re-stated in the Requirements section. A single canonical location with a reference in the other would eliminate the copy-drift risk.

- SA036 [WARN] line 128: Fix pass prompt directive uses four coordinating conjunctions ("and", "and", "either…or", "or") in a single complex instruction.
  Note: The prompt is dense partly by design (it must be self-contained for dispatch), but splitting into two sentences — one for lint fixes, one for advisory handling — would reduce conjunction load and make the branching logic easier to follow.

- SA037 [WARN] line 19: Lint Executor capability list mixes action items (lines 19–21: "Runs…", "Writes…", "Returns…") with a constraint ("Never modifies…") and an observation ("This layer is unchanged…") without a distinguishing signal.
  Note: Separating constraints and observations into a distinct sub-list or labelled block (e.g. "**Constraints:**") would clarify which items describe behavior versus what is prohibited.

- SA037 [WARN] line 31: Analysis Executor list mixes action items (lines 31–34) with a constraint item (line 35: "Never modifies the target file.") using the same bullet style.
  Note: Same pattern as line 19. The constraint item has a different nature from the capability items and a visual separator would signal that distinction.
