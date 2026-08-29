---
name: callstack-diffs
description: Use when a change moves logic between layers, extracts or inlines a function, adds a caching/middleware/adapter layer, or changes what runs on a hot path — anywhere "who calls whom" changed and the line diff shows edited text instead of the new shape
---

# Call Stack Diffs

Show how the call stack changes, not which lines changed. A frame appearing or disappearing on a path is the semantic content of most refactors; the text diff buries it in moved braces.

## The Output

Five parts, in this order:

**1. The entry point, named.** A stack is always relative to one. `entry: GET /sessions/:id (api/routes.py:31)`

**2. The after-stack**, as a tree with markers in a left gutter and `file:line` on every frame:

```
entry: GET /sessions/:id  (api/routes.py:31)

    handle_get_session               routes.py:31
 +  ├── cache.get                    cache.py:44       ← NEW I/O: redis
    ├── auth.require_scope           middleware.py:12
 -  │   └── validate_token_shape     session.py:88     ← moved up a layer
    └── session.load                 session.py:120
        └── db.query                 db.py:200
```

**3. The delta list**, including conditional reachability:

```
+ frame  cache.get              new failure point: redis timeout / miss
- frame  validate_token_shape   off this path; now runs at middleware.py:20
! path   session.load + db.query no longer reached on a cache hit
```

**4. New boundaries crossed.** One line naming what the new frames *cost*: network, disk, lock, subprocess, allocation in a loop, or a new place the path can raise. A new frame doing arithmetic is not worth reporting; a new frame opening a socket is the entire point.

**5. Frames that changed error context.** A frame that moved inside or outside a `try`, a retry wrapper, or a transaction — the code may be identical and the behavior completely different.

## Rules

- **One entry point per stack.** If several entry points changed differently, draw the one that changed most and name the others in a line; don't merge them into a tree that matches no real execution.
- **Mark conditional frames.** A stack is not a static call graph. If a frame is only reached on some branch (cache miss, retry, error path), the `! path` line must say so.
- **Derive it by reading the code.** Dynamic dispatch, decorators, and DI containers hide edges — where you inferred a frame you couldn't confirm, mark it `?` rather than drawing it solid.
- **After-stack only.** The delta list carries the before.

## When Not To Use

Edits inside one function body that don't change what it calls, renames, and formatting. If the tree is identical and only the gutter is empty, say "call path unchanged" in a sentence and move on.

Related: **state-machine-diffs** (order over time, not frames), **blast-radius-maps** (callers of the changed symbol, not callees).
