---
operation_kind: skill-auditing/v2
result: findings
file_paths:
  - capability-cache/SKILL.md
  - capability-cache/spec.md
  - capability-cache/uncompressed.md
---

# Result

**NEEDS_REVISION** — 3 HIGH findings, 2 LOW findings.

---

## Per-file Findings

| File | Check | Severity | Note |
| --- | --- | --- | --- |
| `capability-cache/SKILL.md` | A-FM-5 | HIGH | Footguns F1 and F2 contain root-cause narrative and background prose ("Once `unavailable` cached, persists…", "Corrupted cache (partial write, encoding error, truncation) → …"). Rationale belongs exclusively in `spec.md` (already present there); remove Footguns section from SKILL.md. |
| `capability-cache/SKILL.md` | A-FM-2 | LOW | Opening line ("Consumer skills call before any Copilot CLI invocation.") restates description. Non-verbatim. Remove or replace with uniquely operational content. |
| `capability-cache/uncompressed.md` | A-FM-5 | HIGH | Footguns F1 and F2 contain expanded background prose and root-cause narrative. Rationale belongs exclusively in `spec.md`; remove Footguns section from `uncompressed.md`. |
| `capability-cache/uncompressed.md` | A-FM-2 | LOW | Opening line ("Consumer skills call into this before invoking any Copilot CLI command.") restates description. Non-verbatim. Remove or replace with uniquely operational content. |

---

## Step 2 — Parity Findings

| Compiled | Uncompressed | Severity | Note |
| --- | --- | --- | --- |
| `capability-cache/SKILL.md` | `capability-cache/uncompressed.md` | HIGH | Parity failure: SKILL.md Dependencies section omits two items present in `uncompressed.md` — "Read/write access to `cache_root`." and "`.capability-cache/` must be gitignored in the consuming repo." Both correspond to normative spec requirements (R7, R8). Fix: edit `capability-cache/uncompressed.md` if needed, then recompress to `capability-cache/SKILL.md`. |

---

## Step 1 — Compiled Artifacts

| Check | Result | Notes |
| --- | --- | --- |
| Skill type | PASS | Inline skill — no `instructions.txt` or other dispatch instruction file present. Consistent with spec Content Modes table. |
| A-FM-1 name match | PASS | `name: capability-cache` matches folder name in both SKILL.md and `uncompressed.md`. |
| A-FM-4 valid frontmatter fields | PASS | SKILL.md frontmatter contains only `name` and `description`. |
| A-FM-11 trigger phrases | PASS | Description contains "Triggers -" with 5 trigger phrases. |
| A-FM-12 uncompressed mirror | PASS | `uncompressed.md` has YAML frontmatter with `name` and `description` matching SKILL.md exactly. |
| A-FM-3 H1 placement | PASS | SKILL.md has no real H1; `uncompressed.md` has `# Capability Cache` as first content line after frontmatter. |
| A-FS-1 orphan files | PASS | All three files are well-known role files (`SKILL.md`, `spec.md`, `uncompressed.md`). No orphans. |
| A-FS-2 missing referenced files | PASS | No explicit sibling file-path pointers found in any artifact. |
| A-XR-1 cross-references | PASS | `uncompressed.md` Related line uses canonical names (`copilot-cli`, `hash-record`) with no path-only references. |
| A-FM-6 non-helpful tags | PASS | No non-operational descriptor lines found. |
| A-FM-7 empty leaves | PASS | No empty section leaves in any artifact. |
| A-FM-8 iteration-safety placement | PASS | No Iteration Safety blurb present in any artifact. |
| A-FM-9a/9b iteration-safety pointer | N/A | No iteration-safety references. |
| A-FM-10 launch-script form | N/A | Inline skill. |
| DS-1..DS-6 dispatch checks | N/A | Inline skill. |

---

## Step 3 — Spec Alignment

| Check | Result | Notes |
| --- | --- | --- |
| Spec present | PASS | `capability-cache/spec.md` co-located. |
| Required sections | PASS | Purpose, Scope, Definitions, Requirements, Constraints all present. |
| Normative language | PASS | Requirements R1–R9 use "must" throughout. |
| Internal consistency | PASS | No contradictions between sections. |
| Coverage | PASS | All 9 requirements (R1–R9) represented in SKILL.md. |
| No contradictions | PASS | SKILL.md does not contradict spec. |
| No unauthorized additions | PASS | Footguns in SKILL.md match spec Footguns content; no additional normative requirements introduced. |
| Conciseness (A-FM-5 in spec) | N/A | spec.md is not a runtime artifact. |
| Breadcrumbs | PASS | `uncompressed.md` Related line references valid canonical skill names. |
