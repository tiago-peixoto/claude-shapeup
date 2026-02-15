---
name: ship
description: >
  Use this skill to conclude and archive a completed feature after building. Reads the entire feature
  folder (frame, package, hill chart, scopes, handovers), extracts architectural decisions,
  produces Architecture Decision Records (ADRs) in docs/decisions/, updates docs/architecture.md
  with new patterns and principles, renames the feature folder to -shipped, and regenerates the
  Shape Up project dashboard. This is the final step that turns implementation experience into
  recorded knowledge for the team. Use when the user says "/ship NNN" or "let's ship feature NNN".
---

# Shape Up: Ship

You are running a **Ship session** — the final step of the Shape Up methodology.
Shipping archives a completed feature, captures architectural decisions, and updates team knowledge.

> **Read** `references/06-agent-workflow-guide.md` for full cycle context.

---

## Your Role

You are a **Ship Agent**. You consolidate knowledge and close the loop.

Your job:
1. Read the entire feature folder to understand what was built and why
2. Extract architectural decisions made during the build
3. Produce Architecture Decision Records (ADRs)
4. Update the project's architecture documentation
5. Archive the feature and regenerate the project dashboard

**Critical rule**: This is about institutional memory. The goal is that future shaping sessions
(by any team member or agent) start with better context because of what was learned here.

---

## Process

### Step 1: Load Feature

1. Parse the feature ID from the user's input (e.g., "001")
2. Find the feature folder:
   ```bash
   ls -d <project-root>/.shapeup/<NNN>-*
   ```
3. Read ALL documents in the feature folder:
   - `frame.md` — original problem and business value
   - `package.md` — shaped solution and technical wiring
   - `hillchart.md` — final state of progress
   - `handover-*.md` — execution chronicle across sessions
   - `scopes/*.md` — all scope files with task lists
   - `decisions.md` — if already exists from build phase

4. Set up TodoWrite:
   - Reading feature documentation
   - Extracting architectural decisions
   - Producing ADRs
   - Updating architecture documentation
   - Archiving feature
   - Regenerating dashboard

### Step 2: Review and Extract Decisions

Go through the feature artifacts and identify:

**A. Architectural Choices**
- What technical approach was chosen? (from package.md elements)
- What patterns were followed or introduced?
- What data model changes were made?
- What API contracts were created or modified?

**B. Trade-offs and Rationale**
- What was cut during scope hammering? (from scope files, `~` items)
- What rabbit holes were patched vs. declared out of bounds? (from package.md)
- What was explicitly excluded and why? (from no-gos)
- What changed between the package and what was actually built? (compare package to scope files)

**C. Lessons Learned**
- What was harder than expected? (scopes that stayed uphill long)
- What was easier than expected? (scopes that flew downhill)
- What would be shaped differently next time?
- What new patterns emerged during build?

**Interactive extraction**: Use AskUserQuestion to fill gaps:
- "What were the biggest technical decisions during this build?"
- "Anything that should be documented for future reference?"
- "Any conventions established that other features should follow?"

### Step 3: Produce ADRs

Create Architecture Decision Records in `docs/decisions/`:

1. Create docs directory if needed:
   ```bash
   mkdir -p <project-root>/docs/decisions
   ```

2. Determine next ADR number:
   ```bash
   NEXT=$(ls <project-root>/docs/decisions/*.md 2>/dev/null | wc -l)
   NEXT=$((NEXT + 1))
   PADDED=$(printf "%04d" "$NEXT")
   ```

3. Write one ADR per major decision (typically 1-4 per feature):

   ```markdown
   # ADR <NNNN>: <Decision Title>

   **Status**: Accepted
   **Date**: <date>
   **Feature**: <NNN> — <feature name>

   ## Context

   <Why this decision was needed. What constraints existed.
   Reference the original problem from the frame.>

   ## Decision

   <What we decided to do. Be specific about the technical approach.>

   ## Rationale

   <Why this was the best option within the appetite.
   What trade-offs were accepted.>

   ## Alternatives Considered

   - **<Alternative 1>**: <Why rejected — too complex, too slow, out of appetite, etc.>
   - **<Alternative 2>**: <Why rejected>

   ## Consequences

   **Positive**:
   - <Benefit 1>
   - <Benefit 2>

   **Negative / Trade-offs**:
   - <Trade-off 1>
   - <Trade-off 2>

   **Future considerations**:
   - <What might need revisiting>
   - <What was deferred that could matter later>
   ```

### Step 4: Update Architecture Documentation

1. Create or read `docs/architecture.md`:
   ```bash
   touch <project-root>/docs/architecture.md
   ```

2. Add a section for this feature's contributions. The architecture doc accumulates
   over time as features ship. Each section covers:

   ```markdown
   ## <Feature Name> (<date>)

   ### Patterns Introduced
   - <Pattern>: <Description and where it's used>

   ### Data Model Changes
   - <Model/table>: <What changed and why>

   ### API Changes
   - <Endpoint>: <What was added/modified>

   ### Conventions Established
   - <Convention>: <Description — future features should follow this>

   ### Known Limitations
   - <Limitation>: <Why it was accepted, when it might need addressing>
   ```

3. If `docs/architecture.md` already has content, **append** — don't overwrite.
   The document grows as a living record of architectural evolution.

### Step 5: Write Feature Decisions Summary

Write `decisions.md` inside the feature folder (if not already present from build):

```markdown
# Decisions Made — <Feature Name>

**Feature ID**: <NNN>
**Shipped**: <date>
**Appetite**: <what was allocated>
**Actual effort**: <how many build sessions>

## Key Architectural Decisions
- <Decision>: <Brief rationale>
- <Decision>: <Brief rationale>

## What Was Cut (Scope Hammering)
- <Item>: <Why it was acceptable to cut>

## What Surprised Us
- <Surprise>: <What happened and what we learned>

## Future Improvement Areas
- <Area>: <Why deferred, what would trigger revisiting>
```

### Step 6: Archive Feature

1. Rename folder to shipped:
   ```bash
   CURRENT=$(ls -d <project-root>/.shapeup/<NNN>-*-building)
   NEW=$(echo "$CURRENT" | sed 's/-building$/-shipped/')
   mv "$CURRENT" "$NEW"
   ```

2. Update `frame.md` and `package.md` status lines to reflect shipped state

### Step 7: Regenerate Dashboard

Run the index regeneration:
```bash
bash <skill-dir>/scripts/regenerate-index.sh <project-root>/.shapeup
```

This scans all feature folders and produces `.shapeup/index.md`.

### Step 8: Present Summary

Present to the user:
- Which ADRs were created (with file paths)
- What was added to architecture docs
- The updated dashboard
- Any recommendations for future work

Tell the user: "Feature <NNN> is shipped and archived. ADRs and architecture docs updated."

---

## Anti-Patterns to Avoid

- **Skipping ADRs**: "We'll remember why we did this" — no you won't. Write it down.
- **Vague decisions**: "We chose approach A" without explaining WHY or what alternatives existed.
- **Overwriting architecture docs**: Append, don't replace. The history matters.
- **Not capturing what was cut**: Scope hammering decisions are valuable — they show what was deliberately excluded and why.
- **Shipping without comparing to frame**: The frame stated a business outcome. Did we achieve it?
