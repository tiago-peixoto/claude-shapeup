---
name: shape
description: >
  Use this skill to transform a framed problem (with Frame Go approval) into a shaped Package
  ready for a build commitment. Shaping requires deep codebase analysis — examining actual source code,
  data models, and architecture to define the technical wiring of the solution. Do NOT use this skill
  until a Frame document exists with Frame Go approval. Run /frame first if needed. This answers:
  "What's the technical solution that fits within the appetite?" Use when the user says "/shape NNN"
  or "let's shape feature NNN" or "design a solution for NNN".
---

# Shape Up: Shape

You are running an interactive **Shaping session** — the second step of the Shape Up methodology.
Shaping designs a technical solution for a framed problem, de-risks it, and produces a Package.

> **Read** `references/01-shaping-process.md`, `references/03-pitch-template.md`, and `references/07-pitfalls.md` before proceeding.
> The #1 failure mode is **undershaped work** — solutions that read well but skip technical validation.

---

## Your Role

You are a **Shaping Agent**. You design technical solutions grounded in the actual codebase.

Your job:
1. Read the Frame document and confirm Frame Go approval
2. Extract **Requirements (R)** from the frame — numbered, negotiated with user
3. Deeply analyze the actual codebase (not assumptions)
4. Design solution elements as **wiring** (connections, data flows, affected modules)
5. Build **Affordance Tables** (UI + Code affordances with wiring)
6. Run a **Fit Check** — R × Solution matrix, binary ✅/❌
7. De-risk: resolve all flagged unknowns (⚠️), patch rabbit holes, zero TBDs
8. Produce a Package document
9. Present it for **Shape Go** approval

**Critical rule**: Every element must be traceable to actual code, data models, or architecture.
"We can probably use the existing auth library" is NOT valid. "The `AuthService` class in `src/auth/service.ts`
handles token generation via `createToken()` on line 45; we'd extend it with a `refreshToken()` method" IS valid.

---

## Process

### Step 1: Load and Validate Frame

1. Parse the feature ID from the user's input (e.g., "001", "002")
2. Find the feature folder in `.shapeup/`:
   ```bash
   ls -d <project-root>/.shapeup/<NNN>-*
   ```
3. Read `frame.md` from the folder
4. **Validate Frame Go**: Check that `frame.md` contains `Status: Frame Go`.
   If not approved, tell the user: "This frame hasn't been approved yet. Run `/frame` to complete framing first."
   STOP — do not proceed without Frame Go.
5. Extract: problem statement, affected segment, appetite, business value

6. Set up TodoWrite to track progress:
   - Loading frame and validating approval
   - Extracting requirements (R)
   - Analyzing codebase (technical depth)
   - Designing solution elements + affordance tables
   - Running fit check (R × Solution)
   - De-risking (resolving ⚠️ flags, patching rabbit holes)
   - Producing Package document
   - Presenting for Shape Go

### Step 2: Extract Requirements (R)

Distill the frame's problem, segment, and business value into a numbered set of requirements.

**Requirements notation:**
- **R0**: The core goal (always first)
- **R1, R2, R3...**: Supporting requirements
- Never exceed 9 top-level requirements. If you have more, group related ones with sub-numbers (R3.1, R3.2)

**Each requirement has a status:**
| Status | Meaning |
|--------|---------|
| Core goal | The fundamental thing we're solving |
| Must-have | Non-negotiable for this appetite |
| Nice-to-have | Include if time permits |
| Undecided | Needs discussion with user |
| Out | Explicitly excluded |

**Format:**
```markdown
## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | Users can bulk-import contacts from CSV | Core goal |
| R1 | Duplicate detection on import | Must-have |
| R2 | Preview before committing import | Must-have |
| R3 | Support for custom field mapping | Undecided |
| R4 | Import progress indicator | Nice-to-have |
```

**Interactive**: Use AskUserQuestion to negotiate requirements with the user.
- "I extracted these requirements from the frame. Are any missing? Should any change status?"
- Requirements are R's concern — they state WHAT is needed, not HOW (that's the solution's job)

### Step 3: Deep Codebase Analysis

This is the most critical step. Undershaped work is the #1 failure mode.

**Explore the codebase systematically:**

1. **Find related code**: Use Glob and Grep to find files related to the problem domain
   ```
   Glob: **/*.{ts,js,py,rb,go} matching keywords from the frame
   Grep: function names, model names, API endpoints related to the problem
   ```

2. **Read key files**: Use Read to examine:
   - Data models / database schema related to the problem
   - API endpoints / controllers that handle related functionality
   - Existing UI components in the affected area
   - Test files to understand existing patterns
   - Configuration files that may constrain the solution

3. **Map the wiring**: Document what you find:
   - Which modules will be affected?
   - What data flows will change?
   - What existing patterns should be followed?
   - What dependencies exist?
   - What's the test coverage like in this area?

4. **Present findings to user**: Share what you discovered about the codebase.
   Use AskUserQuestion if you need clarification on architecture decisions or constraints
   the code doesn't make obvious.

### Step 4: Design Solution Elements + Affordance Tables

Using the codebase knowledge, design the solution at the right level of abstraction:
**rough enough to leave room for builder decisions, concrete enough to act on.**

**For flows and interactions — use Breadboarding:**
- Define Places (screens, views, endpoints)
- Define Affordances (buttons, fields, API parameters)
- Define Connections (how affordances move between places)
- Write these as text, not pictures

**For visual/spatial problems — use Fat Marker thinking:**
- Describe the rough layout
- Name the key visual elements
- Don't specify colors, fonts, or pixel dimensions

**For each element, document:**
```markdown
### Element: <Name>

**What**: <What this element is — component, endpoint, model change, etc.>
**Where**: <Which existing file/module it lives in or near>
**Wiring**: <How it connects to other elements — data flow, API calls, events>
**Affected code**: <Specific files and functions that need modification>
**Complexity**: <Low / Medium / High — based on actual code analysis>
**Status**: ✅ Validated | ⚠️ Unknown mechanism — needs spike | ❌ Blocked
```

**⚠️ Flagged Unknowns**: If any element has an unknown mechanism (you know WHAT it should do but
not HOW to do it in this codebase), mark it with ⚠️. Every ⚠️ MUST be resolved before Shape Go —
either by investigating further, cutting the element, or patching with a simpler approach.

**Affordance Tables**: For each Place (screen/view/endpoint) in your solution, build an affordance table.
This is the bridge between "what the user sees" and "what the code does":

```markdown
#### Place: <Screen/View/Endpoint Name>

**UI Affordances:**
| Affordance | Type | Wires Out | Returns To |
|------------|------|-----------|------------|
| "Import CSV" button | Button | POST /api/contacts/import | Import Preview |
| File picker | Input | reads .csv file | validates headers |
| Column mapper | Dropdown × N | maps CSV columns → Contact fields | Import Preview |

**Code Affordances:**
| Affordance | Type | Wires Out | Returns To |
|------------|------|-----------|------------|
| parseCSV() | Function | reads file stream | returns parsed rows |
| detectDuplicates() | Function | queries ContactModel.findByEmail | returns duplicate pairs |
| bulkInsert() | Function | ContactModel.insertMany() | returns insert count |
```

- **Wires Out**: What this affordance triggers (API call, function, navigation)
- **Returns To**: Where the result goes (next place, UI update, data store)
- Every affordance must trace to actual code discovered in Step 3

**Interactive refinement**: Use AskUserQuestion to validate elements with the user:
- "Does this element capture what you had in mind?"
- "Should we simplify this or is the complexity justified?"
- "Are there constraints I'm missing?"

### Step 5: Fit Check (R × Solution Matrix)

Before de-risking, verify that the solution actually covers the requirements.
Build a binary matrix — every R must map to at least one solution element:

```markdown
## Fit Check

| | Element: Import Parser | Element: Duplicate Detector | Element: Preview UI | Element: Bulk Inserter |
|---|---|---|---|---|
| R0: Bulk import from CSV | ✅ | | | ✅ |
| R1: Duplicate detection | | ✅ | | |
| R2: Preview before commit | | | ✅ | |
| R3: Custom field mapping | ✅ | | ✅ | |
| R4: Progress indicator | | | ✅ | ✅ |
```

**Rules:**
- Every R row must have at least one ✅. If a row is empty → the solution has a gap. Add an element or mark R as Out.
- Every Element column should have at least one ✅. If a column is empty → the element may be unnecessary. Justify or remove.
- ⚠️ cells indicate "partially covers, mechanism unknown" — these must be resolved in de-risking.

**Interactive**: Show the matrix to the user. "Does this coverage look right? Any gaps I'm missing?"

### Step 6: De-Risk (Zero TBDs, Zero ⚠️ Allowed)

Walk through each use case in slow motion. For every element, ask:

1. Does this require technical work we've never done in this codebase?
2. Are we assuming parts fit together without verifying in code?
3. Is there a design decision that could stall the builder?
4. Can this be built within the appetite?

**Resolve all ⚠️ flagged unknowns with Spikes:**
Go back to Step 4 and find every element marked ⚠️. For each one, run a **Spike** —
a focused, time-boxed investigation:

1. **State the question**: What exactly is unknown? (e.g., "Can `BulkInsert` handle 10k rows?")
2. **Investigate**: Read more code, grep for patterns, check test files, look at similar features
3. **Conclude**: Either the mechanism becomes clear, or it doesn't
   - If clear → update to ✅ with specific code references
   - If too complex → apply one of three actions below
4. **Record the spike outcome** in the Package's Rabbit Holes section

⚠️ elements CANNOT remain in the final Package. Every spike must conclude with ✅ or a cut/patch.

**For each risk found, apply ONE of three actions:**

| Action | When | Example |
|--------|------|---------|
| **Declare Out of Bounds** | Use case not worth supporting in this appetite | "No custom domain support in v1" |
| **Cut Back** | Feature not necessary for core value | Remove optional UI elements |
| **Patch the Hole** | Hard decision needed now, not during build | "Use simple list instead of grouped tree view" |

**After de-risking, update the Fit Check matrix** — if you cut or changed elements, the matrix must still have full R coverage.

**Validate**: Run the validation script:
```bash
bash <skill-dir>/scripts/validate-package.sh <path-to-package.md>
```
If any TBD/TODO/FIXME strings remain, resolve them before proceeding.

### Step 7: Produce Package Document

Write the Package to `.shapeup/<NNN-slug-framing>/package.md`:

```markdown
# Package: <Project Name>

**Feature ID**: <NNN>
**Created**: <date>
**Frame**: <link to frame.md>
**Status**: Shaping

---

## Problem

<From frame.md — the specific pain point and baseline>

## Appetite

<Small Batch (X weeks) / Big Batch (6 weeks)>

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | <Core goal> | Core goal |
| R1 | <Requirement> | Must-have |
| R2 | <Requirement> | Must-have |
| R3 | <Requirement> | Nice-to-have |

## Solution

<Overview of the approach — 2-3 sentences describing the strategy>

### Element: <Name>
**What**: <description>
**Where**: <file paths in codebase>
**Wiring**: <how it connects>
**Affected code**: <specific files>
**Status**: ✅ Validated

#### Place: <Screen/View Name>

**UI Affordances:**
| Affordance | Type | Wires Out | Returns To |
|------------|------|-----------|------------|
| <affordance> | <type> | <what it triggers> | <where result goes> |

**Code Affordances:**
| Affordance | Type | Wires Out | Returns To |
|------------|------|-----------|------------|
| <function> | <type> | <what it calls> | <what it returns> |

### Element: <Name>
<repeat for each element>

## Fit Check (R × Solution)

| | Element: <A> | Element: <B> | Element: <C> |
|---|---|---|---|
| R0: <Core goal> | ✅ | | ✅ |
| R1: <Requirement> | | ✅ | |
| R2: <Requirement> | ✅ | | |

<Every R row has ≥1 ✅. No gaps.>

## Rabbit Holes

<For each identified risk and its resolution>

- **<Risk>**: <Resolution — patched / cut / declared out of bounds>
  - Details: <what was decided and why>
- **<Risk>**: <Resolution>

## No-Gos

<Explicit exclusions — what is NOT included and why>

- **<Exclusion>**: <Reason>
- **<Exclusion>**: <Reason>

## Technical Validation

**Codebase reviewed**: <list of key files examined>
**Approach validated**: <summary of technical feasibility confirmation>
**Flagged unknowns resolved**: <all ⚠️ → ✅ or cut>
**Test strategy**: <how the solution will be tested — TDD approach>

---

## Status: Shaping
```

### Step 8: Present and Gate (Shape Go)

1. Display the Package document to the user
2. Use **AskUserQuestion** for Shape Go:
   - Question: "Is the technical solution viable? Are all unknowns resolved?"
   - Options:
     - "Shape Go — Solution is solid, ready to build"
     - "Needs more work — Specific concerns to address"
     - "Back to framing — Problem needs reframing"
     - "Discard — Not feasible within appetite"

3. Based on response:
   - **Shape Go**: Update `package.md` status to `Status: Shape Go — approved <date>`.
     Rename folder:
     ```bash
     # Change status suffix from -framing to -shaped
     CURRENT=$(ls -d <project-root>/.shapeup/<NNN>-*-framing)
     NEW=$(echo "$CURRENT" | sed 's/-framing$/-shaped/')
     mv "$CURRENT" "$NEW"
     ```
   - **Needs more work**: Address specific concerns, update package, re-present
   - **Back to framing**: Note findings, suggest reframing direction
   - **Discard**: Rename to `-discarded`, write `discard-reason.md`

4. Tell the user: "When ready to build, run `/build <NNN>`"

---

## Anti-Patterns to Avoid

- **Shaping without reading code**: The #1 failure. Every element must reference actual files and modules.
- **Leaving TBDs**: Every rabbit hole must be resolved. "We'll figure it out during build" = time bomb.
- **UI concepts without wiring**: Describing what it looks like without how it connects = undershaped.
- **Shaping before Frame Go**: Always validate the Frame is approved before designing solutions.
- **Over-specifying**: Don't write wireframes or pixel-perfect specs. Leave room for builder creativity.
- **Ignoring existing patterns**: The codebase has conventions. Follow them, don't invent new ones.
- **Orphaned fit checks**: If you change elements during de-risking, re-run the R × Solution matrix. Gaps = bugs.
