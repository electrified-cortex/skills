---
file_path: markdown-hygiene/markdown-hygiene-lint/lint.spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA006 [FAIL] line 33: single-item list in the Interface section.
  Note: The `<file>` parameter is the only bullet item after the code block; a prose sentence would convey the same information without forming a one-item list.

- SA009 [WARN] line 33: list item spans two sentences.
  Note: The `<file>` entry reads "absolute or relative path … Must exist and be writable." — two distinct sentences inside one bullet; the second sentence could be folded into the first or extracted to prose.

- SA010 [WARN] line 45: `stderr` and `exit 1` appear in plain prose without backticks.
  Note: Both are shell-level technical terms; wrapping them in code spans would match the backtick treatment given to `<file>` and `0x0A` elsewhere in the document.

- SA010 [WARN] line 55: `stderr` appears in plain prose without backticks.
  Note: Same term as line 45, unquoted again in the Exit codes description.

- SA014 [SUGGEST] line 6: "always available and always runs" — both occurrences of `always` are unemphasized.
  Note: Two directive-strength qualifiers in an instruction document are not visually marked; emphasis would signal their intent to a skimming reader.

- SA014 [SUGGEST] line 43: "Always exits 0 on success" — `Always` is unemphasized.
  Note: Opens a behavioral directive; a strong qualifier like this is typically a candidate for emphasis in instruction-style specs.

- SA014 [SUGGEST] line 50: "Never CRLF" — `Never` is unemphasized.
  Note: A strong prohibition in a constraint sentence with no visual marking to distinguish it from surrounding descriptive text.

- SA018 [WARN] line 61: passive voice — "No external packages or tools required".
  Note: The sentence omits an agent; an active phrasing such as "Requires no external packages or tools" would align with the directive register used elsewhere in the Requirements section.
