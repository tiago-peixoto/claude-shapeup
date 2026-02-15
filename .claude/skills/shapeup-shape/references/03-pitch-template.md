# Package Template (formerly "Pitch")

> Reference for AI agents writing or evaluating packages. A Package is the shaped artifact presented at the betting table. It contains all necessary project variables: problem, solution, time, risks, and boundaries.
>
> **Terminology note**: Ryan Singer evolved the term from "Pitch" to "Package" because the business already bought in during Framing. Shaping output isn't a sales pitch — it's a complete package ready for a build commitment. See `08-framing.md` for the framing step that precedes this.
>
> **Prerequisite**: A Package should only be written after **Frame Go** — the business has confirmed the problem matters and authorized shaping time.

## Structure

Every package must contain exactly five ingredients. No more, no less.

---

## 1. Problem

**What it is**: A specific, concrete story showing why the current situation fails for users.

**Requirements**:
- Describe a single, specific scenario (not a general complaint)
- Show the baseline: what the user does today without this feature
- Make the pain point tangible and observable
- Separate "is this problem worth solving?" from "is this solution good?"

**Test**: Can someone read this and understand WHY the current situation is unacceptable? Can they evaluate any proposed solution against this specific pain point?

**Example format**:
```
When [specific user type] tries to [specific action], they have to [current painful workaround].
This causes [specific negative outcome]. Currently [X users / Y% of cases] experience this.
```

---

## 2. Appetite

**What it is**: The time budget — how much time this problem deserves.

**Options**:
- **Small Batch**: 1-2 weeks
- **Big Batch**: 6 weeks

**Requirements**:
- State the appetite explicitly
- The appetite constrains the solution — different appetites produce different designs
- The appetite is non-negotiable once set

**Example format**:
```
Appetite: [Small Batch — 2 weeks] or [Big Batch — 6 weeks]
```

---

## 3. Solution

**What it is**: The shaped elements that address the problem within the appetite.

**Requirements**:
- Describe the key elements (components, not tasks)
- Use embedded sketches or annotated fat marker sketches for visual context
- Stay rough — no wireframes, no pixel-perfect mockups
- Show where new elements fit in the existing system
- Include enough detail for the team to understand the approach
- Leave enough ambiguity for the team to make execution decisions

**Visualization rules**:
- Place new elements in context of existing UI
- Use fat-marker-level detail only
- Add clear labels and annotations
- Include disclaimer: "Designers should feel free to find a different approach"
- Only visualize parts that need concrete understanding to "get" the idea

**Example format**:
```
The solution introduces [key element 1], [key element 2], and [key element 3].

[Element 1] appears [where in the system] and allows [what action].
[Element 2] connects to [element 1] by [how].
[Element 3] handles [what case].

[Embedded sketch or annotated fat marker sketch]
```

---

## 4. Rabbit Holes

**What it is**: Known risks, technical unknowns, and how they've been addressed or scoped out.

**Requirements**:
- List each identified risk
- For each: state how it's been resolved, scoped down, or declared out of bounds
- Call out assumptions that the team should validate early
- Note any simplified implementations chosen to reduce risk

**Example format**:
```
- [Risk 1]: Resolved by [decision]. We chose [simpler approach] instead of [complex approach].
- [Risk 2]: Declared out of bounds. [Use case X] is not supported in this version.
- [Risk 3]: Team should validate [assumption] early. If it doesn't hold, fallback is [alternative].
```

---

## 5. No-Gos

**What it is**: Explicit list of what is NOT included. Features, use cases, and scope deliberately excluded.

**Requirements**:
- List each exclusion clearly
- Briefly explain why (prevents revisiting the decision during build)
- These are boundaries, not future plans

**Example format**:
```
- No [feature X]: [reason — too complex for appetite / not core to problem / can be added later]
- No [use case Y]: [reason — affects too few users / requires infrastructure not yet available]
- No [capability Z]: [reason — would expand scope beyond appetite]
```

---

## Pitch Evaluation Checklist

For AI agents evaluating whether a pitch is ready for the betting table:

### Completeness
- [ ] Problem is specific and story-based (not generic)
- [ ] Appetite is explicitly stated
- [ ] Solution describes concrete elements (not vague features)
- [ ] Rabbit holes are identified and addressed
- [ ] No-gos define clear boundaries

### Quality
- [ ] Problem and solution are separable (can evaluate each independently)
- [ ] Solution fits within stated appetite
- [ ] Solution is rough (not over-specified)
- [ ] Solution is solved (main elements connect at macro level)
- [ ] Solution is bounded (clear limits on scope)
- [ ] Rabbit holes have been de-risked (patched, cut, or declared out of bounds)
- [ ] Technical feasibility validated within appetite

### Betting Table Questions
- [ ] Does the problem matter enough to spend [appetite] on?
- [ ] Is the appetite right for this problem?
- [ ] Is the solution attractive given the constraints?
- [ ] Is this the right time to build this?
- [ ] Are the right people available?

---

## Full Pitch Example Structure

```markdown
# [Project Name]

## Problem
[Specific story about user pain point and current baseline]

## Appetite
[Big Batch — 6 weeks] or [Small Batch — X weeks]

## Solution
[Description of key elements with annotated sketches]

### Element: [Name]
[What it is, where it fits, what it enables]

### Element: [Name]
[What it is, where it fits, what it enables]

## Rabbit Holes
- [Risk]: [Resolution]
- [Risk]: [Resolution]

## No-Gos
- [Exclusion]: [Reason]
- [Exclusion]: [Reason]
```
