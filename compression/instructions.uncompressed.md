# Compression Process

Input: `<file-path>` [`--tier <lite|full|ultra>`] [`--source <src> --target <dst>`] (default tier: ultra)
Blurb → skip gate, step 4

## Modes

**Source→Target:** `--source X --target Y` → read X, compress, write Y. No git check. X untouched.
**In-place (default):** compress file directly. Git check required.
**Fallback:** if file is untracked/dirty and no `--target`, create `<file>.compressed` alongside.

Steps:

1. Parse path + tier (default ultra) + mode. Blurb → step 4.
2. Gate (skip if `--source`/`--target` provided):
   - cd to file's parent dir, `git status --porcelain -- <basename>`.
   - Clean (`  ` or `M `) → in-place mode.
   - Untracked (`??`) or dirty (`M`, `A`, etc.) → fallback: target = `<file>.compressed`.
   - `REJECTED` only on conflict/deleted states.
3. Resolve tier: `--tier` or ultra.
4. Load tier rules: `<tier>/rules.txt` (in this directory). Apply.
5. Verify (file mode only, not blurb): compare compressed result against original content. Every fact, rule, and constraint must survive.
   - Recoverable (single dropped item or collapsed qualifier) → fix in-place, report fix + suggest prevention.
   - Not recoverable (multi-element loss, structural damage, meaning reversal) → restore original, `REJECTED: content lost — <details>`.
6. Write result to target (in-place, `.compressed`, or `--target` path).

Output (required): `<before>→<after> bytes | <N>% reduction | <tier> | <mode>`
Mode = `in-place`, `alongside (<file>.compressed)`, or `source→target (<dst>)`
If fixed: append `Fixed: <what>` + `Suggest: <prevention>`
Blurb mode: compressed text, then `---`, then reduction line.

## Iteration Safety

Before dispatching any compress → audit → recompress cycle, apply both rules:

**Rule A — Fix source before recompressing.** If audit returns NEEDS_REVISION or FAIL, resolve findings in the authoritative source file (`uncompressed.md` or `instructions.uncompressed.md`) before recompressing. Recompressing an unchanged source produces an identical artifact; the verdict is deterministic. The pass is wasted work and must not be performed.

**Rule B — Never re-audit unchanged content.** "Never re-audit a file that has not been modified since the previous audit, period, full stop." If no authoritative source file has changed since the previous compress pass completed, the compressed output is identical and the audit verdict is deterministic. Do not re-dispatch the audit. The prior verdict stands.
