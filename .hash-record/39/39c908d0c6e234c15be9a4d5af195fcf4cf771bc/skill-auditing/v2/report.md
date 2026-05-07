---
file_paths:
  - hash-record/hash-record-check/SKILL.md
operation_kind: skill-auditing/v2
model: haiku-class
result: pass
---

# Result

PASS

Skill `hash-record-check` inline routing card. No dispatch files present. SKILL.md provides direct invocation instructions for both Bash and PowerShell variants. Frontmatter (`name`, `description`) correct. No orphaned files. No reference divergence. Tool trio (check.sh, check.ps1, check.spec.md) defined in SKILL.md and verified externally by tool-auditing pass verdict.

**File-level checks:**
- SKILL.md: non-empty, frontmatter present (name: hash-record-check, description: present), no absolute-path leaks.
- Classification: inline (no dispatch wiring), correctly reflects tool-only delivery model.
- H1 rule: SKILL.md contains no real H1 (check.ps1 and check.sh usage are example content, not real H1s). Compliant.
- No duplication of existing capability.
- No orphaned files; tool trio is normative reference.

**Compiled artifacts:**
- Routing card structure adequate: name, description, usage syntax, argument table, output contract, script locations, CLI reference.
- Mentions companion `check.spec.md` and multi-file variant `misses.ps1`; both consistent with skill intent.

**Verdict:** PASS
