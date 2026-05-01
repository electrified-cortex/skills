---
file_path: skill-auditing/SKILL.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

## Advisory

- SA010 [WARN] line 12: `stdout` appears in plain prose without backticks
  Note: `stdout` is a shell term; it occurs unquoted on lines 12, 19, 20, and 52.

- SA013 [WARN] line 6: heading `## Input` introduces only a single item
  Note: The section contains one parameter definition line; an inline label such as `**Input:**` would be lighter than a full heading.

- SA018 [WARN] line 31: third-person passive phrasing on a directive sentence
  Note: "Audit proceeds only when…" describes behavior from the system's perspective; a direct imperative ("Proceed only when…") would be more consistent with the surrounding instruction style.

- SA029 [WARN] line 50: positional reference to an earlier section
  Note: "Same invocation as first Inline result check" locates content by position rather than by an explicit name or anchor.

- SA032 [WARN] (document-level): `markdown-hygiene` and `mhygiene` are distinct names for the same skill
  Note: The skill is introduced as `markdown-hygiene` on line 26 and then referred to as `mhygiene` on lines 27, 28, and 31 without a declared abbreviation.
