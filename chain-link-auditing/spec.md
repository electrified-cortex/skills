# chain-link-auditing — Specification

## Purpose

Mechanically verify a chain-link SKILL folder against the chain-link contract
defined in `chain-link-writing`. Runs FIRST in the audit sequence — if the
chain contract is wrong, general SKILL hygiene is moot. On PASS, the link is
clean from a chain-orchestration standpoint and the caller may proceed to
general `skill-auditing`. On FAIL, the SKILL is rejected before general
audit runs.

## Scope

Applies to any link directory that participates in a chain (declared via a
`chain.md` manifest at the chain root). Covers: manifest presence, manifest
schema, link directory naming, SKILL body boundary, output declaration
alignment, input alignment with upstream outputs, mode/`instructions.txt`
consistency, terminus/first-link constraints, brevity targets, and
repo-relative path enforcement.

Does not cover: general SKILL frontmatter / triggers / hygiene (see
`skill-auditing`), spec content (see `spec-auditing`), or chain construction
strategy (see `chain-builder` when authored).

## Definitions

- **Link folder**: the directory under audit, e.g.
  `workflows/engineering/investigate/`. Contains at minimum a `SKILL.md`.
  May also contain `spec.md`, `instructions.txt`, `uncompressed.md`,
  `result.sh`/`result.ps1`, or a `.hash-record/` cache.
- **Chain root**: the directory containing `chain.md`. The link folder is
  immediately under (or in a stable sub-path of) the chain root.
- **Chain manifest**: `chain.md` at the chain root. Schema defined in
  `chain-link-writing` spec.
- **Link row**: the row in the manifest's Links table whose `id` equals the
  link folder's directory name.
- **Verdict**: emitted on the sub-agent's last stdout line, column 0, no
  indent. One of `PASS:`, `NEEDS_REVISION:`, `FAIL:`, or `BLOCKED:`,
  followed by the absolute path to the audit report.
- **Audit report**: Markdown file written by the sub-agent to a caller-
  specified path (`--report-path`). Sections: Manifest Check, Boundary
  Check, Contract Alignment, Brevity Check, Findings, Verdict.

## Inputs

| Field | Required | Notes |
|---|---|---|
| `<link_dir>` | yes | Repo-relative path to the link folder |
| `<chain_root>` | optional | Defaults to the link folder's parent directory walked upward to the first `chain.md` |
| `<report_path>` | yes | Absolute path to write the audit report; overwrite if present |

## Requirements

### R-CLA-1 — Manifest presence and schema

The auditor MUST locate the chain manifest. Algorithm:
- If `<chain_root>` is supplied, look for `<chain_root>/chain.md`. Absent →
  finding `M-1 manifest-missing` (FAIL).
- If not supplied, walk upward from `<link_dir>` until a `chain.md` is
  found or the repo root is reached. Not found → finding `M-1 manifest-missing`
  (FAIL).

The auditor MUST parse the manifest's Links table. Required columns: `id`,
`link`, `mode`, `tier`, `prev`, `next-pass`, `next-fail`, `next-blocked`,
`outputs`. Missing column → finding `M-2 manifest-schema-incomplete: column
<name>` (FAIL).

### R-CLA-2 — Link row lookup

The auditor MUST find the row whose `id` equals the link folder's directory
name. Not found → finding `M-3 link-row-missing: <dir-name>` (FAIL).

Field values are constrained:
- `mode` ∈ `{inline, dispatch}` — else `M-4 mode-invalid`.
- `tier` ∈ `{fast-cheap, standard, deep}` — else `M-5 tier-invalid`.
- `prev`, `next-pass`, `next-fail`, `next-blocked` either reference an
  existing `id` in the same manifest or contain `—` — else `M-6
  link-reference-broken: <field>: <value>`.

### R-CLA-3 — SKILL body boundary check

The auditor reads `<link_dir>/SKILL.md` (required; absent → finding `B-1
skill-missing` FAIL) and checks:

- **B-2 orchestration-leak**: SKILL body contains next-link decisions,
  prev/next routing tables, or a routing table whose semantics duplicate the
  manifest row. SEVERITY: HIGH.
- **B-3 narrative-bloat**: SKILL body contains rationale, background, or
  multi-paragraph prose explaining "why." Belongs in spec. SEVERITY: MEDIUM.
- **B-4 stack-leak**: SKILL body declares stack-specific file extensions,
  language idioms, or framework names, AND the chain manifest does NOT
  declare the chain as stack-specific (no `stack: <name>` in manifest
  header or notes). SEVERITY: HIGH.
- **B-5 duplicate-restatement**: SKILL body restates dispatch mechanics,
  markdown-hygiene rules, hash-record semantics, or any other cross-skill
  convention that already exists as a sibling skill. SEVERITY: LOW.

### R-CLA-4 — Output alignment

The auditor extracts the SKILL's declared outputs (typically from an "Output"
or "Outputs" section, or the output JSON's top-level keys). Compares to the
manifest row's `outputs` column.

- **C-1 outputs-undeclared**: SKILL emits a value not listed in manifest
  `outputs`. SEVERITY: HIGH.
- **C-2 outputs-missing**: manifest `outputs` lists a value the SKILL does
  not emit. SEVERITY: HIGH.

### R-CLA-5 — Input alignment

The auditor extracts the SKILL's declared inputs (typically from an "Inputs"
section or the input table). Compares to the union of:
- `outputs` column of every upstream link reachable from this link's `prev`
  chain (walk back to the first link).
- Chain entry-point inputs declared in the manifest's Acceptance paragraph.

- **C-3 inputs-undeclared-upstream**: SKILL consumes a value that no
  upstream link produces and is not a chain entry input. SEVERITY: HIGH.

### R-CLA-6 — Mode / instructions.txt consistency

- **D-1 dispatch-missing-instructions**: `mode: dispatch` and `<link_dir>`
  does NOT contain `instructions.txt`. SEVERITY: HIGH.
- **D-2 inline-has-instructions**: `mode: inline` and `<link_dir>` DOES
  contain `instructions.txt`. SEVERITY: HIGH.

### R-CLA-7 — Terminus / first-link manifest constraints

These checks operate on the manifest as a whole (the link row's check):

- **T-1 no-first-link**: no row has `prev: —`. SEVERITY: HIGH (manifest
  invalid).
- **T-2 multiple-first-links**: more than one row has `prev: —`. SEVERITY:
  HIGH.
- **T-3 no-terminus**: no row has `next-pass: —`. SEVERITY: HIGH (chain
  has no exit).

### R-CLA-8 — Brevity check

Line counts on `<link_dir>/SKILL.md`:

- `mode: dispatch` SKILL > 50 lines → finding `Z-1 dispatch-over-budget: <n>
  lines` (SEVERITY: MEDIUM; threshold 40 + 10 grace).
- `mode: inline` SKILL with no internal loop > 75 lines → finding `Z-2
  inline-over-budget: <n> lines` (SEVERITY: MEDIUM; threshold 60 + 15 grace).
- `mode: inline` SKILL with cap-N loop (loop or iterate keywords present) >
  120 lines → finding `Z-3 inline-loop-over-budget: <n> lines` (SEVERITY:
  MEDIUM; threshold 100 + 20 grace).
- Any SKILL > 150 lines → finding `Z-4 presumptive-bloat: <n> lines`
  (SEVERITY: HIGH).

### R-CLA-9 — Repo-relative path enforcement

Scan SKILL body for absolute paths (drive letters, `/home/`, `/Users/`,
`C:\`, `D:\`, etc.).
- **P-1 absolute-path**: SEVERITY: HIGH for each occurrence.

### R-CLA-10 — Hash-record is optional

Hash-record usage (presence of `result.sh`/`result.ps1`, `.hash-record/`) is
NEVER a finding. Cache mechanics are at the author's discretion (per
chain-link-writing R-CLW-9).

### R-CLA-11 — Verdict rules

Aggregate findings into a verdict:

| Condition | Verdict |
|---|---|
| Zero findings | `PASS` |
| Only LOW severity findings | `PASS` (mention LOW in report) |
| One or more MEDIUM findings, zero HIGH | `NEEDS_REVISION` |
| One or more HIGH findings | `FAIL` |
| Manifest unreadable, link folder unreadable, or sub-agent could not complete | `BLOCKED` |

### R-CLA-12 — Sub-agent procedure (instructions.txt)

The audit procedure is fully specified in `instructions.txt`. The host
SKILL.md MUST NOT inline the procedure.

## Constraints

- **C1** — Audit runs in a dispatched sub-agent. No inline audit by the
  host.
- **C2** — Tier default: `fast-cheap` (haiku-class). Mechanical contract
  checks; sonnet-class only on a re-dispatch for ambiguous results.
- **C3** — Sub-agent MUST NOT modify source files (the SKILL, the spec,
  the manifest, instructions.txt). Read-only except for writing the report.
- **C4** — Sub-agent MUST NOT dispatch further sub-agents.
- **C5** — Hash-record cache is permitted but not required for v1. If
  present, the host checks the cache before dispatching; on HIT, emits the
  cached verdict; on MISS, dispatches.
- **C6** — Report path is caller-specified. No fixed location.
- **C7** — All paths in the report and in any persisted artifact are
  repo-relative. No drive letters, no usernames.
- **C8** — Run BEFORE `skill-auditing`. Chain contract failure makes
  general hygiene moot.

## Sub-Agent Contract

The sub-agent receives `--link-dir <abs>` (required), `--chain-root <abs>`
(optional; auditor walks up to find chain.md if absent), and `--report-path
<abs>` (required, overwrite if present).

The sub-agent MUST:
1. Locate the chain manifest (R-CLA-1). Apply schema check.
2. Find the link row (R-CLA-2).
3. Read the SKILL body. Apply R-CLA-3 through R-CLA-9 checks.
4. Aggregate findings by severity.
5. Write the report. Sections in order: Manifest Check, Boundary Check,
   Contract Alignment, Brevity Check, Findings (severity-tagged), Verdict.
6. Emit verdict as final stdout line:
   `PASS: <report_path>` | `NEEDS_REVISION: <report_path>` |
   `FAIL: <report_path>` | `BLOCKED: <report_path>`

The sub-agent MUST NOT modify any source file or dispatch further sub-agents.

## Behavior

On entry the host holds `<link_dir>` and (optionally) `<chain_root>`. Binds
`<report_path>`. Dispatches a haiku-class sub-agent with `instructions.txt`
and the inputs. Reads verdict from the report's last line. Returns.

When the caller is in the `chain-link-writing` authoring workflow, this
audit runs BEFORE `skill-auditing` (per chain-link-writing step 5). When
still developing the SKILL, `skill-auditing` MAY be skipped per operator
direction (msg 52729) but chain-link-auditing MAY NOT.

## Error Handling

| Error | Behavior |
|---|---|
| `<link_dir>` absent | BLOCKED; reason `link-dir-missing` |
| `chain.md` not found by walk-up | finding M-1; FAIL |
| Manifest schema incomplete | finding M-2; FAIL |
| Link row not found | finding M-3; FAIL |
| Report file absent after dispatch | Surface `ERROR: executor did not write report at <report_path>`; stop |
| Unrecognized verdict token | ERROR: unrecognized verdict in report |
| Sub-agent dispatch failure | BLOCKED; reason `dispatch-failure` |

## Don'ts

- Do not audit a SKILL that is not part of a chain. Use `skill-auditing`
  directly.
- Do not run inline. Always dispatch.
- Do not flag hash-record presence or absence — that's an author choice.
- Do not flag bloat below the thresholds in R-CLA-8 (allow grace room
  beyond the brevity targets in chain-link-writing).
- Do not modify source files.
- Do not write absolute paths into the report.
