---
file_paths:
  - swarm/SKILL.md
operation_kind: skill-auditing
model: sonnet-class
result: findings
---

# Result

NEEDS_REVISION

## Skill Audit: swarm

**Verdict:** NEEDS_REVISION
**Type:** inline
**Path:** swarm/
**Failed phase:** none

### Phase 1 — Spec Gate

| Check | Result | Notes |
| --- | --- | --- |
| Spec exists | PASS | `swarm/spec.md` present |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present |
| Normative language | PASS | Requirements use must/shall/required throughout |
| Internal consistency | PASS | No contradictions or duplicate rules found |
| Completeness | PASS | Terms defined; behavior explicitly stated |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
| --- | --- | --- |
| Classification | PASS | Inline — requires runtime judgment, registry crawl, conditional logic; no context-free execution |
| Inline/dispatch consistency | PASS | No `instructions.txt` found; SKILL.md contains full step sequence; consistent |
| Structure | PASS | Frontmatter present; full procedure self-contained; no stop gates in routing card |
| Input/output double-spec (A-IS-1) | PASS | No output-path double-specification detected |
| Frontmatter | PASS | `name` and `description` present and accurate |
| Name matches folder (A-FM-1) | PASS | `name: swarm` matches folder name `swarm` |
| H1 per artifact (A-FM-3) | PASS | SKILL.md has no H1; `uncompressed.md` has H1 on line 1 |
| No duplication | PASS | No existing skill duplicates this infrastructure capability |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
| --- | --- | --- |
| Coverage | PASS | All spec steps S1–S8, behaviors B1–B8, precedence P1–P5, constraints C1–C7, and Don'ts represented |
| No contradictions | PASS | SKILL.md faithful to spec in all normative points checked |
| No unauthorized additions | PASS | No requirements introduced beyond spec scope |
| Conciseness | PASS | Dense bullet/decision format; no essay prose found |
| Completeness | PASS | Edge cases addressed; defaults stated; no implicit assumptions found |
| Breadcrumbs | PASS | `dispatch`, `compression`, `skill-index` all exist at sibling level |
| Cost analysis | N/A | Inline skill |
| No dispatch refs | N/A | No `instructions.txt` |
| No spec breadcrumbs | PASS | No reference to own `spec.md` in SKILL.md |
| Description not restated (A-FM-2) | PASS | Opening line of `uncompressed.md` ("Operational reference for the swarm multi-personality review skill") uses different phrasing from description frontmatter; not verbatim |
| No exposition in runtime (A-FM-5) | PASS | No rationale, root-cause narrative, or historical notes found in SKILL.md |
| No non-helpful tags (A-FM-6) | FINDINGS | `uncompressed.md` line 3: "Operational reference for the swarm multi-personality review skill." — descriptor line with no operational value (LOW) |
| No empty sections (A-FM-7) | PASS | All headings in all artifacts have body content |
| Iteration-safety placement (A-FM-8) | N/A | No iteration-safety content present |
| Iteration-safety pointer form (A-FM-9a) | N/A | No iteration-safety reference present |
| No verbatim Rule A/B (A-FM-9b) | N/A | No iteration-safety content present |
| Cross-reference anti-pattern (A-XR-1) | PASS | No paths to another skill's `uncompressed.md` or `spec.md` found in SKILL.md or `uncompressed.md` |
| Launch-script form (A-FM-10) | N/A | Inline skill |
| Return shape declared (DS-1) | N/A | Inline skill |
| Host card minimalism (DS-2) | N/A | Inline skill |
| Description trigger phrases (DS-3) | N/A | Inline skill |
| No substrate duplication (DS-5) | N/A | Inline skill |
| No overbuilt sub-skill dispatch (DS-6) | N/A | Inline skill |

### Per-file Basic Checks

| File | Check | Result | Notes |
| --- | --- | --- | --- |
| `SKILL.md` | Not empty | PASS | |
| `SKILL.md` | Frontmatter required | PASS | YAML frontmatter at line 1 with `name` and `description` |
| `SKILL.md` | No abs-path leaks | PASS | |
| `uncompressed.md` | Not empty | PASS | |
| `uncompressed.md` | Frontmatter required | N/A | Not SKILL.md or agent.md |
| `uncompressed.md` | No abs-path leaks | PASS | |
| `spec.md` | Not empty | PASS | |
| `spec.md` | Frontmatter required | N/A | |
| `spec.md` | No abs-path leaks | PASS | |
| `reviewers/devils-advocate.md` | Not empty | PASS | |
| `reviewers/devils-advocate.md` | No abs-path leaks | PASS | |
| `reviewers/index.md` | Not empty | PASS | |
| `reviewers/index.md` | No abs-path leaks | PASS | |
| `reviewers/security-auditor.md` | Not empty | PASS | |
| `reviewers/security-auditor.md` | No abs-path leaks | PASS | |
| `specs/arbitrator.md` | Not empty | PASS | |
| `specs/arbitrator.md` | No abs-path leaks | PASS | |
| `specs/dispatch-integration.md` | Not empty | PASS | |
| `specs/dispatch-integration.md` | No abs-path leaks | PASS | |
| `specs/glossary.md` | Not empty | PASS | |
| `specs/glossary.md` | No abs-path leaks | PASS | |
| `specs/personality-file.md` | Not empty | PASS | |
| `specs/personality-file.md` | No abs-path leaks | PASS | |
| `specs/registry-format.md` | Not empty | PASS | |
| `specs/registry-format.md` | No abs-path leaks | PASS | |
| `.gitignore` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced; not a well-known role file — LOW orphan |
| `specs/arbitrator.md` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced in SKILL.md or `uncompressed.md`; referenced only in `spec.md` — LOW orphan |
| `specs/dispatch-integration.md` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced in SKILL.md or `uncompressed.md`; referenced only in `spec.md` — LOW orphan |
| `specs/glossary.md` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced in SKILL.md or `uncompressed.md`; referenced only in `spec.md` — LOW orphan |
| `specs/personality-file.md` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced in SKILL.md or `uncompressed.md`; referenced only in `spec.md` — LOW orphan |
| `specs/registry-format.md` (A-FS-1) | Referenced in SKILL.md/uncompressed.md | FINDINGS | Not referenced in SKILL.md or `uncompressed.md`; referenced only in `spec.md` — LOW orphan |

### Issues

- [Phase 3 / A-FM-6 / LOW] `uncompressed.md` line 3 contains a descriptor line with no operational value: "Operational reference for the swarm multi-personality review skill." Remove it. The H1 already identifies the document; the subtitle restates without instructing.
- [Per-file / A-FS-1 / LOW] `specs/` sub-specifications (`specs/arbitrator.md`, `specs/dispatch-integration.md`, `specs/glossary.md`, `specs/personality-file.md`, `specs/registry-format.md`) are not referenced by filename in SKILL.md or `uncompressed.md`. They are only referenced from `spec.md`. Consider adding a brief reference pointer in `uncompressed.md` (e.g., "See `specs/arbitrator.md` for arbitrator detail") or accept them as companion spec artifacts if this is intentional.
- [Per-file / A-FS-1 / LOW] `.gitignore` is not a well-known role file and is not referenced in SKILL.md or `uncompressed.md`. If it is intentional (e.g., ignores a `.reference/` directory), no action needed but flagged per check.

### Recommendation

Remove the non-operational subtitle from `uncompressed.md` and optionally add `specs/` cross-reference pointers; all substantive spec compliance checks pass.
