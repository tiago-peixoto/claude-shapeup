# Shape Up Skills for Claude Code

A set of four Claude Code skills that implement the [Shape Up](https://basecamp.com/shapeup) methodology for AI-assisted product development. These skills guide an AI agent through the full product lifecycle — from raw idea to shipped feature — using fixed time, variable scope principles.

## What is Shape Up?

Shape Up is a product development methodology created by Ryan Singer at Basecamp (now 37signals). Instead of backlogs and sprints, Shape Up uses a fixed time-box (typically 6 weeks) with variable scope: you commit to a time budget, then shape the work to fit within it. The core pipeline is **Frame → Shape → Build → Ship**.

This project translates that methodology into structured AI agent workflows, so Claude Code can run each phase interactively with a human product engineer.

## Skills

### `/frame` — Lock the problem before designing solutions

Runs an interactive session to investigate a raw idea or feature request. Produces a Frame document that captures the problem, affected users, business value, and time appetite. Ends with a **Frame Go** gate — no shaping begins until the problem is locked.

### `/shape` — Design a technical solution grounded in the codebase

Takes a Frame Go–approved problem and designs a solution through deep codebase analysis. Extracts numbered requirements (R0, R1...), builds affordance tables mapping UI and code, runs a fit check matrix (R × Solution), resolves all unknowns via time-boxed spikes, and produces a Package document. Ends with a **Shape Go** gate.

### `/build` — Execute with TDD, hill charts, and scope hammering

Implements the shaped Package using test-driven development. Orients on the codebase, picks a first piece (core/small/novel), discovers scopes, tracks progress on hill charts, and scope-hammers when capacity runs low. Writes handover documents for multi-session continuity.

### `/ship` — Archive decisions and consolidate knowledge

Reads the entire feature folder, extracts architectural decisions into ADRs (`docs/decisions/`), updates `docs/architecture.md`, renames the feature folder to `-shipped`, and regenerates the project dashboard.

## Installation

Copy the `.claude/` directory into your project root:

```bash
cp -r .claude/ /path/to/your-project/.claude/
```

If your project already has a `.claude/` directory:

```bash
cp -r .claude/skills/shapeup-* /path/to/your-project/.claude/skills/
cp .claude/hooks/ripple-check.sh /path/to/your-project/.claude/hooks/
```

Then merge the hook configuration from `.claude/settings.local.json` into your existing settings file.

The skills will be available in Claude Code as `/frame`, `/shape`, `/build`, and `/ship`.

## Project Structure

```
.claude/
├── hooks/
│   └── ripple-check.sh          # PostToolUse hook for cross-document consistency
├── settings.local.json           # Hook registration
└── skills/
    ├── shapeup-frame/
    │   ├── SKILL.md              # Framing session instructions
    │   ├── scripts/
    │   │   └── init-feature.sh   # Creates numbered feature folders
    │   └── references/           # Shape Up methodology docs (9 files)
    ├── shapeup-shape/
    │   ├── SKILL.md              # Shaping session instructions
    │   ├── scripts/
    │   │   └── validate-package.sh  # Checks for TBDs, missing sections, ⚠️ flags
    │   └── references/
    ├── shapeup-build/
    │   ├── SKILL.md              # Build cycle instructions
    │   ├── scripts/
    │   │   └── update-hillchart.sh  # Hill chart initialization and display
    │   └── references/
    └── shapeup-ship/
        ├── SKILL.md              # Ship and archive instructions
        ├── scripts/
        │   └── regenerate-index.sh  # Dashboard generation from feature folders
        └── references/

.shapeup/                         # Created at runtime — feature folders live here
├── 001-feature-name-framing/
│   ├── frame.md
│   ├── package.md
│   ├── hillchart.md
│   └── scopes/
├── 002-another-feature-shipped/
└── index.md                      # Auto-generated dashboard
```

## The Ripple-Check Hook

A PostToolUse hook that fires whenever a `.shapeup/**/*.md` file is written or edited. It prints context-aware reminders about cross-document consistency — for example, if you modify `frame.md`, it reminds the agent to check whether `package.md` still aligns. Advisory only, never blocks.

## Acknowledgments

This project stands on the shoulders of Ryan Singer's work.

**The Shape Up book** — the foundation for everything here. Written by Ryan Singer and published by 37signals (formerly Basecamp). The full book is freely available at [basecamp.com/shapeup](https://basecamp.com/shapeup). If you're new to Shape Up, read the book first — these skills are a complement, not a replacement.

**Ryan Singer's articles** — two posts significantly shaped (pun intended) the evolution of these skills beyond the original book:

- [Framing](https://www.ryansinger.co/framing/) — introduces Framing as a formal step before Shaping, and renames "Pitch" to "Package". This directly informed our `/frame` skill and the Frame Go gate.
- [Pitfalls When Adopting Shape Up](https://www.ryansinger.co/pitfalls-when-adopting-shape-up/) — identifies the three most common failure modes, especially undershaped work as the #1 killer. This informed our emphasis on deep codebase analysis and the zero-TBD rule.

**Ryan Singer's [shaping-skills](https://github.com/rjs/shaping-skills) repository** — Ryan's own Claude Code skills for shaping. Several concepts from his implementation were absorbed into this project, including: formal requirement notation, fit check matrices, affordance tables with wiring, flagged unknowns, and the spike pattern for resolving them. His approach to structured shaping through AI agents was a key reference point. If you're looking for an alternative take on AI-assisted shaping, check out his repo.

## License

MIT

## Contributing

These skills were designed to be forked and adapted. The reference documents in each skill's `references/` directory are self-contained — no external dependencies. Modify the SKILL.md files to match your team's workflow, add new reference docs for your domain, or create entirely new skills for phases we haven't covered (like a `/bet` skill for the betting table).
