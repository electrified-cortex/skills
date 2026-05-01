# LESS-IS-MORE — 2026-05-01

## Findings

### Finding 1 — Don'ts Section Duplication

**Severity:** MEDIUM

**Signal:** `## Don'ts` section in `uncompressed.md` (18 items, lines 255–274)

**Reasoning:** Every item in the Don'ts list is already covered by an operative instruction elsewhere in `uncompressed.md`:

- "Do not load reviewer prompts for personalities that will not be dispatched" → Step 4: "Load only files for dispatched personalities. Do not load files for non-dispatched personalities."
- "Do not use a fixed roster" → Step 2: "Build the combined registry by crawling `reviewers/`..."
- "Do not fail-stop when a personality is unavailable" → E1, Step 3: "Do not fail-stop or surface an error to the caller."
- "Do not dump raw sub-agent output to the caller" → Step 8: "Do not dump raw sub-agent output or raw arbitrator output to the caller."
- "Do not merge with or replace the `code-review` skill" → C5
- "Do not dispatch personalities sequentially" → Step 5: "do not issue them sequentially"
- "Do not include bare model names" → C6
- "Do not allow `model_overrides` to specify a backend change" → Inputs table + P2
- "Do not allow custom menu entries to override built-in entries" → Custom Personality Menu section
- "Do not apply `personality_filter` as an exclusion list" → Inputs table + P1
- "Do not have the host parse raw member output" → Step 8
- "Do not add the arbitrator to the registry" → Step 6 (line 177)
- "Do not implement `local-llm`" → Key Terms (Backend definition notes "local-llm (reserved)")
- "Do not embed a normative personality registry as static table" → Registry section
- "Do not fail the swarm if cross-vendor diversity fails" → B8
- "Do not treat `reviewers/*.md` without valid frontmatter as registered" → Metadata-validation gate section

The two remaining items without exact counterparts elsewhere:
- "Do not perform CLI-as-dispatch until task 10-0845 lands" → C7 covers this
- "Do not expand the registry without a spec amendment and audit pass" → not restated elsewhere — this is the one load-bearing Don't

The Don'ts section in `uncompressed.md` is redundant against Constraints + Behavior + Error Handling + Precedence + Step Sequence already present in the same file. In SKILL.md the Don'ts serve a different purpose (quick scanning summary of a compressed doc), but in the uncompressed reference, the full operational sections make it overhead. A model executing from `uncompressed.md` reads each constraint at least twice, adding load without precision.

**Recommendation:** Remove the `## Don'ts` section from `uncompressed.md`. Retain the one non-covered constraint ("Do not expand the registry without a spec amendment and audit pass") by adding it to the existing C5 block in Constraints or as a new C8. The SKILL.md Don'ts list is unaffected — it remains the right format for the compressed surface.

**Action taken:** Applied. Removed `## Don'ts` section from `uncompressed.md`. Merged the unique constraint ("Do not expand the registry without a spec amendment and audit pass") into Constraints as C8.

---

### Finding 2 — B8 Over-specification

**Severity:** LOW

**Signal:** B8 in `uncompressed.md` expands to conditional sub-rules per host model class

**Reasoning:** B8 reads: "If host is opus-class, prefer at least one personality on a non-Anthropic model or non-opus model. If host is sonnet-class, prefer one personality on opus-class or a non-Anthropic model." These sub-rules are host-class-specific conditionals that a model can derive from the operative directive ("prefer at least one personality on a different model family or vendor than the host"). The derived sub-rules add 35 words of overhead without changing behavior — the directive plus the `vendor` frontmatter field already provides sufficient signal. SKILL.md correctly omits these sub-rules.

**Recommendation:** Trim B8 in `uncompressed.md` to match the operative level of the SKILL.md version: state the diversity goal, the best-effort qualifier, the monoculture note requirement, and the Devil's Advocate signal. Remove the "if host is opus-class…/if host is sonnet-class…" conditionals.

**Action taken:** Applied. Trimmed B8 to remove the per-class conditional sub-rules.
