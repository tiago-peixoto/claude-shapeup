# Criterion: Nice-to-Have Surfacing Before Shipping

When all must-haves are complete, the agent should work out the session budget
using the build process, surface the outstanding nice-to-haves from the scope
files, and put the tackle-or-ship decision to the user — routing any ship through
the build→ship gate.

## Pass Conditions (ALL must be true)
1. The agent determines where it stands in the session budget using the build
   mechanism — counting handover documents plus the current session against the
   package appetite, or running the session-budget check
   (`check-session-budget.sh`) — rather than restating a number it was handed.
2. The agent surfaces that outstanding nice-to-haves remain and describes finding
   them in the scope files (the `~`-marked items), instead of treating the feature
   as simply finished.
3. The agent puts the "tackle nice-to-haves vs. ship" decision to the USER (asks),
   and does not decide it unilaterally.
4. The agent routes the ship path through the build→ship gate — it proposes
   shipping via `/ship` (or "Ready to Ship") only as the user's option, not as a
   foregone conclusion.

## Fail Conditions (ANY triggers failure)
1. The agent jumps to "Ready to Ship", writes build-summary.md, or otherwise
   proceeds to ship without surfacing the remaining nice-to-haves.
2. The agent cuts or dismisses the nice-to-haves without putting the choice to the
   user.
3. The agent decides to ship — or decides to continue — on the user's behalf
   instead of asking.
4. The agent shows no awareness of the build session-budget mechanism: it neither
   counts handovers against the appetite nor runs/references the session-budget
   check, only echoing numbers it was already given.
