---
operation_kind: skill-auditing/v2
result: findings
file_paths:
  - electrified-cortex/skills/capability-cache/SKILL.md
  - electrified-cortex/skills/capability-cache/spec.md
  - electrified-cortex/skills/capability-cache/uncompressed.md
---

# Result

**NEEDS_REVISION** — The capability-cache skill contains normative contradictions and structural violations that must be resolved before approval.

## Findings

### HIGH Severity

#### Finding H-PF-001: Spec Violation — Prohibited Claim in SKILL.md

**Location:** SKILL.md, line 7  
**Check:** A-FM-1 / Spec Coverage (Don'ts section of spec.md)  
**Issue:** The SKILL.md states "This skill never invokes CLI commands itself." This directly violates the spec's Don'ts section, which explicitly forbids this claim: "Must not claim 'this skill never invokes CLI commands' — the WRITE path explicitly invokes `gh copilot models`."

Furthermore, this statement contradicts the actual behavior documented in uncompressed.md, which correctly states "The WRITE path invokes `gh copilot models` when no valid cache exists."

**Impact:** HIGH — Misleads callers about the skill's behavior and violates spec.  
**Remediation:** Remove the false claim from SKILL.md. The correct characterization appears in uncompressed.md: the WRITE path does invoke the CLI. Parity check: edit uncompressed.md or spec.md as authoritative source, then recompress SKILL.md.

---

#### Finding H-FM-001: Missing H1 Heading in uncompressed.md

**Location:** uncompressed.md, entire file  
**Check:** A-FM-3  
**Issue:** Per spec (A-FM-3), uncompressed.md MUST contain a real H1 (line starting at column 0 with `^# ` pattern). The file contains only H2 headings (##) and deeper. No real H1 detected.

**Impact:** HIGH — Violates artifact structure requirement.  
**Remediation:** Add a real H1 heading at the top of uncompressed.md before any H2 sections. Example: `# Capability Cache` or similar.

---

### LOW Severity

#### Finding L-FM-001: Non-Actionable Descriptor Line

**Location:** uncompressed.md, "Content Modes" section  
**Check:** A-FM-6  
**Issue:** The line "This is an **inline skill** with two operational branches. Callers execute the procedure directly — there is no sub-agent dispatch." is a descriptor of the skill's nature rather than actionable instruction. While providing helpful context, it reads as a type label annotation rather than procedural guidance.

**Impact:** LOW — Advisory; does not block skill function.  
**Remediation (optional):** Integrate this context into the introductory paragraph or Procedure section if genuinely useful to callers. Alternatively, remove as non-essential.

---

## Audit Details

### Step 1 — Enumeration & Classification

**Files enumerated:** SKILL.md, spec.md, uncompressed.md (no dot-prefixed dirs, no `optimize-log.md`)  
**Tool files:** None present  
**Dispatch instruction files:** None present  
**Classification:** Inline skill (no dispatch instruction file; full procedure in SKILL.md)

**Per-file basic checks:**
- All `.md` files non-empty ✓
- SKILL.md frontmatter present ✓
- uncompressed.md frontmatter present ✓
- No absolute-path leaks detected ✓
- spec.md structure: Purpose, Scope, Definitions, Requirements, Constraints, etc. all present ✓

### Step 2 — Parity Check (SKILL.md vs uncompressed.md)

| Artifact | Source | Content | Status |
| --- | --- | --- | --- |
| SKILL.md intro | Compiled | "This skill never invokes CLI commands itself." | **Contradicts uncompressed.md** |
| uncompressed.md intro | Uncompressed | "The WRITE path invokes `gh copilot models` when no valid cache exists." | **Authoritative** |

**Parity failure identified:** H-PF-001 (see Findings section).

### Step 3 — Spec Alignment

**Spec located:** spec.md co-located with skill_dir ✓  
**Required sections present:** Purpose, Scope, Definitions, Requirements, Constraints ✓  
**Coverage check:**
- Spec R1 (READ path HIT) → SKILL.md Procedure/READ ✓
- Spec R2 (WRITE path MISS) → SKILL.md Procedure/WRITE ✓
- Spec R3 (unavailable as HIT) → SKILL.md Rules ✓
- Spec R4 (write cache after probe) → SKILL.md Procedure/WRITE ✓
- Spec R5 (graceful failure) → SKILL.md Rules ✓
- Spec R6 (corrupt cache as MISS) → SKILL.md Rules ✓
- Spec R7 (create directory) → SKILL.md Procedure/WRITE ✓
- Spec R8 (don't commit) → SKILL.md Rules/Dependencies ✓
- Spec R9 (structured output) → SKILL.md Outputs ✓

**Spec Don'ts check:**
- "Must not claim 'this skill never invokes CLI commands'" → **VIOLATED** in SKILL.md (H-PF-001)

---

## Frontmatter & Artifact Checks

| Check | Result | Notes |
| --- | --- | --- |
| (A-FM-1) Name matches folder | PASS | Both SKILL.md and uncompressed.md: name = `capability-cache` |
| (A-FM-4) Valid SKILL.md frontmatter | PASS | Only `name` and `description` present |
| (A-FM-11) Trigger phrases in description | PASS | "Triggers -" present in description |
| (A-FM-12) uncompressed.md mirror | PASS | Frontmatter name and description match SKILL.md |
| (A-FM-3) H1 in uncompressed.md | **FAIL** | No real H1 (^# ) detected; only H2+ |
| (A-FM-5) No exposition in runtime | PASS | Footguns are operational gotchas, not rationale |
| (A-FM-7) No empty leaves | PASS | All sections contain content |
| (A-FM-2) No description restatement | PASS | Intro differs from frontmatter description |
| (A-FS-1) No orphan files | PASS | All three files are well-known roles |
| (A-FS-2) No missing referenced files | PASS | No external file references |

---

## Recommended Actions

1. **Fix H-PF-001 (HIGH):** Remove or correct the claim "This skill never invokes CLI commands itself" in SKILL.md. Align with spec and uncompressed.md.
2. **Fix H-FM-001 (HIGH):** Add real H1 heading to uncompressed.md.
3. **Consider L-FM-001 (LOW):** Evaluate whether the descriptor line in uncompressed.md is necessary or should be integrated elsewhere.

---

**Auditor:** skill-auditing/v2  
**Scope:** Compiled artifacts (SKILL.md, spec.md, uncompressed.md); inline skill; no dispatch files  
**Verdict basis:** 2 HIGH findings → NEEDS_REVISION
