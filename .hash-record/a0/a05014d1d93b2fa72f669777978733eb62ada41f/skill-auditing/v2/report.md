---
file_paths:
  - swarm/SKILL.md
  - swarm/spec.md
  - swarm/uncompressed.md
operation_kind: skill-auditing/v2
model: sonnet-class
result: fail
---

# Result

FAIL

## Skill Audit: swarm

**Verdict:** FAIL
**Type:** inline
**Path:** swarm/

### Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — SKILL.md contains full procedure; no instructions.txt present |
| Inline/dispatch consistency | PASS | No dispatch instruction file; SKILL.md is full procedure |
| Structure | PASS | Frontmatter present, direct instructions, self-contained |
| Input/output double-spec (A-IS-1) | PASS | No sub-skill output path duplication |
| Sub-skill input isolation (A-IS-2) | N/A | |
| Frontmatter | PASS | `name` and `description` only in both SKILL.md and uncompressed.md |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder `swarm/` |
| Valid frontmatter fields (A-FM-4) | PASS | No extra keys |
| Trigger phrases (A-FM-11) | PASS | `Triggers -` present in description |
| Frontmatter mirror (A-FM-12) | PASS | uncompressed.md `name` and `description` match SKILL.md exactly |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no real H1; uncompressed.md has `# swarm — Uncompressed Reference` |
| No duplication | PASS | No equivalent skill found |
| Orphan files (A-FS-1) | PASS | All files in skill_dir are well-known role files or referenced by SKILL.md/spec.md |
| Missing referenced files (A-FS-2) | PASS | All explicitly referenced files exist: specs/arbitrator.md, specs/dispatch-integration.md, specs/glossary.md, specs/personality-file.md, specs/registry-format.md, reviewers/index.yaml, reviewers/devils-advocate.md, reviewers/security-auditor.md |

### Step 2 — Parity

| Pair | Result | Notes |
| --- | --- | --- |
| SKILL.md ↔ uncompressed.md | FAIL | Step 7: SKILL.md says `personality names cited`; uncompressed.md says `personality indices cited` |
| instructions.txt ↔ instructions.uncompressed.md | N/A | Neither file present |

### Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located with SKILL.md |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use `must`, `shall`, `required` throughout |
| Internal consistency | PASS | No contradictions within spec |
| Spec completeness | PASS | All terms defined; behavior explicitly stated |
| Coverage | FAIL | SKILL.md C6 omits `gpt-class` from permitted model class list; spec C6 includes it |
| No contradictions | FAIL | SKILL.md Step 6 says `source personality indices`; spec Step 6 says `source personality names` |
| No unauthorized additions | PASS | |
| Conciseness | PASS | Agent-facing density; decision trees and bullets throughout |
| Completeness | PASS | All runtime instructions present |
| Breadcrumbs | PASS | Related section references valid targets; all sub-spec files confirmed present |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No instructions.txt |
| No spec breadcrumbs | PASS | SKILL.md does not reference companion spec.md |
| Eval log (informational) | ABSENT | |
| Description not restated (A-FM-2) | PASS | Body prose does not duplicate frontmatter description |
| No exposition in runtime (A-FM-5) | FAIL | Two `Rationale:` blocks in uncompressed.md body |
| No non-helpful tags (A-FM-6) | PASS | |
| No empty sections (A-FM-7) | PASS | |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety references present |
| Iteration-safety pointer form (A-FM-9a) | N/A | |
| No verbatim Rule A/B (A-FM-9b) | N/A | |
| Cross-reference anti-pattern (A-XR-1) | PASS | All cross-skill references use canonical names (`dispatch`, `compression`) |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| Inline dispatch guard (DS-4) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| SKILL.md | Not empty | PASS | |
| SKILL.md | Frontmatter required | PASS | YAML frontmatter present at line 1 |
| SKILL.md | No abs-path leaks | PASS | |
| spec.md | Not empty | PASS | |
| spec.md | Frontmatter required | N/A | Not SKILL.md or agent.md |
| spec.md | No abs-path leaks | PASS | |
| uncompressed.md | Not empty | PASS | |
| uncompressed.md | Frontmatter required | PASS | YAML frontmatter present at line 1 |
| uncompressed.md | No abs-path leaks | PASS | |
| reviewers/devils-advocate.md | Not empty | PASS | |
| reviewers/devils-advocate.md | Frontmatter required | N/A | Not SKILL.md or agent.md |
| reviewers/devils-advocate.md | No abs-path leaks | PASS | |
| reviewers/security-auditor.md | Not empty | PASS | |
| reviewers/security-auditor.md | Frontmatter required | N/A | Not SKILL.md or agent.md |
| reviewers/security-auditor.md | No abs-path leaks | PASS | |
| specs/arbitrator.md | Not empty | PASS | |
| specs/arbitrator.md | Frontmatter required | N/A | Not SKILL.md or agent.md |
| specs/arbitrator.md | No abs-path leaks | PASS | |

### Issues

**[FAIL] Step 3 — No contradictions: SKILL.md Step 6 uses `personality indices` where spec requires `personality names`**

SKILL.md Step 6 (Required arbitrator output format):
```
Obvious actions: 2+ swarm members independently flagged same concern, or concern is self-evident from artifact. Each entry: action description + source personality indices + evidence cite.
Critical actions: items that, if unaddressed, would block shipping or require architectural change, regardless of reviewer agreement count. Each entry: action description + source personality indices + evidence cite + severity rationale.
```

Spec Step 6(a): `Each item includes: description, source personality names, and evidence cite.`
Spec Step 6(b): `Each item includes: description, source personality names, evidence cite, and severity rationale.`

Spec is authoritative. SKILL.md says `personality indices`; spec says `personality names`. uncompressed.md Step 6 has the same `personality indices` language (in sync with SKILL.md, both wrong). Fix: change `source personality indices` to `source personality names` in SKILL.md Step 6 (both Obvious and Critical entries) and uncompressed.md Step 6, then recompress.

---

**[FAIL] Step 3 — Coverage: SKILL.md C6 and uncompressed.md C6 omit `gpt-class` from permitted model class list**

SKILL.md C6:
```
C6. No bare model names in skill, reviewer files, or synthesis output. Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`.
```

uncompressed.md C6:
```
C6. No bare model names may appear in the skill, reviewer files, or synthesis output. Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`.
```

Spec C6:
```
C6. No bare model names (e.g., specific version strings) may appear in the skill, its reviewer files, or its synthesis output. Use model class terms only: `haiku-class`, `sonnet-class`, `opus-class`, `gpt-class`.
```

Spec explicitly includes `gpt-class`. Both compiled artifacts omit it. `gpt-class` is used in reviewers/index.yaml (Devil's Advocate entry) and is defined in Key Terms of both SKILL.md and uncompressed.md — the omission from C6 is inconsistent and means agents following C6 have an incomplete permitted-terms list. Fix: append `` `gpt-class` `` to the permitted terms in SKILL.md C6 and uncompressed.md C6.

---

**[HIGH] A-FM-5: Two `Rationale:` blocks in uncompressed.md body**

Instance 1, uncompressed.md Step 2:
```
Rationale: the token cost of a selection dispatch exceeds the cost of inline evaluation for registries of the current scale (under 12 entries). This decision should be revisited if the registry grows beyond approximately 20 entries.
```

Instance 2, uncompressed.md Step 4:
```
Rationale for sub-skill files over inline data: inline prompts bloat the context regardless of which personalities are selected, defeating lazy loading. Dynamic data loading at dispatch time keeps the skill's base context minimal. This is a normative decision; implementors must not revert to inline prompts.
```

Both blocks are rationale prose. Per A-FM-5, rationale belongs exclusively in spec.md (where it already appears verbatim). Fix: remove both `Rationale:` blocks from uncompressed.md, then recompress SKILL.md. SKILL.md itself does not have these rationale blocks and is clean.

---

**[HIGH] Step 2 — Parity failure: uncompressed.md Step 7 says `personality indices cited`; SKILL.md Step 7 says `personality names cited`**

SKILL.md Step 7: `record: personality names cited, finding summary, cited evidence.`

uncompressed.md Step 7: `the skill records: personality indices cited, finding summary, evidence cite.`

Compiled artifact (SKILL.md) and uncompressed source diverge on `names` vs `indices`. Spec Step 7 confirms `personality names cited` is correct. Fix: edit uncompressed.md Step 7 to read `personality names cited`, then recompress to SKILL.md.
