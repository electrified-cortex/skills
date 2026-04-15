# Compression Process

Input: `<file-path>` [`--tier <lite|full|ultra>`] (default: ultra)
Blurb → skip gate, step 4

Steps:

1. Parse path + tier (default ultra). Blurb → step 4.
2. Gate: cd to file's parent dir, then `git status --porcelain -- <basename>`. Accept only: empty (clean) or `M  <file>`; otherwise `REJECTED: <reason>`.
3. Resolve tier: `--tier` or ultra.
4. Load tier rules: `<tier>/rules.txt` (in this directory). Apply.
5. Verify (file only): compare compressed result against `git show :0:<file>` or `git show HEAD:<file>`. Every fact, rule, and constraint must survive.
   - Recoverable (single dropped item or collapsed qualifier) → fix in-place, report fix + suggest prevention.
   - Not recoverable (multi-element loss, structural damage, meaning reversal) → restore original, `REJECTED: content lost — <details>`.
6. Write result to file.

Output (required): `<before>→<after> bytes | <N>% reduction | <tier>` or `REJECTED: <reason>`
If fixed: append `Fixed: <what>` + `Suggest: <prevention>`
Blurb mode: compressed text, then `---`, then reduction line.
