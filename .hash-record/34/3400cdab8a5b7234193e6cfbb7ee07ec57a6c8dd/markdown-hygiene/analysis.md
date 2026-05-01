---
file_path: gh-cli/gh-cli-repos/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA013 [WARN] line 3: The `## Purpose` heading introduces only a single sentence.
  Note: A single-sentence section could be expressed as an inline bold label (e.g. `**Purpose:**`) rather than a full heading, reducing structural weight.

- SA014 [SUGGEST] line 36: Unemphasized `must not` directive in the Requirements section.
  Note: "The skill must not assume a default visibility" carries strong prohibitive intent; this pattern also recurs at lines 40, 45, and 51 — none are emphasized, making them easy to overlook when scanning.

- SA018 [WARN] line 40: Passive voice on directive sentence — "Visibility must always be specified explicitly."
  Note: The actor is implicit; rephrasing as "The skill must always specify visibility explicitly" makes the subject clear and removes the passive construction.

- SA018 [WARN] line 51: Passive voice on directive sentence — "personal repos must not be assumed."
  Note: Rephrasing as "agents must not assume personal ownership" makes the directive actor explicit.

- SA028 [WARN] lines 36 and 40: The phrase "must not assume a default" appears verbatim in both the Requirements and Behavior sections.
  Note: The constraint is stated twice in close proximity; one of the two occurrences may be redundant.

- SA032 [WARN]: The terms "caller" (lines 44, 46, 50) and "operator" (line 74) may refer to the same authorizing human entity but are used in different sections without a cross-reference or distinguishing definition.
  Note: If they denote the same role, using one term consistently would remove ambiguity; if they are distinct, a Definitions entry would clarify the difference.

- SA036 [WARN] line 40: The Behavior paragraph sentence listing skill coverage contains three or more coordinating conjunctions (two instances of "or" within parentheticals and a final "and" closing the series).
  Note: The enumerated operations could be expressed as a bullet list — mirroring the Intent section structure — which would reduce conjunction density and improve scanability.
