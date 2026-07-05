---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment
---

# Writing Skills

## Overview

**Writing skills IS Test-Driven Development applied to process documentation.**

You write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes).

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**REQUIRED BACKGROUND:** You MUST understand workflow:test-driven-development. That skill defines the RED-GREEN-REFACTOR cycle; this skill adapts it to documentation.

**Official guidance:** For Anthropic's official skill authoring best practices, fetch https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices when needed.

## What is a Skill?

A **skill** is a reference guide for proven techniques, patterns, or tools — NOT a narrative about how you solved a problem once.

**Create when:** the technique wasn't intuitively obvious, you'd reference it across projects, and it applies broadly.

**Don't create for:** one-off solutions, standard practices documented elsewhere, project-specific conventions (instructions file), or mechanical constraints (if it's enforceable with regex/validation, automate it — save documentation for judgment calls).

**Skill types:** technique (concrete steps), pattern (way of thinking), reference (API/tool docs).

## Directory Structure

```
skills/
  skill-name/
    SKILL.md              # Main reference (required)
    supporting-file.*     # Only for heavy reference (100+ lines) or reusable tools
```

Keep principles, concepts, and code patterns (< 50 lines) inline in SKILL.md.

## SKILL.md Structure

**Frontmatter (YAML):**
- Two required fields: `name` and `description` (see [agentskills.io/specification](https://agentskills.io/specification)); max 1024 characters total
- `name`: letters, numbers, hyphens only; verb-first gerunds work well (`creating-skills`, `condition-based-waiting`); name by what you DO or the core insight
- `description`: third person, starts with "Use when...", describes ONLY when to use — NOT what the skill does

**Body sections:** Overview (core principle in 1-2 sentences), When to Use (symptoms, use cases, when NOT), Core Pattern / Quick Reference, Implementation, Common Mistakes.

## Skill Discovery Optimization (SDO)

Your agent reads the description to decide which skills to load. Make it answer: "Should I read this skill right now?"

**CRITICAL: Description = When to Use, NOT What the Skill Does.**

Testing revealed that when a description summarizes the skill's workflow, agents follow the description instead of reading the skill body. A description saying "code review between tasks" caused an agent to do ONE review even though the skill's flowchart showed TWO. With the workflow summary removed, the agent read the flowchart and complied.

```yaml
# ❌ BAD: Summarizes workflow - agents follow this instead of reading the skill
description: Use when executing plans - dispatches subagent per task with code review between tasks

# ❌ BAD: Too abstract, no trigger
description: For async testing

# ✅ GOOD: Triggering conditions only, describes the problem
description: Use when tests have race conditions, timing dependencies, or pass/fail inconsistently
```

**Description content:**
- Concrete triggers, symptoms, and situations — including symptoms that you're ABOUT to violate the rule
- Describe the *problem* (race conditions), not language-specific symptoms (setTimeout) — unless the skill is technology-specific, then say so explicitly
- Use keywords an agent would search for: error messages, symptoms ("flaky", "hanging"), synonyms, actual tool/command names. Carry keywords through the skill body too.

**Token efficiency:** SKILL.md competes with conversation history once loaded. Aim for <500 words where possible. Reference `--help` output instead of documenting flags; cross-reference other skills instead of repeating them; one compressed example per pattern, not several.

**Cross-referencing other skills:** use the skill name with an explicit requirement marker — `**REQUIRED SUB-SKILL:** Use workflow:test-driven-development`. Never use `@` file links: they force-load immediately and burn context.

## Flowcharts

**Use ONLY for:** non-obvious decision points, process loops where you might stop too early, "A vs B" decisions.

**Never for:** reference material (use tables), code, linear instructions (use numbered lists), or labels without semantic meaning (step1, helper2).

## Code Examples

One excellent example beats many mediocre ones. Pick the most relevant language, make it complete and runnable, comment the WHY. Don't implement in 5 languages, write fill-in-the-blank templates, or invent contrived examples — you're good at porting.

## The Iron Law (Same as TDD)

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to NEW skills AND EDITS to existing skills.

Write skill before testing? Delete it. Start over.
Edit skill without testing? Same violation.

**No exceptions:**
- Not for "simple additions"
- Not for "just adding a section"
- Not for "documentation updates"
- Don't keep untested changes as "reference"
- Don't "adapt" while running tests
- Delete means delete

## Testing by Skill Type

| Skill type | Test with | Success criteria |
|---|---|---|
| Discipline-enforcing (TDD, verification) | Academic questions + pressure scenarios (time + sunk cost + exhaustion combined) | Complies under maximum pressure |
| Technique (how-to) | Application + variation scenarios; gap-check instructions | Applies technique to new scenario |
| Pattern (mental model) | Recognition scenarios + counter-examples | Knows when — and when NOT — to apply |
| Reference (docs/APIs) | Retrieval + application scenarios | Finds and correctly applies information |

## Common Rationalizations for Skipping Testing

| Excuse | Reality |
|--------|---------|
| "Skill is obviously clear" | Clear to you ≠ clear to other agents. Test it. |
| "It's just a reference" | References have gaps and unclear sections. Test retrieval. |
| "Testing is overkill" | Untested skills have issues. Always. 15 min testing saves hours. |
| "I'll test if problems emerge" | Problems = agents can't use skill. Test BEFORE deploying. |
| "Too tedious to test" | Less tedious than debugging a bad skill in production. |
| "I'm confident it's good" | Overconfidence guarantees issues. Test anyway. |
| "Academic review is enough" | Reading ≠ using. Test application scenarios. |
| "No time to test" | Deploying untested wastes more time fixing it later. |

**All of these mean: Test before deploying. No exceptions.**

## Match the Form to the Failure

Before writing guidance, classify the baseline failure. The form that bulletproofs one failure type measurably backfires on another.

| Baseline failure | Right form | Wrong form |
|---|---|---|
| Skips/violates a rule under pressure (knows better, does it anyway) | Prohibition + rationalization table + red flags (see Bulletproofing below) | Soft guidance ("prefer...", "consider...") |
| Complies, but output has the wrong shape (bloated prompt, buried verdict, restated spec) | Positive recipe or contract: state what the output IS — its parts, in order | Prohibition list ("don't restate", "never narrate") |
| Omits a required element from something they already produce | Structural: REQUIRED field or slot in the template they fill in | Prose reminders near the template |
| Behavior should depend on a condition | Conditional keyed to an observable predicate ("if the brief exists, reference it") | Unconditional rule + exemption clauses |

**Why prohibitions backfire on shaping problems:** under a competing incentive ("make the prompt self-contained"), agents negotiate with "don't X". In head-to-head wording tests on dispatch-prompt guidance, the prohibition arm produced clearly more of the unwanted content than the recipe arm (fully separated distributions), and trended worse than even the no-guidance control — micro-test your own case rather than assuming, but never reach for the prohibition by default. A recipe leaves nothing to negotiate: the output matches the stated shape or it doesn't.

**Rules for whichever form you pick:**
- **No nuance clauses.** "Don't X unless it matters" reopens the negotiation — appending a single nuance clause to a winning recipe degraded it from consistent to noisy in the same wording tests. Express a real exception as its own conditional on an observable predicate.
- **Exemption clauses don't scope.** "This limit doesn't apply to code blocks" still suppresses code blocks. If part of the output must be exempt, restructure so the rule can't reach it.

## Bulletproofing Skills Against Rationalization

Discipline-enforcing skills need to resist rationalization — agents find loopholes under pressure. This toolkit is for discipline failures only; for wrong-shaped output, prohibitions backfire (see above).

**Psychology note:** See persuasion-principles.md for the research foundation (Cialdini, 2021; Meincke et al., 2025) on authority, commitment, scarcity, social proof, and unity.

**Close every loophole explicitly** — don't just state the rule, forbid the specific workarounds:

```markdown
Write code before test? Delete it. Start over.

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Delete means delete
```

**Address spirit-vs-letter arguments** with a foundational principle early: "**Violating the letter of the rules is violating the spirit of the rules.**"

**Build a rationalization table** from baseline testing — every excuse agents actually made, each paired with the reality.

**Create a red flags list** of thoughts that signal imminent violation ("I already manually tested it", "This is different because..."), ending with what they all mean: stop and follow the rule.

## RED-GREEN-REFACTOR for Skills

**RED (baseline):** Run pressure scenarios with a subagent WITHOUT the skill. Document verbatim what they chose, what rationalizations they used, which pressures triggered violations. You must see what agents naturally do before writing the skill.

**GREEN:** Write a minimal skill addressing those specific rationalizations — no extra content for hypothetical cases. Re-run the scenarios WITH the skill; agents should comply.

**REFACTOR:** Agent found a new rationalization? Add an explicit counter. Re-test until bulletproof.

### Micro-Test Wording Before Full Scenarios

Full pressure-scenario runs are the final gate, but they are slow per iteration. Verify wording first with micro-tests:

1. **One fresh-context sample per call** — raw API call or single-shot subagent. System prompt = the realistic context the guidance will live in; user message = a task that tempts the failure.
2. **Always include a no-guidance control.** If the control doesn't exhibit the failure, there is nothing to fix — stop.
3. **5+ reps per variant.** Single samples lie.
4. **Manually read every flagged match.** Template echoes and quoted counter-examples masquerade as hits.
5. **Variance is a metric.** Five different interpretations across five reps means the wording isn't binding — tighten the form before adding words.

Micro-tests verify wording; they do not replace pressure scenarios for discipline skills.

**Testing methodology:** See [testing-skills-with-subagents.md](testing-skills-with-subagents.md) for pressure scenario design, pressure types, and hole-plugging.

## Anti-Patterns

- ❌ **Narrative examples** ("In session 2025-10-03, we found...") — too specific, not reusable
- ❌ **Multi-language dilution** (example in 5 languages) — mediocre quality, maintenance burden
- ❌ **Code in flowcharts** — can't copy-paste, hard to read
- ❌ **Generic labels** (helper1, step3) — labels need semantic meaning

## STOP: Before Moving to Next Skill

**After writing ANY skill, STOP and complete the checklist below for it.** No batching skills without testing each, no moving on before the current one is verified. Deploying untested skills = deploying untested code.

## Skill Creation Checklist (TDD Adapted)

**IMPORTANT: Create a todo for EACH checklist item below.**

**RED Phase - Write Failing Test:**
- [ ] Create pressure scenarios (3+ combined pressures for discipline skills)
- [ ] Run scenarios WITHOUT skill - document baseline behavior verbatim
- [ ] Identify patterns in rationalizations/failures

**GREEN Phase - Write Minimal Skill:**
- [ ] Name uses only letters, numbers, hyphens (no parentheses/special chars)
- [ ] YAML frontmatter with required `name` and `description` fields (max 1024 chars)
- [ ] Description starts with "Use when...", third person, triggers/symptoms only
- [ ] Keywords throughout for search (errors, symptoms, tools)
- [ ] Clear overview with core principle
- [ ] Address specific baseline failures identified in RED
- [ ] Guidance form matches the failure type (see Match the Form to the Failure)
- [ ] For behavior-shaping guidance: wording micro-tested against a no-guidance control (5+ reps, every flagged match read manually) — N/A for pure reference skills
- [ ] Code inline OR link to separate file; one excellent example (not multi-language)
- [ ] Run scenarios WITH skill - verify agents now comply

**REFACTOR Phase - Close Loopholes:**
- [ ] Identify NEW rationalizations from testing; add explicit counters (if discipline skill)
- [ ] Build rationalization table from all test iterations
- [ ] Create red flags list
- [ ] Re-test until bulletproof

**Quality Checks:**
- [ ] Small flowchart only if decision non-obvious
- [ ] Quick reference table; common mistakes section
- [ ] No narrative storytelling
- [ ] Supporting files only for tools or heavy reference

**Deployment:**
- [ ] Commit skill to git and push to your fork (if configured)
- [ ] Consider contributing back via PR (if broadly useful)

## The Bottom Line

Same Iron Law as TDD: no skill without a failing test first. Same cycle: RED (baseline) → GREEN (write skill) → REFACTOR (close loopholes). If you follow TDD for code, follow it for skills.
