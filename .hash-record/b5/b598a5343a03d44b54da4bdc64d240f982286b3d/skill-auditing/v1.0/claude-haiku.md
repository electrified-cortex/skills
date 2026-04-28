---
hash: b598a5343a03d44b54da4bdc64d240f982286b3d
file_paths:
  - gh-cli/gh-cli-projects/spec.md
  - gh-cli/gh-cli-projects/uncompressed.md
operation_kind: skill-auditing
model: claude-haiku
result: findings
---

# Result

## Skill Audit: gh-cli-projects

**Verdict:** NEEDS_REVISION  
**Type:** inline  
**Path:** gh-cli\gh-cli-projects

### Phase 1 — Spec Gate

| Check | Result | Notes |
|---|---|---|
| Spec exists | PASS | |
| Required sections | PASS | |
| Normative language | PASS | |

### Phase 2 — Skill Smoke Check

| Check | Result | Notes |
|---|---|---|
| Frontmatter | PASS | |
| Name matches folder | FAIL | name field must equal folder name |
| H1 per artifact | PASS | SKILL.md must NOT have H1 |
| Has content | PASS | |

### Phase 3 — Spec Compliance

| Check | Result | Notes |
|---|---|---|
| Coverage | FAIL | Missing: project IDs, resolve.*name.*ID |
| Contradictions | PASS |  |
| Markdown hygiene | PASS | basic checks only |

## Recommendation

Review flagged items. Resubmit after revision.

## References

*(None - all checks passed or findings documented above)*

