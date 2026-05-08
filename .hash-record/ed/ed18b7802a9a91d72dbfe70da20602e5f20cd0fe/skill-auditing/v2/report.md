---
file_paths:
  - messaging/SKILL.md
  - messaging/spec.md
  - messaging/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: messaging

**Verdict:** FAIL
**Type:** inline
**Path:** messaging/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — no dispatch instruction file present; SKILL.md is a self-contained reference card |
| Inline/dispatch consistency | PASS | No instructions.txt; SKILL.md contains full procedure |
| Structure | PASS | Frontmatter present; direct instructions; self-contained |
| Input/output double-spec (A-IS-1) | N/A | Inline skill; no sub-skills |
| Sub-skill input isolation (A-IS-2) | N/A | No sub-skills |
| Frontmatter | PASS | name and description present in SKILL.md |
| Name matches folder (A-FM-1) | PASS | `name: messaging` matches folder `messaging/` in both SKILL.md and uncompressed.md |
| Valid frontmatter fields (A-FM-4) | PASS | SKILL.md frontmatter contains only `name` and `description` |
| Trigger phrases (A-FM-11) | PASS | `Triggers -` present in description of both SKILL.md and uncompressed.md |
| uncompressed.md frontmatter mirror (A-FM-12) | PASS | name and description match SKILL.md exactly |
| H1 per artifact (A-FM-3) | FAIL | SKILL.md contains a real H1 (`# Messaging` at line 6); SKILL.md MUST NOT contain a real H1 — HIGH |
| No duplication | PASS | No equivalent skill found in workspace |
| Orphan files (A-FS-1) | PASS | `implementation.md` referenced in spec.md (R12, R22, C1); all other non-manifest files are well-known role files |
| Missing referenced files (A-FS-2) | PASS | `implementation.md` referenced by spec.md exists |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | PASS | Compressed form faithfully represents uncompressed content; no omitted requirements or changed behavior |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file exists |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md present co-located with messaging/ |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | MUST used throughout requirements |
| Internal consistency | PASS | No contradictions detected |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | PASS | All normative requirements represented in SKILL.md |
| No contradictions | PASS | SKILL.md content consistent with spec |
| No unauthorized additions | PASS | SKILL.md introduces no normative requirements absent from spec |
| Conciseness | PASS | Agent-facing density; no "too much why," no essay prose |
| Completeness | PASS | Runtime instructions present; edge cases addressed; defaults stated |
| Breadcrumbs | PASS | Related section references `markdown-hygiene`, `skill-auditing`, `compression` by canonical name |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No instructions file |
| No spec breadcrumbs | PASS | SKILL.md and uncompressed.md do not reference their own spec.md |
| Eval log (informational) | ABSENT | No eval.txt or eval.md present |
| Description not restated (A-FM-2) | LOW | Body openers in SKILL.md ("Agents communicate via inbox msg files") and uncompressed.md ("Agents communicate by posting message files into one another's inbox") restate the description concept ("File-based agent-to-agent messaging via shared inbox"). Not verbatim → LOW |
| No exposition in runtime (A-FM-5) | PASS | No rationale or background prose found |
| No non-helpful tags (A-FM-6) | PASS | No bare descriptor labels found |
| No empty sections (A-FM-7) | PASS | All headings have body content |
| Iteration-safety placement (A-FM-8) | N/A | No instructions file |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety reference present |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references in Related section use canonical names |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Applied via A-FM-11 above |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

**Tool Integration (DS-7):**

| Check | Result | Notes |
| --- | --- | --- |
| All tools referenced | PASS | init, post, drain, status referenced in SKILL.md and spec.md |
| Complete trios present | PASS | Each tool has .ps1, .sh, and .spec.md |
| Tool-spec alignment with spec.md | PASS | Tool spec behaviors consistent with spec.md role descriptions |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter | PASS | Required; present |
| `SKILL.md` | No abs-path leaks | PASS | |
| `SKILL.md` | H1 (A-FM-3) | FAIL | Contains `# Messaging` at line 6 — SKILL.md MUST NOT have a real H1 — HIGH |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter | PASS | |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `spec.md` | No abs-path leaks | PASS | |
| `implementation.md` | Not empty | PASS | |
| `implementation.md` | Frontmatter | N/A | Not SKILL.md or agent.md |
| `implementation.md` | No abs-path leaks | PASS | |
| `init.spec.md` | Not empty | PASS | |
| `init.spec.md` | No abs-path leaks | PASS | |
| `init.spec.md` | Purpose section | PASS | `## Purpose` present |
| `init.spec.md` | Parameters section | FAIL | Has `## Inputs`; MUST contain `## Parameters` or `# Parameters` — HIGH |
| `init.spec.md` | Output section | FAIL | No `## Output` or `# Output`; has `## Exit Codes` only — HIGH |
| `post.spec.md` | Not empty | PASS | |
| `post.spec.md` | No abs-path leaks | PASS | |
| `post.spec.md` | Purpose section | PASS | `## Purpose` present |
| `post.spec.md` | Parameters section | FAIL | Has `## Inputs`; MUST contain `## Parameters` or `# Parameters` — HIGH |
| `post.spec.md` | Output section | FAIL | No `## Output` or `# Output` — HIGH |
| `drain.spec.md` | Not empty | PASS | |
| `drain.spec.md` | No abs-path leaks | PASS | |
| `drain.spec.md` | Purpose section | PASS | `## Purpose` present |
| `drain.spec.md` | Parameters section | FAIL | Has `## Inputs`; MUST contain `## Parameters` or `# Parameters` — HIGH |
| `drain.spec.md` | Output section | FAIL | Has `## Output Format`; MUST contain `## Output` or `# Output` exactly — HIGH |
| `status.spec.md` | Not empty | PASS | |
| `status.spec.md` | No abs-path leaks | PASS | |
| `status.spec.md` | Purpose section | PASS | `## Purpose` present |
| `status.spec.md` | Parameters section | FAIL | Has `## Inputs`; MUST contain `## Parameters` or `# Parameters` — HIGH |
| `status.spec.md` | Output section | FAIL | Has `## Output Example`; MUST contain `## Output` or `# Output` exactly — HIGH |

### Issues

- **[HIGH — A-FM-3] SKILL.md real H1:** `SKILL.md` contains `# Messaging` at line 6. SKILL.md MUST NOT contain a real H1. Fix: remove the `# Messaging` heading from `messaging/SKILL.md`.

- **[HIGH — Per-file *.spec.md] init.spec.md missing `## Parameters`:** Section heading is `## Inputs` not `## Parameters`. Fix: rename `## Inputs` to `## Parameters` in `messaging/init.spec.md`.

- **[HIGH — Per-file *.spec.md] init.spec.md missing `## Output`:** No `## Output` or `# Output` section present; tool outputs are described only implicitly via exit codes. Fix: add an `## Output` section documenting stdout behavior to `messaging/init.spec.md`.

- **[HIGH — Per-file *.spec.md] post.spec.md missing `## Parameters`:** Section heading is `## Inputs` not `## Parameters`. Fix: rename `## Inputs` to `## Parameters` in `messaging/post.spec.md`.

- **[HIGH — Per-file *.spec.md] post.spec.md missing `## Output`:** No `## Output` or `# Output` section present. Fix: add an `## Output` section to `messaging/post.spec.md`.

- **[HIGH — Per-file *.spec.md] drain.spec.md missing `## Parameters`:** Section heading is `## Inputs` not `## Parameters`. Fix: rename `## Inputs` to `## Parameters` in `messaging/drain.spec.md`.

- **[HIGH — Per-file *.spec.md] drain.spec.md missing `## Output`:** Section heading is `## Output Format`, not `## Output`. Fix: rename `## Output Format` to `## Output` in `messaging/drain.spec.md`.

- **[HIGH — Per-file *.spec.md] status.spec.md missing `## Parameters`:** Section heading is `## Inputs` not `## Parameters`. Fix: rename `## Inputs` to `## Parameters` in `messaging/status.spec.md`.

- **[HIGH — Per-file *.spec.md] status.spec.md missing `## Output`:** Section heading is `## Output Example`, not `## Output`. Fix: rename `## Output Example` to `## Output` in `messaging/status.spec.md`.

- **[LOW — A-FM-2] Description concept restated in body:** Body openers in SKILL.md and uncompressed.md restate "file-based agent-to-agent messaging via shared inbox" in different words. Not verbatim — LOW. Consider rewording openers to add content beyond the description.

### Recommendation

Remove the H1 from SKILL.md and rename `## Inputs` → `## Parameters` and `## Output Format`/`## Output Example` → `## Output` across all four tool spec files to satisfy per-file structural checks.
