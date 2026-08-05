# checkInput GUI-field stomping fix (real session)

## Symptom reported by user
Ran `cltasks.startIEDmorphobes` with `numTargets=4` and
`edDimension='appendages'` via `CageLab.mlapp`, but the task still ran **2
targets** using **colour and shape** dimensions (both incorrect).

## Root causes (three distinct bugs, all real)
1. **Unconditional overwrite in `checkInput.m` `case 'ied'`:**
   `in.numTargets = 2; in.idDimension = 'colour'; in.edDimension = 'shape';`
   wiped the GUI's user-selected values before the task ever read them.
   `CageLab.mlapp` STARTIED button always sends `opts.task='ied'` PLUS the
   real `numTargets`/`idDimension`/`edDimension`/`criterion`/`maxIncorrect`/
   `taskType` (see GUI source, `STARTIED` callback). So `'ied'` forces 2D.

2. **Singular-only validation:** task's `validDims = {'shape','colour',
   'appendage','texture'}`. Even if `'appendages'` survived checkInput,
   `ismember('appendages', validDims)` is false → warn + default `'shape'`.

3. **GUI taskType format:** GUI Task Order field defaults to a MATLAB
   array-literal string `'[ "sd" "sr" "cd" "cr" "ids" "idr" "eds" "edr" ]'`.
   Old parser `string(in.taskType); split(strip(...))` would produce tokens
   like `"["`, `'"sd"'` → invalid → default to `'sd'`. Only became visible
   once field was no longer overwritten by checkInput.

## Fixes applied (verified)
- `checkInput.m`: capture `userFields = fieldnames(in)` BEFORE the generic
  defaults fill loop; add `applyIedDefaults(in, userFields, ...)` local
  subfunction that only fills a field when `~ismember(f, userFields) ||
  isempty(in.(f))`. `'ied'` chooses sizing by *effective* numTargets.
- `clutil/normaliseDimension.m` (new): lowercases, strips whitespace, strips
  trailing `'s'` if the singular is valid, returns `''` for invalid.
- `startIEDmorphobes.m`: call `clutil.normaliseDimension` on id/ed dims
  before validation; robust stage parser `replace(stages, {'[',']','"',
  '''',',',';'},' ')` then `split(strip(stages))` then filter empties.
  Added `ConstantEDDimension` warning when the chosen ED dim has <2 unique
  levels in set 3 (e.g. appendage ED with numTargets=2).

## Verification results (matlab -batch)
- `checkInput(struct('task','ied','numTargets',4))` → numTargets=4,
  objectSize=8, objectSep=12 (4D sizing followed user override). ✓
- `checkInput(struct('task','ied','numTargets',4,'edDimension','appendages'))`
  → edDimension preserved ('appendages'). ✓
- Defaults still apply with no user fields (numTargets=2, colour/shape,
  criterion=6, maxIncorrect=50). ✓
- `normaliseDimension('appendages')`→'appendage', `'Appendage'`→'appendage',
  `'sound'`→''. ✓
- Stage parser: GUI format and space format both → identical 8-stage
  sequence. ✓
- `StartIEDMorphobesTest` CI-safe suite: 23 passed, 0 failed.

## Pre-existing failure (NOT caused by fix, do not chase)
`ClutilTest/testCheckInputDefaults` fails on HEAD too: expects
`in.task == 'generic'` but `checkInput.m:34` defaults `task='train'`.
Unrelated to this change.

## Other observation
`+cltasks/startIEDmorphobes4D.m` was reportedly "deleted" in an earlier
session but is still present and tracked in git — verify with
`git status`/`git ls-files` before trusting a deletion claim.
