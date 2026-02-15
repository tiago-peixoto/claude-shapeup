# Shaping Process

> Reference for AI agents performing the Shaping role. Shaping transforms raw ideas into bet-ready pitches.

## Overview

Shaping is the pre-work that happens before any team is assigned. It operates on a separate track from building. Shaping produces a Pitch — a document concrete enough to act on but rough enough to leave room for execution decisions.

**Critical distinction**: Shaping has two phases that must not blur together (see `07-pitfalls.md`):
- **Framing** (Step 1 below) — Lock the problem, outcome, and appetite. Status: **Candidate → Frame Go**.
- **Shaping** (Steps 2-4 below) — Design the technical solution. Status: **Frame Go → Shape Go**.

Never design solutions before the problem is locked. Never write a pitch before the solution is technically validated.

## Step 1: Frame the Problem (Set Boundaries)

### Set the Appetite

Before designing anything, decide how much time the idea deserves:

- **Small Batch**: 1-2 weeks (one designer + 1-2 programmers)
- **Big Batch**: Full 6 weeks (same team size)
- If idea exceeds 6 weeks after narrowing, break it into independent 6-week pieces

The appetite is a **constraint**, not an estimate. It drives the design, not the other way around.

**Fixed time, variable scope**: The time is locked. The scope flexes to fit. This forces trade-off decisions and prevents indefinite expansion.

### Narrow the Problem

Transform generic requests into specific pain points:

1. **Never accept raw ideas at face value.** Default response: "Interesting. Maybe some day."
2. **Ask: "What's really going wrong?"** — Move from "we need a calendar" to "users can't see free time slots to schedule posts."
3. **Identify the specific moment** the workflow breaks down.
4. **Understand the baseline** — what do users do today without this feature?
5. **Reject grab-bags** — "Redesign X" or "X 2.0" without a single defined problem is not shapeable. Split into specific problems.

### Frame Go Checklist

Before proceeding to solution design (elements):

- [ ] Raw idea captured
- [ ] Appetite set (small or big batch)
- [ ] Problem narrowed to a specific pain point
- [ ] Business value / desired outcome stated
- [ ] Grab-bags rejected or decomposed
- [ ] **Status: Frame Go** — problem is tight enough to design a solution for

---

## Step 2: Find the Elements

### Working Rules

- Work alone or with one trusted collaborator (not a committee)
- Stay at the right abstraction level: concrete enough to make progress, rough enough to explore broadly
- Answer: Where does this fit in the system? How do you get to it? What are the key components? Where does it take you?

### Technique A: Breadboarding

Use for **flows and interactions**. Borrowed from electrical engineering.

Three elements only:
1. **Places** — screens, dialogs, menus (underlined names)
2. **Affordances** — buttons, fields, actions (listed below places)
3. **Connection Lines** — how affordances move user between places

Rules:
- Words only, no pictures
- Debate flows, not visuals
- Stay lightweight — speed enables exploration

### Technique B: Fat Marker Sketches

Use when **visual arrangement is the core problem**.

Rules:
- Draw with a thick line (prevents adding detail)
- Show rough layout and spatial relationships
- No wireframes, no high-fidelity elements

### Output Requirements

Elements must be:
- **Specific** (not "a calendar" but "2-up monthly grid with dots for events and an agenda list below")
- **Components, not tasks** — describe what exists, not what to do
- **Incomplete** — leave room for designers to make decisions

### Gate Check

- Elements are NOT deliverables. They are rough, mostly indecipherable to outsiders.
- No commitment has been made. Work can be shelved or dropped at this point.

---

## Step 3: De-Risk (Risks and Rabbit Holes)

### Goal

Shape the probability distribution: slight chance of running one week over, but never multiple times the appetite.

### Process

1. **Walk through the use case in slow motion** — trace the user's path from start to end. Reveal gaps.
2. **Ask these questions for each element:**
   - Does this require technical work we've never done?
   - Are we assuming parts fit together without verifying?
   - Are we assuming a design solution exists that we haven't validated?
   - Is there a hard decision that could stall the team?

### Three De-Risking Actions

| Action | When to Use | Example |
|--------|-------------|---------|
| **Declare Out of Bounds** | Use case not worth supporting | "No custom domain support for v1" |
| **Cut Back** | Feature not necessary for core value | Remove non-essential UI elements |
| **Patch the Hole** | Known hard problem that needs a decision now | Choose a simpler implementation, accept trade-off |

### Technical Validation

Before writing the pitch, present to a technical expert if uncertain:

- **Frame as exploratory**: "Here's something I'm thinking about..."
- **Right question**: "Is this possible in 6 weeks?" (not "Is this possible?")
- **Goal**: Hunt for time bombs
- **Keep clay wet**: Redraw elements, invite alternative approaches

### De-Risked State Checklist (Shape Go)

- [ ] Solution elements defined as **wiring** (connections, data flows, affected modules) — not just UI concepts
- [ ] Actual codebase, data models, and architecture reviewed
- [ ] Rabbit holes patched or declared out of bounds — **zero TBDs allowed** (every unresolved rabbit hole is a time bomb)
- [ ] Technical feasibility validated within appetite (not just "possible" — possible *in 6 weeks*)
- [ ] Thin-tailed risk profile achieved
- [ ] **Status: Shape Go** — a builder could pick this up and know what to do

---

## Step 4: Write the Pitch

### Five Required Ingredients

#### 1. Problem
- A specific story showing why the status quo fails
- Establishes the baseline for judging the solution
- Without a problem statement, there is no way to evaluate solution fitness

#### 2. Appetite
- How much time to spend (constraint, not estimate)
- Different appetites yield fundamentally different solutions
- Frames the creative constraint for everyone

#### 3. Solution
- The shaped elements with enough visual support to communicate
- Use **embedded sketches** (elements placed in existing UI context) or **annotated fat marker sketches**
- Stay rough — no wireframes, no pixel-perfect mockups
- Add disclaimer: "Designers should feel free to find a different approach"

#### 4. Rabbit Holes
- Known technical or design risks and how they've been addressed
- Things explicitly NOT addressed ("URLs won't live on custom domains for v1")
- Prevents surprises during build

#### 5. No-Gos
- Functionality intentionally excluded
- Use cases deliberately not covered
- Prevents scope creep during build

### Pitch Distribution

- Post asynchronously where betting table members can read on their own time
- Enable commenting for technical experts to poke holes
- Keep betting table meetings short — everyone reads in advance

---

## Shaping Decision Tree

```
Raw idea arrives
  → Is the problem specific?
    NO → Narrow it or reject as grab-bag
    YES → Set appetite (small or big batch)
      → Find elements (breadboard or fat marker)
        → Walk through use case slowly
          → Any rabbit holes?
            YES → Patch, cut back, or declare out of bounds
            NO → Validate with technical expert
              → Write pitch (5 ingredients)
                → Post for betting table
```

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| Wireframes in shaping | Too concrete. Kills designer creativity. Causes estimation errors. |
| Words-only descriptions | Too abstract. Team can't make trade-offs or know scope. |
| Grab-bag projects ("Redesign X") | No single problem. Impossible to scope, start, or finish. |
| Estimating then designing | Inverts the constraint. Scope grows indefinitely. |
| Committing to raw ideas | No shaping done. High risk of rabbit holes and overruns. |
| Shaping in committees | Too slow. Requires trust and shorthand between 1-2 people. |
| Skipping technical validation | Time bombs discovered during build, not during shaping. |
| **Shaping without codebase analysis** | Pitch reads well but hides technical unknowns. #1 failure mode. (See `07-pitfalls.md`) |
| **Jumping to solutions before framing** | Solution is unanchored. No way to evaluate fit or make trade-offs. Leads to scope spirals and cancelled projects. |
| **Leaving rabbit holes as TBD** | Every unresolved rabbit hole detonates during build. Zero TBDs allowed. |
| **Describing UI concepts instead of wiring** | Pitch shows what it looks like but not how it connects. Builders discover missing plumbing mid-cycle. |
