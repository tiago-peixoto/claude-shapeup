---
name: ship
description: >
  Use this skill to conclude and archive a completed feature after building. Reads the entire feature
  folder (frame, package, hill chart, scopes, handovers), extracts architectural decisions,
  produces Architecture Decision Records (ADRs) in docs/decisions/, updates docs/architecture.md
  with new patterns and principles, renames the feature folder to -shipped, and regenerates the
  Shape Up project dashboard. This is the final step that turns implementation experience into
  recorded knowledge for the team. Use when the user says "/ship NNN" or "let's ship feature NNN".
allowed-tools: Bash Read Write Edit Glob Grep
---

# Shape Up: Ship

You are running a **Ship session** — the final step of the Shape Up methodology.
Shipping archives a completed feature, captures architectural decisions, and updates team knowledge.

> **Reference Index** — Read only what you need, when you need it.
>
> | File | Contains | When to read |
> |------|----------|-------------|
> | `../../references/06-agent-workflow-guide.md` | Full pipeline overview, role mapping, status formats | **Read now** — core context for archival |
> | `../../references/00-glossary.md` | Shape Up terminology definitions | Read if you encounter an unfamiliar term |
> | `../../references/03-pitch-template.md` | Package format (5 ingredients) | Read if you need to interpret the Package structure |
> | `../../references/01-shaping-process.md` | How shaping works | Read if you need context for extracting shaping decisions |
> | `../../references/02-building-process.md` | How building works | Read if you need context for extracting build decisions |
> | `../../references/07-pitfalls.md` | Three critical failure modes | Read if you need to document lessons learned |
> | `../../references/04-scope-hammering-rules.md` | Scope cutting decisions | Read if you need to document what was cut and why |
> | `../../references/05-hill-chart-protocol.md` | Progress tracking model | Not needed during shipping |
> | `../../references/08-framing.md` | Framing methodology | Not needed during shipping |
>
> **Do NOT read all references upfront.** Read the "Read now" file, then consult others only when a specific question arises during the session.

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

## Paths and Variables

Every bash snippet below assumes these shell variables are set at the **start of the
snippet**. Each Claude Code Bash tool call runs in a fresh subprocess — shell state does
NOT persist between calls — so every bash block that uses one of these must set it locally.

- **`<project-root>`**: the user's working repository, where `.shapeup/` lives.
  Resolves to `"${CLAUDE_PROJECT_DIR:-$(pwd)}"`.
- **`<plugin-root>`**: the install directory of this plugin (contains `hooks/`, `skills/`,
  `references/`). Resolves to `"${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"`.
- **`<skill-dir>`**: this skill's directory, equal to `$PLUGIN_ROOT/skills/ship`.
- **`<feature-dir>`** / **`$FEATURE_DIR`**: the resolved feature folder. Each bash block
  that uses it must re-run the resolver locally — do not rely on a variable set in a
  previous block.
- **`<KEY>`** / **`$KEY`**: the feature key the user typed (date-slug, short slug, or
  legacy NNN).

Standard bash prelude — paste at the top of any snippet that needs these:

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SKILL_DIR="$PLUGIN_ROOT/skills/ship"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
KEY="<feature key the user typed>"
FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
```

---

## Process

### Step 0: Verify Prior State (Trust but Verify)

Before archiving, **dispatch an Explore subagent** to verify the build actually shipped what
the tracking documents claim. Agents that skip this step produce ADRs for features that were
silently left half-done, because `build-summary.md` said "shipped" when the code didn't.

1. Resolve the feature folder:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   echo "$FEATURE_DIR"
   ```

2. Dispatch an Explore subagent with this question: for every must-have behavior marked
   `[GREEN]` in every `scope-*.md` file, is there corresponding code, tests, and (for web
   projects) a working UI affordance that makes the user-noticeable behavior observable?
   Report any `[GREEN]` behavior marked without evidence (and any must-have behavior still
   `[RED]`).

3. Run the pre-ship consistency check:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$PLUGIN_ROOT/hooks/lib/check-consistency.sh" "$FEATURE_DIR" pre-ship
   ```
   If any FAIL appears, STOP. Tell the user the feature is not actually ready to ship and
   either send them back to `/build <KEY>` to finish the RED must-have behaviors or mark the
   remaining behaviors cut (with `~`) and commit that decision before re-running `/ship`.

### Step 1: Load Feature

1. Use the `$FEATURE_DIR` resolved in Step 0 (re-resolve with the standard prelude).
2. **Check for build summary first** (token-efficient path):
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   cat "$FEATURE_DIR/build-summary.md" 2>/dev/null
   ```
   - **If `build-summary.md` exists**: Read it + `frame.md` + `package.md`.
     The build summary contains cuts, files changed, and lessons learned.
     The package is needed to compare what was planned vs what was built for ADRs.
     Skip handovers, scopes, and hillchart — the summary covers them.
   - **If `build-summary.md` does NOT exist** (older features): Fall back to reading all:
     - `frame.md` — original problem and business value
     - `package.md` — shaped solution and technical wiring
     - `hillchart.md` — final state of progress
     - `handover-*.md` — execution chronicle across sessions
     - `scopes/*.md` — all scope files with task lists
     - `decisions.md` — if already exists from build phase

3. Set up TodoWrite:
   - Verifying prior state (subagent audit + pre-ship check)
   - Reading feature documentation
   - Extracting architectural decisions
   - Producing ADRs
   - Updating architecture documentation
   - Archiving feature
   - Regenerating dashboard

### Step 2: Review and Extract Decisions

If `decisions.md` already exists from the build phase, read it first. Use it as a starting
point — only ask interactive questions to fill gaps, not to recreate work already captured.

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
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   mkdir -p "$PROJECT_ROOT/docs/decisions"
   ```

2. Determine next ADR number:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   NEXT=$(ls "$PROJECT_ROOT/docs/decisions/"*.md 2>/dev/null | wc -l)
   NEXT=$((NEXT + 1))
   PADDED=$(printf "%04d" "$NEXT")
   echo "$PADDED"
   ```

3. Write one ADR per major decision (typically 1-4 per feature).

   **Write an ADR only if the decision meets at least one of these criteria:**
   - It involved choosing between 2+ materially different approaches
   - It deferred work or accepted a known limitation
   - It introduces a pattern the team should replicate in future features

   Routine implementation details ("we used async/await", "we followed the existing REST pattern")
   don't need ADRs — they're conventions, not decisions.

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

   <example>
   # ADR 0003: Polling-Based Lead Notifications Instead of WebSockets

   **Status**: Accepted
   **Date**: 2026-04-15
   **Feature**: 007 — lead-alerts

   ## Context

   Sales reps miss time-sensitive leads because they only check the dashboard twice daily.
   The frame established that ~2 deals/month are lost to stale leads. We needed a way to
   surface new leads within minutes, not hours.

   ## Decision

   Implemented 60-second polling from the dashboard to GET /api/leads?since=<timestamp>,
   with a badge counter in the nav bar. No WebSocket infrastructure.

   ## Rationale

   WebSockets would deliver sub-second updates but require new infrastructure (connection
   management, reconnection logic, load balancer config). Within a Medium Batch appetite,
   polling delivers "minutes not hours" — which matches the frame's need — without the
   infrastructure overhead.

   ## Alternatives Considered

   - **WebSockets**: Real-time but out of appetite — estimated 2 extra sessions for infrastructure alone
   - **Server-Sent Events**: Simpler than WebSockets but still requires server-side connection management
   - **Email notifications**: No code change needed but doesn't solve the "already in the app" workflow

   ## Consequences

   **Positive**:
   - Zero infrastructure changes — uses existing REST endpoints
   - Works with current load balancer configuration

   **Negative / Trade-offs**:
   - 60-second latency (vs sub-second with WebSockets)
   - Adds ~1 req/min/user to API load

   **Future considerations**:
   - If user count grows past 500 concurrent, polling load may justify WebSocket migration
   - Could reduce interval to 30s if 60s proves too slow for sales workflow
   </example>

### Step 4: Update Architecture Documentation

1. Create or read `docs/architecture.md`:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   touch "$PROJECT_ROOT/docs/architecture.md"
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
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   NEW=$(echo "$FEATURE_DIR" | sed 's/-building$/-shipped/')
   mv "$FEATURE_DIR" "$NEW"
   ```

2. Update `frame.md` and `package.md` status lines to reflect shipped state (the new
   path is `$NEW` from the snippet above; subsequent steps re-run the resolver to find it).

### Step 7: Regenerate Dashboard

Run the index regeneration:
```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SKILL_DIR="$PLUGIN_ROOT/skills/ship"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
bash "$SKILL_DIR/scripts/regenerate-index.sh" "$SHAPEUP_DIR"
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

- **Skipping ADRs**: Write an ADR for every meaningful trade-off because future shapers need to understand why constraints exist, not just what was built. Without ADRs, the next person to touch this area will re-investigate decisions that were already made.
- **Vague decisions**: "We chose approach A" without explaining WHY or what alternatives existed. An ADR without alternatives and rationale is just a changelog entry — it doesn't prevent future teams from revisiting the same dead ends.
- **Overwriting architecture docs**: Append, don't replace. The history of how architecture evolved shows which patterns worked and which were abandoned — overwriting erases that signal.
- **Not capturing what was cut**: Scope hammering decisions show what was deliberately excluded and why. Without them, future shapers may re-discover and re-shape features that were intentionally cut.
- **Shipping without comparing to frame**: The frame stated a business outcome. Comparing the shipped result to the frame validates that the investment paid off and closes the accountability loop.
