---
file_path: gh-cli/gh-cli-setup/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA014 [SUGGEST] line 31: `must not` appears unemphasized in spec document.
  Note: "The skill must not assume any particular shell." uses a directive keyword without bold or emphasis; emphasis would make the constraint more salient in a spec context.

- SA018 [WARN] line 46: Passive-voice directive in spec document.
  Note: "Interactive setup paths and automated (scriptable) paths must be presented as distinct options" uses passive construction; the actor is unspecified.

- SA028 [WARN] lines 31, 38: Phrase "not assume any particular shell" appears verbatim more than once.
  Note: The Requirements section and the Behavior section both end with this clause; the Behavior section appears to restate Requirements content as prose, producing the duplicate.

- SA036 [WARN] line 38: Directive sentence with 3+ coordinating conjunctions.
  Note: The opening Behavior sentence chains six participial clauses joined by "and" (twice) and "or", making it difficult to parse as a single unit; splitting into shorter directives would improve clarity.
