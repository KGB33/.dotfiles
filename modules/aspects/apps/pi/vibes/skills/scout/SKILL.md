---
name: scout
description: Implements and independently reviews one ready node from a Cartographer Neorg map. Use only when the user explicitly invokes Scout.
---

# Scout

Implement and review exactly one ready DAG node, persist the result, and stop.
The node—not the whole feature—is the unit of work and review.

<MANUAL-ONLY>
Do not load Scout for an ordinary implementation request. One invocation never
selects a second node.
</MANUAL-ONLY>

**REQUIRED SUB-SKILLS:** Use `test-driven-development` for product changes,
`systematic-debugging` for unexpected failures, and
`verification-before-completion` before completion.

## Select One Node

1. Use the host-resolved Neorg workspace, if it is missing or unreadable, stop with a direct
   diagnostic.
2. Find `maps/*/plan.norg`, ask which active feature to use, and read its step
   summary. Read only each candidate's `step`, `status`, and `depends_on` metadata
   to determine readiness. Cartographer already checked map structure; do not
   validate the whole map again.
3. If metadata needed during selection is missing or unreadable, name that file and
   field and stop. Do not turn the error into a map-wide validation pass.
4. Never create, switch, reset, stash, or clean a branch for the user. If the
   current branch is `main` or `master`, confirm with the user before
   continuing.
5. Resume any `in-progress` or `blocked` node with retained changes before offering
   new work, preserving its original base. Otherwise offer pending nodes whose
   dependencies are complete and ask the user to choose one.
6. Read the selected step, its Scout Log, the global constraints, and relevant
   cross-step discoveries. If repository reality makes the node stale, propose the
   smallest map change and wait for approval.

Only one Scout may operate on a feature at a time.

## Delegate Through Pi

1. For a new node, set it to `in-progress`, record `base = HEAD` and a timestamp in
   its Scout Log, and refresh the plan summary. A resumed node keeps its original
   base and prior evidence.
2. Call the subagent tool with `action: "list"`. Require one executable writing
   agent and one executable read-only review agent. If either is unavailable, log
   the blocker and stop; the parent must not implement the node.
3. Load `implementer-prompt.md`. Dispatch one fresh writing agent with the repository
   path, selected step text, global constraints, discoveries, prior attempt context,
   and base SHA directly in the task. The agent returns its result directly; do not
   generate workspace, context, or result files.
4. Require committed changes and a clean worktree. Record `head = HEAD`, then load
   `reviewer-prompt.md` and dispatch one fresh read-only agent with the same
   requirements, implementer result, and exact `base..head` range.
5. Send all Critical and Important findings together to one fresh writing agent.
   Require covering RED/GREEN evidence, committed fixes, and a clean worktree; then
   refresh `head` and obtain a fresh read-only review of the complete `base..head`
   range. Repeat only while findings are actionable; escalate a blocker to the user.
6. Record `reviewed_head` only from an Approved review.

Use Pi's configured subagent orchestration for the sequence. Keep one writer active
in the checkout at a time. Context travels in task arguments and results, never in
generated handoff artifacts.

## Verify and Persist

The parent session owns this gate:

1. Freshly run the focused checks and applicable full suite.
2. Confirm the worktree is clean, every node change is committed, the commit list is
   exactly `base..HEAD`, and `HEAD == reviewed_head`.
3. If verification changes product files, review the new complete range again.
4. Append commits, RED/GREEN evidence, tests, review verdict, discoveries, concerns,
   and final timestamp to the Scout Log. Put cross-node discoveries in `plan.norg`.
5. Set the node to `complete` only after the gate passes and refresh the summary.
   Otherwise set it to `blocked` with evidence while preserving its original base.
6. Report the node, commits, checks, review, and Minor findings. Mention what
   nodes are still pending, but stop without reading or selecting another node.

## Ownership

| Parent session | Fresh implementer | Fresh reviewer |
|---|---|---|
| Selection, user interaction, status, final verification, durable log | Product edits, tests, commits | Read-only exact-range inspection |

## Red Flags

- Rechecking the entire map before selection
- Implementing in the parent because no writer is available
- Reviewing only the last commit instead of `base..head`
- Selecting another node because context is warm

All mean: stop and restore the one-node boundary.
