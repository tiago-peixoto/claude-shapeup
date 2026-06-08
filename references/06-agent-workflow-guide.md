# Shape Up for AI Agents: Workflow Guide

> Master reference for implementing the Shape Up methodology with AI agent systems. Maps Shape Up roles and processes to agent capabilities.

---

## Shape Up Roles Mapped to Agents

| Shape Up Role | Agent Type | Responsibility |
|---------------|-----------|----------------|
| **Framer** | Framing Agent | Investigates raw ideas. Narrows problem, evaluates business value, produces Frame document. Gate: Frame Go. (See `08-framing.md`) |
| **Shaper** | Shaping Agent | Transforms framed problems into packages. Finds elements, de-risks with codebase analysis, writes packages. Gate: Shape Go. |
| **Betting Table** | Orchestrator / Human | Decides which packages to commit resources to. Requires human judgment for strategic prioritization. |
| **Builder (Designer)** | Design Agent | Creates affordances, UI structure, interaction flows. Works at breadboard level first, refines later. |
| **Builder (Programmer)** | Coding Agent | Implements backend, wires affordances, deploys. Builds strategically patchy scaffolding. |
| **QA** | Verification Agent | Finds edge cases in completed scopes. All findings are nice-to-haves by default. |

---

## Agent Workflow: The Full Pipeline

### Shaping Track

**WARNING: The #1 failure mode is undershaped work. See `07-pitfalls.md`.**

```
PIPELINE: Candidate → Frame Go → Shape Go → Bet → Build → Ship

1. INTAKE
   Agent receives raw idea or feature request.
   Default stance: "Interesting. Maybe some day." — do not commit.
   Status: CANDIDATE

2. FRAME (problem + business value, NOT solution) — See 08-framing.md
   → Investigate: What's the actual pain point? Who's affected? What segment?
   → Quantify: How many users, how often, what revenue/retention impact?
   → Evaluate: Does this align with current priorities? Is now the right time?
   → Narrow: From generic request → specific, observable pain point
   → Set appetite: Small Batch (1 session) / Medium Batch (2-3 sessions) / Big Batch (4-5 sessions)
   → Reject grab-bags: No "redesign X" without a single defined problem
   → Produce Frame document (see template in 08-framing.md)
   → CHECKPOINT: Present to human. "Is this worth investing shaping time in?"
   Status: FRAME GO

3. ELEMENTS (with technical depth)
   → Breadboard: Define places, affordances, connections (for flows)
   → Fat marker: Rough spatial layout (for visual problems)
   → Output: Wiring — how things connect, what data flows where, what code is affected
   → NOT just UI concepts. Must describe the blueprint, not the rendering.

4. DE-RISK (zero TBDs allowed)
   → Review actual codebase, data models, existing architecture
   → Walk through use case step by step
   → For each element: Is it technically feasible IN THE APPETITE?
   → Apply: Declare out of bounds / Cut back / Patch holes
   → Every rabbit hole must have a resolution. Unresolved = time bomb.
   → CHECKPOINT: Could a builder pick this up and know what to do?
   Status: SHAPE GO

5. PACKAGE (evolved term for "Pitch")
   → Write document with 5 ingredients:
     Problem | Appetite | Solution | Rabbit Holes | No-Gos
   → This is not a sales pitch — business already bought in at Frame Go
   → This is a complete package of all project variables
   → Submit to Betting Table for final approval
```

### Building Track

**WARNING: Never mix reactive work into build sessions. See `07-pitfalls.md`.**

```
SESSION 1: ORIENT + FIRST PIECE
├── Study package, explore codebase, identify approach
├── Pick first piece (core + small + novel)
├── Integrate first piece vertically (UI + backend)
└── Milestone: One clickable, working piece

SESSION 1-2: MAP SCOPES
├── Discover scopes through real work (not upfront planning)
├── Name scopes with project-specific language
├── Classify behaviors (RED→GREEN slices): must-have vs nice-to-have (~)
└── Validate: Can you see the whole project? Do scope names feel natural?

MIDDLE SESSIONS: EXECUTE + TRACK
├── Push riskiest scopes uphill first
├── Validate approaches with real code (not theory)
├── Update hill chart positions for each scope
├── Scope hammer continuously: question every new task
└── Priority: unknowns first, routine last

FINAL SESSION: CONVERGE + SHIP
├── All scopes should be downhill
├── Scope hammer aggressively: cut anything not must-have
├── Compare to baseline: is this better than what exists?
├── Deploy
└── Do not commit to post-ship feedback
```

### Reactive Work Classification (runs separately from build)

Incoming work during a build must be classified before acting:

```
Incoming item →
  Is it a shaped, bet-on project?
    YES → Build work. Execute within allocated sessions.
  Is it an active incident / system down / upset stakeholder?
    YES → Urgent. Handle on separate capacity (kanban). Track separately.
  Is it a bug that isn't on fire?
    NO  → Batch for later. Do NOT mix into active build.
  Does it depend on third-party response?
    YES → Track separately. You don't control the timeline.
```

Never let reactive work silently consume session time. If it's eating into the build, surface it and adjust scope explicitly.

### Post-Build

```
1. Treat all feedback as raw ideas
2. Do not promise changes
3. Important feedback → enters shaping track
4. Unimportant feedback → "Interesting. Maybe some day."
```

---

## Agent Decision Rules

### When Shaping

| Situation | Rule |
|-----------|------|
| Idea is vague | Narrow to specific pain point before proceeding |
| Idea is too big for 5 sessions | Decompose into independent pieces |
| Idea is a grab-bag ("redesign X") | Reject. Require specific problem statement. |
| Technical feasibility uncertain | Validate within appetite, not in abstract |
| Can't find simple solution | Cut scope, not timeline. Appetite is fixed. |
| Multiple approaches exist | Choose the one with fewest unknowns within appetite |

### When Building

| Situation | Rule |
|-----------|------|
| Don't know where to start | Pick the most core, small, novel piece |
| Task seems necessary but not core | Apply scope hammering questions. Likely nice-to-have. |
| Scope is stuck on hill chart | Split into smaller scopes or investigate the unknown |
| New requirement discovered | Default: nice-to-have. Elevate only if truly critical. |
| Running out of time | Cut nice-to-haves. Ship must-haves. Compare to baseline. |
| Work is still uphill at final session | Shaping failure. Do not extend. Return to shaping. |
| QA finds issues | Nice-to-haves by default. Triage for severity. |
| Post-ship feedback arrives | Raw idea. Do not commit. Shape if important. |

### Progress Assessment

| Signal | Health | Action |
|--------|--------|--------|
| Session 1: First piece integrated | Healthy | Continue |
| Session 1-2: Scopes mapped, riskiest uphill | Healthy | Push risks over hill |
| Mid-build: Riskiest scopes downhill | Healthy | Execute remaining scopes |
| Mid-build: Most scopes downhill | Healthy | Begin convergence |
| Final session: Everything downhill | Healthy | Polish and ship |
| Session 2: No integrated piece yet | Warning | Investigate blockers |
| Mid-build: Scopes still stuck uphill | Danger | Split scopes, scope hammer |
| Final session: Scopes still uphill | Critical | Cannot extend. Shaping failure. |

---

## Key Constraints for Agents

1. **Never extend the timeline.** The appetite is fixed. Only scope flexes.
2. **Never commit to unproven approaches.** Validate with code, not theory.
3. **Never accept grab-bags.** Every project needs a specific problem.
4. **Never skip de-risking.** Walk through use cases before building.
5. **Never organize by role.** Organize by scope (independent, finishable units).
6. **Never start with peripheral features.** Start with core + small + novel.
7. **Never estimate tasks.** Track uncertainty (hill position) instead.
8. **Nice-to-haves are the pressure valve.** Mark liberally with `~`. Cut freely.
9. **Compare to baseline, not ideal.** Ship when better than today, not when perfect.
10. **Feedback is raw material.** Never commit to post-ship changes. Shape them first.
11. **Never shape without technical depth.** Review actual code, data models, architecture. Wiring, not styling. (#1 failure mode — see `07-pitfalls.md`)
12. **Never shape before framing.** Lock the problem before designing the solution. Candidate → Frame Go → Shape Go.
13. **Never leave rabbit holes as TBD.** Every unresolved rabbit hole detonates during build. Patch, cut, or declare out of bounds.
14. **Never mix reactive work into build sessions.** Bugs, incidents, and third-party-dependent work are separate streams with separate tracking.

---

## Betting Table Input Format

When presenting a Package for betting decision:

```
PACKAGE: [Project Name]
PROBLEM: [One-sentence pain point]
SEGMENT: [Who's affected, how many, business value]
APPETITE: [Small Batch 1 session / Medium Batch 2-3 sessions / Big Batch 4-5 sessions]
SOLUTION: [Key elements, 2-3 sentences — wiring, not styling]
RISKS ADDRESSED: [How rabbit holes were handled — zero TBDs]
EXCLUDED: [What's NOT included]
FRAME STATUS: Frame Go (approved on [date/by whom])
SHAPE STATUS: Shape Go (all unknowns resolved)
```

## Hill Chart Status Format

When reporting progress:

```
BUILD: [Name] — Session [X] of [N]

SCOPES:
  ▲ [Scope Name] — Uphill (investigating approach)
  ▲ [Scope Name] — Uphill (validated, near peak)
  ▼ [Scope Name] — Downhill (executing known work)
  ▼ [Scope Name] — Downhill (nearly done)
  ✓ [Scope Name] — Done (deployed)
  ~ [Scope Name] — Nice-to-have (cut if needed)

RISK: [Riskiest scope and its status]
NEXT: [What the team is pushing uphill next]
```
