---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

**Core principle:** ALWAYS find the root cause before attempting fixes. Symptom patches waste time and create new bugs.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Applies to every technical issue — test failures, production bugs, build breaks, performance problems, integration issues. Especially under time pressure: systematic debugging is *faster* than guess-and-check thrashing. "Simple" issues have root causes too.

## The Four Phases

Complete each phase before the next.

### Phase 1: Root Cause Investigation

- **Read the error completely** — message, stack trace, line numbers, error codes. It often contains the exact solution.
- **Reproduce reliably.** Exact steps, every time. Not reproducible → gather more data, don't guess.
- **Check recent changes** — git diff, recent commits, new dependencies, config, environment differences.
- **Multi-component systems** (CI → build → signing; API → service → database): before proposing anything, instrument each boundary — log what enters and exits each layer, verify env/config propagation — and run once to see WHERE it breaks. Then investigate that component.
- **Error deep in a call stack:** trace the bad value backward to where it originates and fix at the source, not the symptom. Full technique: `root-cause-tracing.md` in this directory.

### Phase 2: Pattern Analysis

Find similar *working* code in the same codebase. If implementing a documented pattern, read the reference completely — skimming guarantees bugs. List every difference between working and broken, however small; don't assume "that can't matter." Note the dependencies, config, and assumptions the broken path relies on.

### Phase 3: Hypothesis and Testing

State one specific hypothesis: "I think X is the root cause because Y." Test it with the smallest possible change, one variable at a time. Confirmed → Phase 4. Refuted → form a new hypothesis; do NOT stack more changes on top. If you don't understand something, say so and research it — don't pretend.

### Phase 4: Implementation

1. Create a failing test reproducing the bug — required before fixing (**REQUIRED SUB-SKILL:** test-driven-development).
2. Fix the root cause with ONE change. No bundled refactoring, no "while I'm here."
3. Verify: the new test passes, no other tests broke, the original symptom is gone (**REQUIRED SUB-SKILL:** verification-before-completion).

**If the fix doesn't work:** STOP and return to Phase 1 with the new information — don't attempt another fix on top. **After 3 failed fixes, stop fixing entirely.** The telltale pattern — each fix reveals new coupling somewhere else, or requires "massive refactoring" — means the architecture is wrong, not the hypothesis. Question the fundamentals with your human partner before any fix #4.

## Red Flags — STOP, return to Phase 1

- "Quick fix for now, investigate later" / "just try X and see if it works"
- Proposing fixes before tracing data flow ("it's probably X")
- Changing multiple things at once, or skipping the failing test
- "One more fix attempt" when 2+ have already failed — that's an architecture question now
- Your partner saying "Stop guessing", "Is that not happening?", or "Will it show us…?" — you assumed instead of verifying

If investigation genuinely shows an environmental or timing cause — rare; 95% of "no root cause" is incomplete investigation — document what you checked, implement appropriate handling (retry, timeout, clear error), and add logging for next time.

## Supporting Techniques

In this directory:

- **`root-cause-tracing.md`** — trace bugs backward through the call stack to the original trigger
- **`defense-in-depth.md`** — add validation at multiple layers *after* finding the root cause
- **`condition-based-waiting.md`** — replace arbitrary timeouts with condition polling

Related: **test-driven-development** (the failing test in Phase 4), **verification-before-completion** (verify before claiming fixed).
