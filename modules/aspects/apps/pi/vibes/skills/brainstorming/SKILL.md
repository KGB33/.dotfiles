---
name: brainstorming
description: Use only when explicitly invoked for collaborative design, or when an explicitly invoked workflow requests an approved specification
---

# Brainstorming Ideas Into Designs

Turn an idea into an approved, self-reviewed specification. This is a reusable
sub-skill: the caller owns planning, persistence, and implementation.

<HARD-GATE>
Do not plan implementation or edit product code until the design is approved.
Do not hand off to another workflow unless the caller explicitly instructs you to.
</HARD-GATE>

## Process

1. Explore project context: relevant files, documentation, and recent commits.
2. Ask one clarifying question per message. Establish intent, constraints, and success.
3. Propose two or three approaches with trade-offs and a recommendation. Apply YAGNI.
4. Present the design in sections sized to their complexity. Cover architecture,
   components, data flow, errors, and testing; obtain approval after each section.
5. Compose one specification and self-review it for placeholders, contradictions,
   ambiguity, missing requirements, and scope that should be split.
6. Return the approved specification to the invoking workflow and stop.

For a standalone invocation, return the approved specification to the user and
stop. Save it only when the user explicitly requests a destination, using the
destination they provide.

## Design Boundaries

Each unit has one clear purpose, an explicit interface, and dependencies that can
be named. Prefer independently understandable and testable units. Follow existing
project patterns and include only targeted improvements needed by this design.

## Common Mistakes

| Mistake | Correction |
|---|---|
| Starting a full implementation plan after approval | Return the specification to the caller and stop. |
| Asking several questions at once | Ask one question per message. |
| Treating a small feature as design-free | Use a short design, not no design. |
| Adding unrelated refactors | Keep only work required by the approved outcome. |

## Red Flags

- "The old workflow always invokes a planning skill next."
- "Stopping after approval breaks the established process."
- "Starting implementation now preserves momentum."
- "The caller can extract the spec from my implementation plan."

These all mean: return the approved specification and stop.
