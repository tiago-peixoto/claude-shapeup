# Hill Chart Protocol

> Reference for AI agents tracking and reporting progress. The hill chart replaces estimates and task-completion percentages with a model based on uncertainty.

## The Model

Work has two phases:

```
UPHILL (figuring out)              DOWNHILL (executing)
├── Unknowns                       ├── All unknowns resolved
├── Problem-solving                ├── Known steps remaining
├── Investigation                  ├── Predictable work
├── "I'm not sure how yet"        ├── "I know exactly what to do"
└── Risk is high                   └── Risk is low

Start ────────────── Peak ────────────── Done
```

---

## Uphill Sub-Phases

| Position | Meaning | Validation |
|----------|---------|------------|
| Bottom third | "I've thought about this" | Mental model only — NOT validated |
| Middle third | "I've validated my approach" | Tried the approach, confirmed it works |
| Top third | "I've built enough to confirm no remaining unknowns" | Real code/design proves feasibility |

**Critical Rule**: Never mark a scope as "at the top of the hill" based on thinking alone. Validate with hands, not head. Theory-based confidence collapses in practice.

---

## Downhill Sub-Phases

| Position | Meaning |
|----------|---------|
| Just past peak | All unknowns solved, significant execution remaining |
| Middle | Steady execution, making visible progress |
| Near bottom | Final touches, cleanup, integration |
| Done | Deployed |

---

## Scope Tracking Rules

### Each scope gets a position on the hill

Plot every scope as a dot. Update positions as work progresses.

### Movement signals health

| Signal | Meaning | Action |
|--------|---------|--------|
| Dot moves steadily | Work is progressing | None needed |
| Dot stuck uphill | Unknown or blocker not resolved | Investigate: What's the unknown? |
| Dot slides back | Unexpected complexity discovered | Re-evaluate scope. Consider splitting. |
| Dot jumps to downhill | Breakthrough — approach validated | Confidence boost. Move to next risk. |

### Stuck scope protocol

When a scope hasn't moved in 2+ status updates:

1. Ask: What specific unknown is blocking progress?
2. Ask: Is this scope too broadly drawn?
3. If scope contains unrelated parts at different stages → **split into smaller scopes**
4. If a genuine blocker exists → escalate or re-shape

---

## Work Sequencing

### Priority order based on hill position and risk:

1. **First**: Push riskiest / most uncertain scopes uphill
2. **Second**: Get those scopes over the hill (validate approach)
3. **Third**: Leave those scopes on the downhill side and find the next risky scope
4. **Last**: Execute downhill work for all scopes

### Inverted pyramid principle

Like journalism (most important info first), tackle work in this order:
- Most important problems first
- Most unknowns first
- Routine / least risky last

### End-of-cycle target state

By cycle end:
- Important scopes → done or nearly done
- Risky scopes → over the hill and completed
- Only nice-to-haves and low-risk work → remaining (and cuttable)

---

## Status Reporting

### For managers / stakeholders

The hill chart enables status without asking. Self-serve progress visibility.

**What the chart shows**:
- Where each scope sits (uphill vs. downhill)
- What's in motion vs. what's stuck
- Whether the team chose the right problems to solve first
- History of movement (comparing past snapshots)

### Conversation triggers

Instead of "How's it going?", the chart enables specific questions:
- "Scope X has been uphill for a while. What's the unknown?"
- "Everything is downhill. Are we on track to ship by cycle end?"
- "Scope Y slid back. What happened?"

---

## Hill Chart vs Traditional Progress

| Traditional | Hill Chart |
|-------------|-----------|
| 60% of tasks done | 3 scopes downhill, 2 scopes uphill |
| Estimated 40 hours remaining | 2 unknowns to resolve, then execution |
| On track / behind schedule | Riskiest work is over the hill |
| Task completion percentage | Uncertainty vs. certainty |

The hill chart shows **risk**, not **effort**. A project with all scopes downhill is low risk regardless of remaining work volume. A project with one scope stuck uphill is high risk regardless of how many other scopes are done.
