---
name: cartographer
description: Use only when the user explicitly invokes cartographer to map a feature or ticket into a Neorg implementation DAG
---

# Cartographer

Map one approved feature into small, independently reviewable changes. A map is the
finished product of this run; product code is out of scope.

<MANUAL-ONLY>
Do not invoke this skill from an ordinary feature request. The user must explicitly
invoke cartographer.
</MANUAL-ONLY>

**REQUIRED SUB-SKILL:** Use brainstorming to obtain the approved, self-reviewed
specification. Cartographer owns map persistence.

## Ground Rules

- Never edit product code, create a branch/worktree, or begin a DAG node.
- Set `workspace_root` from the `Host-resolved workflow context` supplied with the
  invocation. That path is authoritative and already validated; use it directly
  without inspecting `NEORG_WORKSPACE_PATH`.
- If no host-resolved workspace was supplied, fall back to `NEORG_WORKSPACE_PATH`.
  If it is unset or inaccessible, stop with:
  `Set NEORG_WORKSPACE_PATH to a readable Neorg workspace directory.`
- Ask one question per message, including ticket and feature naming questions.
- A node is one independently reviewable behavior with one coherent TDD cycle.

## Workflow

1. Resolve `workspace_root` by the Ground Rules, then inspect repository files,
   docs, and recent commits.
2. Invoke brainstorming and receive the approved specification.
3. Slug names to lowercase ASCII. Write under
   `$workspace_root/maps/<ticket_><feature>/`; `_` appears only between an
   optional ticket slug and feature slug. Steps are `NN-kebab-case.norg`.
4. Decompose by behavior. Fold setup/docs/config into the behavior needing them;
   add an edge only for a real prerequisite. Split any node a reviewer could only
   approve in parts.
5. Write `plan.norg` and every step using the contracts below.
6. After writing, perform one concise manual structural check: confirm `plan.norg`
   and every step file exist with the required metadata, each filename agrees with
   its `step` metadata, every dependency names an existing step, no step depends on
   itself, and the graph is acyclic. Keep the check manual. Perform it only once at
   map creation; do not repeat it before review or require it when the map is used
   later.
7. Ask the user to review the written map and stop. Do not invoke Scout or begin
   implementation.

## Step Contract

```norg
@document.meta
step: 01-issue-session
title: Issue session
status: pending
depends_on: []
@end
```

All four fields are required. `depends_on` is always an inline list such as
`[]` or `[01-foundation, 02-policy]`; one dependency line replaces block-style
metadata.

The body headings, in order, are `* Outcome`, `* Why`, `* Scope`,
`* Acceptance Criteria`, `* TDD Notes`, `* Non-Goals`, and `* Scout Log`.
Acceptance criteria are observable; Scope names expected product/test files and
interfaces. Scout Log starts empty.

## Plan Contract

`plan.norg` contains the feature goal, approved specification and global constraints,
architecture/decisions, a Mermaid DAG in an `@code mermaid` block, a step summary
using Neorg file links such as `{:01-issue-session:}[Issue session]` with status and
dependency snapshots, and `* Cross-step discoveries`. Step document metadata—not
the summary—is canonical for readiness and status.

## Node Sizing Test

A node passes only if a fresh reviewer could approve or reject its single outcome
without also deciding a neighboring outcome, and it can finish its own TDD cycle.
Numeric prefixes order files; dependencies determine execution order.

## Common Mistakes

| Mistake | Correction |
|---|---|
| One node per technical layer | Slice one observable behavior through needed layers. |
| A setup-only node | Fold setup into its first consumer. |
| Starting implementation to check the map | Perform the one manual structural check and ask for review; code belongs to Scout. |
| Treating plan summary status as canonical | Read and update step document metadata. |
| Writing multiline dependency metadata | Use the required inline list. |

## Red Flags

- "A comprehensive plan is easier than many files."
- "We can approve the design after seeing code."
- "I should implement the first node while context is fresh."

These all mean: finish the map, perform its one manual structural check, request
review, and stop.
