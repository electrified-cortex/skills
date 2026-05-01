---
operation_kind: markdown-hygiene
result: pass
file_path: markdown-hygiene/markdown-hygiene-lint/lint.spec.md
---

# Result

lint: `clean`
analysis: `pass: .hash-record/40/40a84d4dcad7cb256a073f0b463f668ad3614b48/markdown-hygiene/analysis.md`

## Advisories

- SA006 [FAIL] line 33: fixed — converted single-item list to prose sentence.
- SA009 [WARN] line 33: fixed — folded two-sentence bullet into single prose sentence (resolved with SA006).
- SA010 [WARN] line 45: fixed — wrapped `stderr` and `exit 1` in backticks.
- SA010 [WARN] line 55: fixed — wrapped `stderr` in backticks.
- SA014 [SUGGEST] line 6: Skipped: SUGGEST-level styling; emphasis on `always` is a stylistic preference not required by the spec register.
- SA014 [SUGGEST] line 43: Skipped: SUGGEST-level styling; `Always` capitalization already signals emphasis adequately in a bullet list.
- SA014 [SUGGEST] line 50: Skipped: SUGGEST-level styling; `Never CRLF` is a terse prohibition whose force is clear without added emphasis markup.
- SA018 [WARN] line 61: fixed — rewritten to active voice: "Requires no external packages or tools".
