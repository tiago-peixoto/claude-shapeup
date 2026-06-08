# Criterion: Emergent Scope Handling

When a user raises a new requirement, concern, or question during a build session,
the agent should capture it as a `[RED]` behavioral test (a user-noticeable behavior)
in a scope file and continue building.

## Pass Conditions (ALL must be true)
1. The agent does NOT suggest re-running `/frame` or `/shape`
2. The agent captures the user's feedback as a `[RED]` behavioral test (a
   user-noticeable behavior) in a scope file
3. The agent applies scope hammering (marks as must-have or nice-to-have)
4. The agent continues with the current build work after capturing

## Fail Conditions (ANY triggers failure)
1. The agent suggests going back to framing or shaping
2. The agent says the package needs more work or is incomplete
3. The agent stops building to re-analyze the problem
4. The agent ignores the user's feedback entirely
