# Shape Up Skills for Claude Code

Four Claude Code skills that teach your AI agent the [Shape Up](https://basecamp.com/shapeup) methodology. Fixed time, variable scope, zero hand-waving.

**Frame** the problem. **Shape** the solution. **Build** the code. **Ship** the knowledge.

## Why?

Backlogs are where ideas go to die. Shape Up replaces the infinite todo list with a simple bet: pick a time budget, shape the work to fit, build it, ship it. This project gives Claude Code the vocabulary and guardrails to run that process with you — interactively, one feature at a time.

## The Skills

| Skill | What it does | Gate |
|-------|-------------|------|
| `/shapeup:frame` | Turns a vague idea into a locked problem statement with appetite | Frame Go |
| `/shapeup:shape` | Deep codebase analysis → requirements, affordance tables, fit check matrix, Package | Shape Go |
| `/shapeup:build` | TDD, hill charts, scope hammering, handovers for multi-session work | Ready to Ship |
| `/shapeup:ship` | Extracts ADRs, updates architecture docs, archives the feature folder | Done |

Each skill is self-contained with its own reference docs — no external dependencies, no magic.

## Quick Start

In Claude Code, run:

```
/plugin marketplace add tiago-peixoto/claude-shapeup
/plugin install shapeup
```

Type `/shapeup:frame` and follow the conversation.

## What Happens at Runtime

```
.shapeup/
├── 001-csv-import-framing/       # Active: being framed
│   └── frame.md
├── 002-auth-refresh-shaped/      # Ready: waiting for a build bet
│   ├── frame.md
│   └── package.md
├── 003-dashboard-v2-building/    # In progress
│   ├── frame.md
│   ├── package.md
│   ├── hillchart.md
│   ├── scopes/
│   └── handover-01.md
├── 004-search-shipped/           # Done: decisions archived
└── index.md                      # Auto-generated dashboard
```

Multiple features can run in parallel. Each one is a numbered folder with a status suffix.

## The Ripple-Check Hook

A PostToolUse hook that watches `.shapeup/**/*.md` edits. When the agent modifies `frame.md`, it gets a nudge: "Does the package still match?" When `package.md` changes: "Do the scopes still align?" Advisory only — it reminds, never blocks.

## Project Structure

```
.claude-plugin/
├── plugin.json
└── marketplace.json
hooks/
└── ripple-check.sh
skills/
├── frame/
│   ├── SKILL.md
│   ├── scripts/init-feature.sh
│   └── references/              # 9 methodology docs per skill
├── shape/
│   ├── SKILL.md
│   ├── scripts/validate-package.sh
│   └── references/
├── build/
│   ├── SKILL.md
│   ├── scripts/update-hillchart.sh
│   └── references/
└── ship/
    ├── SKILL.md
    ├── scripts/regenerate-index.sh
    └── references/
```

## Acknowledgments

This project exists because of [Ryan Singer](https://www.ryansinger.co/)'s work.

The **[Shape Up book](https://basecamp.com/shapeup)** is the foundation — written by Ryan and published by 37signals. It's free to read online and you should read it before using these skills. We distilled it; we didn't replace it.

Two of Ryan's articles pushed the methodology further and directly shaped these skills. **[Framing](https://www.ryansinger.co/framing/)** introduced a formal step before shaping — lock the problem before you design solutions — which became our `/shapeup:frame` skill and the Frame Go gate. It also renamed "Pitch" to "Package," and we followed suit. **[Pitfalls When Adopting Shape Up](https://www.ryansinger.co/pitfalls-when-adopting-shape-up/)** identified undershaped work as the #1 failure mode, which is why `/shapeup:shape` obsesses over actual codebase analysis and enforces zero TBDs.

Ryan's own **[shaping-skills](https://github.com/rjs/shaping-skills)** repo for Claude Code was a direct inspiration. We absorbed several of his ideas: formal requirement notation (R0, R1...), fit check matrices, affordance tables with wiring, flagged unknowns, and time-boxed spikes for resolving them. If you want a different take on AI-assisted shaping, check his repo out.

## License

MIT

## Contributing

Fork it, break it, make it yours. Each skill's `references/` directory is self-contained — swap in your own methodology docs, add domain-specific references, or build new skills for phases we skipped (a `/shapeup:bet` skill for the betting table, anyone?).
