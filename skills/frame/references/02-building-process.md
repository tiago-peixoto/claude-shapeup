# Building Process

> Reference for AI agents performing the Building role. Building executes shaped work within a fixed six-week cycle.

## Overview

Building begins after a pitch is bet on at the betting table. A team (typically one designer + 1-2 programmers) receives the full project — not individual tasks. The team owns all decisions about how to execute within the shaped boundaries. The cycle ends with deployed software.

---

## Phase 1: Orientation (Days 1-3)

### What Happens

- Team studies the pitch, existing codebase, and system
- Each member identifies starting points and approaches
- No visible output is produced — this is normal and necessary

### Rules

- **Do not interrupt** the team during orientation
- **Do not ask for status** or demand visible progress
- **Three-day rule**: If silence continues past day three, check in

### Output

- Team has identified the first piece to integrate

---

## Phase 2: Get One Piece Done (Days 3-7)

### Selection Criteria for First Piece

The first piece must be:

1. **Core** — Central to the project concept. Without it, other work doesn't make sense.
2. **Small** — Achievable in a few days. Creates momentum.
3. **Novel** — If two pieces are equally core and small, prefer the one never done before. Eliminates uncertainty.

**Do NOT start with**: Login systems, project setup, infrastructure, or anything peripheral.

### Vertical Integration

Integrate fully across all layers for this one piece:

```
WRONG: Complete all design → Complete all backend → Integrate at the end
RIGHT: Design one piece → Wire to backend → Working feature you can click through
```

### Execution Pattern

1. **Designer**: Creates basic affordances (buttons, fields, layout) — NOT pixel-perfect. Plain HTML, default colors, just enough visual hierarchy.
2. **Programmer**: Builds just enough backend to make the affordance functional. Strategic scaffolding — routes, partial models, mock data where needed.
3. **Back and forth**: Take turns layering affordances, code, and styling. Click through after each round to judge progress.

### Priority Order

1. Affordances (what can users interact with?)
2. Wiring to backend (does it actually work?)
3. Copy and layout (is it understandable?)
4. Visual styling (does it look right?)

### Backend Strategy

Build **strategically patchy** backends:
- Controller that renders templates but no model yet
- Routes that navigate between screens, even if not all wired
- Hard-coded values or mock data where real implementation isn't needed yet
- Simplest possible authentication if testing requires it (e.g., HTTP Basic Auth with hardcoded password)

### Milestone

By end of first week: one integrated, clickable piece of the project works end-to-end. Team has confidence. Concept is validated.

---

## Phase 3: Map the Scopes (Week 1-2)

### What Are Scopes

Scopes are independent parts of the project that can be built, integrated, and finished separately. They are:
- Bigger than individual tasks
- Much smaller than the project
- The project's working vocabulary

### Discovery Process

Scopes are **discovered through real work**, not planned upfront.

1. Start by capturing tasks as they're found
2. As work reveals relationships, group tasks into scopes
3. Name each scope with language specific to THIS project
4. Expect scopes to stabilize around end of week 1 or start of week 2
5. Expect shuffling and renaming as real boundaries emerge

### Scope Quality Checks

**Good scopes have:**
- [ ] You can see the whole project at macro level
- [ ] Conversations use scope names naturally
- [ ] New tasks easily categorize into existing scopes

**Bad scopes show:**
- [ ] Hard to say when a scope is "done" → tasks inside are unrelated, factor them out
- [ ] Name isn't unique to the project (e.g., "frontend", "bugs", "chores") → grab-bag, not a real scope
- [ ] Too big to finish soon → break into smaller pieces

### Scope Patterns

| Pattern | Description | Strategy |
|---------|-------------|----------|
| **Layer Cake** | Even UI and backend work | Estimate by UI surface area. Default for info systems. |
| **Iceberg** | Backend vastly exceeds UI (or vice versa) | Factor UI out as separate scope. Split backend into independent pieces. |
| **Upside-down Iceberg** | UI vastly exceeds backend | Question if complexity is necessary. Simplify if possible. |
| **Chowder** | Loose tasks that don't fit anywhere | Keep one list, max 3-5 items. If longer, a scope is hiding in there. |

### Nice-to-Have Marking

Mark tasks with `~` prefix to indicate nice-to-have status:
- `~ Polish loading animation`
- `~ Handle edge case for empty state`
- `~ Refactor data layer`

Nice-to-haves are cut without guilt if time runs out. They are the primary tool for scope management.

Entire scopes can also be marked as nice-to-have.

---

## Phase 4: Track Progress with Hill Charts

### The Hill Model

All work moves through two phases:

```
        ↗ UPHILL ↗          ↘ DOWNHILL ↘
   (unknowns, figuring out)  (execution, known work)

Start ──────── Peak ──────── Done
```

### Uphill Sub-Phases

1. **First third**: "I've thought about this"
2. **Second third**: "I've validated my approach"
3. **Final third**: "I've built enough to confirm no remaining unknowns"

**Critical rule**: Move a scope to the top of the hill only after validating with hands, not just head. Theory-based confidence ("I'll just use that API") often collapses in practice.

### Using Hill Charts

- Plot each scope as a dot on the hill
- Update positions regularly
- Compare past states to see movement
- A dot that doesn't move = raised flag that something may be stuck

### Stuck Scope Protocol

When a scope appears stuck on the hill:

1. Probe what's unknown or blocking progress
2. Check if the scope is too broadly drawn
3. If scope contains unrelated parts at different stages → **break it apart** into smaller scopes
4. After refactoring, individual pieces move independently

### Work Sequencing Rules

1. **Riskiest scopes first** — push the scariest unknowns uphill before anything else
2. **Question for prioritization**: "If we run out of time, which scope could we whip together despite unknowns? Which might be harder than expected?"
3. **Inverted pyramid**: Most important problems first, most unknowns first. Leave routine work for last.
4. By cycle end: important things finished, only nice-to-haves remaining.

---

## Phase 5: Decide When to Stop

### Compare to Baseline, Not Ideal

- **Wrong question**: "Is this the best possible version?"
- **Right question**: "Is this better than what customers have today?"

The baseline (how customers solve the problem now) is the comparison point. Ship when the improvement is clear, not when perfection is achieved.

### Scope Hammering

Continuously question every piece of work:

| Question | Purpose |
|----------|---------|
| Is this a must-have for the new feature? | Core vs. peripheral |
| Could we ship without this? | Necessity test |
| What happens if we don't do this? | Impact assessment |
| Is this a new problem or pre-existing? | Scope boundary |
| How likely is this case to occur? | Probability filter |
| Which customers see it? How many? | Audience filter |
| Is it core (everyone) or edge case? | Priority filter |
| What's the actual impact? | Severity assessment |

### Must-Have vs Nice-to-Have

- **Must-have**: Task stays on scope. Scope not done until task finished.
- **Nice-to-have** (`~`): Done if time permits. Cut without guilt. Usually never built.

### QA Integration

- QA enters toward cycle end to find edge cases
- All QA-discovered issues are **nice-to-haves by default**
- Team triages and elevates to must-have only if truly critical
- Designers and programmers own basic quality — QA is a level-up, not a gate

### Extension Criteria

Extensions are **very rare** and require BOTH conditions:

1. Outstanding tasks are true must-haves that survived scope hammering
2. ALL remaining work is downhill (no unknowns, only execution)

If work is still uphill at cycle end → shaping problem. Return to shaping, do not extend.

---

## Phase 6: Ship and Move On

### Deployment

- Done means deployed. Not "ready for review" or "in staging."
- Small batch projects ship individually as completed within the cycle
- Testing and QA happen within the cycle, not after

### Post-Ship Rules

1. **Let the feedback storm pass** — Give it a few days. Don't react to initial noise.
2. **Stay debt-free** — Do not commit to changes based on initial feedback. Keep the clean slate.
3. **Feedback needs shaping** — Treat all post-ship feedback as raw ideas. They enter the shaping process like any other idea.
4. **No immediate promises** — "No" to immediate commitments preserves future freedom. "Yes" creates debt.

### Feedback Processing

```
Post-ship feedback arrives
  → Treat as raw idea (not commitment)
    → If truly important → Shape it on the shaping track
      → Compete at next betting table
        → If bet on → Build in future cycle
```

---

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| Assigning individual tasks | Disconnects team from big picture. Blinds to reality. |
| Pre-planning all tasks upfront | Imagined tasks ≠ discovered tasks. Plan will be wrong. |
| Horizontal layering (all design, then all code) | Nothing integrated until the end. High risk of late-stage failure. |
| Starting with peripheral features | Delays learning about core concept. Wastes time on non-essentials. |
| Pixel-perfect design before wiring | Wastes effort if approach doesn't work. |
| Organizing scopes by role | Hides real project structure. Prevents seeing big picture. |
| Extending projects with uphill work | Unknowns at deadline = shaping failure. Don't throw more time at it. |
| Reacting to post-ship feedback | Creates debt. Loses clean slate. Bypasses shaping process. |
| Estimating task duration | Estimates hide uncertainty. Use hill position instead. |
