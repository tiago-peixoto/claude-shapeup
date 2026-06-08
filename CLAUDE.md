# Working on this repo (baseline instructions for any Claude agent)

This repo is a Claude Code plugin. Its skills under `skills/*/SKILL.md` are
mostly prompts — the agent's behavior is defined by the text, not by code.
A prompt edit can silently shift what the agent produces, even when every
deterministic test still passes. Full rationale:
[`CONTRIBUTING.md`](./CONTRIBUTING.md).

## One-time setup (per clone)

Run once after cloning, to activate the local git hooks that enforce the
workflow at commit and push time:

```bash
bash scripts/setup-hooks.sh
```

This points `core.hooksPath` at `.githooks/` (tracked in the repo), so
the hooks stay in sync as the repo evolves.

## Test architecture (two layers, no snapshots)

| Layer | Subject | Determinism | Where it fires |
|---|---|---|---|
| Unit | Hooks, scripts, prompt structure (placeholder grounding, `$FEATURE_DIR` block locality, hook wiring) | Deterministic — exact text assertions | `tests/unit/*.sh`; runs on `pre-commit` |
| Behavioral | Agent outcomes via LLM-as-judge against rubric-based scenarios | Non-deterministic — evaluated by meaning, not text | `tests/behavioral/`; runs on `pre-push` when prompts / hooks / references change |

There is **no snapshot/baseline layer**. Exact-text diffs against a
non-deterministic generator are a category error. Regressions on meaning belong
in the behavioral layer; regressions on scaffolding belong in the unit layer.

## Before editing a prompt

**Use the `behavior-tdd` skill** (`.claude/skills/behavior-tdd/`) for any change to agent
behavior — editing a `skills/*/SKILL.md`, a `references/*` doc, or a behavioral contract. It
operationalizes the steps below: establish the behavioral RED, prove it with the ablation
negative-control (`run-behavioral.sh --ablate`), edit, verify GREEN pass^k + unit + regression,
and commit cleanly with a single version bump. Don't hand-roll prompt edits without it.

1. Start from a concrete signal: a failing test, a user complaint, or a
   behavioral scenario. No speculative rewording — if you can't describe
   what's broken, don't edit.
2. Run `bash tests/run-all.sh --unit`. Must be green before continuing.
3. Dispatch an Explore subagent to audit the current state of the skill
   you plan to edit. Do not edit blind.

## After editing a prompt

1. Run unit tests again:
   ```bash
   bash tests/run-all.sh --unit
   ```
2. If the change is semantic (not just wording), run the behavioral suite:
   ```bash
   bash tests/run-all.sh --behavioral
   ```
   Behavioral is non-deterministic — treat a single FAIL as a flag to
   re-run once, not a hard block. Consistent failures are real regressions.
3. If the change introduces a new outcome invariant — e.g. a new commit rule,
   a renamed status, a reshaped artifact — add a scenario under
   `tests/behavioral/scenarios/` and a criterion under
   `tests/behavioral/criteria/` that pins the new invariant.

## Commit discipline

- **One SKILL = one commit.** Never combine edits to multiple SKILLs in a
  single commit — regressions become impossible to attribute.
- **Never manually edit `plugin.json` / `marketplace.json` versions.** The
  `post-commit` hook bumps the patch automatically and folds the bump into
  the commit that just landed. Exception: explicit minor or major bumps for
  breaking changes (new files emitted, status labels renamed, step numbers
  shifted) — edit the JSONs in the same commit and the hook will see the
  version already changed and skip the auto-bump.
- **Never skip hooks with `--no-verify`** unless you know exactly why and
  the tests that would have fired are irrelevant to the change.

## Hard rules (enforced by `tests/unit/test-prompt-grounding.sh`)

These fail the unit suite, which fails the pre-commit hook, which blocks
the commit:

- Every `<plugin-root>`, `<skill-dir>`, `<project-root>` placeholder in a
  SKILL.md MUST have a definition in that same file (a table row or a
  bulleted list item of the form `` - **`<name>`**: <definition> ``).
- Every `$FEATURE_DIR` reference inside a ```bash``` block MUST be assigned
  locally at the top of that same block, **before** first use. Claude
  Code's Bash tool spawns a fresh subprocess per call — shell state does
  not persist between invocations.

If these tests fail on your change, fix the prompt. Do not edit the test
to silence them.

## Breaking prompt changes

A prompt change is breaking when it shifts the contract the agent gives
the user: new files emitted, existing files removed, status labels
renamed, step numbers reordered. For breaking changes:

1. Edit `plugin.json` and `marketplace.json` in the same commit as the
   breaking edit to bump the minor or major version (the post-commit hook
   only bumps patch, and skips when it sees the version already changed in
   the commit).
2. Explicitly describe the break in the commit body.
3. Keep any legacy-path support (e.g. the resolver's NNN fallback) for at
   least one release after the break.

## When in doubt

- Path and environment variable conventions: see the "Paths and Variables"
  section at the top of each SKILL.md.
- Test-layer responsibilities: see `CONTRIBUTING.md` § Test layers.
- How to extend the grounding tests when you find a new class of mistake:
  `tests/unit/test-prompt-grounding.sh` is itself part of the contract —
  add a new check when you discover a new failure mode.
