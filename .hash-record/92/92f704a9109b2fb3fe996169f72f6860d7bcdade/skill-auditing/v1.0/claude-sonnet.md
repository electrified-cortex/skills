---
hash: 92f704a9109b2fb3fe996169f72f6860d7bcdade
file_paths:
  - markdown-hygiene/instructions.uncompressed.md
  - markdown-hygiene/spec.md
  - markdown-hygiene/uncompressed.md
operation_kind: skill-auditing
result: findings
---

# Result

NEEDS_REVISION

Skill Audit: markdown-hygiene

**Verdict:** NEEDS_REVISION
**Type:** dispatch
**Path:** markdown-hygiene/SKILL.md
**Failed phase:** none

Phase 1 — Spec Gate:

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | spec.md co-located |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | must/shall/MUST NOT/required used correctly |
| Internal consistency | PASS | spec is internally self-consistent |
| Completeness | PASS | all terms defined; behavior explicit |

Phase 2 — Skill Smoke Check:

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | haiku-class, mechanically self-contained — dispatch correct |
| Inline/dispatch consistency | PASS | instructions.txt present; SKILL.md is short routing card |
| Structure | PASS | routing card minimal; params typed; output stated |
| Input/output double-spec (A-IS-1) | PASS | no input double-spec found |
| Frontmatter | PASS | name + description present and accurate |
| Name matches folder (A-FM-1) | PASS | name: markdown-hygiene matches folder |
| H1 per artifact (A-FM-3) | PASS | SKILL.md no H1 (correct); uncompressed.md H1 present; instructions.uncompressed.md H1 present; instructions.txt no H1 (correct) |
| No duplication | PASS | unique skill; no equivalent in corpus |

Phase 3 — Spec Compliance:

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | FINDINGS | spec line 116 declares `model:` field written to records; instructions procedure (step 5 frontmatter list) does not include `model:` — partial coverage: procedure correct per contract change, spec not updated |
| No contradictions | FINDINGS | spec says write `model:` (line 116); instructions.uncompressed.md step 5 omits it; description prose in instructions.uncompressed.md line 96 and instructions.txt line 82 still say frontmatter holds `model` — three-way inconsistency between spec, procedure, and description |
| No unauthorized additions | PASS | nothing in instructions beyond spec |
| Conciseness | PASS | tightly written; no rationale bloat |
| Completeness | PASS | edge cases covered; defaults stated |
| Breadcrumbs | PASS | ../hash-record/filenames.md reference verified as existing |
| Cost analysis | PASS | routing card short; haiku-class; single turn |
| Markdown hygiene | PASS | all files CLEAN |
| No dispatch refs | PASS | instructions.txt contains no dispatch commands |
| No spec breadcrumbs | PASS | no own spec.md reference in runtime files |
| Description not restated (A-FM-2) | PASS | body prose does not duplicate description frontmatter |
| Lint wins (A-FM-4) | PASS | SKILL.md CLEAN with --ignore MD041 |
| No exposition in runtime (A-FM-5) | PASS | no rationale or why-narrative in SKILL.md or instructions.txt |
| No non-helpful tags (A-FM-6) | PASS | no bare type labels |
| No empty sections (A-FM-7) | PASS | all sections have body content |
| Iteration-safety placement (A-FM-8) | PASS | no blurb in instructions.uncompressed.md or instructions.txt |
| Iteration-safety pointer form (A-FM-9a) | N/A | no iteration-safety pointer in instructions files |
| No verbatim Rule A/B (A-FM-9b) | N/A | no Rule A/B restatement |
| Cross-reference anti-pattern (A-XR-1) | PASS | instructions.uncompressed.md uses file path as example string only — not a cross-file pointer |
| Launch-script form (A-FM-10) | PASS | uncompressed.md: frontmatter + H1 + dispatch invocation + return contract + filenames.md ref only |

Issues:

- [Coverage / No contradictions — model: field, MEDIUM] spec.md line 116 says `model:` is set to the `--filename` value in record frontmatter. The instructions procedure (step 5) correctly omits `model:` from the write list — consistent with the recent model: drop contract change. However two stale references remain: (1) instructions.uncompressed.md line 96 "Frontmatter holds `file_path`, `result`, `hash`, `model`" — drop `model` from this list; (2) instructions.txt line 82 "Frontmatter: `file_path`, `result`, `hash`, `model`" — drop `model` from this list. spec.md line 116 itself also needs updating to remove the model: field declaration, but spec edits require operator decision.

Recommendation:
Remove stale `model` mentions from instructions.uncompressed.md line 96 and instructions.txt line 82; flag spec.md line 116 for operator update.

References:
