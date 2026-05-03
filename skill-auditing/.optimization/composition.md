# COMPOSITION — skill-auditing

Date: 2026-05-01
Model: Claude Sonnet 4.6
Status: pending

## Findings

### Finding 1 — HIGH

**Signal:** SKILL.md omits the `--uncompressed` flag entirely. `<input-args>` is hardcoded as `skill_dir=<skill_dir> --report-path <report_path>` — no `[--uncompressed]`. uncompressed.md exposes it.

**Reasoning:** SKILL.md is the authoritative source for callers. Any agent composing skill-auditing from that file cannot discover or invoke uncompressed audit mode. The flag is silently unreachable from the compressed runtime.

**Recommendation:** Restore `[--uncompressed]` to SKILL.md's `<input-args>` line and add it to the `Input:` declaration above the Inline result check.

---

### Finding 2 — MEDIUM

**Signal:** `--fix` mode appears only inside `instructions.uncompressed.md` ("Fix Mode (--fix) — Only after NEEDS_REVISION"). It is absent from the input declarations in both SKILL.md and uncompressed.md.

**Reasoning:** A caller that receives `NEEDS_REVISION` and wants to trigger repair cannot do so — the input contract gives no signal that `--fix` is a valid continuation. The mode exists, is gated on a specific verdict, and is a natural chaining step, but there's no breadcrumb leading a caller to it.

**Recommendation:** Add `--fix` to the input declaration in both SKILL.md and uncompressed.md, with the precondition (`only after NEEDS_REVISION`) stated inline so the chain is self-documenting.

---

### Finding 3 — MEDIUM

**Signal:** Post-execute inline result check in SKILL.md says only "Branch on `stdout`." — no branch definitions. Pre-execute check defines exact branch logic. The `MISS` case at post-execute is especially undefined — executor already ran, report path was already bound.

**Reasoning:** A caller following SKILL.md doesn't know what to do with each post-execute token. Even the success path (PASS, NEEDS_REVISION) has no prescribed caller behavior.

**Recommendation:** Add post-execute branch definitions to SKILL.md's post-execute section: `PASS/NEEDS_REVISION/FAIL -> emit stdout verbatim, stop. MISS/ERROR -> surface as execution failure.`

---

**Action taken:** No change yet. Findings 1 and 3 are targeted SKILL.md edits. Finding 2 requires both SKILL.md and uncompressed.md. All are small and concrete.
