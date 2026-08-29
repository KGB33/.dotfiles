---
name: behavior-table-diffs
description: Use when reporting a bugfix, a validation or parsing change, or new edge-case handling, to show what each class of input did before versus after — especially when the fix might have silently changed a neighboring case
---

# Behavior Table Diffs

Ignore code shape entirely. Enumerate the classes of input, and show what each one *does* before and after. This catches the two things a passing test suite does not: a fix that silently changed a neighboring case, and a fix that doesn't actually cover the class the user cares about.

## The Output

A three-column table — input class, before, after — with a marker on every row that changed or is still wrong:

```
input class          before          after
──────────────────────────────────────────────────────────────
empty list           IndexError      returns None       ← FIXED
single element       returns x       returns x
n > 1, distinct      returns max     returns max
all equal            returns x       returns x
contains NaN         returns NaN     raises ValueError  ← CHANGED, unintended?
contains None        TypeError       TypeError          ← still unhandled
```

Then one line naming what the changed rows imply:

```
tests needed: empty list (added), NaN (not added — is the raise intended?)
```

## Rules

- **Rows are equivalence classes, not test cases.** "empty", "one", "many", "all equal" — not `test_foo_1`. Always include: the reported bug's class, the classes on either side of the new boundary, and the degenerate cases (empty, null, single, duplicate).
- **Never fill a cell from assumption.** Run it, or read the exact code path. If you did neither, write `unverified` in the cell rather than a guess. A table of guesses is worse than no table.
- **Every `← CHANGED` row is a claim that needs a test.** Say which ones exist and which don't (**REQUIRED SUB-SKILL:** test-driven-development).
- **Keep the still-broken rows in.** The rows that didn't get fixed are the most useful thing in the table; deleting them to make the fix look clean defeats the point.
- **Behavior includes errors, exceptions, and return-value *type*.** "returns None" and "raises ValueError" are different rows, not the same one.

## When Not To Use

Pure refactors with no intended behavior change — there the whole table would be "unchanged", and saying so in a sentence is enough.

Related: **systematic-debugging** (find the root cause before tabulating), **verification-before-completion** (a filled cell is a claim).
