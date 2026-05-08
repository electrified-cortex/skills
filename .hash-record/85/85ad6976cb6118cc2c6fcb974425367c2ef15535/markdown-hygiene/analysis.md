---
file_path: messaging/init.spec.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA012 [WARN] line 20: `## Behavior` heading immediately followed by `### Normal (first registration)` with no content between.
  Note: The Behavior heading has no introductory content before its first subheading.

- SA014 [SUGGEST] line 39: "Never fails due to pre-existing inbox." — "Never" unemphasized.
  Note: The word "Never" carries directive force but is not bold or otherwise emphasized.

- SA018 [WARN] line 45: "Errors written to stderr." — passive voice on a spec directive.
  Note: The subject "Errors" is grammatically passive; the active form would state what the tool does.

- SA035 [WARN] line 6: "Fails if the name is already taken" — action stated before gate condition.
  Note: The action ("Fails") precedes the condition ("if the name is already taken"); conventional gate-first ordering would be "If the name is already taken, fails."
