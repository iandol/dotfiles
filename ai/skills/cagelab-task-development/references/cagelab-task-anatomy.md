# CageLab Task Anatomy — Detailed Reference

> **API evolution (2026-08):** the config described below as
> `clutil.iedMorphobesConfig(numTargets)` returning `dimLevels` +
> `setExemplars` has since been replaced by
> `clutil.iedMorphobesConfig(in, metaTable)`, which reads the task settings
> and derives every level from the dataset metadata (per-set `relLevels`,
> distractor values/pools, exemplar pools — see SKILL.md "Dimension level
> configuration"). This was driven by the discovery that the procedural
> morphobes dataset uses non-contiguous level encodings (shape
> {0,1,2,4,7,8,11} etc.), so hardcoded contiguous matrices silently broke.
> The merge case study below remains valid as the architectural rationale
> (algorithmic config > per-stage switch; unified dataset; 5-param lookup).

## The Morphobes Merge Case Study

### Problem

Two IED task functions existed with ~70% identical code:

- `startIEDmorphobes.m` (434 lines) — 2-target, 2-dimension (colour=ID, shape=ED)
  - Hardcoded 8-case `switch` statement for per-stage stimulus selection
  - 2-param `lookupPNG(shapeLv, colourLv)`
  - Dataset: `morphobes_ied` (42 stimuli, appendage=0, texture=0, exemplar=0)
  - Logging: `chosenVariant` (A/B), `shapeA/B`, `colourA/B`

- `startIEDmorphobes4D.m` (421 lines) — 4-target, 4-dimension (configurable ID/ED)
  - Algorithmic stimulus selection via `dimLevels` struct + `setExemplars`
  - 5-param `lookupPNG(shape, colour, appendage, texture, exemplar)`
  - Dataset: `morphobes_ied4d` (4096 stimuli, all dimensions)
  - Logging: `chosenTarget` (1-4 from `tM.windowTouched`), `stimVals` struct

### Key Insight

The 4D architecture is strictly more general than the 2D:

1. **Configurable ID/ED dimensions** subsumes 2D's hardcoded colour=ID/shape=ED
2. **Algorithmic `dimLevels`** subsumes the 2D's per-stage switch — the switch
   is just a less flexible way of doing what `dimLevels` + `setExemplars` does
3. **4 targets** can be reduced to 2 by using a 1×2 grid instead of 2×2
4. **5-param lookup** works on the 2D dataset because both datasets share
   identical metadata.csv column structure — the 2D dataset just has
   appendage=0, texture=0, exemplar=0 for all rows

### Merge Steps

1. **Base on 4D architecture** — its algorithmic approach is the superset
2. **Add `in.numTargets`** parameter (2 or 4), routed via `checkInput.m`
3. **Configure `dimLevels` per mode** (extracted to
   `clutil.iedMorphobesConfig(numTargets)` so tests and task share one
   source of truth):
   ```matlab
   if numTargets == 4
       dimLevels.shape     = [0 1 2 3; 4 5 6 7; 0 1 2 3];
       dimLevels.colour    = [0 1 2 3; 4 5 6 7; 0 1 2 3];
       dimLevels.appendage = [0 1 2 3; 0 1 2 3; 0 1 2 3];
       dimLevels.texture   = [0 1 2 3; 0 1 2 3; 0 1 2 3];
       setExemplars = [0 1 2];
   else
       % 2D: values within the unified dataset's available range.
       % NOTE: the original s1/s2/s3 shapes [3 6; 8 10; 7 11] used levels
       % 8/10/11 that no longer exist after the dataset consolidation
       % (shapes are now 0-7). New 2D config uses valid levels only.
       dimLevels.shape     = [3 6; 1 5; 0 7];
       dimLevels.colour    = [0 1; 2 4; 6 7];
       dimLevels.appendage = [0 0; 0 0; 0 0];
       dimLevels.texture   = [0 0; 0 0; 0 0];
       setExemplars = [0 0 0];  % 2D dataset only has exemplar 0
   end
   ```
4. **Conditional grid positions:**
   ```matlab
   if numTargets == 4
       posX = [-sep/2, sep/2, -sep/2, sep/2];
       posY = [sep/2, sep/2, -sep/2, -sep/2];
   else
       posX = [-sep/2, sep/2];
       posY = [0, 0];
   end
   ```
5. **Dynamic prefix:** `'IEDmorphobes'` for 2D, `'IEDmorphobes4D'` for 4D
6. **Unified logging:** `chosenTarget` (1-N from `tM.windowTouched`) replaces
   `chosenVariant` (A/B) — for 2 targets they're positionally equivalent
7. **`checkInput.m` split:**
   - `case 'ied'` → `numTargets=2`, morphobes_ied defaults, 2D display defaults
   - `case {'ied-2' 'ied-4'}` → conditional `numTargets` based on `in.task`
8. **Delete** `startIEDmorphobes4D.m`
9. **Update** `docs/UserGuide.md`

### Stimulus Selection: Switch vs. dimLevels

The old 2D approach used a 44-line `switch` with 8 cases:

```matlab
switch r.stage
    case 'sd'
        shapeA = neutralShapeLevel; colourA = s1_colours(1);
        shapeB = neutralShapeLevel; colourB = s1_colours(2);
        correctVariant = 'A';
    case 'sr'
        % ... same stimuli, correctVariant = 'B'
    case 'cd'
        % ... compound, randomize shape pairing
    % ... 5 more cases
end
```

The unified approach replaces this with algorithmic computation:

```matlab
relLevels = dimLevels.(relDim)(setNum, :);
stimVals.(relDim) = relLevels;
if distractorsConstant
    for d = 1:length(distDims)
        stimVals.(distDims{d})(:) = 0;
    end
else
    for d = 1:length(distDims)
        availLv = dimLevels.(distDims{d})(setNum, :);
        stimVals.(distDims{d}) = availLv(randperm(numTargets));
    end
end
```

This is ~12 lines that handle all 8 stages generically, vs. 44 lines of
hardcoded per-stage logic. The `correctIdx` (1 for non-reversal, 2 for
reversal) replaces `correctVariant` ('A'/'B').

### Files Changed

| File | Action |
|---|---|
| `+cltasks/startIEDmorphobes.m` | Rewritten as unified function |
| `+cltasks/startIEDmorphobes4D.m` | Deleted |
| `+clutil/iedMorphobesConfig.m` | **Added** — extracted dimLevels/setExemplars config, testable without running the task |
| `+clutil/checkInput.m` | Split `case {'ied' 'ied-2' 'ied-4'}` into `case 'ied'` + `case {'ied-2' 'ied-4'}` with `numTargets` routing |
| `docs/UserGuide.md` | Updated IED section to describe unified function |
| `tests/StartIEDMorphobesTest.m` | **Added** — CI-safe config/dataset tests + hardware run tests |

### Backward Compatibility

- `in.task = 'ied'` → 2D behaviour (numTargets=2)
- `in.task = 'ied-4'` → 4D behaviour (numTargets=4)
- `in.task = 'ied-2'` → 2D with 4D-style defaults
- Direct `cltasks.startIEDmorphobes(in)` with `in.numTargets = 4` replaces old `cltasks.startIEDmorphobes4D(in)`
- Dataset folder: unified `resources/morphobes` preferred, legacy
  `morphobes_ied` / `morphobes_ied4d` accepted via fallback resolution
