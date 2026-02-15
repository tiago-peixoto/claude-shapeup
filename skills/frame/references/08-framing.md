# Framing

> Reference for AI agents performing the Framing role. Framing is the formal step BEFORE shaping that locks the problem, evaluates business value, and authorizes investment in shaping.

Source: Ryan Singer, "Framing" (Apr 2022) — an evolution of Shape Up based on real-world adoption.

---

## Why Framing Exists

The original Shape Up book placed the Betting Table after shaping. This created a problem: shapers couldn't justify spending time on rigorous technical shaping without knowing if the business valued the problem. The result was **undershaped work** — pitches that sold the idea but lacked technical rigor, leading to blown-up build cycles.

Framing solves this by establishing business commitment *before* shaping begins. It separates two distinct questions:

1. **Framing**: "Does this problem matter enough to invest in finding a solution?"
2. **Shaping**: "What's the technical solution that fits within the appetite?"

---

## What Framing Is

Framing is the work of challenging a problem, narrowing it down, and determining if the business has both interest and urgency to solve it.

It is **NOT**:
- Dragging items up and down a priority list
- Saying yes or no to feature requests
- Writing a solution or designing anything

It **IS**:
- Digging into what a request really means
- Identifying who is actually affected
- Evaluating whether now is the right time
- Quantifying the business value and opportunity
- Narrowing the problem to something specific and actionable

---

## What Happens in a Framing Session

A framing session involves a shaper and a product/business person investigating the problem together.

### Questions to Answer

- **Which customer segment is affected?**
- **How valuable is this segment compared to others?**
- **What other things are competing for attention in the business?**
- **What data supports (or contradicts) the urgency?**
- **What's the actual pain point vs. the stated feature request?**
- **Is this the right time, or are there dependencies or blockers?**

### Activities

- Pull up customer research data
- Run queries to quantify the problem (how many users affected, frequency, revenue impact)
- Review past feedback and support tickets
- Examine the customer segment and its strategic importance
- Challenge assumptions about urgency and value

### Output

A **well-framed problem** that can be stated as:

> "If we can shape this into something doable and execute within [X weeks], that will be meaningful to us."

This is a **commitment to spend time shaping**, but NOT yet a commitment to build.

---

## The Revised Pipeline

The original book's pipeline was:

```
Raw Idea → Shape → Pitch → Betting Table → Build
```

The evolved pipeline is:

```
Raw Idea → Frame → [Frame Go] → Shape → Package → [Betting Table] → Build
```

### Stage Definitions

| Stage | Input | Work | Output | Gate |
|-------|-------|------|--------|------|
| **Candidate** | Raw idea, feature request, complaint | None yet | — | — |
| **Framing** | Candidate | Problem investigation, business value analysis, segment analysis | Well-framed problem with appetite | **Frame Go**: Business says "this matters, invest in shaping" |
| **Shaping** | Framed problem | Technical solution design, de-risking, codebase analysis | Package (problem + solution + appetite + rabbit holes + no-gos) | **Shape Go**: Solution is viable, all unknowns resolved |
| **Betting Table** | Package | Strategic evaluation | Bet or pass | **Bet**: Commit team for one cycle |
| **Building** | Bet package | Execution | Deployed software | Ship |

### Terminology Update

| Old Term (Book) | New Term (Evolved) | Why |
|-----------------|-------------------|-----|
| Pitch | **Package** | Shaping output isn't a sales pitch anymore — it's a complete package of all variables (problem, solution, time, risks, boundaries). The business already bought in during framing. |
| (implicit in Ch. 3) | **Framing** | Now a named, explicit step with its own session, participants, and approval gate. |

"Pitching" better describes the **input to framing** — someone advocating that a problem deserves attention. The **output of shaping** is a Package: all the necessary variables for a project brought together.

---

## Framing for AI Agents

### Why Agents Need This

An agent given a feature request will default to designing a solution immediately. Without framing, the agent:
- Shapes work that the business may not value
- Produces solutions disconnected from business context
- Can't make intelligent scope trade-offs (doesn't know which customer segment matters or why)
- Risks the "shiny object" failure — work that gets cancelled mid-cycle because there was never real conviction

### Agent Framing Protocol

When an agent receives a raw idea or feature request:

```
1. CLASSIFY as Candidate
   → Do not design anything yet

2. INVESTIGATE the problem
   → What is the actual pain point? (not the stated feature request)
   → Who is affected? Which segment?
   → How many users / how frequently / what revenue impact?
   → What data supports or contradicts the urgency?
   → What's the baseline — how do users cope today?

3. EVALUATE business alignment
   → Does this align with current strategic priorities?
   → What else is competing for attention?
   → Is this the right time?

4. NARROW the problem
   → From generic request → specific, observable pain point
   → Reject grab-bags (must be a single problem)

5. SET appetite
   → How much time does this deserve? (Small Batch 1-2 weeks / Big Batch 6 weeks)
   → The appetite constrains everything downstream

6. PRODUCE the Frame
   → Problem statement (specific, story-based)
   → Affected segment and business value
   → Appetite
   → Statement: "If we can build [X] within [appetite], it will [business outcome]"

7. REQUEST Frame Go
   → Present frame to human decision-maker
   → Gate: "Is this worth investing shaping time in?"
   → Only proceed to shaping after approval
```

### Frame Document Template

```markdown
# Frame: [Short Name]

## Problem
[Specific story showing the pain point. Who is affected, what happens, what's the current workaround.]

## Affected Segment
[Which users/customers. How many. How valuable.]

## Business Value
[What changes if we solve this. Revenue, retention, efficiency, strategic positioning.]

## Evidence
[Data points, query results, support ticket counts, customer quotes — anything that quantifies the problem.]

## Appetite
[Small Batch X weeks / Big Batch 6 weeks]

## Frame Statement
"If we can shape this into something doable and execute within [appetite], it will [specific business outcome]."

## Status: Candidate / Frame Go / Rejected
```

---

## Relationship to Other Documents

- After **Frame Go**, proceed to the shaping process described in `01-shaping-process.md`
- The shaping output is now called a **Package** (not a Pitch) — see `03-pitch-template.md` for the format (the five ingredients remain the same)
- Framing failure modes are covered in `07-pitfalls.md` (Pitfall #2: Blurred framing and shaping)
- The full agent workflow incorporating framing is in `06-agent-workflow-guide.md`
