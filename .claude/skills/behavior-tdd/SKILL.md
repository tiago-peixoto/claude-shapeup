---
name: behavior-tdd
description: >
  Use this skill BEFORE changing what any agent in this plugin does — editing any
  skills/*/SKILL.md prompt, a references/* doc, or a behavioral contract. It drives the change
  strictly test-first with the isolated behavioral harness and an ablation negative-control, then
  commits cleanly with a single version bump. Invoke whenever you are implementing a new agent
  behavior or modifying an existing one in this repo, so prompt edits never ship on vibes.
allowed-tools: Bash Read Write Edit Glob Grep Agent Workflow
---

# Behavior-change TDD (for this plugin)

This repo's agent behavior is defined by prompt text (`skills/*/SKILL.md`, `references/*`), not
code. A prompt edit can silently change outcomes while every deterministic test still passes.
This skill is the **mandatory procedure** for changing behavior here. The rule:

> **Deterministic checks for scaffolding. LLM-as-judge for outcomes. An ablation proves the
> prompt is what caused the change — not the model's defaults.**

Read `CLAUDE.md` and `CONTRIBUTING.md` first; this skill operationalizes them.

## When to use

- Editing any `skills/<phase>/SKILL.md`, a `references/*.md`, or a shared script the skills call.
- Adding or changing a behavioral invariant (a new commit rule, a renamed status, a reshaped
  artifact, a new "the agent must/never…").

**Do NOT** use for pure scaffolding (hook/script logic with exact-text assertions) — that's the
unit layer only. And never edit speculatively: start from a concrete signal (a failing test, a
user complaint, an observed bad run). No signal → no edit.

## The loop (RED → edit → GREEN → regression → commit)

### 1. Establish the behavioral RED — and prove the test bites
- Write or locate a **criterion** (`tests/behavioral/criteria/<name>.md`) and a **scenario**
  (`tests/behavioral/scenarios/<name>.md`). Criteria are **binary** pass/fail propositions that
  name the exact observable behavior; the judge must cite evidence (see `judge-rubric.md`).
- Confirm it **FAILs against the current prompt**:
  ```bash
  bash tests/behavioral/run-behavioral.sh <scenario>
  ```
- **Ablation (negative control) — non-negotiable.** Confirm the criterion needs the prompt:
  ```bash
  bash tests/behavioral/run-behavioral.sh --ablate <scenario>   # must print "OK: fails without the skill"
  ```
  If ablation prints `CONTAMINATED`, the criterion passes with a neutral prompt — it's measuring
  the model (or the scenario leaks the answer), not your SKILL. **Tighten the criterion** until
  it hinges on prompt-specific mechanism, then re-ablate. (This is the "confirm-the-red" /
  scaffold-removal discipline; a *passing* ablation is a failed test.)

### 2. Make the prompt edit
One concern at a time. Match the surrounding wording, density, and idiom.

### 3. GREEN — multi-sample, don't trust one run
- Unit first (deterministic; grounding + any structural pins):
  ```bash
  bash tests/run-all.sh --unit
  ```
- Then the scenario, **pass^k** (run ≥3×; require it to pass every/most runs — behavioral is
  noisy, so a single green is not green):
  ```bash
  for i in 1 2 3; do bash tests/behavioral/run-behavioral.sh <scenario>; done
  ```

### 4. Regression — sentinels hold, nothing newly contaminated
- Run the affected scenarios ×2 and confirm the **frozen sentinels** still pass (currently
  `phase-boundaries` via `frame-user-proposes-solution`, `vertical-scopes` via
  `scope-discovery-api-project` — they must never regress on an unrelated edit).
- Re-run the whole negative control:
  ```bash
  bash tests/behavioral/run-behavioral.sh --ablate-all   # 0 contaminated
  ```
- If a criterion's **contract** intentionally changed (e.g. checkboxes → behaviors), update that
  criterion/scenario in the **same commit** as the prompt edit — that's an intentional change,
  not a regression. A sentinel you did NOT mean to touch going red **is** a regression: fix the
  prompt, not the test.

### 5. Commit discipline + single version bump
- **One SKILL = one commit.** Never combine edits to two SKILLs. Tests for that change ride along.
- **Suppress the per-commit auto-bump** so a multi-commit PR bumps the version only once:
  ```bash
  BUMPING_VERSION=1 git add <files>
  BUMPING_VERSION=1 git commit -m "…"
  ```
  (The `post-commit` hook short-circuits on `BUMPING_VERSION=1`.)
- When the PR is ready, do **one deliberate bump**: edit `.claude-plugin/plugin.json` +
  `marketplace.json` (minor/major for breaking: new files, renamed statuses, reshaped artifacts;
  patch otherwise) in a final commit. Because that commit changes the version line, the hook sees
  it and does not double-bump.

## Isolation guarantees (why the harness is trustworthy)

`run-behavioral.sh` runs every `claude` call from a throwaway temp cwd with `--tools ""` and
`--no-session-persistence` (`iso_claude`). Project memory and `CLAUDE.md` are cwd-keyed, so they
do **not** leak into the agent-under-test — the only instruction context is the scenario + the
SKILL.md you pass. Do not "fix" a failing eval by adding the answer to memory or CLAUDE.md; that's
contamination, and the ablation/isolation is designed to expose it.

## Large or multi-file changes: orchestrate with a Workflow

For a change that spans a SKILL + its criteria + references + a version bump, drive it with a
background **Workflow** that gates each commit on the unit + pass^k + regression checks above.
A worked, reusable template is committed next to this skill:
`./example.workflow.mjs` — adapt its edit spec, scenario list, and commit messages. Launch with
`Workflow({ scriptPath: ".claude/skills/behavior-tdd/example.workflow.mjs" })` after editing.

## Checklist before you call it done
- [ ] Started from a concrete signal.
- [ ] Behavioral RED confirmed **and** ablation proved the prompt is necessary.
- [ ] `--unit` green (grounding + structural pins).
- [ ] Scenario green pass^k (≥3 runs).
- [ ] Frozen sentinels still pass; `--ablate-all` shows 0 contaminated.
- [ ] One SKILL = one commit; per-commit bump suppressed; single version bump when PR-ready.
- [ ] Breaking contract change → minor/major bump + `BREAKING CHANGE:` in the body + legacy path
      kept for one release.
