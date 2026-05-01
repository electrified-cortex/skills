---
file_path: markdown-hygiene/markdown-hygiene-lint/spec.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA004 [WARN]: Significant portion of non-code prose is bold — all eight procedure step labels and all four Output Contract sub-section headers use bold.
  Note: Bold serves a structural/navigational role rather than inline emphasis; the one inline bold ("**do not**") loses contrast against the surrounding label-bold.

- SA009 [WARN] line 22: Step 2 list item spans four sentences covering three distinct conditions.
  Note: Linter availability, installation prohibition, and SKILL.md exception are bundled into one item; the density is higher than the surrounding steps.

- SA014 [SUGGEST] line 21: "always runs" — "always" is unemphasized in plain prose.
  Note: Instruction-strength qualifier with no visual signal to distinguish it from descriptive text.

- SA014 [SUGGEST] line 106: "This executor must not modify the target file." — "must not" is unemphasized.
  Note: Prohibitive directive carries no visual emphasis, unlike the bolded "**do not**" on line 22 and 26.

- SA018 [WARN] line 106: "Preparation auto-fix is the only permitted modification." — passive construction in a constraint sentence.
  Note: The permitted actor is implicit; "Only preparation auto-fix may modify the target file" would name the subject directly.

- SA028 [WARN]: "co-located in this sub-skill folder" appears verbatim on lines 21, 26, and 62.
  Note: Three occurrences of the same five-word phrase; it describes a static fact about the skill layout that is repeated rather than stated once.

- SA031 [WARN] line 97: H3 siblings mix capitalization conventions — lines 66, 74, and 82 begin with lowercase `lint.md` (filename prefix), while line 97 `Return value` begins with a capital.
  Note: The lowercase-initial headings are driven by the filename; `Return value` follows a different pattern, making the group inconsistent.

- SA032 [WARN]: The preparation activity is called "preparation pass" (line 5), "auto-fix pass" (lines 5 and 22), and "Preparation auto-fix" (line 106).
  Note: Three distinct names appear to reference the same workflow phase; a single term used consistently would reduce ambiguity.

- SA038 [FAIL]: Line 5 states "Preparation always modifies the target file"; line 106 states "This executor must not modify the target file."
  Note: Taken individually the two statements contradict; the reconciling clause "Preparation auto-fix is the only permitted modification" appears in the same sentence as the prohibition but is easy to miss; merging the constraint into a single affirmative statement would remove the surface contradiction.
