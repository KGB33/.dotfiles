---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** If subagents are available (Claude Code always qualifies), use workflow:subagent-driven-development instead of this skill — the quality of the work is significantly higher.

**Branches and worktrees:** The user creates and manages both. Never create a branch or worktree. If you're on main/master, stop and ask the user to set up a branch before executing anything.

## The Process

### Step 1: Load and Review Plan
1. Read plan file (plans live in `~/.claude/plans/<project>/`)
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Report and Stop

After all tasks complete and verified:
1. Run the full test suite one final time and confirm it passes (**REQUIRED SUB-SKILL:** workflow:verification-before-completion)
2. Confirm every change is committed (each task should already have its own small commits — do not squash or rewrite them)
3. Summarize for the user: what was built, the commit list (`git log --oneline <base>..HEAD`), test results, and any concerns or follow-ups
4. **STOP.** Integration is the user's job: do not merge, rebase, push, open PRs, tag, or delete/create branches or worktrees. Don't present a menu of integration options — just hand the branch back.

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never implement on main/master — ask the user for a branch; never create one yourself

## Integration

**Required workflow skills:**
- **workflow:writing-plans** - Creates the plan this skill executes
- **workflow:verification-before-completion** - Final verification before reporting done
