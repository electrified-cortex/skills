# Fixing

Surfacing the report may be the intent and if so, do so and stop here.
But commonly the caller may `dispatch` the report to agent for fixing.

When auditing a skill with the intent to make corrections,
the compiled artifiacts are the first to be tested (smoke check)
which end up generating the `report.md`,
but the real issue is likely in the uncompressed files.
So after failing an audit without the `--uncompressed` flag,
subsequent audits must fix all issues with `--uncompressed` until there are none,
before doing a final audit on compiled artifiacts.

So a typical `FAIL` or `NEEDS_REVISION` audit+fix will look like:

1. `skill-auditing` was run without the `--uncompressed` flag.
2. Then dispatch an agent to apply correct findings to the uncompressed counterparts (or spec).
3. Run `skill-auditing` `--uncompressed` on the target skill (all steps except fixing).
4. If changes required, go back to step 2 unless at the 3rd iteration of this step.

At this point the core uncompressed files should be sealed, and should not need any revision.
But to complete the audit and prevent further looping, the compiled artifacts must also be resolved.

Choices can be made here:

If "in development" and the skill is being tested, it's best to just:

- Copy the uncompressed files directly to their counterparts.
- Stop and surface the uncompresesd report to the caller.

If in final form and ready for production, then compress the files (ultra).
For example, `uncompressed.md` -> `SKILL.md` and `instructions.uncompressed.md` -> `instructions.txt`.

Then you'll run `skill-auditing` without the `--uncompressed` flag again.
If corrections still required, you should only tweak the compiled artifacts until passing
as trying to fix the uncompressed versions will potentially cause infinite recursion.

If ANY process doesn't complete after 3 iterations, be sure to stop and signal the caller.
