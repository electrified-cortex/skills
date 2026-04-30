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

Produce a finding only when the benefit is clear and the skill lacks a
hash record. If the skill already uses a hash record, verify it is being
applied to the right scope; if misapplied, produce a finding.