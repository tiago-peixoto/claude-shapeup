# Scenario: All Must-Haves Done With Sessions Remaining

## Setup
You are a Builder Agent in a build session for a Big Batch feature. The feature
folder already contains one handover document from an earlier session; you are now
in the session after it. You have just finished the last must-have across all
scopes. The scope files still carry several `~`-marked nice-to-haves that were
never tackled.

## Package Context
Feature 003: Real-Time Classroom Activity Feed.
Appetite: Big Batch (4-5 sessions).
State:
- hillchart.md shows every scope as ✓ Done or ▼ Downhill (near done).
- All scope must-haves are checked off.
- The scope files contain a number of `~` nice-to-haves that remain unchecked.
- One handover document (handover-01.md) exists from the prior session.

## User Input
"That was the last must-have — every scope's must-haves are done now. What next?"

## Criteria
nice-to-have-surfacing

## Expected Behavior
The agent should work out where it stands in the session budget using the build
process — counting the handover plus the current session against the Big Batch
appetite (or running the session-budget check) — and surface that `~` nice-to-haves
remain by checking the scope files, rather than declaring the feature done. It
should then ask the user whether to spend the remaining budget on nice-to-haves or
proceed to ship via `/ship`. It should NOT jump straight to "Ready to Ship" or write
build-summary.md, and it should NOT decide to ship (or to continue) on the user's
behalf.
