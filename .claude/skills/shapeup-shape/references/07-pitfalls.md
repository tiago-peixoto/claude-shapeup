# Shape Up Pitfalls for Agents

> Critical failure modes identified by Ryan Singer (Shape Up creator) in real-world adoption. These pitfalls are especially dangerous for AI agents because agents will follow instructions literally and lack the institutional intuition that helps humans course-correct.

Source: Ryan Singer, "Common Pitfalls When Adopting Shape Up" (Oct 2025)

---

## Pitfall 1: Shaping Without Technical Depth

### The Trap

The book says shaping is "primarily design work." But the people at Basecamp who shaped were deeply technical. When non-technical people shape, the work is **undershaped** — full of unanswered technical questions that explode during build.

> This is the #1 failure mode of Shape Up adoption.

### Why Agents Are Especially Vulnerable

An agent shaping a feature will default to describing *what* should exist (product/design language) without verifying *how* it connects to the actual codebase, data model, APIs, and infrastructure. An agent can produce a pitch that reads well but contains hidden time bombs — assumptions about technical feasibility that were never validated.

### Rules for Agents

1. **Shaping must include technical analysis.** Before writing a pitch, the agent must examine the actual codebase, data models, and existing architecture.

2. **The output is wiring, not styling.** Think blueprint — where the walls go, where the pipes connect. NOT the paint color or tile choice. The pitch must describe:
   - Where the feature connects to existing systems
   - What data flows where
   - What existing code is affected
   - What new technical primitives are required

3. **Every rabbit hole is a time bomb.** Any rabbit hole left unresolved in the pitch WILL blow up during build. Agents must not leave rabbit holes as "TBD" — they must be patched, cut, or declared out of bounds.

4. **High fidelity last.** Build raw and ugly first. Meet functional and interaction requirements. Style literally in the final days of the cycle. This is painting the walls after construction is done.

### Agent Checklist — Technical Depth

Before finalizing any pitch:

- [ ] Reviewed relevant source code and data models
- [ ] Identified which existing modules/files are affected
- [ ] Confirmed technical approach is feasible within appetite (not just "possible")
- [ ] Every rabbit hole has a resolution (patched, cut, or out of bounds) — zero TBDs
- [ ] Solution describes wiring and connections, not just UI concepts

---

## Pitfall 2: Blurred Framing and Shaping

### The Trap

The book doesn't clearly distinguish between two separate work steps:

- **Framing**: Defining the problem, the business value, and the desired outcome
- **Shaping**: Designing the technical solution within the appetite

When these blur together, projects go in circles, spiral in scope, or get cancelled mid-cycle ("shiny object syndrome") because there was never real conviction about what problem was being solved.

### Why Agents Are Especially Vulnerable

An agent given "we need feature X" will jump straight to designing a solution without first locking down what problem is being solved and why it matters. This produces pitches that are technically sound but strategically unanchored — there's no way to evaluate whether the solution actually addresses the right pain point, or to make scope trade-offs when time gets tight.

### The Fix: Separate Framing from Shaping

**Framing** (= Chapter 3 "Set Boundaries" in the book):
- What problem are we solving?
- For whom?
- What's the business value / desired outcome?
- What's the appetite?

**Shaping** (= Chapters 4-5 in the book):
- What's the technical solution?
- What are the elements?
- What are the risks?

### Status Terminology

Use these explicit states instead of vague terms:

| Status | Definition |
|--------|-----------|
| **Candidate** | A request or idea that hasn't been framed yet. Raw material. |
| **Frame Go** | Problem and outcome are locked. Aligned on WHAT we're solving and WHY. Ready to shape a solution. |
| **Shape Go** | Technical solution defined. No material unknowns. Ready to hand to a builder. |

### Rules for Agents

1. **Always frame before shaping.** When receiving a raw idea, produce a Frame document first. Do not design solutions until the problem is locked.

2. **Separate the questions.** "Are we working on the problem or on the solution?" If the problem isn't tight, stop and tighten it. Don't compensate with a better solution.

3. **Use explicit checkpoints.** An agent must confirm Frame Go before proceeding to shaping. An agent must confirm Shape Go before producing a final pitch.

4. **Name the documents clearly.** Use "Frame" for problem/outcome definition. Use "Shape" for the technical solution. Avoid ambiguous terms like "one-pager" or "spec."

### Agent Checklist — Framing vs Shaping

Before shaping:
- [ ] Problem is specific and story-based (not generic feature request)
- [ ] Business value / desired outcome is stated
- [ ] Appetite is set
- [ ] Frame Go confirmed (problem is tight enough to design a solution for)

Before pitching:
- [ ] Solution addresses the framed problem specifically
- [ ] No material technical unknowns remain
- [ ] Shape Go confirmed (a builder could pick this up and know what to do)

---

## Pitfall 3: Mixing Project Work with Reactive Work

### The Trap

If shaped project work and reactive work (bugs, incidents, urgent requests, third-party dependencies) share the same queue and the same team, focus is destroyed. Too much WIP, unclear priorities, and no way to measure real capacity.

### Why Agents Are Especially Vulnerable

An agent managing a build cycle will encounter bug reports, urgent requests, and external blockers. Without explicit separation rules, the agent will treat everything as equal priority — interleaving reactive fixes with shaped project work, losing focus, and putting the cycle at risk.

### Rules for Agents

1. **Separate the streams completely.** Shaped project work and reactive work are different processes with different tracking.

2. **Classification rules for incoming work:**

   | Type | Criteria | Handling |
   |------|----------|----------|
   | **Shaped project work** | Has a pitch. Has been bet on. Has a cycle deadline. | Execute within cycle. Full focus. |
   | **Urgent / on-fire** | Active incident. Upset stakeholder. System down. | Separate capacity. Kanban-style. Track separately. |
   | **Non-urgent bug** | Bug that isn't on fire. No immediate stakeholder pressure. | Batch for cool-down or rainy day. Do NOT mix into cycle. |
   | **Third-party dependent** | Waiting on external response. Agent doesn't control timeline. | Kanban, not Shape Up. Don't put in a cycle because you can't guarantee the deadline. |

3. **Never let reactive work silently consume cycle time.** If reactive work is eating into a cycle, surface it explicitly. The cycle scope must be adjusted or the reactive work must be deferred.

4. **Make capacity allocation explicit.** If a team (or agent) splits time between project and reactive work, define the split upfront (e.g., "80% project, 20% reactive buffer"). Measure actuals against plan.

---

## Summary: The Three Traps Agents Will Fall Into

| Pitfall | Agent Behavior | Fix |
|---------|---------------|-----|
| **Undershaped work** | Agent produces pitches that read well but skip technical validation | Require codebase analysis. Every rabbit hole resolved. Wiring, not styling. |
| **Blurred framing/shaping** | Agent jumps to solutions before locking the problem | Enforce Frame Go checkpoint before any solution design |
| **Mixed work streams** | Agent interleaves bugs and urgent requests with cycle work | Classify all incoming work. Separate streams. Explicit capacity. |

These aren't edge cases — they are the most common failure modes in Shape Up adoption. Agents must have explicit guardrails against all three.
