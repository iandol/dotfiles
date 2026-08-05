---
name: cagelab-task-development
description: "Author and refactor CageLab cltasks/start*.m task functions."
version: 1.0.0
metadata:
  hermes:
    tags: [matlab, cagelab, opticka, psychtoolbox, behavioral-task, ied]
    related_skills: [alyx-api, matlab-class-based-tests]
---

# CageLab Task Development

Author, refactor, and debug CageLab behavioral task functions in the
`+cltasks/` package. These are MATLAB functions that run visual/touch
behavioral paradigms using Opticka + Psychtoolbox-3.

## When to Use

- Writing a new `+cltasks/start*.m` task function
- Merging duplicate task variants into a unified parameterized function
- Modifying stimulus selection, stage progression, or trial loop logic
- Updating `+clutil/checkInput.m` to add or modify task routing
- Working with morphobes dataset metadata lookups
- Debugging IED (Intra-Dimensional / Extra-Dimensional) set-shifting tasks

## Task Anatomy

Every `start*.m` task follows the same skeleton. Understanding this shared
structure is essential for refactoring — ~70% of code is identical across
tasks, with differences concentrated in stimulus configuration and result
logic.

```
1. Input parsing          — if ~exist('in','var'); in = struct(...); end
2. clutil.checkInput(in)  — apply defaults from the switch(in.task) router
3. Stage/task parsing     — split taskType into string array, validate stages
4. Dataset setup          — load metadata.csv, build lookupPNG lambda
5. Stimulus creation      — imageStimulus + metaStimulus, grid positions
6. Setup & hide           — setup(r.fix, sM); setup(targets, sM); hide(targets)
7. IED progression state  — r.stageIdx, r.consecutiveCorrect, r.stageIncorrect
8. Trial loop (while r.keepRunning)
   a. clutil.initTrialVariables(r)
   b. Determine stage parameters (setNum, relDim, correctIdx, exemplar)
   c. Select stimuli (dimLevels lookup, randperm positions)
   d. Log to r.store (all per-trial fields for offline analysis)
   e. showSet + update targets
   f. clutil.ensureTouchRelease → clutil.initTouchTrial
   g. Stimulus presentation while-loop (draw, flip, testHold, KbCheck)
   h. Result logic (-5 no-init / 0 incorrect / 1 correct / -1 unknown)
   i. clutil.ensureTouchRelease → clutil.updateTrialResult
   j. Stage progression (criterion check, maxIncorrect check)
9. clutil.endTask(dt, in, r, sM, tM, rM, aM)
10. catch block — cleanup (reset, close, Priority, ShowCursor), rethrow
```

### Shared clutil infrastructure

| Function | Purpose |
|---|---|
| `clutil.checkInput(in)` | Apply per-task defaults via `switch in.task` |
| `clutil.initialise(in, bgName, prefix)` | Create sM, aM, rM, tM, r, dt; load background |
| `clutil.initTrialVariables(r)` | Reset per-trial state (preserves IED progression fields) |
| `clutil.ensureTouchRelease(r, tM, sM, afterResult)` | Wait for touch release before/after trial |
| `clutil.initTouchTrial(r, in, tM, sM, dt)` | Initialize touch window for trial initiation |
| `clutil.updateTrialResult(in, dt, r, sM, tM, rM, aM)` | Log trial, deliver reward/audio feedback |
| `clutil.endTask(dt, in, r, sM, tM, rM, aM)` | Save data, cleanup, broadcast final trial |
| `clutil.broadcastTrial(in, r, dt, status)` | Send trial data via ØMQ |

### The catch block pattern

All tasks share an identical catch block (cleanup + rethrow). The only
variation is the error prefix string in the `writelines` call. When merging
tasks, this block is identical — just update the prefix.

## checkInput.m Task Routing

`+clutil/checkInput.m` contains a `switch in.task` block that sets per-task
defaults. Task types map to function entry points:

| `in.task` | Function | Description |
|---|---|---|
| `'ied'` | `startIEDmorphobes` | 2-target IED (numTargets=2, unified dataset) |
| `'ied-2'` | `startIEDmorphobes` | 2-target IED (4D-style display defaults) |
| `'ied-4'` | `startIEDmorphobes` | 4-target IED (numTargets=4, unified dataset) |
| `'dmts'` etc. | `startMatchToSample` | Match-to-sample variants |
| (others) | respective `start*.m` | |

When adding a new task variant, add a `case` to this switch. When merging
variants, split a combined case into separate cases that set the
distinguishing parameter (e.g., `numTargets`). The `'ied'` case uses 2D
display defaults (objectSize=10, objectSep=15); `'ied-2'`/`'ied-4'` share
4D-style defaults (objectSize=8, objectSep=12). New IED defaults depend on
the effective `numTargets`: `distractors` and `useExemplars` default to
`false` for 2 targets (classic simple discrimination) and `true` for 4
targets (compound display with per-trial exemplars).

### CRITICAL: never stomp user-supplied fields in the switch

The `CageLab.mlapp` GUI always sends `opts.task='ied'` **plus** the user's
real choices (`numTargets`, `idDimension`, `edDimension`, `criterion`,
`maxIncorrect`, `taskType`). If the `case` block assigns these
unconditionally, it silently erases what the user actually picked in the
GUI — e.g. `case 'ied'` forcing `in.numTargets = 2; in.edDimension = 'shape';`
ignored a user-selected `numTargets=4` + `edDimension='appendage'`, so the
task ran 2 targets with colour/shape regardless of the GUI.

**Fix pattern** — capture which fields the caller supplied BEFORE the
generic defaults fill, then only fill task-specific defaults for fields not
in that list:

```matlab
userFields = fieldnames(in);   % capture BEFORE the defaults fill loop
% ... existing for-loop that fills missing fields from `defaults` struct ...
case 'ied'
    n = 2;
    if isfield(in, 'numTargets') && ~isempty(in.numTargets); n = in.numTargets; end
    if n == 4
        in = applyIedDefaults(in, userFields, 4, 8, 12);   % 4D sizing
    else
        in = applyIedDefaults(in, userFields, 2, 10, 15);  % 2D sizing
    end
% local helper (subfunction in checkInput.m):
%   for each field in iedDefaults: if ~ismember(f, userFields) || isempty(in.(f)); in.(f)=default; end
```

Two gotchas when adding this guard:
- `userFields` MUST be captured **before** the `defaults` struct fill loop.
  If captured after, every default field looks user-supplied and the
  task-specific defaults never apply (data file/session names silently break).
- Sizing should follow the *effective* `numTargets` the caller chose, not
  the task name — so when `numTargets=4` is supplied on `'ied'`, pick the
  4D objectSize/objectSep defaults.
- The user might send dimension names in plural/case variants (`'appendages'`,
  `'Appendage'`). Extract a singularising normaliser into `clutil` (see
  `clutil.normaliseDimension`), apply it in the task AFTER `checkInput`,
  and accept `''` as invalid → warn + default. Never validate against a
  singular-only list without normalising first (this silently downgraded
  `'appendages'` to `'shape'`).
- GUI `taskType` is a MATLAB array-literal string, e.g.
  `'[ "sd" "sr" "cd" "cr" "ids" "idr" "eds" "edr" ]'` (brackets + quotes).
  The stage parser must strip `[ ] " ' , ;` before `split` — otherwise with
  the field now respected (not overwritten), all stages collapse to `'sd'`.
  Accept both that format and plain space-delimited strings; make the parser
  a testable unit.

## Morphobes Dataset Lookup

The resources submodule holds a **single unified dataset** at
`resources/morphobes/` (4096 stimuli, factorial grid: shape 0-7, colour
0-7, appendage 0-3, texture 0-3, exemplar 0-3). Legacy checkouts may still
have separate `morphobes_ied` / `morphobes_ied4d` folders — resolve the
dataset folder with candidate fallbacks rather than hardcoding one name:

```matlab
candidates = {fullfile(in.folder, 'morphobes'), ...
    fullfile(in.folder, 'morphobes_ied4d'), ...
    fullfile(in.folder, 'morphobes_ied')};
idx = find(cellfun(@isfolder, candidates), 1);
if isempty(idx); idx = 1; end
in.morphobesFolder = candidates{idx};
```

Key metadata.csv columns: `shape_level`, `colour_level`,
`appendage_level`, `texture_level`, `exemplar`, `png_path`.

The lookup is a 5-parameter anonymous function:

```matlab
lookupPNG = @(shapeLv, colourLv, appendageLv, textureLv, exemplar) ...
    char(fullfile(in.morphobesFolder, metaTable.png_path(...
        metaTable.shape_level == shapeLv & ...
        metaTable.colour_level == colourLv & ...
        metaTable.appendage_level == appendageLv & ...
        metaTable.texture_level == textureLv & ...
        metaTable.exemplar == exemplar)));
```

This works universally on both datasets — the 2D dataset simply has
appendage=0, texture=0, exemplar=0 for all rows.

### Dimension level configuration — clutil.iedMorphobesConfig(in, metaTable)

The per-set stimulus specification is computed by
`clutil.iedMorphobesConfig(in, metaTable)`, which reads the task settings
(numTargets, idDimension, edDimension, distractors, randomiseDistractors,
distractorOne, distractorTwo, useExemplars) and derives every level value
directly from the dataset metadata table. Returns:

```matlab
config.numTargets / idDimension / edDimension / distractors /
  randomiseDistractors / useExemplars / distractorOne / distractorTwo /
  distractorDims = {d1 d2}        % the two non-ID/ED dimensions
config.available.(dim)            % levels present in metaTable per dim
config.sets(1..3)                 % one entry per IED stimulus set
  sets(n).relDim                  % relevant dim (ID for sets 1-2, ED for set 3)
  sets(n).relLevels               % 1xnumTargets levels for relDim (distinct)
  sets(n).nonRelevantDims         % cellstr of non-relevant dims
  sets(n).distractorValues        % cell of 1xN fixed values (neutral if
                                  %   distractors=false; distractorOne/Two for
                                  %   the two persistent distractors, 0 for the
                                  %   temporarily irrelevant ID/ED dim)
  sets(n).distractorPools         % cell of 1xM pools (when distractors &&
                                  %   randomiseDistractors) drawn per trial
  sets(n).exemplar / exemplarPool % fixed exemplar or per-trial draw pool
```

The task, per trial in set n: `stimVals.(relDim) = relLevels`; each
non-relevant dim gets a fresh draw from its pool (randomise) or its fixed
values; exemplar is drawn from the pool (useExemplars) or fixed. Every
level value is guaranteed to exist in the dataset. `pickLevels` spreads
2-target pairs roughly half a catalogue apart for discriminability.

Sets correspond to IED stages: Set 1 (SD/SR/CD/CR), Set 2 (IDS/IDR),
Set 3 (EDS/EDR).

## IED Stage Progression

The stage progression algorithm is shared across all IED variants:

1. Stages parsed from `in.taskType` (space-delimited string or string array)
2. Each stage runs until `criterion` consecutive correct (default 6)
3. `maxIncorrect` (default 50) triggers task termination
7. Only trials with `result == 1 || result == 0` count toward progression
8. Reversal stages (`sr`, `cr`, `idr`, `edr`) swap `correctIdx` from 1→2
9. ID dimension is relevant for sets 1-2; ED dimension for set 3
10. Distractor behaviour is explicit, not stage-based: `distractors`
    (show non-ID/ED dims), `randomiseDistractors` (draw from dataset
    levels per trial), `distractorOne`/`distractorTwo` (fixed values),
    `useExemplars` (fresh exemplar per trial). Defaults: 2 targets →
    neutral distractors + fixed exemplar (classic SD); 4 targets →
    compound random distractors + per-trial exemplars.

### Key r.store fields for offline analysis

- `stage`, `stageIdx`, `stagesTotal`, `stagesCompleted`, `taskFailed`
- `consecutiveCorrect`, `stageIncorrect`, `stageTrialN`
- `relDim`, `idDim`, `edDim`, `setNum`, `exemplar`, `distractorsConstant`
- `idx` (position randomization), `correctIdx`, `stimVals`, `chosenTarget`
- `result`, `anyTouch`, `fixationChoice`, `correctDim`, `numTargets`

## Merging Duplicate Task Variants

When two task functions share >70% code (common for variants of the same
paradigm), merge using this approach:

1. **Identify the superset architecture** — the variant with more general
   stimulus selection (algorithmic > hardcoded switch) is the base
2. **Parameterize the distinguishing dimension** — add a `numTargets` (or
   similar) field to `in`, routed via `checkInput.m`
3. **Replace hardcoded switch with algorithmic config** — the 4D
   `dimLevels` + `setExemplars` approach subsumes the 2D per-stage switch
4. **Make dataset selection conditional** — default folder based on
   `numTargets` (or equivalent parameter)
5. **Make grid layout conditional** — 1×2 for 2 targets, 2×2 for 4
6. **Keep prefix dynamic** — preserves data file naming conventions
7. **Unify logging** — use the more general `chosenTarget` (1-N) over
   `chosenVariant` (A/B); for 2 targets they're equivalent
8. **Update `checkInput.m`** — split the combined case into per-variant
   cases that set the distinguishing parameter
9. **Delete the redundant file** — remove the subsumed variant
10. **Update docs** — UserGuide.md, any references to the old function name

### Backward compatibility

- Existing `in.task` values must continue to work
- Direct function calls (`cltasks.startX(in)`) should still work with
  explicit `in.numTargets` (or equivalent)
- Data file prefixes should be preserved per variant

## Conventions (from AGENTS.md)

- **Indentation**: tabs for MATLAB, 2 spaces for YAML
- **Naming**: camelCase functions, CamelCase classes, UPPER_CASE constants
- **Strings**: double quotes `"string"` preferred
- **Managers**: sM (screenManager), aM (audioManager), rM (rewardManager),
  tM (touchManager)
- **Structs**: `in` (input params), `r` (runtime state), `dt` (touch data)
- **Comments**: `%` single-line, `%%` section headers, `%>` Doxygen
- **Paths**: use `filesep` not hardcoded `/`

## Pitfalls

- **`initTrialVariables` preserves IED fields** — `r.stageIdx`,
  `r.consecutiveCorrect`, `r.stageIncorrect`, `r.stageTrialN` are NOT reset
  per trial; they persist across the session. Only add new progression
  fields if they follow the same pattern.
- **`tM.windowTouched` gives the physical target index** — after
  `testHold`, this is 1-N matching the target order in `metaStimulus`, NOT
  the randomized `idx` order. Use it directly for `chosenTarget`.
- **`targets.fixationChoice` uses the randomized index** — set it to
  `idx(correctIdx)` after position randomization, not `correctIdx` directly.
- **`metaStimulus` clones** — when creating N targets, use
  `repmat({targetL}, 1, N)` then clone each, or clone sequentially. The
  clone approach ensures independent stimulus objects.
- **Dataset metadata column names** — both morphobes datasets use
  `shape_level`, `colour_level`, etc. (snake_case with `_level` suffix).
  Do not assume `shape` or `colour` — always use the full column name.
- **Exemplar affects shape, appendage, texture simultaneously** — colour is
  unaffected by exemplar. In 2D mode, only exemplar 0 exists in the dataset.
- **`in.taskType` is overwritten to first stage** — after parsing,
  `in.taskType = char(stages(1))` for `updateTrialResult` compatibility.
  The full stage sequence is preserved in `in.stages`.
- **Levels must exist in the dataset — derive them, never hardcode.** The
  current procedural morphobes dataset (`procedural_microorganisms.py`,
  master seed 1234) uses NON-CONTIGUOUS level encodings: shape
  {0,1,2,4,7,8,11}, colour {0,1,2,3,6,7}, appendage {0,1,2,4,5}, texture
  {0,1,2,3,4}, exemplar {0,1,2,3}. Hardcoded contiguous matrices (shape
  0-7, colour 0-7, appendage 0-3) silently miss levels; `lookupPNG` then
  returns an empty result and the task breaks at runtime with no
  compile-time warning. `clutil.iedMorphobesConfig(in, metaTable)` reads
  `unique(metaTable.<dim>_level)` and validates/clamps every value, so
  config and dataset can never drift apart. Check `metadata.json`
  `catalogue_sizes` for the current encodings.
- **Extract level config into a clutil function for testability** — the
  per-set stimulus spec was pulled out of `startIEDmorphobes` into
  `clutil.iedMorphobesConfig(in, metaTable)`. Tests validate the config
  against dataset metadata (every reachable sample resolves to exactly one
  metadata row whose PNG exists) without running the task, and the task
  and tests share one source of truth. Follow this pattern for any task
  whose stimulus levels are dataset-dependent.
- **checkInput switch cases can silently erase GUI settings** — if the
  `switch(in.task)` case assigns `numTargets`/`idDimension`/`edDimension`/
  `criterion`/`taskType` unconditionally, it overrides what the user picked
  in `CageLab.mlapp`. Guard every task-specific default with a
  `userFields` capture taken BEFORE the defaults fill (see "CRITICAL:
  never stomp user-supplied fields in the switch" above). Symptom of hitting
  this: user sets `numTargets=4`/`edDimension='appendage'` but task runs
  2 targets with colour/shape.
- **Dimension names are plural/case tolerant** — normalise via
  `clutil.normaliseDimension` (accepts `'appendages'`, `'Appendage'`,
  `'colours'`, strips whitespace, returns `''` for invalid) before
  matching against the singular canonical set `{'shape','colour','appendage','texture'}`.
- **GUI taskType is an array-literal string** — `'[ "sd" "sr" ... ]'` with
  brackets/quotes. Strip `[ ] " ' , ;` before `split` in the stage parser.
  Once `taskType` is no longer overwritten by checkInput, an unhandled
  format collapses every stage to `'sd'`.
- **Legacy test may assert an old default — fix with `git blame`, not a
  guess.** After changing a `checkInput` default (or any shared default),
  an older test can fail because it hardcodes the pre-change value (e.g.
  `ClutilTest/testCheckInputDefaults` asserted `task='generic'` but a later
  commit changed the default to `'train'`). Before deciding which side is
  wrong, `git blame` BOTH the test line and the source default line: if the
  source was intentionally changed in a later commit and the test is older,
  the test is stale — update the test to the new value (a shared default
  change can legitimately ripple into test assertions). Verify the new
  default is semantically real (not a typo) by confirming consumers branch
  on it (e.g. `matches(in.task,'train')` still has meaning in
  `updateTrialResult`/`startTouchTraining`).
- **Verify a file is truly unused before `git rm`** — before deleting a
  subsumed `start*.m` file, search the whole code root (e.g. `~/Code`, not
  just the repo) for references besides its own definition/header. A bare
  self-reference or a reference in a docs file that is itself deleted
  on disk does not block removal. Only delete once the merged behaviour is
  confirmed reachable via the surviving entry point.

## References

Read `references/cagelab-task-anatomy.md` for:
- Detailed line-by-line annotation of the shared task skeleton
- The morphobes merge case study (startIEDmorphobes + startIEDmorphobes4D → unified)
- Stimulus selection algorithm comparison (switch vs. dimLevels)

Read `references/testing-tasks.md` for:
- Class-based test patterns for monolithic `start*.m` entry points
  (CI-safe config/dataset validation, synthetic fixture datasets,
  hardware-run tests with xdotool quit-key injection, Xvfb runner script)

Read `references/checkinput-stomping-fix.md` for:
- A worked session where checkInput overwrote GUI-supplied numTargets/
  edDimension, the triple root-cause (unconditional default, singular-only
  validation, GUI array-literal taskType), and the exact fixes + verified
  output. Debugging reference for the "user picked X but task ran Y" class
  of bug.

