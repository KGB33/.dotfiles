---
name: dispatching-parallel-agents
description: Use when facing 2+ independent tasks that can be worked on without shared state or sequential dependencies
---

# Dispatching Parallel Agents

## Overview

You delegate tasks to specialized agents with isolated context. By precisely crafting their instructions and context, you ensure they stay focused and succeed at their task. They should never inherit your session's context or history — you construct exactly what they need. This also preserves your own context for coordination work.

**Core principle:** Dispatch one agent per independent problem domain. Let them work concurrently.

## When to Use

**Use when:**
- Multiple failures with different root causes (different test files, subsystems, bugs)
- Each problem can be understood without context from the others
- No shared state between investigations

**Don't use when:**
- Failures are related — fixing one might fix others; investigate together first
- Understanding requires seeing the entire system
- Exploratory debugging — you don't know what's broken yet
- Agents would interfere (editing same files, using same resources) — run sequentially instead

## The Pattern

1. **Identify independent domains** — group failures by what's broken (e.g., tool approval flow vs. batch completion vs. abort handling). Each domain is one agent's scope.
2. **Create focused agent tasks** — each agent gets a specific scope, a clear goal, constraints, and an expected output.
3. **Dispatch in parallel** — issue all subagent dispatches in the same response; multiple dispatch calls in one response run concurrently, one per response runs sequentially.
4. **Review and integrate** — read each summary, check the fixes don't conflict, run the full test suite.

## Agent Prompt Structure

Good agent prompts are focused (one problem domain), self-contained (all context needed), and specific about output:

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:

1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by:
   - Replacing arbitrary timeouts with event-based waiting
   - Fixing bugs in abort implementation if found
   - Adjusting test expectations if testing changed behavior

Do NOT just increase timeouts - find the real issue.

Return: Summary of what you found and what you fixed.
```

## Common Mistakes

**❌ Too broad:** "Fix all the tests" — agent gets lost
**✅ Specific:** "Fix agent-tool-abort.test.ts" — focused scope

**❌ No context:** "Fix the race condition" — agent doesn't know where
**✅ Context:** paste the error messages and test names

**❌ No constraints:** agent might refactor everything
**✅ Constraints:** "Do NOT change production code" or "Fix tests only"

**❌ Vague output:** "Fix it" — you don't know what changed
**✅ Specific:** "Return summary of root cause and changes"

## Verification

After agents return:
1. **Review each summary** — understand what changed
2. **Check for conflicts** — did agents edit the same code?
3. **Run full suite** — verify all fixes work together
4. **Spot check** — agents can make systematic errors
