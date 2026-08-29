---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, or before committing or creating a PR
---

# Verification Before Completion

**Core principle: evidence before claims, always.** Claiming work is complete without fresh verification is dishonesty, not efficiency.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command *in this message*, you cannot claim it passes. Before any success claim — or any wording implying one ("Done!", "Great!", a paraphrase, a synonym): identify the command that proves the claim, run it fresh and complete, read the full output including the exit code, and only then state the result, with the evidence. If the output contradicts the claim, report the actual status instead.

**Violating the letter of this rule is violating the spirit of this rule.** No exceptions — not for confidence, not for time pressure, not for exhaustion.

## What Counts as Evidence

| Claim | Requires | Not sufficient |
|-------|----------|----------------|
| Tests pass | Fresh full test run: 0 failures | Previous run, "should pass" |
| Linter/build clean | Fresh run: 0 errors / exit 0 | Partial check, linter standing in for compiler |
| Bug fixed | Original symptom re-tested: gone | Code changed, assumed fixed |
| Regression test works | Red-green verified: fails with fix reverted, passes with it restored | Test passing once |
| Agent/subagent completed | You inspected the VCS diff yourself | Agent's own "success" report |
| Requirements met | Line-by-line checklist against the plan | Tests passing |

## Red Flags — STOP and run the verification

- "Should work" / "probably" / "seems to" / "I'm confident"
- Expressing satisfaction before the verification has run
- About to commit, push, or PR without a fresh run
- "A partial check is enough" — partial proves nothing
- "Just this once" / tired and wanting the work over — exhaustion is not evidence
