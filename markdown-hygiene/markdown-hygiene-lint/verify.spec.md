# verify — Spec

## Purpose

Provide a deterministic, installation-free pre-pass for mechanical markdown
hygiene rules. Replaces per-invocation script improvisation in the executor
with a stable, versioned tool whose output is reproducible and testable.

## Scope

Covers the following markdownlint rules via pure shell logic (no external
packages). MD009, MD012, and MD047 are handled by the co-located `lint` tool
and are NOT re-checked here.

| Rule | Description |
| --- | --- |
| MD010 | Hard tabs outside fenced code blocks |
| MD041 | First non-blank line must be H1 (auto-suppressed for frontmatter) |

Does NOT cover: MD001, MD003, MD004, MD009, MD012, MD022, MD023, MD024, MD025, MD026,
MD029, MD031, MD032, MD033, MD034, MD040, MD047, MD055, MD056, MD058, MD060.
Those remain the responsibility of the executor's LLM rule-knowledge pass.

## Interface

### Inputs

```text
verify.sh  <file> [--ignore RULE[,RULE...]]
verify.ps1 <file> [-Ignore  RULE[,RULE...]]
```

- `<file>` (positional, required): absolute or relative path to the `.md`
  file to check.
- `--ignore` / `-Ignore` (optional): comma-separated list of rule codes to
  suppress for this run.

Adaptive MD041 suppression: if the first non-blank line of the file is `---`
(YAML frontmatter), MD041 is automatically suppressed regardless of `--ignore`.

### Output (stdout)

CLEAN case (no violations):

```text
CLEAN
```

Violations (one pair per violation, no blank lines between pairs):

```text
MD009 line 3: trailing spaces
Fix: remove trailing whitespace from line 3
MD047: file lacks trailing newline
Fix: append a single newline at end of file
```

Each violation is exactly two lines:

1. `<RULE> [line <N>]: <description>` — file-level rules omit `line N`.
2. `Fix: <imperative>` — complete, standalone. The executor passes this
   verbatim to the Fix-line section of the report.

### Output encoding

- UTF-8, no BOM.
- LF line endings (`0x0A`). Never CRLF.
- ASCII content only in rule/fix lines (file paths never appear in output).

### Exit codes

- `0`: success (CLEAN or violations found — both are valid results).
- `1`: usage error or file not found (message on stderr).

## Requirements

R1. Both scripts MUST produce byte-identical stdout when run against the same
    input file on the same platform.

R2. Both scripts MUST require no installation. `verify.sh` uses bash 4.3+
    and POSIX `tail`. `verify.ps1` uses pwsh 7.0+ .NET APIs only.

R3. Both scripts MUST implement all five rules listed in Scope with identical
    behavior.

R4. Frontmatter detection MUST suppress MD041. Detection: first non-blank
    line equals exactly `---`.

R5. MD010 MUST NOT flag tab characters inside fenced code blocks (triple
    backtick fences). The fence delimiter lines themselves are also exempt.

R6. MD012 MUST flag each excess blank line individually. A run of three
    consecutive blank lines produces two violations (lines N+1 and N+2).

R7. Output MUST use the exact format defined in this spec. No trailing
    spaces on output lines. No blank lines between violation pairs. Final
    line of output terminates with `\n`.

R8. The `--ignore` / `-Ignore` flag MUST suppress the specified rules
    entirely for the run. Suppressed rules produce no output entries.

R9. Both scripts MUST be idempotent. Running verify twice on the same file
    with the same flags produces identical output.

## Constraints

C1. No external packages. No `npm install`, no `pip install`, no `gem`.
C2. No file modification. Verify is read-only.
C3. Output is ASCII-strict. No Unicode arrows, no emoji, no special chars.
C4. `verify.sh` requires bash 4.3+ (`mapfile`, `declare -A`). Not POSIX sh.
C5. `verify.ps1` requires pwsh 7.0+.
C6. Tilde-fence code blocks (`~~~`) are not detected. Only backtick fences.
    This is a known limitation; file it as a future enhancement if needed.
C7. CRLF input is tolerated by `verify.ps1` (strips `\r` from line ends
    before analysis). `verify.sh` behavior on CRLF files is undefined —
    inputs are expected to use LF.

## Test Fixtures and Eval Suite

Located at `markdown-hygiene/.tests/verify/`.

Each fixture file has a companion `<name>.expected.txt` containing the
expected verify stdout (LF-terminated, byte-comparable).

Required fixtures:

| File | Rule triggered |
| --- | --- |
| `clean.md` | none (CLEAN) |
| `trailing-spaces.md` | MD009 |
| `tabs.md` | MD010 |
| `blanks.md` | MD012 |
| `no-frontmatter-no-h1.md` | MD041 |
| `no-trailing-newline.md` | MD047 |

`verify.test.sh` and `verify.test.ps1` run each fixture through the
respective script and diff stdout against `<name>.expected.txt`. Exit 0
if all pass; print per-fixture FAIL lines and exit 1 if any fail.
