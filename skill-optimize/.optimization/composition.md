# COMPOSITION — 2026-04-30

**Severity:** LOW (deferred)

**Finding:** Common direct-invocation path (topic provided) loads the full
`uncompressed.md` including the Haiku qualifier prompt, fallback heuristics
table (~40 lines), and topic index (~30 lines) — none of which are used on
that path. The unused-content-per-path issue is real but the appropriate fix
is the SKILL.md compressed surface (already identified in COMPRESSIBILITY),
not a structural split. Splitting assessor vs. direct paths would create two
nearly-identical entry points sharing most of the same files.

**Action taken:** No change. Deferred — SKILL.md creation (from
COMPRESSIBILITY finding) collapses this automatically. Revisit structural
split if topic library grows beyond ~40 topics.
