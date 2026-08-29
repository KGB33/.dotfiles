---
name: blast-radius-maps
description: Use when a change alters a function signature, an exported symbol, a schema, a config key, or shared-module behavior, and call sites elsewhere may now be stale — or when summarizing how far a change you did not write actually reaches
---

# Blast Radius Maps

Turns "I updated all the call sites" from a vibe into a checkable list. The map answers one question: what else touches this, and is each one handled?

## The Output

```
tier 0 │ auth/session.py:refresh_token()            ← signature changed
       │
tier 1 │ ├─ api/middleware.py:44        updated  ✓
       │ ├─ api/login.py:91             updated  ✓
       │ ├─ workers/refresh.py:88       STALE    ✗  still passes ttl= kwarg
       │ └─ tests/test_session.py:12    STALE    ✗  mocks the old 2-arg shape
       │
tier 2 │    └─ (via middleware) 6 route handlers — behavior unchanged
       │
───────┴─────────────────────────────────────────────────────────────
escapes the module?  YES — re-exported from auth/__init__.py, so callers
                     outside this repo may exist
found by: rg -n 'refresh_token' --type py
```

- **tier 0** — the changed symbol, with `file:line`.
- **tier 1** — every direct caller/importer, each marked `updated ✓`, `STALE ✗` with the reason, or `unaffected` with the reason.
- **tier 2** — only if behavior propagates further; collapse to a count.
- **escape line** — is the symbol exported, re-exported, or public API? If yes, the map is incomplete by definition and must say so.
- **found by** — the actual search command, so the enumeration can be re-run.

## Rules

- **Enumerate with a real search, and show it.** No search command, no map. Dynamic dispatch, reflection, string-keyed lookups, and templates won't appear in it — name that limitation on the escape line rather than implying the list is complete.
- **A `✗` row is unfinished work, not a footnote.** Either fix it or state plainly that it's left undone and why.
- **Stop at the first tier where behavior stops changing.** Depth is not thoroughness; a three-tier map of unaffected callers is noise.

## When Not To Use

Changes local to one function body, or new files with no callers yet.

Related: **verification-before-completion** (the `✓` marks are claims), **callstack-diffs** (callees of the change, not callers), **type-shape-diffs** (when the shape of the data changed, not the signature).
