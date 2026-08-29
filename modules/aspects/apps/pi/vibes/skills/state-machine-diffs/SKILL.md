---
name: state-machine-diffs
description: Use when reporting a change to retry or backoff logic, a connection/session/request lifecycle, a status or state field, a queue consumer, or a parser — anywhere the same functions recur in different orders and a line-by-line diff hides what actually changed
---

# State Machine Diffs

Line diffs show edited text. Call-stack diffs show who calls whom. Neither shows *order over time*, which is the only thing that matters in a retry loop or a handshake. Diff the state graph instead.

## The Output

Four parts, in this order:

**1. The after-graph, drawn once.** ASCII box-and-arrow. Nodes are states, edge labels are the trigger plus any guard. Mark new nodes `( NEW )`.

**2. The delta list.** One line per change, using these markers:

```
+ state   backoff
+ edge    inflight --5xx & tries<3--> backoff
+ edge    backoff  --timer--> inflight
~ edge    inflight --5xx--> failed        now guarded by tries == 3
- edge    inflight --timeout--> idle      removed
```

**3. The reachability line.** What is newly reachable, what is no longer reachable, and any state that is now unreachable (that last one is usually a bug):

```
newly reachable:  failed, only after 3 attempts
unreachable now:  (none)
```

**4. Anchors.** Where each state lives, so the drawing is checkable:

```
states: client.py:41 (Status enum)   transitions: client.py:88-140
```

## Rules

- **Derive the graph by reading the code, not by recalling the design.** Every node and edge must come from a line you actually read. A confidently-drawn wrong graph is worse than no drawing.
- **If you cannot find where a transition fires, say so** — `? edge  inflight --?--> done  (couldn't locate; assumed from the type)`. Never smooth over the gap.
- **Draw the after-graph only.** A before/after pair doubles the drawing and halves the attention; the delta list carries the "before".
- **Skip the drawing under ~4 states.** The delta list alone is clearer.

## When Not To Use

Straight-line code, pure functions, and refactors that don't touch ordering. If no state variable or lifecycle is involved, this is decoration.

Related: **callstack-diffs** (who calls whom, when order doesn't matter), **behavior-table-diffs** (what each input class now does), **blast-radius-maps** (who else is affected).
