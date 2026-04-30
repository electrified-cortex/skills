# Caching (hash-record)

Assess whether the skill would benefit from a hash record to avoid
redundant processing on unchanged inputs.

**Strong signal for hash record:**

- The skill operates on one or more files and produces a deterministic
  output or verdict given the same files.
- The skill is expensive — it invokes LLMs, runs build tools, or processes
  large file sets.
- The skill is called repeatedly (audit loops, hygiene pipelines, CI).
- The skill already has logic to check "was this already done?" — if so,
  that logic should be formalized as a hash record.

**Weak or no signal:**

- The skill is short and cheap enough that caching provides negligible
  benefit.
- The skill's output depends on external state (network, time, system
  config) that changes independently of the input files.
- The skill is invoked at most once per session.

**Cache key construction:** The hash should cover exactly the inputs that
determine the output — typically input file contents. If parameters,
flags, or environment state affect the result, they must be included in
the hash. Omitting them causes stale cache hits (different parameters,
same file = different result, but the cache says it's the same).

**Foot gun — LLM-dependent skills are not deterministic:** A hash record
caches one response variant. For skills whose value is consistency (the
optimizer always produces the same findings on the same unchanged files),
this is fine and desirable. For skills where output variance is meaningful,
hash records suppress that variance — you get one cached answer but never
know if a re-run would produce something different. Reserve hash records
for skills where determinism is a design goal, not a side effect.

**Idempotency relationship:** Idempotency and caching are complementary
but distinct. An idempotent skill can be safely run twice on the same input
and produces the same result without duplicate side effects (no double-
written files, no double-committed changes, no double-emitted findings).
A hash record is one way to achieve idempotency (the second run hits the
cache and stops), but the skill should be idempotent by design regardless
of whether a cache exists. Assess: if the cache were absent, would running
the skill twice cause problems? If yes, the skill is not idempotent and
that is a separate finding from the caching assessment.

Produce a finding only when the benefit is clear and the skill lacks a
hash record. If the skill already uses a hash record, verify it is being
applied to the right scope; if misapplied, produce a finding.
