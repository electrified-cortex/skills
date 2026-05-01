---
file_path: gh-cli/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA012 [WARN] line 1: Document title (H1 `gh-cli — Spec`) is immediately followed by `## Purpose` with no content between them.
  Note: A single-line document subtitle or brief introductory sentence between the title and the first section would satisfy this rule; the pattern itself is common but technically consecutive headings.

- SA014 [SUGGEST] line 44: `never` is unemphasized in the directive "Domain ambiguity must be resolved by asking the caller — never assume."
  Note: The keyword `never` is a strong constraint and is unformatted; emphasis would make the prohibition visually distinct for an agent scanning requirements.

- SA014 [SUGGEST] line 58: `must not` is unemphasized in "it must not guess or default to any domain."
  Note: Same pattern as above; the prohibition appears in plain text in a directive sentence.

- SA018 [WARN] line 44: Passive voice on directive: "Authentication must be verified via `gh auth status` if the setup skill was not previously loaded in the session."
  Note: No named agent performs the verification; active form would be "The router must verify authentication via `gh auth status` if…"

- SA018 [WARN] line 45: Passive voice on directive: "Domain ambiguity must be resolved by asking the caller — never assume."
  Note: "must be resolved" omits the agent; active form would be "The router must resolve domain ambiguity by asking the caller."

- SA018 [WARN] line 46: Passive voice on directive: "Multi-domain tasks are split: primary domain runs, remaining domains are reported to the caller."
  Note: Both "are split" and "are reported" lack a named subject; the router is the implicit agent but not stated.

- SA028 [WARN]: Phrase "to the correct domain sub-skill" (5 words) appears verbatim in both the Purpose section and the Intent bullet list.
  Note: The repetition is natural given the document's subject, but the phrase could be consolidated or one instance could reference the definition.

- SA032 [WARN]: The routing skill entity is referred to by three distinct names across the document — "this skill" (Purpose section), "the router" (Requirements, Behavior, Error Handling), and implicitly as the subject in Constraints bullets.
  Note: Definitions establishes "Router" as the canonical name, but Purpose uses "this skill" before that definition is introduced; consistent use of "the router" throughout would remove the ambiguity.

- SA035 [WARN] line 44: Action stated before gate condition: "Authentication must be verified via `gh auth status` if the setup skill was not previously loaded in the session."
  Note: The gate condition ("if the setup skill was not previously loaded") trails the action; preferred form is "If the setup skill was not previously loaded in the session, the router must verify authentication via `gh auth status`."
