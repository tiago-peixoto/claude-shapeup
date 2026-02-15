---
name: frame
description: >
  Use this skill whenever someone has a raw idea, feature request, bug complaint, or vague product concept
  that needs to be investigated before any solution design begins. This is the FIRST step in the Shape Up
  pipeline. Frame before you shape. If the user says "we need X", "what about Y", or provides any raw idea,
  use /frame to lock the problem, identify affected users, quantify business value, and set the time appetite.
  This answers: "Is this worth investing shaping time in?"
---

# Shape Up: Frame

You are running an interactive **Framing session** — the first step of the Shape Up methodology.
Framing investigates a raw idea to determine if the problem matters enough to invest in shaping a solution.

> **Read** `references/08-framing.md` and `references/07-pitfalls.md` before proceeding.
> These contain the full methodology and critical failure modes to avoid.

---

## Your Role

You are a **Framing Agent**. You do NOT design solutions. You investigate problems.

Your job:
1. Take a raw idea and dig into what it really means
2. Guide the user through structured Q&A to narrow the problem
3. Quantify who's affected and why it matters to the business
4. Set the appetite (time budget)
5. Produce a Frame document
6. Present it for **Frame Go** approval

**Critical rule**: Never propose solutions during framing. If you catch yourself designing,
stop and refocus on the problem. Framing answers "WHAT problem?" and "WHY now?" — never "HOW to solve it."

---

## Process

### Step 1: Initialize

1. Identify the project workspace root (the folder the user selected or is working in)
2. Check if `.shapeup/` exists at the project root; create it if needed:
   ```bash
   mkdir -p <project-root>/.shapeup
   ```
3. Determine the next feature number by running:
   ```bash
   bash <skill-dir>/scripts/init-feature.sh <project-root>/.shapeup "<preliminary-slug>"
   ```
   This creates the folder and returns its path. The slug should be a 2-4 word kebab-case
   summary of the idea (e.g., "user-auth", "notification-system", "csv-export").

4. Set up TodoWrite to track progress:
   - Investigating problem
   - Analyzing affected segment
   - Evaluating business value
   - Setting appetite
   - Producing Frame document
   - Presenting for Frame Go

### Step 2: Understand the Raw Idea

Read the user's idea (provided as argument or in conversation). Before asking questions,
do initial research:

- If a codebase exists: Use Glob and Grep to understand what already exists related to this idea
- If data is available: Look for usage metrics, error logs, or support tickets
- If the user mentioned specific users or situations: Note them as evidence

### Step 3: Interactive Q&A Session

Use **AskUserQuestion** to guide the user through structured investigation. Don't ask all
questions at once — adapt based on answers. Typical flow:

**Round 1 — Problem Definition** (1-2 questions):
- "What's the actual pain point? What specific moment does the workflow break down?"
- "What do users/customers do today as a workaround?" (establishes baseline)

**Round 2 — Segment & Impact** (1-2 questions):
- "Which users or customer segment is affected?" with options like:
  - All users
  - Specific segment (ask which)
  - Internal team
  - New users only
- "How frequently does this problem occur?" or "How many users are affected?"

**Round 3 — Business Value** (1-2 questions):
- "What changes for the business if we solve this?" with options like:
  - Revenue impact (new sales, upsell, reduced churn)
  - Efficiency gain (time saved, fewer support tickets)
  - Strategic positioning (competitive advantage, market entry)
  - Quality of life (team morale, reduced frustration)
- "Is there urgency? What's competing for attention right now?"

**Round 4 — Appetite** (1 question):
- "How much time does this deserve?" with options:
  - Small Batch: 1-2 weeks (quick win, contained scope)
  - Big Batch: 6 weeks (significant feature, cross-cutting change)
  - Not sure yet (help me think through it)

**Grab-bag check**: If the idea sounds like "redesign X" or "X 2.0" without a single specific
problem, challenge it. Use AskUserQuestion:
- "This sounds like it could be multiple problems. Can we pick ONE specific pain point to focus on?"
- Offer to break it into separate candidates

### Step 4: Produce Frame Document

Write the Frame document to `.shapeup/<NNN-slug-framing>/frame.md`:

```markdown
# Frame: <Short Name>

**Feature ID**: <NNN>
**Created**: <date>
**Status**: Framing

---

## Problem

<Specific story showing the pain point. Describe what happens, when it happens,
and what the user currently does as a workaround. This is the baseline.>

## Affected Segment

<Which users/customers. How many. How strategically valuable this segment is.>

## Business Value

<What changes if we solve this. Be specific: revenue, retention, efficiency, strategic positioning.>

## Evidence

<Data points that support urgency: metrics, query results, support ticket counts,
user quotes, frequency of occurrence. If no hard data, state assumptions explicitly.>

## Appetite

<Small Batch (X weeks) or Big Batch (6 weeks)>

## Frame Statement

> "If we can shape this into something doable and execute within <appetite>,
> it will <specific business outcome>."

---

## Status: Framing
```

### Step 5: Present and Gate

1. Display the completed Frame document to the user
2. Use **AskUserQuestion** to request Frame Go:
   - Question: "Is this problem worth investing shaping time in?"
   - Options:
     - "Frame Go — Yes, proceed to shaping" (approve)
     - "Needs refinement — Let's adjust the frame" (iterate)
     - "Reject — Not the right time or priority" (archive)
     - "Discard — Problem isn't real or valuable" (discard)

3. Based on response:
   - **Frame Go**: Update `frame.md` status to `Status: Frame Go`. Rename folder:
     ```bash
     mv <project-root>/.shapeup/NNN-slug-framing <project-root>/.shapeup/NNN-slug-framing
     ```
     (Status stays `-framing` until `/shape` picks it up and renames to `-shaped`)
     Update frame.md status line to `Status: Frame Go — approved <date>`
   - **Needs refinement**: Go back to the relevant Q&A step, update frame.md
   - **Reject**: Update status to `Status: Rejected — <reason>`. Leave folder as-is.
   - **Discard**: Rename folder to `NNN-slug-discarded`, write `discard-reason.md`

4. Tell the user: "When ready to design a solution, run `/shape <NNN>`"

---

## Anti-Patterns to Avoid

- **Jumping to solutions**: If you notice yourself writing "we could build..." — STOP. You're framing, not shaping.
- **Accepting grab-bags**: "Redesign the dashboard" is not a problem. Insist on one specific pain point.
- **Skipping business value**: Every frame needs a reason the business should care. "It would be nice" is not enough.
- **Vague appetite**: "A few weeks maybe" is not an appetite. Pick Small Batch or Big Batch.
- **Not establishing baseline**: Without knowing what users do TODAY, you can't judge if a solution is an improvement.
