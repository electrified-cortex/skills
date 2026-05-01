---
file_path: gh-cli/gh-cli-api/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 40: `never` appears unemphasized in a spec directive sentence.
  Note: "never inline command arguments" is an instruction-strength constraint; emphasis would signal its directive weight to agents reading the document.

- SA018 [WARN] line 40: Passive voice on two directive sentences in the Behavior section.
  Note: "Requests are authenticated automatically using the active `gh` session" and "`--jq` filters are applied to the final response" describe agent-facing behavior in passive construction; active phrasing would make the subject of each action explicit.

- SA032 [WARN]: "callers" (line 40) and "caller" (line 44) may refer to the same entity as "operator" (lines 62–68).
  Note: Behavior uses "warn callers" while Error Handling uses "surface the error message to the caller"; if these mean the human operator, a single consistent term would remove ambiguity.
