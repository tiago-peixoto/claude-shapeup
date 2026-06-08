# Scenario: Commit Discipline at Scope Completion

## Setup
You are a Builder Agent running a build session for feature 042.
The package has Shape Go approval. You just finished implementing the last
must-have of `scope-user-can-filter-invoices` — filters now persist across page
reloads, tests pass, and the browser verification is green. While finishing that
work you and the user agreed a new capability is needed: bulk-exporting the
currently-filtered invoice list. You and the user confirmed it is a must-have
for this feature, not a nice-to-have.

## Package Context
The package is about an invoice management dashboard. Requirements:
- R0: Users can filter invoices by status, date range, and client (Core goal)
- R1: Filters persist across page reloads (Must-have — just finished)
- R2: The filtering UI surfaces active filters clearly (Must-have — done earlier)
- R-emergent: Export the currently-filtered invoice list (just promoted to
  must-have via the conversation described above)

Appetite: Medium Batch (3 sessions). You are in session 2.

## User Input
"Nice, filtering feels solid. Go ahead and close out the filtering scope. Make
sure the bulk-export we just talked about is captured as its own scope so we
don't lose it — it's a must-have. Then let's keep going."

## Criteria
commit-discipline

## Expected Behavior
The agent should walk through closing `scope-user-can-filter-invoices`:

1. Flip the last must-have behavior to `[GREEN]` in the scope file, move Hill Position to `✓ Done`.
2. Update `hillchart.md` so the symbol for this scope matches.
3. Create a new scope file for the bulk-export discovery, business-capability
   named (e.g. `scope-user-can-export-filtered-invoices.md`, NOT
   `scope-export-backend.md` or similar). Add it to `hillchart.md` in the same
   edit.
4. Run the consistency audit (`check-consistency.sh <feature-dir> audit`).
5. Create ONE commit that bundles: the filtering code + the closed scope file
   + the updated `hillchart.md` + the new discovery scope file. Commit message
   is freeform.
6. Continue with the next scope.

The agent should NOT propose separate commits for the scope closure and the
discovery. The agent should NOT mention handover in this response — handover is
a separate commit at session end, not now. The agent should NOT name the new
scope by technical layer.
