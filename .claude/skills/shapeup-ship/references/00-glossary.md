# Shape Up Glossary

> Reference for AI agents. All terms used across Shape Up documents.

## Core Concepts

**Appetite**: The amount of time allocated to a project. NOT an estimate. A creative constraint that drives scope decisions. Sizes: Small Batch (1-2 weeks) or Big Batch (6 weeks).

**Baseline**: What customers currently do without the feature being built. The comparison point for judging "good enough."

**Bet**: A commitment to assign a team to a project for one cycle with no interruptions and an expectation to finish.

**Betting Table**: A meeting during cool-down where stakeholders decide which packages to fund for the next cycle. Clean slate each time.

**Breadboard**: A UI concept that defines places, affordances, and connections without any visual styling. Uses words and arrows, not pictures.

**Candidate**: A raw request or idea that hasn't been framed yet. The starting state in the pipeline.

**Circuit Breaker**: Default policy: if a project doesn't ship in one cycle, it is cancelled (not extended). Prevents runaway projects.

**Cool-Down**: A two-week break between cycles for ad-hoc tasks, bug fixes, and the betting table.

**Cycle**: A six-week period where teams work uninterrupted on shaped projects.

**De-Risk**: The process of removing rabbit holes and unknowns from shaped work to improve odds of shipping within one cycle.

**Discovered Tasks**: Tasks the team finds only after starting real work. These make up the true bulk of any project.

**Downhill**: The execution phase of work where all unknowns are solved and only implementation remains.

**Fat Marker Sketch**: A very low-fidelity UI sketch drawn with a thick line, making detail impossible. Used when visual arrangement is the core problem.

**Frame**: The document produced by the framing step. Contains the problem, affected segment, business value, evidence, and appetite. See `08-framing.md`.

**Frame Go**: Approval gate after framing. Means: "This problem matters. Invest shaping time." Authorizes the shaper to spend time designing a technical solution.

**Framing**: The formal step before shaping where a problem is investigated, narrowed, and evaluated for business value and urgency. Answers: "Does this matter enough to shape?" See `08-framing.md`.

**Hill Chart**: A visualization showing work status on a spectrum from unknown (uphill) to known (downhill) to done.

**Iceberg**: A scope where backend work vastly exceeds UI complexity (or vice versa). Requires factoring into smaller scopes.

**Imagined Tasks**: Tasks the team thinks they need based on thinking about the project, before doing real work. Often inaccurate.

**Layer Cake**: A scope with evenly distributed UI and backend work. Can be estimated by UI surface area.

**Nice-to-Have**: A task marked with `~` prefix. Done only if time permits; cut without guilt if not.

**Must-Have**: A task required for a scope to be considered done. Survives scope hammering.

**No-Go**: An explicit exclusion stated in the pitch. Functionality deliberately NOT included.

**Package**: The evolved term for "Pitch." A document with five ingredients (Problem, Appetite, Solution, Rabbit Holes, No-Gos) presented at the betting table. Called "Package" because the business already bought in during framing — this isn't a sales pitch, it's a complete bundle of all project variables.

**Pitch** (legacy term): See **Package**. The original book used "Pitch" but Ryan Singer later noted that "pitching" better describes the input to framing (advocating a problem deserves attention), not the output of shaping.

**Rabbit Hole**: A part of a project that is too unknown, complex, or open-ended to safely bet on without resolution.

**Raw Idea**: A feature request or idea expressed only in words. Not yet shaped. Default response: "Interesting. Maybe some day."

**Scope**: A part of a project that can be built, integrated, and finished independently. Bigger than a task, much smaller than the project. Becomes the project's working vocabulary.

**Scope Hammering**: Forcefully questioning every piece of work to determine if it truly deserves time within the fixed time box.

**Shape Go**: Approval gate after shaping. Means: "Solution is viable, all unknowns resolved. Ready for a build commitment."

**Shaping**: The process of making a framed problem concrete by defining key elements, technical wiring, and risks. Happens AFTER framing. Produces a Package.

**Six Weeks**: The cycle length. Long enough to finish something meaningful; short enough to feel the deadline from day one.

**Small Batch**: A set of 1-2 week projects that a single team ships within one six-week cycle.

**Big Batch**: One project that occupies a team for a whole cycle.

**Uphill**: The phase of work where unknowns and unsolved problems remain. Requires investigation and problem-solving.

## Shaping Properties

Shaped work must have all three:

1. **Rough**: Visibly unfinished. Open spaces for interpretation. Prevents premature commitment.
2. **Solved**: Main elements connect at macro level. Direction is clear. Open questions identified.
3. **Bounded**: Defines what NOT to do. Where the team stops. Appetite enforces limits.
