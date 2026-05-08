---
file_path: messaging/uncompressed.md
operation_kind: markdown-hygiene-analysis
result: fixed
---

# Result

## Advisory

- SA003 [WARN]: "NOT" (ALL CAPS) appears 8 times in the document (lines 176–183).
  Note: Every item in the Don'ts section uses "Do NOT"; the repetition is concentrated and may signal that the Don'ts section and the inline "Do not" directives in body sections are doing the same work twice.

- SA014 [SUGGEST] line 76: "Do not" unemphasized in directive sentence.
  Note: "Do not write inbox files directly." uses plain lowercase "not" while the corresponding Don'ts rule at line 178 emphasizes it as "NOT"; the two occurrences are inconsistent in stress.

- SA014 [SUGGEST] line 91: "Do not" unemphasized in directive sentence.
  Note: "Do not post to your own inbox." appears as plain prose; mirrors the Don'ts rule at line 181 without matching emphasis.

- SA014 [SUGGEST] line 148: "Do not" unemphasized in directive sentence.
  Note: "Do not drain another agent's inbox." in the ## Draining an Inbox section uses plain "do not"; mirrors the Don'ts rule at line 179 without matching emphasis.

- SA014 [SUGGEST] line 178: "always" unemphasized in directive.
  Note: "always use `post`" appears in a Don'ts bullet alongside an ALL-CAPS "NOT"; "always" itself carries no emphasis, unlike `**always**` used on line 145 for the drain sweep rule.

- SA031 [WARN] line 99: Level-3 sibling headings mix casing styles.
  Note: "Option A — Wire status to your Monitor" leaves "status", "to", and "your" lowercase, and "Option B — Implement the loop yourself" leaves "the", "loop", and "yourself" lowercase, while "On Startup" (line 129) uses consistent Title Case; the three headings do not follow a uniform convention.
