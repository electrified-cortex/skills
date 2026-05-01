---
file_path: gh-cli/gh-cli-pr/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 9: `CODEOWNERS` referenced as a filename in plain prose without backticks.
  Note: File name references in prose are conventionally wrapped in backticks to signal they are literal names rather than concepts.

- SA010 [WARN] line 50: `push` and `checkout` referenced as shell subcommands in a parenthetical without backticks.
  Note: Command names used illustratively in parentheses are typically backticked even when not the focus of the sentence.

- SA010 [WARN] line 58: `push`, `checkout`, and `fetch` referenced as git subcommands in a parenthetical without backticks.
  Note: Same pattern as line 50; the list reads as literal command names and would benefit from backtick treatment.

- SA010 [WARN] line 60: `CODEOWNERS` referenced as a filename in plain prose without backticks.
  Note: Second occurrence of the same filename without backtick treatment; consistent with line 9.

- SA013 [WARN] line 3: `## Purpose` heading introduces exactly one sentence.
  Note: A heading that governs a single sentence is often better expressed as a bold inline label, reserving headings for multi-sentence sections.

- SA014 [SUGGEST]: Multiple `must` and `must not` directives in Requirements (lines 39-42), Behavior (line 46), Error Handling (line 50), and Precedence Rules (line 54) appear unemphasized.
  Note: In instruction and specification documents, directive keywords such as `must` and `must not` are sometimes emphasized to increase the salience of requirements.

- SA018 [WARN] line 46: Passive voice used in directive sentences in the Behavior section: "Write operations are not executed by this skill — they are dispatched to the correct sub-skill."
  Note: Both clauses omit an active subject; stating who does what (the skill, the agent) is clearer and more directly actionable in a spec.

- SA028 [WARN] lines 42 and 46: The phrase "for blocking until CI completes" appears verbatim in both the Requirements and Behavior sections.
  Note: Repeating the same phrase across two sections may signal that one section is restating the other rather than contributing distinct information.

- SA032 [WARN]: The concept of directing write operations to sub-skills is expressed using three distinct terms: "delegated" (Scope, Precedence Rules), "dispatched" (Behavior, Intent), and "routing" / "routed" (Definitions, Requirements, Precedence Rules).
  Note: Using three synonyms for the same mechanism across a single spec may signal an unintended distinction; consistent terminology reduces ambiguity for the implementing agent.
