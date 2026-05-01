---
file_path: gh-cli/gh-cli-api/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA013 [WARN] line 63: heading "## GitHub Enterprise" introduces only a single sentence
  Note: The heading precedes exactly one sentence; could be restructured as an inline bold label "**GitHub Enterprise:**" within the surrounding prose.

- SA013 [WARN] line 76: heading "## See Also" introduces only a single reference line
  Note: The heading covers a single comma-separated reference list rather than multi-sentence content; could be restructured as an inline bold label.

- SA014 [SUGGEST] line 69: directive word "Never" is unemphasized
  Note: The word begins a hard prohibition but carries no bold or other emphasis; emphasis would increase its salience in an instruction document.

- SA027 [WARN] lines 14, 21: sibling headings "## REST — GET" and "## REST — mutate" share the repeated word "REST"
  Note: The shared prefix suggests a grouping pattern that could be expressed as a parent heading with sub-headings, or by omitting the prefix from the siblings.

- SA027 [WARN] lines 37, 43: sibling headings "## jq — extract" and "## jq — filter + transform" share the repeated word "jq"
  Note: Same repeated-prefix pattern as the REST group.

- SA027 [WARN] lines 49, 56: sibling headings "## GraphQL — query" and "## GraphQL — mutation (resolve review thread)" share the repeated word "GraphQL"
  Note: Same repeated-prefix pattern as the REST group.

- SA031 [WARN] document-level: sibling ## headings mix Title Case and lowercase/mixed case
  Note: "## When to Use", "## GitHub Enterprise", "## Token Safety", "## Scope Boundaries", and "## See Also" use Title Case, while "## jq — extract" and "## jq — filter + transform" use lowercase, and "## REST — mutate", "## GraphQL — query", "## GraphQL — mutation (resolve review thread)" are mixed; consistent casing across all siblings would improve uniformity.

- SA035 [WARN] line 8: action stated before gate condition in "Prefer domain-specific skills … when they cover operation"
  Note: Placing the condition first ("When domain-specific skills cover the operation, prefer them over gh api") makes the gate explicit before the directive fires.
