# Scope Hammering Rules

> Reference for AI agents making scope decisions during building. Scope hammering is the discipline of forcefully questioning every piece of work to keep the project within its time box.

## Core Principle

Fixed time, variable scope. The deadline never moves. The scope flexes.

---

## Decision Framework

For every task, feature, or requirement that surfaces during build, ask these questions in order:

### Gate 1: Is It a Must-Have?

```
Is this required for the feature to work at all?
  YES → Keep as must-have. Proceed to Gate 2.
  NO  → Mark with ~ (nice-to-have). Move to Gate 3.
```

### Gate 2: Does It Fit the Appetite?

```
Can this be completed within the remaining time?
  YES → Execute.
  NO  → Can it be simplified to fit?
    YES → Simplify and execute.
    NO  → Escalate: Is it truly a must-have, or can the project ship without it?
```

### Gate 3: Nice-to-Have Triage

```
Is there remaining time after all must-haves?
  YES → Execute nice-to-have.
  NO  → Cut without guilt.
```

---

## Scope Hammering Questions

Apply these questions to ANY piece of work that surfaces:

| # | Question | What a "No" Means |
|---|----------|-------------------|
| 1 | Is this a must-have for the new feature? | Mark as nice-to-have (~) |
| 2 | Could we ship without this? | If yes, it's a nice-to-have |
| 3 | What happens if we don't do this? | If impact is low, cut it |
| 4 | Is this a new problem or pre-existing? | If pre-existing, users already live with it — not urgent |
| 5 | How likely is this case to occur? | Low probability → nice-to-have |
| 6 | Which customers see it when it occurs? | Few customers → nice-to-have |
| 7 | Is it core (everyone uses) or edge case? | Edge case → nice-to-have |
| 8 | What's the actual impact when it happens? | Low impact → nice-to-have |
| 9 | How aligned is this with the intended audience? | Low alignment → cut |

---

## Task Classification

### Must-Haves
- Required for the scope to be considered "done"
- Survived all scope hammering questions above
- Listed as regular tasks on the scope

### Nice-to-Haves (marked with `~`)
- Done if time permits
- Cut without guilt when time runs out
- Usually never get built — and that's fine
- Can apply to individual tasks OR entire scopes

### Out of Bounds (from pitch No-Gos)
- Explicitly excluded during shaping
- Not discussed during build
- Not reconsidered unless the team discovers a critical dependency

---

## Scope Cutting Patterns

### Pattern: Simplify the Implementation
Instead of the ideal solution, use a simpler one that still addresses the core problem.
- Example: Instead of grouped display with expand/collapse, show a flat list with group labels appended.

### Pattern: Reduce Surface Area
Support fewer cases or fewer entry points.
- Example: Support the feature only from the main view, not from every sub-page.

### Pattern: Defer Polish
Ship working functionality without visual refinement.
- Example: Default browser styles, basic typography, no animations.

### Pattern: Drop Edge Cases
Handle the common path. Let edge cases fail gracefully or show a generic message.
- Example: Support single timezone instead of timezone conversion.

### Pattern: Narrow the Audience
Serve the primary user type. Other user types get the feature later (or never).
- Example: Build for project managers only, not for all team member roles.

---

## Comparison Point: Baseline

When deciding whether to cut scope, always compare to the **baseline** — what customers have today.

```
Is this better than what customers currently have?
  YES → Ship it. Even if imperfect.
  NO  → Reconsider the cut. This may be a must-have.
```

Cutting scope is NOT lowering quality. It is being selective about WHAT to execute, not HOW WELL to execute it. Code quality, visual design quality, copy quality, and interaction performance remain high. The question is only: which things actually matter for the core use case?

---

## QA-Discovered Issues

When QA finds issues late in the cycle:

1. **Default classification**: All QA issues are nice-to-haves
2. **Triage**: Team evaluates severity
3. **Elevate to must-have**: Only if genuinely critical to core functionality
4. **Organize**: Move must-have issues to the relevant scope's task list
5. **Leave nice-to-haves**: They get cut if time runs out

---

## Extension Decision (Rare)

A project extension past the cycle deadline requires BOTH:

1. Remaining tasks are genuine must-haves that survived every scope hammering question
2. ALL remaining work is downhill (no unknowns, only execution)

If any remaining work is uphill (unknowns remain) → **do not extend**. Return to shaping.
