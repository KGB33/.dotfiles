---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context** — check files, docs, recent commits
2. **Ask clarifying questions** — one at a time, understand purpose/constraints/success criteria
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — in sections scaled to their complexity, get user approval after each section
5. **Write design doc** — save to `~/.claude/plans/<project>/YYYY-MM-DD-<topic>-design.md` (project = `basename "$(git rev-parse --show-toplevel)"`). Never write it into the repository or commit it.
6. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope (see below)
7. **User reviews written spec** — ask user to review the spec file before proceeding
8. **Transition to implementation** — invoke writing-plans skill to create implementation plan

**The terminal state is invoking writing-plans.** Do NOT invoke frontend-design, mcp-builder, or any other implementation skill. The ONLY skill you invoke after brainstorming is writing-plans.

## How to Run Each Step

**Questions (step 2):** one question per message — if a topic needs more exploration, break it into multiple questions. Prefer multiple choice when possible; open-ended is fine too. Before diving into details, assess scope: if the request spans multiple independent subsystems (e.g., "chat, file storage, billing, and analytics"), don't refine details — help the user decompose into sub-projects, agree on order, then brainstorm the first one. Each sub-project gets its own spec → plan → implementation cycle.

**Approaches (step 3):** present options conversationally, leading with your recommendation and why. YAGNI ruthlessly — remove unnecessary features from all designs.

**Design (step 4):** scale each section to its complexity — a few sentences if straightforward, up to 200-300 words if nuanced. Ask after each section whether it looks right. Cover: architecture, components, data flow, error handling, testing. Go back and clarify whenever something doesn't make sense.

**Design for isolation and clarity:** break the system into units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently. For each unit you should be able to answer: what does it do, how do you use it, what does it depend on? If you can't change a unit's internals without breaking consumers, the boundaries need work. Smaller, well-bounded units are also easier for you to work with — you reason better about code you can hold in context at once.

**Existing codebases:** explore current structure before proposing changes; follow existing patterns. Where existing code has problems that affect the work (a file grown too large, tangled responsibilities), include targeted improvements in the design — but don't propose unrelated refactoring.

## After the Design

**Spec self-review (step 6):** look at the written spec with fresh eyes:

1. **Placeholder scan:** any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** do sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** could any requirement be read two ways? Pick one and make it explicit.

Fix issues inline — no need to re-review.

**User review gate (step 7):**

> "Spec written to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."

Wait for the user's response. If they request changes, make them and re-run the self-review. Only proceed once the user approves — then invoke writing-plans.
