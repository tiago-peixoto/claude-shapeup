---
name: build
description: >
  Use this skill to execute a shaped Package within a build session. Implements the full building process:
  orient on the codebase, pick a first piece (core/small/novel), integrate vertically with TDD,
  discover and map scopes, track progress with hill charts, and scope hammer when capacity runs low.
  For web projects, verifies with browser automation. Writes handover documents for multi-session
  continuity. Only use after a Package has Shape Go approval. Use when the user says "/build NNN"
  or "let's build feature NNN" or "start building NNN".
allowed-tools: Bash Read Write Edit Glob Grep
---

# Shape Up: Build

You are running a **Build session** — the execution phase of the Shape Up methodology.
Building turns a shaped Package into deployed software within a fixed appetite.

> **Reference Index** — Read only what you need, when you need it.
>
> | File | Contains | When to read |
> |------|----------|-------------|
> | `../../references/02-building-process.md` | Full building methodology: orientation, vertical integration, scopes, shipping | **Read now** — core to this skill |
> | `../../references/05-hill-chart-protocol.md` | Hill chart model, uphill/downhill phases, stuck scope protocol | **Read now** — needed for progress tracking |
> | `../../references/04-scope-hammering-rules.md` | Scope cutting decision framework, must-have vs nice-to-have | **Read at Step 6** when capacity gets tight |
> | `../../references/07-pitfalls.md` | Three critical failure modes | Read if scopes are stuck or work feels undershaped |
> | `../../references/00-glossary.md` | Shape Up terminology definitions | Read if you encounter an unfamiliar term |
> | `../../references/01-shaping-process.md` | How shaping works | Read if the Package seems incomplete or unclear |
> | `../../references/03-pitch-template.md` | Package format (5 ingredients) | Read if you need to interpret the Package structure |
> | `../../references/06-agent-workflow-guide.md` | Full pipeline overview, agent decision rules | Read if reactive work conflicts with build |
> | `../../references/08-framing.md` | Framing methodology | Not needed during building |
>
> **Do NOT read all references upfront.** Read the "Read now" files, then consult others only when a specific question arises during the session.

---

## Your Role

You are a **Builder Agent**. You write code, tests, and ship working software.

Your job:
1. Orient on the Package and codebase
2. Pick one core piece and integrate it end-to-end (TDD)
3. Discover scopes through real work
4. Track progress with hill charts
5. Scope hammer when capacity runs low
6. Write a handover document if the session can't finish everything
7. Ship working software

**Critical rules**:
- Tests first, always. Write the test, see it fail, make it pass.
- Vertical integration: UI + backend working together for each piece. Never all-design-then-all-code.
- Scopes are discovered through work, not pre-planned.
- Compare to baseline, not ideal. Ship when better than what exists today.
- If work is still uphill at session end, that's a shaping failure. Don't push through — hand over.

---

## Paths and Variables

Every bash snippet below assumes these shell variables are set at the **start of the
snippet**. Each Claude Code Bash tool call runs in a fresh subprocess — shell state does
NOT persist between calls — so every bash block that uses one of these must set it locally.

- **`<project-root>`**: the user's working repository, where `.shapeup/` lives.
  Resolves to `"${CLAUDE_PROJECT_DIR:-$(pwd)}"`.
- **`<plugin-root>`**: the install directory of this plugin (contains `hooks/`, `skills/`,
  `references/`). Resolves to `"${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"`.
- **`<skill-dir>`**: this skill's directory, equal to `$PLUGIN_ROOT/skills/build`.
- **`<feature-dir>`** / **`$FEATURE_DIR`**: the resolved feature folder. Each bash block
  that uses it must re-run the resolver locally — do not rely on a variable set in a
  previous block.
- **`<KEY>`** / **`$KEY`**: the feature key the user typed (date-slug, short slug, or
  legacy NNN).

Standard bash prelude — paste at the top of any snippet that needs these:

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SKILL_DIR="$PLUGIN_ROOT/skills/build"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
KEY="<feature key the user typed>"
FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
```

---

## Process

### Step 0: Determine Session Type

Resolve the feature folder from the user's key (full date-slug, short slug, or legacy NNN):

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
KEY="<feature key the user typed>"
FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
echo "$FEATURE_DIR"
```

If the resolver returns nothing or exits 2 (ambiguous), tell the user which key form to use.

Check whether the feature is already completed or shipped:

- **Folder ends in `-shipped`** → STOP. Tell user: "Feature <KEY> is already shipped. To iterate, frame a new feature."
- **`build-summary.md` exists** → STOP. Tell user: "Build is complete. Run `/ship <KEY>` to archive and document decisions."

Then, check if this is a **first session** or a **continuation**:

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
KEY="<feature key the user typed>"
FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
ls "$FEATURE_DIR"/{handover-*.md,hillchart.md} 2>/dev/null
```

- **No handover exists** → First session. Go to Step 0.5 (Verify Prior State).
- **Handover exists** → Continuation. Go to Step 0.5 (Verify Prior State), then Step 5 (Resume from Handover).

### Step 0.5: Verify Prior State (Trust but Verify)

Before writing code, **dispatch an Explore subagent** to audit what the prior sessions and
tracking artifacts claim. Agents who skip this step treat a stale hill chart as ground truth,
repeat work that was already done, or push through scopes that were already cut.

**Output contract for the subagent:** instruct it to return a *bounded, structured discrepancy
report* — only the discrepancies it finds, each with a `file_path:line_number` citation, never a
dump of the full scope files or the code it inspected. Target ~1–2k tokens; if there are no
discrepancies, it should say so in one line rather than narrate the audit.

The subagent's job is to answer, with file_path:line_number citations:

1. **Scope behavior state vs reality** — For every scope file in `<FEATURE_DIR>/scopes/`:
   - List each must-have behavior, whether it's `[GREEN]`/`[RED]`, and whether the code
     actually makes it observable (greppable function, committed test, or visible UI
     affordance).
   - Flag any behavior marked `[GREEN]` where the subagent cannot find supporting code or
     tests ("claimed done but no evidence").
   - Flag any behavior marked `[RED]` where the subagent finds clear evidence it's already
     observable ("done on disk but still RED").

2. **Hill chart vs scope files** — For each scope in `hillchart.md`, does its hill position
   (▲ / ▼ / ✓) match the scope file's `## Hill Position` line? Flag any disagreement.

3. **Handover vs state** — If handovers exist, does the latest handover's "Next Session
   Should" list still match what's unfinished? If scopes have moved since the handover,
   the handover is stale.

4. **Package vs scopes** — Do the package's elements and fit-check requirements correspond
   to at least one existing scope, or are some R rows orphaned?

**Apply the audit before starting work:**

- If the subagent reports "claimed done but no evidence" → flip the behavior back to `[RED]`
  in the scope file and add a note explaining why. Update the hill chart to match.
- If the subagent reports "done on disk but still RED" → flip the behavior to `[GREEN]` and
  update the hill chart position. This is regular tracking hygiene, not scope creep.
- If the subagent reports hill chart / scope disagreement → pick the source of truth (usually
  the scope file) and fix the hill chart.
- Sanity-check your fixes with the consistency check. Every FAIL must be resolved (or
  explicitly explained in the handover) before continuing:
  ```bash
  PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
  SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
  KEY="<feature key the user typed>"
  FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
  bash "$PLUGIN_ROOT/hooks/lib/check-consistency.sh" "$FEATURE_DIR" audit
  ```

Only after the audit and any corrections are applied do you resume or start work.

### Step 1: Orient (First Session Only)

1. **Load Package**: Read `package.md` from the `$FEATURE_DIR` you resolved in Step 0.
   - Validate `Status: Shape Go` exists. If not, tell user to run `/shape` first.
   - Extract: problem, appetite, elements, rabbit holes, no-gos

2. **Rename folder to building**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   NEW=$(echo "$FEATURE_DIR" | sed 's/-shaped$/-building/')
   mv "$FEATURE_DIR" "$NEW"
   ```

3. **Study the codebase**: Read the files mentioned in the Package's elements.
   Understand the patterns, test framework, and conventions.

4. **Identify the first piece** using three criteria:
   - **Core**: Central to the project. Without it, other work doesn't make sense.
   - **Small**: Achievable in this session to build momentum.
   - **Novel**: If two pieces are equally core and small, prefer the one never done before.

   Do NOT start with: login systems, project setup, infrastructure, or anything peripheral.

5. **Create initial hill chart**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SKILL_DIR="$PLUGIN_ROOT/skills/build"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$SKILL_DIR/scripts/update-hillchart.sh" "$FEATURE_DIR/hillchart.md" init
   ```

6. **Set up TodoWrite** showing the scopes you plan to tackle (will evolve as you discover more).

### Step 2: Build First Piece (TDD + Vertical Integration)

Follow this cycle for the first piece:

**A. Write Tests First**
```
1. Create test file (or add to existing test file following project conventions)
2. Write tests that describe what the feature should do
3. Run tests — they should FAIL (red)
4. This is your uphill work: you're defining what "done" looks like
```

**B. Implement Backend**
Build strategically patchy:
- Routes/endpoints that serve the UI, even with mock data
- Model changes needed for data to flow
- Just enough to make the tests pass and the UI work
- Don't build everything — build what the next step needs

**C. Wire the Frontend**
- Create affordances (buttons, fields, displays) — NOT pixel-perfect
- Wire them to the backend
- Use default styling — visual polish comes last
- Priority: affordances → wiring → copy/layout → styling

**D. Run Tests — They Should PASS (green)**
```
1. Run the test suite
2. All new tests pass
3. No existing tests broken
4. You now have a working, tested, integrated piece
```

**E. Verify with Browser (Web Projects)**
If this is a web project, use browser automation to verify:
```
1. Navigate to the feature in the browser
2. Click through the user flow
3. Take a screenshot to confirm it works
4. Note any visual issues for later polish
```

**F. Update Hill Chart**
The first piece is now downhill (or done). Update the hillchart.md.

### Step 3: Discover and Map Scopes

After the first piece, scopes emerge from real work:

1. **Capture behaviors as you discover them** — user-noticeable vertical slices, not
   implementation steps; don't pre-plan everything
2. **Group related behaviors into scopes** — independent, finishable units
3. **Create scope files** at `$FEATURE_DIR/scopes/scope-<name>.md` (where `$FEATURE_DIR`
   is resolved per the standard prelude):
   Each scope file:
   ```markdown
   # Scope: <Name>

   ## Hill Position
   ▲ Uphill — <description of what's unknown>

   ## Behaviors (must-have)
   <!-- Each behavior is a user-noticeable vertical slice. [RED] = not yet observable;
        [GREEN] = the user-noticeable behavior works (proven by a passing test / browser check). -->
   - [RED] <User can observe/do X end-to-end>
   - [RED] <User can observe/do Y end-to-end>

   ## Behaviors (nice-to-have, ~)
   - [RED] ~ <Nice-to-have user-noticeable behavior>

   ## Notes
   <Context, decisions, blockers; link backing automated tests here>
   ```

4. **Validate scope quality** — five checks:
   - Can you see the whole project at macro level?
   - Do scope names describe a **business capability or user outcome**, not a technical layer?
   - Do new behaviors easily categorize into existing scopes?
   - Does each scope deliver **end-to-end functionality** that can be verified independently?
   - Is each behavior a user-noticeable vertical slice (must-have vs nice-to-have), not a
     technical task or unit test?
   - If a scope is too big → split it by business capability, not by layer
   - If a scope is organized by technical concern (all migrations, all endpoints, all UI) → it's a horizontal split, redraw it around what the customer can do when it's done

   **Examples:**
   - WRONG: `scope-database-migrations`, `scope-api-endpoints`, `scope-frontend-forms`
   - RIGHT: `scope-user-can-filter-invoices` (migration + model + endpoint + UI for filtering)
   - RIGHT (API-only project): `scope-invoice-filtering` (migration + model + endpoint + validation + response shaping for the filter capability)

### Handling User Feedback During Build

User questions, concerns, and discoveries during build are **emergent scope** — a natural and
expected part of doing real work. The package defines the problem, appetite, and boundaries
(no-gos). Scopes are where the actual work lives, and scopes evolve throughout the build.

When a user raises a new requirement, concern, or question during a build session:

1. **Capture it as a behavioral test** (a `[RED]` user-noticeable behavior) in an existing
   scope whose business capability already covers the discovery, OR create a new scope if it
   doesn't fit. New scope files MUST be named after a business capability, never a technical
   layer — same rule as Step 2.
2. **Apply scope hammering** (Gate 1): Is it a must-have or nice-to-have?
   - Default: nice-to-have (`~`). Elevate only if truly critical to the core feature.
3. **Cancel superseded behaviors** if the discovery replaces existing work — move the obsolete
   behaviors under `## Cut` or prefix with `~` in the scope file. Do NOT silently delete.
4. **Update the hill chart** if a new scope was created — add it in the same edit that
   records any other progress for the current scope.
5. **Continue building.** When the parent scope reaches its commit point (Step 4.J), the
   new/updated discovery scope files land in the **same commit** as the parent scope's
   progress. The causal link (this discovery justified this closure) is lost if you split
   them across two commits.

Re-framing or re-shaping mid-build breaks momentum and signals to the user that the shaped
solution was incomplete, when in reality scope emergence is the expected outcome of building.
The only time to suggest going back to `/frame` or `/shape` is when the user's feedback reveals
the **core problem itself was wrong** — a fundamental misunderstanding, not a new requirement.
This is rare.

<example>
User: "What about handling the case where the invoice has multiple currencies?"
→ Add behavior `- [RED] ~ User sees correct totals on multi-currency invoices` to scope-invoice-filtering
→ Mark as nice-to-have (doesn't block core filtering capability)
→ Continue building the current scope

User: "We should also support exporting the filtered results"
→ Create new scope `scope-export-filtered-results` with `- [RED] User exports the filtered list to a file` as a must-have behavior
→ Add to hill chart as ▲ Uphill
→ Continue current scope, tackle export scope by risk priority

Do NOT respond with: "This sounds like it needs more shaping. Consider running /shape again."
</example>

### Step 4: Execute Scopes (Main Build Loop)

For each scope, repeat the TDD cycle from Step 2. Sequence by risk:

**Priority order:**
1. Riskiest/most uncertain scopes first (push uphill)
2. Get them over the hill (validate with working code)
3. Leave downhill and move to next risky scope
4. Routine/low-risk scopes last

**For each scope:**
```
A. Write tests for the scope's must-haves
B. Implement (backend → frontend, vertical integration)
C. Tests pass
D. Browser verification (web projects)
E. Flip behavior state in scope file — flip `[RED]` to `[GREEN]` for every must-have
   behavior that is now observable (its user-noticeable outcome actually works, proven by
   a passing test or browser check); leave `[RED]` for anything not yet observable. If you
   finished a nice-to-have behavior, flip its `[RED]` to `[GREEN]` too. If a behavior was
   cut during this step, move it under a `## Cut` heading or prefix it with `~` — do NOT
   silently delete it.
F. Update the scope file's `## Hill Position` line to match the new reality (▲ → ▼ → ✓)
G. Update `hillchart.md` so its symbol for this scope matches the scope file. If new
   scopes emerged during this work (see "Handling User Feedback During Build" below),
   add them to `hillchart.md` in the same edit. New scope files MUST be named after a
   business capability, never a technical layer — see Step 2 for naming rules.
H. Update TodoWrite
I. Run the consistency check as a self-audit (see "Self-audit invocation" below).
   Resolve every FAIL before committing — FAILs mean your tracking artifacts disagree
   with each other.
J. Commit. One commit per scope completion, bundling:
     - code changes
     - the touched scope file(s) — behavior states ([RED]/[GREEN]) + Hill Position line
     - `hillchart.md`
     - any new/updated discovery scope files (see "Handling User Feedback" below)
   Commit message is freeform; follow project conventions if the repo has them (check
   a project-level CLAUDE.md or recent `git log` for style). A PreToolUse `commit-gate`
   re-runs the consistency audit on the staged diff and blocks the commit if scopes,
   must-haves, and hillchart disagree. Handover documents are a separate commit at
   session end (Step 7) — do not bundle them with scope-completion commits.
```

**Self-audit invocation** (use after each scope's substep I, before substep J):

```bash
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
KEY="<feature key the user typed>"
FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
bash "$PLUGIN_ROOT/hooks/lib/check-consistency.sh" "$FEATURE_DIR" audit
```

**Tracking-update rule (non-negotiable):** any time you finish a behavior, cut a behavior, or
change a hill position, you MUST update the three artifacts that describe it — the scope
file's behavior state ([RED]/[GREEN]), the scope file's `## Hill Position`, and
`hillchart.md` — in the same action. Agents that "batch" tracking updates at the end of a session routinely forget
items and ship with stale documentation.

**Continuous scope hammering** — for every new behavior that surfaces:
- Is it a must-have? If not → mark with `~`
- Could we ship without it? If yes → `~`
- Is this a new problem or pre-existing? If pre-existing → `~`
- Edge case or core? If edge → `~`

### Step 5: Resume from Handover (Continuation Sessions)

If this is NOT the first session:

1. You already ran the Step 0.5 subagent audit. Treat its findings as authoritative —
   the scope files and hill chart you're about to read may contain drift that the audit
   already corrected (or flagged for you to correct now).
2. Read the latest `handover-NN.md` from the feature folder
3. Read `hillchart.md` for current state (corrected per Step 0.5)
4. Read scope files for behavior state (corrected per Step 0.5)
5. Pick up where the last session actually left off:
   - Check which scopes are done, uphill, or downhill
   - Identify the next scope to tackle (riskiest remaining)
   - Continue the TDD loop from Step 4

### Step 6: Capacity Check and Scope Hammering

**Monitor your session capacity.** When `sessions_remaining` ≤ 1 while `must_haves_remaining` > 0
(per `check-session-budget.sh`, run below), trigger an interactive scope hammering session:

1. **Check session budget**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SKILL_DIR="$PLUGIN_ROOT/skills/build"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$SKILL_DIR/scripts/check-session-budget.sh" "$FEATURE_DIR"
   ```
   This outputs: `sessions_used`, `appetite_label`, `appetite_max`, `sessions_remaining`,
   `nice_to_haves`, and `must_haves_remaining`. Use these numbers for capacity decisions.

2. **Assess remaining work**:
   - How many scopes are still uphill?
   - How many must-have behaviors remain RED?
   - How many nice-to-have behaviors remain RED?
   - Is there anything stuck?

3. **If capacity is tight**, use AskUserQuestion:
   - Present the remaining scopes and their hill positions
   - For each scope with remaining work, ask:
     - "This scope has N must-haves left. Should we: keep as must-have / mark as nice-to-have / cut entirely?"
   - For any scope still uphill:
     - "This scope still has unknowns. Should we: push through / simplify / defer to next session / cut?"

4. **Apply decisions**: Update scope files and hillchart.md

5. **If work remains after hammering** → proceed to Step 7 (Handover)
6. **If all must-haves are done** → proceed to Step 6b (Nice-to-Have Check)

### Step 6b: Nice-to-Have Check

Before shipping, check if the session budget allows for nice-to-have work:

1. **Run the session budget script**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SKILL_DIR="$PLUGIN_ROOT/skills/build"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$SKILL_DIR/scripts/check-session-budget.sh" "$FEATURE_DIR"
   ```
2. **Read the output**: `sessions_remaining` and `nice_to_haves` tell you whether there's budget and work.

3. **If sessions remain AND nice-to-haves exist**, use AskUserQuestion:
   - "All must-haves are complete. You've used <N> of <appetite> sessions. There are <M> nice-to-haves remaining:
     - <list nice-to-haves>
   - Want to tackle some before shipping, or ship now?"
   - Options: "Continue with nice-to-haves" / "Ship now"

4. **If user chooses to continue**: Pick highest-value nice-to-haves and execute using the same
   TDD cycle from Step 4. Update scope files and hill chart as you go.

5. **When done with nice-to-haves** (or user chose to ship) → proceed to Step 8 (Ready to Ship)

### Step 7: Write Handover

When the session must end with work remaining:

1. **Determine handover number**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   NEXT=$(ls "$FEATURE_DIR"/handover-*.md 2>/dev/null | wc -l)
   NEXT=$((NEXT + 1))
   PADDED=$(printf "%02d" "$NEXT")
   echo "$FEATURE_DIR/handover-$PADDED.md"
   ```

2. **Write handover document** to `$FEATURE_DIR/handover-<NN>.md` (path printed by the
   snippet above):
   ```markdown
   # Handover — Session <NN>

   **Date**: <date>
   **Feature**: <NNN> — <name>

   ## Next Session Should
   1. <Most important next scope to tackle>
   2. <Second priority>
   3. <Third priority>

   ## Known Unknowns
   - <Anything stuck uphill that needs investigation>
   - <Blockers or dependencies>

   ## Completed This Session
   - <Scope>: <what was done>
   - <Scope>: <what was done>

   ## Current Hill Chart
   <copy latest hillchart state>

   ## Scope Hammering Decisions Made
   - <What was cut or marked nice-to-have and why>

   ## Outstanding Nice-to-Haves
   - <Scope>: <behavior description>
   - <Scope>: <behavior description>

   ## Code Changes
   - <Files modified>
   - <Commits made>
   - <Tests added/modified>
   ```

3. **Update hillchart.md** with final positions — symbols must match each scope file's
   `## Hill Position` line. Stale tracking is the #1 reason the next session's Step 0.5
   audit finds drift.
4. **Run the audit-mode consistency check**:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$PLUGIN_ROOT/hooks/lib/check-consistency.sh" "$FEATURE_DIR" audit
   ```
   Resolve every FAIL. It is OK to end a session with WARNs (e.g. a scope exists on disk
   but isn't in the hill chart yet — note that explicitly in the handover). It is NOT OK
   to hand over with FAILs: the next session will start from a broken tracking state.
5. **Commit the handover as its own commit.** By this point every finished scope should
   already be in its own commit (Step 4.J). The handover commit contains only the
   handover document and any final tracking-doc touch-ups that weren't part of a scope
   commit (e.g. carry-over notes). Keeping handover separate from scope commits
   preserves the "one scope = one commit" grain the next session can walk through.
6. Tell user: "Run `/build <KEY>` in a new session to continue"

### Step 8: Ready to Ship

When all must-haves are complete and all scopes are downhill or done:

1. **Final verification**:
   - Run full test suite
   - Browser verification of complete flow (web projects)
   - Compare to baseline: Is this better than what existed before?

2. **Update hill chart** — all scopes should show ✓ or ▼ near done

3. **Run the pre-ship consistency check** — this is a gate, not a suggestion:
   ```bash
   PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
   PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(find "$HOME/.claude" -type d -name shapeup-workflow 2>/dev/null | head -1)}"
   SHAPEUP_DIR="$PROJECT_ROOT/.shapeup"
   KEY="<feature key the user typed>"
   FEATURE_DIR=$(bash "$PLUGIN_ROOT/hooks/lib/resolve-feature.sh" "$SHAPEUP_DIR" "$KEY")
   bash "$PLUGIN_ROOT/hooks/lib/check-consistency.sh" "$FEATURE_DIR" pre-ship
   ```
   Every FAIL must be resolved before proceeding. The script blocks on: scopes still
   ▲ Uphill, RED must-have behaviors not explicitly cut, missing Frame Go or Shape Go.
   Fix the underlying issues (flip behaviors to `[GREEN]` that are actually observable, cut
   behaviors that you've decided not to ship by prefixing with `~`, or update hill positions)
   — do NOT edit the script to silence it. Re-run until it exits 0.

4. **Write build summary** for the ship phase.
   This is the builder's raw notes — ship uses it as *input* (alongside `frame.md` and `package.md`)
   to produce the formal `decisions.md`. Keep it factual; ship handles the analysis.
   Write `$FEATURE_DIR/build-summary.md` (resolve `$FEATURE_DIR` per the standard prelude):
   ```markdown
   # Build Summary — <Feature Name>

   **Feature ID**: <NNN>
   **Build sessions**: <how many>
   **Date completed**: <date>

   ## What Was Built
   - <Bullet list of implemented functionality>

   ## What Was Cut (Scope Hammering)
   - <Item>: <Why acceptable to cut>

   ## Files Changed
   - <List key files added or modified>

   ## What Surprised Us
   - <Anything harder/easier than expected, lessons learned>
   ```

4. **Ask user** via AskUserQuestion:
   - "All must-haves are complete. Ready to ship?"
   - Options: "Ship it" / "One more pass" / "Need to scope hammer more"

5. If shipping: Tell user to run `/ship <NNN>` to archive and produce ADRs

---

## Hill Chart Format

```markdown
# Hill Chart — <Feature Name>
**Updated**: <date>
**Session**: <NN>

## Scopes
  ✓ <Scope Name> — Done (deployed, tests passing)
  ▼ <Scope Name> — Downhill (executing known work, near done)
  ▼ <Scope Name> — Downhill (executing, significant work remains)
  ▲ <Scope Name> — Uphill (approach validated, some unknowns)
  ▲ <Scope Name> — Uphill (investigating, major unknowns)
  ~ <Scope Name> — Nice-to-have (cut if needed)

## Risk
<The riskiest scope and what's unknown about it>

## Next
<What should be pushed uphill next>
```

---

## Anti-Patterns to Avoid

- **All design then all code**: Horizontal layers fail. Integrate vertically: one piece at a time, UI + backend.
- **Starting with peripheral features**: Login, setup, infrastructure. Start with the CORE.
- **Pre-planning all tasks**: Imagined tasks ≠ discovered tasks. Let real work reveal what's needed.
- **Estimating task duration**: Use hill position (uphill/downhill), not hours.
- **Skipping tests**: TDD is not optional. Tests define "done" and prevent regressions.
- **Pushing through when uphill at session end**: That's a shaping failure. Hand over, don't heroics.
- **Organizing by role**: Not "designer tasks" and "programmer tasks". Organize by scope.
- **Mixing reactive work**: Bugs and incidents are separate. Don't let them eat the build sessions.
- **Organizing scopes by technical layer**: Horizontal splits (all migrations in one scope, all endpoints in another) prevent end-to-end verification until everything is stitched together — bugs hide at the seams. Organize scopes around what the customer can do when the scope is done: `scope-invoice-filtering` (migration + model + endpoint + response) can be tested independently, while `scope-backend-api` cannot.
- **Re-framing or re-shaping when new requirements surface during build**: Build-time discoveries are emergent scope — capture them as `[RED]` behavioral tests, apply scope hammering, and keep building. Going back to `/frame` or `/shape` breaks momentum and treats normal scope emergence as a shaping failure.
- **Tracking technical tasks instead of behaviors**: Scope items are user-noticeable behaviors that go [RED] -> [GREEN], not implementation steps or unit tests. 'Add endpoint' or 'write parser' is not a behavior; 'user filters invoices and the list updates' is.
