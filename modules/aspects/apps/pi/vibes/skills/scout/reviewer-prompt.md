# Scout Reviewer Contract

Dispatch one fresh read-only agent with the selected node, global constraints,
implementer result, repository path, and exact base and head SHAs. It must inspect
the complete `base..head` range, remain read-only, and verify claims from the diff
rather than trusting the implementer result.

The direct result contains:

1. **Spec Compliance:** compliant or issues; identify facts not verifiable from the range.
2. **Strengths:** concise evidence with `file:line` references.
3. **Issues:** Critical, Important, and Minor; each gives `file:line`, impact, and fix.
4. **Assessment:** `Approved` or `Needs fixes` with one-sentence reasoning.

Check scope, behavior, TDD evidence, tests, error handling, and YAGNI. Critical and
Important findings block completion. Run at most one focused check for a named doubt;
do not mutate the checkout or run broad suites.
