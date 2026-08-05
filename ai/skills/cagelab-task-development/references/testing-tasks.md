# Testing CageLab Task Functions (class-based tests)

How to test the monolithic `+cltasks/start*.m` entry points. These
functions initialise the whole screen/audio/touch stack and run a trial
loop until criterion — they cannot be unit-tested internally. Split tests
into CI-safe (no PTB) and hardware-tagged (real PTB window) groups, as
done in `tests/StartIEDMorphobesTest.m`.

## CI-safe tests (no PTB window)

### 1. Entry contract

```matlab
function testEntryPointSignature(testCase)
    name = "cltasks.startIEDmorphobes";
    functionHandle = str2func(name);
    expectedPath = fullfile(testCase.repoRoot, '+cltasks', 'startIEDmorphobes.m');
    verifyEqual(testCase, nargin(functionHandle), 1, 'nargin must be 1');
    verifyEqual(testCase, which(name), expectedPath, 'file location');
end

function testRejectsNonStructInput(testCase)
    % errors before any hardware initialisation
    verifyError(testCase, @() cltasks.startIEDmorphobes(1), 'checkInput:InvalidInput');
end
```

### 2. checkInput routing

Every `in.task` value must map to the expected distinguishing parameter
plus defaults:

```matlab
function testCheckInputIedDefaults(testCase)
    in = clutil.checkInput(struct('task', 'ied'));
    verifyEqual(testCase, in.numTargets, 2, 'ied defaults to 2D');
    verifyEqual(testCase, string(in.taskType), "sd cd cr ids idr eds edr");
    verifyEqual(testCase, in.idDimension, 'colour');
    verifyEqual(testCase, in.edDimension, 'shape');
    verifyEqual(testCase, in.criterion, 6);
    verifyEqual(testCase, in.maxIncorrect, 50);
end
```

### 3. Config-vs-dataset consistency (the strongest regression test)

For tasks driven by a dimLevels level matrix, verify every
`(shape, colour, appendage, texture, exemplar)` combination referenced by
the config resolves to **exactly one** metadata.csv row whose PNG exists:

```matlab
function verifyConfigResolves(testCase, numTargets, meta, folder)
    config = clutil.iedMorphobesConfig(numTargets);
    for setN = 1:3
        exemplar = config.setExemplars(setN);
        for t = 1:numTargets
            s = config.dimLevels.shape(setN, t);
            c = config.dimLevels.colour(setN, t);
            a = config.dimLevels.appendage(setN, t);
            tx = config.dimLevels.texture(setN, t);
            mask = meta.shape_level == s & meta.colour_level == c & ...
                meta.appendage_level == a & meta.texture_level == tx & ...
                meta.exemplar == exemplar;
            verifyEqual(testCase, sum(mask), 1, 'lookup must be unique');
            png = char(meta.png_path(mask));
            verifyTrue(testCase, isfile(fullfile(folder, png)), ['PNG exists: ' png]);
        end
    end
end
```

This catches the classic bug: a level value (e.g. shape 8/10/11) silently
stops existing after the dataset is consolidated/regenerated — the 5-param
lookup returns empty instead of erroring, so the task breaks at runtime
with no compile-time warning.

Also test the neutral case: SD/SR set all non-relevant dimensions to 0,
so shape 0 must exist paired with every set colour.

### 4. Source-level stage coverage

```matlab
source = fileread(which('cltasks.startIEDmorphobes'));
stages = {'sd','sr','cd','cr','ids','idr','eds','edr'};
for stage = stages
    verifyTrue(testCase, contains(source, ['''' stage{1} '''']), ...
        ['missing IED stage: ' stage{1}]);
end
```

## Synthetic fixture datasets (deterministic CI tests)

Real datasets often live in git submodules CI does not check out. Build a
minimal synthetic dataset in `TestClassSetup` — one shared tiny PNG plus
a metadata.csv covering every config combo — so config-resolution tests
run identically everywhere:

```matlab
methods (TestClassSetup)
    function makeFixture(testCase)
        testCase.fixtureDir = tempname; mkdir(testCase.fixtureDir);
        mkdir(fullfile(testCase.fixtureDir, 'png'));
        imwrite(randi(255, 8, 8, 3, 'uint8'), ...
            fullfile(testCase.fixtureDir, 'png', 'microbe_00001.png'));
        % rows: full factorial of shape 0-7 x colour 0-7 x appendage 0-3
        % x texture 0-3 x exemplar 0-2, all png_path -> microbe_00001.png
        writetable(T, fullfile(testCase.fixtureDir, 'metadata.csv'));
    end
end
methods (TestClassTeardown)
    function removeFixture(testCase)
        if isfolder(testCase.fixtureDir); rmdir(testCase.fixtureDir, 's'); end
    end
end
```

Run the same config-resolution check against the fixture (always) AND
against the real dataset guarded by `assumeTrue(isfile(realMetadata))` so
real data is exercised when present but CI skips cleanly.

## Hardware tests: actually run the task, then quit it

Tag with `hardware`. Guards, in order:

1. Display available: `assumeTrue(~isempty(getenv('DISPLAY')) || isunix)`
2. `xdotool` present: `assumeTrue(system('command -v xdotool') == 0)`
3. PTB can open a window (probe, don't assume):
   ```matlab
   function ok = canOpenWindow(testCase)
       ok = false;
       try
           PsychDefaultSetup(2);
           if isempty(Screen('Screens')); return; end
           [w, ~] = Screen('OpenWindow', 0, [0.5 0.5 0.5], [0 0 200 200]);
           Screen('Flip', w); Screen('CloseAll'); ok = true;
       catch ME
           try Screen('CloseAll'); catch, end
       end
   end
   ```

Input struct for a dummy-manager run:

```matlab
in = struct();
in.task = 'ied-2';            % or 'ied-4'
in.numTargets = numTargets;
in.taskType = 'sd cd cr ids idr eds edr';
in.criterion = 6; in.maxIncorrect = 50;
in.objectSize = 8; in.objectSep = 12; in.sampleY = 0;
in.trialTime = 1.5; in.targetHoldTime = 0.05; in.initHoldTime = 0.05;
in.morphobesFolder = testCase.fixtureDir;
in.dummy = true; in.audio = false; in.reward = false;
in.debug = true; in.screen = 0;          % windowed debug mode
in.disableSync = true; in.useVulkan = false;
in.remote = false; in.useAlyx = false;
in.smartBackground = false; in.highPriority = false; in.verbose = false;
```

Terminate deterministically by injecting the quit key (Escape) from a
background shell — the trial loop checks `KbCheck` for `r.quitKey` each
frame, so the task ends cleanly and `endTask` saves `~/lastTaskRun.mat`:

```matlab
lastTaskRun = fullfile(getenv('HOME'), 'lastTaskRun.mat');
if isfile(lastTaskRun); delete(lastTaskRun); end
system('(sleep 4; xdotool key Escape; sleep 4; xdotool key Escape) &');
err = '';
try
    cltasks.startIEDmorphobes(in);
catch ME
    err = ME.message;
end
verifyEmpty(testCase, err, ['task ran without error: ' err]);
verifyTrue(testCase, isfile(lastTaskRun), 'endTask saved data');
```

Note: the task overrides `in.totalTrials = 1e6`, so you cannot bound the
run that way — the quit key is the reliable termination path.

## Running hardware tests headless (GitHub Actions / SSH)

Mirror the opticka `runOptickaTestsXvfb.sh` pattern. CageLab's version is
`tests/runCageLabTestsXvfb.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
matlab_bin="${MATLAB_BIN:-matlab}"
xvfb_screen="${XVFB_SCREEN:-1920x1080x24}"
if [[ $# -gt 0 ]]; then
    matlab_command="$*"
else
    matlab_command="addOptickaToPath; cd('${repo_root}'); addpath('tests'); suite = matlab.unittest.TestSuite.fromFolder('tests'); results = run(suite); if any([results.Failed]); error('CageLab:TestsFailed', 'One or more MATLAB tests failed.'); end"
fi
exec xvfb-run -a -s "-screen 0 ${xvfb_screen}" "$matlab_bin" -batch "$matlab_command"
```

## Pitfalls specific to these tests

- **Xvfb screen size**: the task's windowed debug mode is `[0 0 1600 900]`
  (hardcoded in `clutil.initialise`). CI's Xvfb must be at least
  `1920x1080x24`, not the opticka default `1024x768` — a 1600x900 window
  cannot open on a 1024x768 screen.
- **PTB window-open segfaults on some GPUs**: on machines with a discrete
  AMD GPU (radeonsi), `Screen('OpenWindow')` under Xvfb can segfault the
  whole MATLAB process — the Xvfb log shows `amdgpu_query_info failed`.
  `Screen('Screens')` works; only window creation crashes. This is
  machine-specific: GitHub runners use clean Mesa/llvmpipe where windowed
  PTB works. The `canOpenWindow()` probe cannot catch a segfault (it kills
  MATLAB), but it does catch clean failures — and the probe makes the test
  skip on environments where windowed PTB is simply unavailable. When in
  doubt, run hardware tests on a rig machine with a real display.
- **`~/lastTaskRun.mat` as completion signal**: `endTask` always writes it
  (plus `~/cagelab-start.txt` and ALF save paths under `~/OptickaFiles`).
  Delete it before the run so existence after the run is meaningful.
- **Don't forget `in.highPriority` and `in.verbose`**: `clutil.initialise`
  reads `in.highPriority` (line ~250) and `in.verbose` (line ~45/153), but
  `checkInput.m` does not define defaults for them — set both explicitly
  in the test input struct or the run fails on undefined struct fields.
