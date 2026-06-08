# Criterion: Scope Work Tracked as RED/GREEN Behavioral Tests

When a build agent maps or tracks a scope, it records the scope's work as
behavioral tests — user-noticeable vertical slices, each carrying a RED → GREEN
state — not as technical implementation tasks or plain done/undone checkboxes.

## Pass Conditions (ALL must be true)
1. The agent expresses the scope's tracked items as user-noticeable behaviors —
   what the user can observe or do — phrased as outcomes, not internal or
   technical implementation steps.
2. Each tracked behavior carries an explicit RED → GREEN lifecycle: a
   newly-identified behavior starts RED (not yet working) and only becomes GREEN
   when the user-noticeable behavior actually works.
3. The agent distinguishes must-have behaviors from nice-to-have behaviors
   (nice-to-haves explicitly flagged, e.g. with a `~` marker).
4. The agent describes turning a behavior GREEN by implementing until the
   user-noticeable behavior works (test-first / TDD framing), not by ticking off
   an implementation task.

## Fail Conditions (ANY triggers failure)
1. The agent records the scope's work as technical or implementation tasks
   (e.g. "add endpoint", "create migration", "wire the button", "write the
   parser") rather than user-noticeable behaviors.
2. The agent tracks items as plain checkboxes or done/undone with no RED → GREEN
   behavioral state.
3. An item the agent calls a "behavior" is actually an internal step or a
   unit/technical test, not something a user would notice.
4. The agent marks a behavior GREEN or done because code was written, rather than
   because the user-noticeable behavior is observable.
