---
file_path: skill-auditing/instructions.uncompressed.md
operation_kind: markdown-hygiene-analysis
result: pass
---

# Result

PASS

## Markdown Hygiene Analysis

File analyzed: `skill-auditing/instructions.uncompressed.md`

### Findings

#### SA014 [SUGGEST] — Unemphasized directives in instruction document
Multiple directive phrases use strong enforcement language (`must`, `must not`, `shall`, `should`) that are not consistently emphasized via bold, caps, or other formatting. Examples:
- Line 5: "do NOT author scripts" (caps-emphasized, good)
- Line 8: "Do not invent" (unemphasized)
- Line 27: "must not invent" (unemphasized)
- Line 100: "MUST NOT contain a real H1" (caps-emphasized, good)
- Line 103: "MUST NOT apply to them" (caps-emphasized, good)
- Lines throughout use bare "must", "must not", "shall" without emphasis

Note: This document is a reference manual, not a directive instruction. Inconsistent emphasis on procedural language suggests the directives could be more visually scannable.

#### SA028 [WARN] — Repeated phrase
The phrase "SKILL.md" appears verbatim 47+ times in the document. While this is a canonical filename reference for this skill-auditing procedure, the high repetition may indicate opportunity to use pronouns or reduce redundancy in some contexts.

Note: This is acceptable repetition for a reference manual covering repeated concepts. Not actionable given the domain.

#### SA031 [WARN] — Heading case inconsistency  
Minor inconsistency in sibling heading capitalization:
- Dispatch Skill Checks (DS-1..DS-8): Title Case
- Return shape declared: Sentence case with title-case term
- Classification: Single word (Title Case)
- No duplication: Lowercase as a directive phrase

Note: Headings are functionally clear despite minor capitalization variations. Recommend standardizing on Title Case for consistency.

### Summary

- Total findings: 3 (all WARN or SUGGEST level)
- No FAIL findings
- No HIGH findings

Document is well-structured with clear sections and comprehensive content. Directive language is generally well-marked with caps emphasis where critical. The repetition of "SKILL.md" is appropriate for a reference manual on skill structure. Minor heading capitalization inconsistency does not impact clarity.
