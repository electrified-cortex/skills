# Test File — Markdown Hygiene Fix Path Validation

This file is used to validate the detect -> fix -> verify flow with special characters.
Special chars that must survive: em-dash — , right-arrow ->, left-arrow <-, ellipsis ..., curly quotes "like this".

## Section One
Content here.
### Sub-section (no blank before heading)
This should trigger MD022.

- item one
- item two
- item three
Trailing content after list with no blank line — should trigger MD032.
