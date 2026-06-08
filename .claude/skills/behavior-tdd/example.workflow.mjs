export const meta = {
  name: 'behavioral-tests-scope-feature',
  description: 'Apply the RED/GREEN behavioral-test model to the build SKILL, TDD-gated, with clean commits and one version bump',
  whenToUse: 'Driving the scope-checkboxes -> behavioral-tests change through build/ship/references with strict TDD and regression checks',
  phases: [
    { title: 'Edit build skill' },
    { title: 'Validate feature' },
    { title: 'Commit build' },
    { title: 'Regression' },
    { title: 'Ship + references' },
    { title: 'Version bump' },
    { title: 'Report' },
  ],
}

// ---------------------------------------------------------------------------
// Schemas
// ---------------------------------------------------------------------------
const EDIT_RESULT = {
  type: 'object',
  additionalProperties: false,
  properties: {
    applied: { type: 'boolean' },
    unit_passed: { type: 'boolean' },
    files_changed: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
    problems: { type: 'string' },
  },
  required: ['applied', 'unit_passed', 'files_changed', 'summary', 'problems'],
}

const BEHAV_RESULT = {
  type: 'object',
  additionalProperties: false,
  properties: {
    scenario: { type: 'string' },
    runs: { type: 'integer' },
    passes: { type: 'integer' },
    fails: { type: 'integer' },
    notes: { type: 'string' },
  },
  required: ['scenario', 'runs', 'passes', 'fails', 'notes'],
}

const ABLATE_RESULT = {
  type: 'object',
  additionalProperties: false,
  properties: {
    scenario: { type: 'string' },
    prompt_needed: { type: 'boolean' },
    notes: { type: 'string' },
  },
  required: ['scenario', 'prompt_needed', 'notes'],
}

const COMMIT_RESULT = {
  type: 'object',
  additionalProperties: false,
  properties: {
    committed: { type: 'boolean' },
    sha: { type: 'string' },
    message_subject: { type: 'string' },
    problem: { type: 'string' },
  },
  required: ['committed', 'sha', 'message_subject', 'problem'],
}

// ---------------------------------------------------------------------------
// Shared context handed to editing agents
// ---------------------------------------------------------------------------
const MODEL =
  'The scope tracking unit changes from technical task checkboxes (- [ ] / - [x]) to ' +
  'BEHAVIORAL TESTS: each is a vertical slice describing a USER-NOTICEABLE change, carrying ' +
  'a RED/GREEN state. ASCII markers only: "- [RED]" (not yet observable) and "- [GREEN]" ' +
  '(the user-noticeable behavior works). Nice-to-haves keep the ~ marker: "- [RED] ~ ...". ' +
  'Must-have vs nice-to-have still applies, now attached to behaviors. A scope is done when ' +
  'its must-have behaviors are GREEN. Legacy - [ ]/- [x] scope files remain accepted by the ' +
  'parsers (back-compat) but the build prompt must now EMIT [RED]/[GREEN]. The consistency ' +
  'and session-budget scripts already understand both vocabularies (do not touch them).'

const BUILD_EDIT_INSTRUCTIONS = `
You are applying a precise, TDD-gated prompt change to a Claude Code plugin. Work ONLY on the
files listed. Do NOT touch hooks, scripts, plugin.json, marketplace.json, or any other SKILL.

CONTEXT (the model being introduced):
${MODEL}

Apply these edits with the Edit tool. Read each file first. Preserve surrounding wording,
formatting, and tone; change only what the transformation requires.

=== A. skills/build/SKILL.md ===
A1. Scope-file template (Step 3, "Discover and Map Scopes"): replace the "## Must-Haves" /
    "## Nice-to-Haves (~)" block (the markdown code sample with "- [ ] Task 1" etc.) with a
    behaviors-based template:

      ## Behaviors (must-have)
      <!-- Each behavior is a user-noticeable vertical slice. [RED] = not yet observable;
           [GREEN] = the user-noticeable behavior works (proven by a passing test / browser check). -->
      - [RED] <User can observe/do X end-to-end>
      - [RED] <User can observe/do Y end-to-end>

      ## Behaviors (nice-to-have, ~)
      - [RED] ~ <Nice-to-have user-noticeable behavior>

      ## Notes
      <Context, decisions, blockers; link backing automated tests here>

    Keep "# Scope: <Name>" and "## Hill Position" exactly as they are.

A2. Step 3 "Validate scope quality" and surrounding prose: where it says to classify TASKS as
    must-have vs nice-to-have, reframe to classifying BEHAVIORS (user-noticeable vertical
    slices) as must-have vs nice-to-have. Do not change the business-capability-not-technical-
    layer rule for scope NAMES — that stays.

A3. Step 4 substep E (the "Mark scope tasks as done ... tick [x]" instruction): replace with
    flipping behavior state: flip "[RED]" to "[GREEN]" for every must-have behavior that is now
    observable (its user-noticeable outcome actually works, proven by a passing test or browser
    check); leave "[RED]" for anything not yet observable; flip finished nice-to-have behaviors
    too; if a behavior was cut, move it under a "## Cut" heading or prefix with "~" — never
    silently delete. (Keep substeps F/G about Hill Position and hillchart.md intact.)

A4. Step 4 substep J commit bundle: where it lists "the touched scope file(s) — checkboxes +
    Hill Position line", change "checkboxes" to "behavior states ([RED]/[GREEN])".

A5. The "Tracking-update rule (non-negotiable)" paragraph: change "the scope file's checkbox"
    to "the scope file's behavior state ([RED]/[GREEN])".

A6. "Handling User Feedback During Build" section: where it says capture the discovery "as a
    task", change to capture it "as a behavioral test (a [RED] user-noticeable behavior)". In
    the <example> block, the items added to scopes (e.g. "~ Handle multi-currency invoices")
    should be phrased as user-noticeable behaviors with the [RED] / [RED] ~ markers.

A7. Step 0.5 "Verify Prior State" audit bullets: where it lists each must-have "task, whether
    it's [x]/[ ]", change to each must-have "behavior, whether it's [GREEN]/[RED]". Keep the
    "claimed done but no evidence" / "done on disk but still unchecked" logic, rephrased to
    GREEN/RED.

A8. Step 8 "Ready to Ship": where the pre-ship gate prose mentions "unchecked must-haves not
    explicitly cut", change to "RED must-have behaviors not explicitly cut".

A9. Anti-Patterns list: add one new bullet:
    "- **Tracking technical tasks instead of behaviors**: Scope items are user-noticeable
    behaviors that go [RED] -> [GREEN], not implementation steps or unit tests. 'Add endpoint'
    or 'write parser' is not a behavior; 'user filters invoices and the list updates' is."

A10. Anywhere else in build/SKILL.md that refers to scope "tasks", "checkboxes", "tick [x]",
    "[ ]"/"[x]" as the tracking unit, align it to behaviors and [RED]/[GREEN] — but do NOT
    change references to the consistency script, session-budget script, hill chart symbols
    (▲▼✓), or scope NAMING rules.

=== B. New structural unit test: tests/unit/test-build-scope-format.sh ===
Create a small deterministic bash unit test (same style as the other tests/unit/test-*.sh:
PASS/FAIL counters, exit "$FAIL"). It must assert that skills/build/SKILL.md:
  - contains the heading "## Behaviors (must-have)"
  - contains the heading "## Behaviors (nice-to-have, ~)"
  - contains "[RED]" and "[GREEN]"
  - no longer contains a literal "## Must-Haves" heading line in the scope template
Make it executable-safe (it will be run via 'bash'). Follow the exact output/exit conventions
of tests/unit/test-session-budget.sh so the runner (tests/run-all.sh) picks it up.

=== C. Refresh behavioral criteria/scenarios for the new vocabulary (INTENTIONAL contract change) ===
These describe build behaviors whose CONTRACT changed from checkboxes to behaviors. Update the
vocabulary while PRESERVING the original intent. Do NOT loosen them — a neutral prompt must
still fail them (they are ablation-guarded).

C1. tests/behavioral/criteria/commit-discipline.md: change "must-haves checked" / references to
    "[x]" so they read "must-have behaviors GREEN ([GREEN])". The one-commit bundling rule, the
    business-capability naming rule, and the handover-separate rule are UNCHANGED.
C2. tests/behavioral/scenarios/scope-completion-commit-discipline.md: in Expected Behavior, change
    "Tick the last must-have [x]" to "flip the last must-have behavior to [GREEN]". Keep
    everything else (one commit, business-capability scope name, no handover now).
C3. tests/behavioral/criteria/emergent-scope.md: change "capture it as a scope task" / "captures
    the user's feedback as a task" to "capture it as a [RED] behavioral test (a user-noticeable
    behavior) in a scope file". The do-NOT-reshape/reframe rule is UNCHANGED.
C4. tests/behavioral/scenarios/user-raises-concern-during-build.md: in Expected Behavior, change
    "capture ... as a task" to "capture ... as a [RED] behavioral test (a user-noticeable
    behavior)". Keep the scope-hammering-to-nice-to-have and keep-building intent.

DO NOT TOUCH (frozen regression sentinels): tests/behavioral/criteria/phase-boundaries.md,
tests/behavioral/criteria/vertical-scopes.md, tests/behavioral/scenarios/frame-user-proposes-solution.md,
tests/behavioral/scenarios/scope-discovery-api-project.md, tests/behavioral/criteria/nice-to-have-surfacing.md,
tests/behavioral/scenarios/must-haves-done-sessions-remain.md (already updated).

=== Validate ===
After all edits, run: bash tests/run-all.sh --unit
Report unit_passed=true only if it exits clean (all unit tests pass, including the new
test-build-scope-format.sh and the prompt-grounding test). If grounding fails, you introduced an
ungrounded <placeholder> or $FEATURE_DIR — fix it. List every file you changed.
Do NOT git commit anything. Return the structured result.
`

// ---------------------------------------------------------------------------
// Helpers used by validation agents
// ---------------------------------------------------------------------------
function runScenarioPrompt(scenario, k) {
  return (
    `Run this behavioral test ${k} time(s) and report the tally. Each run:\n` +
    `  bash tests/behavioral/run-behavioral.sh ${scenario}\n` +
    `The harness prints PASS or FAIL near the end of each run. Count how many of the ${k} runs ` +
    `printed PASS and how many printed FAIL. Do not edit any files. Be patient — each run calls ` +
    `the LLM twice and takes ~1-2 minutes. Return runs=${k}, passes, fails, and a short note ` +
    `quoting any FAIL reason you saw.`
  )
}

function ablatePrompt(scenario) {
  return (
    `Run the ablation (negative control) for this scenario once:\n` +
    `  bash tests/behavioral/run-behavioral.sh --ablate ${scenario}\n` +
    `A line "OK: fails without the skill (prompt is necessary)" means prompt_needed=true. ` +
    `A line "CONTAMINATED" means prompt_needed=false. Do not edit files. Return the result.`
  )
}

// ---------------------------------------------------------------------------
// Phase: Edit build skill (+ structural unit test + criteria refresh)
// ---------------------------------------------------------------------------
phase('Edit build skill')
log('Applying the behavioral-test model to build/SKILL.md + refreshing affected criteria...')
const editRes = await agent(BUILD_EDIT_INSTRUCTIONS, {
  label: 'edit:build+criteria',
  phase: 'Edit build skill',
  schema: EDIT_RESULT,
})

if (!editRes || !editRes.applied || !editRes.unit_passed) {
  return {
    status: 'STOPPED — unit gate failed',
    phase: 'Edit build skill',
    detail: editRes,
    next: 'No commit was made. Fix the unit failures (likely prompt-grounding or the new structural test) and re-run.',
  }
}
log(`Edits applied; unit tests green. Files: ${editRes.files_changed.join(', ')}`)

// ---------------------------------------------------------------------------
// Phase: Validate feature (pass^k on the build-authors scenario)
// ---------------------------------------------------------------------------
phase('Validate feature')
log('Validating the feature RED->GREEN: build-authors-behavioral-tests x3 (need >=2 PASS)...')
const featRes = await agent(runScenarioPrompt('build-authors-behavioral-tests', 3), {
  label: 'validate:build-authors',
  phase: 'Validate feature',
  schema: BEHAV_RESULT,
})

if (!featRes || featRes.passes < 2) {
  return {
    status: 'STOPPED — feature did not reach GREEN',
    phase: 'Validate feature',
    detail: featRes,
    edit: editRes,
    next: 'The build prompt edit did not reliably make build-authors-behavioral-tests pass. No commit was made. Inspect the working tree (uncommitted) and adjust the prompt.',
  }
}
log(`Feature GREEN: ${featRes.passes}/${featRes.runs} PASS.`)

// ---------------------------------------------------------------------------
// Phase: Commit build (single bump suppressed via BUMPING_VERSION=1)
// ---------------------------------------------------------------------------
phase('Commit build')
const buildCommit = await agent(
  `Stage and commit the build behavioral-test change as ONE commit, suppressing the version ` +
  `auto-bump. Run exactly:\n` +
  `  BUMPING_VERSION=1 git add skills/build/SKILL.md tests/unit/test-build-scope-format.sh ` +
  `tests/behavioral/criteria/behavioral-test-tracking.md tests/behavioral/scenarios/build-authors-behavioral-tests.md ` +
  `tests/behavioral/criteria/commit-discipline.md tests/behavioral/scenarios/scope-completion-commit-discipline.md ` +
  `tests/behavioral/criteria/emergent-scope.md tests/behavioral/scenarios/user-raises-concern-during-build.md\n` +
  `Then commit with BUMPING_VERSION=1 and this message (use a heredoc):\n` +
  `  feat(build)!: track scope work as RED/GREEN behavioral tests, not task checkboxes\n\n` +
  `  Scope files now record user-noticeable behaviors with [RED]/[GREEN] state instead of\n` +
  `  technical task checkboxes. Build authors behaviors RED and drives them GREEN via TDD.\n` +
  `  Refreshed the affected behavioral criteria/scenarios (commit-discipline, emergent-scope)\n` +
  `  to the behavior vocabulary; added a new behavioral-test-tracking criterion + scenario and\n` +
  `  a structural unit test. Parsers already accept legacy [ ]/[x] (back-compat).\n\n` +
  `  BREAKING CHANGE: scope-file artifact shape and status semantics changed.\n\n` +
  `  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>\n` +
  `Confirm: 'git rev-parse HEAD' (sha) and 'git log -1 --pretty=%s' (subject). The pre-commit ` +
  `hook runs unit tests; if it blocks, report the problem. Do NOT push. Verify the version in ` +
  `.claude-plugin/plugin.json did NOT change (BUMPING_VERSION=1 must have suppressed the bump).`,
  { label: 'commit:build', phase: 'Commit build', schema: COMMIT_RESULT },
)

if (!buildCommit || !buildCommit.committed) {
  return {
    status: 'STOPPED — build commit failed',
    phase: 'Commit build',
    detail: buildCommit,
    next: 'Edits validated but the commit did not land. Inspect git state.',
  }
}
log(`Build committed: ${buildCommit.sha} "${buildCommit.message_subject}"`)

// ---------------------------------------------------------------------------
// Phase: Regression (parallel) — sentinels must stay PASS, refreshed must PASS, ablations must hold
// ---------------------------------------------------------------------------
phase('Regression')
log('Running regression: 2 frozen sentinels + 3 refreshed scenarios (x2 each) + ablations...')

const SENTINELS = ['frame-user-proposes-solution', 'scope-discovery-api-project']
const REFRESHED = [
  'scope-completion-commit-discipline',
  'user-raises-concern-during-build',
  'must-haves-done-sessions-remain',
]
const ALL_REG = SENTINELS.concat(REFRESHED)

const regRuns = await parallel(
  ALL_REG.map((s) => () =>
    agent(runScenarioPrompt(s, 2), { label: `regress:${s}`, phase: 'Regression', schema: BEHAV_RESULT }),
  ),
)
const ablRuns = await parallel(
  ALL_REG.concat(['build-authors-behavioral-tests']).map((s) => () =>
    agent(ablatePrompt(s), { label: `ablate:${s}`, phase: 'Regression', schema: ABLATE_RESULT }),
  ),
)

const reg = regRuns.filter(Boolean)
const abl = ablRuns.filter(Boolean)

const sentinelRegressions = reg.filter((r) => SENTINELS.includes(r.scenario) && r.passes < 2)
const refreshedFails = reg.filter((r) => REFRESHED.includes(r.scenario) && r.passes < 1)
const contaminated = abl.filter((a) => !a.prompt_needed)

const regressionClean = sentinelRegressions.length === 0 && refreshedFails.length === 0

if (!regressionClean) {
  return {
    status: 'STOPPED — regression detected after build commit',
    phase: 'Regression',
    buildCommit,
    sentinelRegressions,
    refreshedFails,
    contaminated,
    regression: reg,
    ablation: abl,
    next: 'The build commit landed but a sentinel/refreshed scenario regressed. Review and consider `git revert ' + buildCommit.sha + '`. Ship/references/version-bump were NOT applied.',
  }
}
log('Regression clean: sentinels hold, refreshed scenarios pass, ablations prompt-dependent.')

// ---------------------------------------------------------------------------
// Phase: Ship + references edits (each its own commit, bump suppressed)
// ---------------------------------------------------------------------------
phase('Ship + references')

const shipCommit = await agent(
  `Edit skills/ship/SKILL.md ONLY (one SKILL = one commit). CONTEXT:\n${MODEL}\n\n` +
  `Changes: in Step 0 the Explore-subagent audit question asks about every must-have listed as ` +
  `"[x]" — change it to ask about every must-have behavior marked "[GREEN]" (and missing/RED ` +
  `evidence). Anywhere the pre-ship gate prose refers to unchecked/[x] must-haves, reframe to ` +
  `"RED must-have behaviors". Do not change ship's actual steps, ADR logic, or the consistency-` +
  `script invocation. Then run 'bash tests/run-all.sh --unit' (must pass — grounding). Commit ` +
  `ONLY skills/ship/SKILL.md with BUMPING_VERSION=1 and message:\n` +
  `  refactor(ship): pre-ship gate speaks RED/GREEN behaviors, not task checkboxes\n\n` +
  `  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>\n` +
  `Suppress the version bump (BUMPING_VERSION=1 on both add and commit). Confirm sha + subject; ` +
  `confirm plugin.json version unchanged. Do NOT push.`,
  { label: 'commit:ship', phase: 'Ship + references', schema: COMMIT_RESULT },
)
if (shipCommit && shipCommit.committed) log(`Ship committed: ${shipCommit.sha}`)

const refsCommit = await agent(
  `Edit ONLY files under references/ to align the documented model with the behavioral-test ` +
  `change. CONTEXT:\n${MODEL}\n\n` +
  `Files and changes:\n` +
  `- references/00-glossary.md: update the Must-Have/Nice-to-Have entries to note behaviors carry ` +
  `RED/GREEN state; add a short "Behavioral Test" entry (a user-noticeable vertical slice tracked ` +
  `RED->GREEN). Keep alphabetical/section ordering sensible.\n` +
  `- references/02-building-process.md: where scopes track must-have/nice-to-have TASKS, reframe to ` +
  `BEHAVIORS tracked RED->GREEN (user-noticeable). Keep everything else.\n` +
  `- references/04-scope-hammering-rules.md: where it classifies TASKS as must/nice, note these are ` +
  `behaviors now; keep the hammering questions intact.\n` +
  `- references/06-agent-workflow-guide.md: in the Building Track, "Classify tasks: must-have vs ` +
  `nice-to-have" -> classify BEHAVIORS; keep the rest.\n` +
  `Do NOT touch any SKILL.md, scripts, or hooks. Then run 'bash tests/run-all.sh --unit' (must ` +
  `pass). Commit ONLY the changed references/*.md with BUMPING_VERSION=1 and message:\n` +
  `  docs(references): describe scope work as RED/GREEN behaviors, not tasks\n\n` +
  `  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>\n` +
  `Suppress the bump. Confirm sha + subject; confirm plugin.json version unchanged. Do NOT push.`,
  { label: 'commit:references', phase: 'Ship + references', schema: COMMIT_RESULT },
)
if (refsCommit && refsCommit.committed) log(`References committed: ${refsCommit.sha}`)

// ---------------------------------------------------------------------------
// Phase: Single version bump (PR-ready) — minor bump for the breaking change
// ---------------------------------------------------------------------------
phase('Version bump')
const bumpCommit = await agent(
  `Do the SINGLE version bump for this PR. Current version is 1.2.5; this PR is a breaking ` +
  `change, so bump the MINOR: set "version" to "1.3.0" in BOTH .claude-plugin/plugin.json and ` +
  `.claude-plugin/marketplace.json (replace the 1.2.5 string). Then:\n` +
  `  git add .claude-plugin/plugin.json .claude-plugin/marketplace.json\n` +
  `  git commit -m "chore(release): bump version to 1.3.0 (behavioral-test scope model)"\n` +
  `Because the commit itself changes the version line, the post-commit hook will see it and NOT ` +
  `double-bump (no BUMPING_VERSION needed). Confirm with 'git log -1 --pretty=%s' and ` +
  `'grep version .claude-plugin/plugin.json'. The final version MUST read 1.3.0 (not 1.3.1). Do NOT push.`,
  { label: 'commit:bump', phase: 'Version bump', schema: COMMIT_RESULT },
)
if (bumpCommit && bumpCommit.committed) log(`Version bump committed: ${bumpCommit.sha}`)

// ---------------------------------------------------------------------------
// Phase: Report
// ---------------------------------------------------------------------------
phase('Report')
return {
  status: 'COMPLETE',
  edit: editRes,
  feature_validation: featRes,
  commits: {
    build: buildCommit,
    ship: shipCommit,
    references: refsCommit,
    version_bump: bumpCommit,
  },
  regression: reg,
  ablation: abl,
  contaminated_after_change: contaminated,
  notes:
    'Strict TDD: build edit gated on unit (grounding + structural) then pass^k feature scenario; ' +
    'commits suppress per-commit auto-bump (BUMPING_VERSION=1) with one deliberate minor bump to ' +
    '1.3.0 at the end. Frozen sentinels (phase-boundaries, vertical-scopes) re-verified; refreshed ' +
    'criteria re-verified; ablation re-run so every criterion stays prompt-dependent.',
}
