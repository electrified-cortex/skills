---
file_path: markdown-hygiene/markdown-hygiene-lint/lint.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA012 [WARN] line 1: `# lint — Spec` is immediately followed by `## Purpose` with no body content between.
  Note: No introductory sentence or context appears between the document title heading and the first section heading; a brief lead-in would bridge the two.

- SA014 [SUGGEST] line 6: `always` appears unemphasized twice in a directive context ("is always available and always runs").
  Note: In a spec document, `always` typically signals a non-negotiable behavioral constraint; unemphasized usage may reduce its weight to readers.

- SA014 [SUGGEST] line 42: `Always` appears unemphasized at the start of a behavioral directive list item ("Always exits 0 on success").
  Note: Consistent emphasis on directive keywords across the document would make non-negotiable constraints more visually distinct.

- SA014 [SUGGEST] line 49: `Never` appears unemphasized in an output encoding constraint ("Never CRLF").
  Note: The constraint is short and likely to be scanned rather than read; emphasis would help it stand out as a hard rule.

- SA018 [WARN] line 24: passive construction in a spec directive — "left to the executor scan pass".
  Note: The passive phrasing ("left to") in a behavioral rule in a spec document makes the responsible party implicit; an active form would name the actor directly.

- SA031 [WARN] document-level: sibling H2 headings mix Sentence case and Title Case — "Output encoding" and "Exit codes" use Sentence case while "Purpose", "Scope", "Interface", "Behavior", and "Requirements" are single capitalized words consistent with Title Case.
  Note: The inconsistency is subtle due to single-word headings, but "Output encoding" and "Exit codes" are unambiguously Sentence case; choosing one convention throughout would remove the ambiguity.
