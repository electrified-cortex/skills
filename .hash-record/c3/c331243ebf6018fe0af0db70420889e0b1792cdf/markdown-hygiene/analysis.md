---
file_path: gh-cli/gh-cli-pr/gh-cli-pr-inline-comment/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA013 [WARN] line 8: `## Purpose` heading introduces only a single sentence.
  Note: The entire Purpose section is one sentence; a `**Purpose:**` inline label would avoid the heading overhead for a single-sentence entry.

- SA014 [SUGGEST] line 22: `never` appears unemphasized in a directive context.
  Note: "Use `line`, never the deprecated `position`" — the prohibition keyword carries instruction weight but has no emphasis.

- SA014 [SUGGEST] line 55: `must not` appears unemphasized in a directive context.
  Note: "The agent must not skip the diff verification step" — key prohibition is plain text.

- SA014 [SUGGEST] line 56: `always` appears unemphasized in a directive context.
  Note: "always fetch fresh" — the requirement keyword is plain text in an instruction sentence.

- SA014 [SUGGEST] line 63: `never` appears unemphasized in a directive context.
  Note: "`position` parameter is deprecated; never use it" — prohibition keyword is plain text.

- SA018 [WARN] line 20: passive voice on a directive sentence in a spec document.
  Note: "Must be fetched at execution time via `headRefOid`" — the subject (agent) is omitted; reads as a passive requirement rather than an active instruction.

- SA028 [WARN] lines 70–72: phrase "Operator approval required before execution" appears verbatim three times.
  Note: Repeated identically in three consecutive table rows (POST, PATCH, DELETE); could be collapsed into a table footer or section note to reduce duplication.

- SA028 [WARN] lines 64 and 75: phrase "explicit operator authorization in the current session" appears verbatim twice.
  Note: Once in the Constraints bullet list and once in the bold closing sentence of Safety Classification; the repetition adds no new information.

- SA032 [WARN] document-level: the defined term "inline review comment" and the shortened form "inline comment" are used interchangeably.
  Note: Definitions section establishes "inline review comment" as the canonical term, but Requirements and Safety Classification consistently use the shorter "inline comment"; the two forms refer to the same concept.

- SA037 [WARN] lines 60–64: Constraints list mixes scope-exclusion observations with a command directive and a requirement statement.
  Note: The first three items follow a "Does not cover X → Y" observation pattern; the fourth item ("`position` parameter is deprecated; never use it") is a directive command; the fifth ("All destructive operations require explicit operator authorization…") is a standing requirement — the three item types are structurally dissimilar within one list.
