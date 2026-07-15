---
name: matlab-class-based-tests
description: Write MATLAB class-based unit tests using matlab.unittest.TestCase, compatible with GitHub Actions (matlab-actions). Convert legacy function-based tests to the modern framework.
version: 1.0.0
platforms: [linux, macos, windows]
environments: [matlab, ci]
metadata:
  hermes:
    tags: [matlab, unit-testing, ci, github-actions]
    related_skills: []
---

# MATLAB Class-Based Unit Tests

Write, organize, and run MATLAB unit tests using the `matlab.unittest.TestCase` framework, with GitHub Actions integration via matlab-actions.

## When to use

- Converting legacy `assert`-based function tests to class-based tests
- Writing new MATLAB unit tests for Opticka or other MATLAB projects
- Setting up GitHub Actions CI for MATLAB test suites
- Running tests locally with `runtests` or in batch mode

## Anatomy of a class-based test

```matlab
classdef MyTest < matlab.unittest.TestCase

    properties
        %> shared state visible to test methods and anonymous fcn handles
        traceStore cell = {}
    end

    methods (TestClassSetup)
        function setupPath(testCase)
            %> runs once before all tests in this class
            addOptickaToPath;
        end
    end

    methods (TestMethodSetup)
        function resetState(testCase)
            %> runs before EACH test method
            testCase.traceStore = {};
        end
    end

    methods (Test)
        function testSomething(testCase)
            %> verifyEqual for exact matches
            verifyEqual(testCase, actual, expected, 'message');

            %> verifyTrue / verifyFalse for booleans
            verifyTrue(testCase, condition, 'message');
            verifyFalse(testCase, condition, 'message');

            %> verifyNotEqual for inequality
            verifyNotEqual(testCase, actual, unexpected, 'message');

            %> verifyLessThan / verifyGreaterThan for bounds
            verifyLessThan(testCase, actual, threshold, 'message');

            %> fatalAssert stops the entire test file on failure
            fatalAssertEqual(testCase, actual, expected, 'message');
        end
    end

    methods (Access = private)
        function appendTrace(testCase, s)
            %> helper called from anonymous function handles
            testCase.traceStore{end+1} = s;
        end
    end
end
```

## Key patterns

### Trace-based testing (for state machines / callbacks)

When testing code that calls anonymous function handles, use a `traceStore` property to record execution order:

```matlab
properties
    traceStore cell = {}
end

methods (TestMethodSetup)
    function resetTrace(testCase)
        testCase.traceStore = {};
    end
end

% In test method:
entryFcn = { @() testCase.appendTrace('enter A') };
exitFcn  = { @() testCase.appendTrace('exit A')  };
% ... build state machine, run it ...
verifyEqual(testCase, testCase.traceStore, ...
    {'enter A','exit A'}, 'execution order mismatch');
```

**Critical**: the anonymous functions must call `testCase.appendTrace(...)`, NOT a local `logTrace` function. The testCase object is the persistent store.

### Parameterized tests

Use `Test` methods with `parameters` attribute:

```matlab
properties (TestParameter)
    classToTest = {'stateMachine', 'stateMachineHSM', 'stateMachineTree'}
end

methods (Test, ParameterizedBy = {classToTest})
    function testFlatMode(testCase, classToTest)
        sm = feval(classToTest, 'realTime', false, ...);
        % ...
    end
end
```

### Testing invalid property assignments (setter validation)

You cannot write `@() (obj.prop = val)` — that's invalid MATLAB syntax. Use one of these patterns instead:

#### General-purpose helper function

Define a single local function **after** the classdef `end`:

```matlab
function setProp(obj, prop, value)
	%> Trigger a property setter for testing validation errors
	obj.(prop) = value;
end
```

Use it in tests:

```matlab
function testDistanceInvalid(testCase)
	obj = someClass('verbose', false);
	verifyError(testCase, @() setProp(obj, 'distance', 0), ...
		'', 'distance=0 should error');
end
```

#### Error identifiers to expect

| Source | Example | Error ID |
|--------|---------|----------|
| `assert(cond)` (no message) | `assert(x > 0)` | `'MATLAB:assertion:failed'` |
| `assert(cond, 'msg')` (with message) | `assert(x > 0, 'must be positive')` | `''` (empty / no identifier) |
| `mustBeMember` property validator | `prop {mustBeMember(prop,{'a','b'})}` | `'MATLAB:validators:mustBeMember'` |
| `mustBePositive` / `mustBeInteger` | `n {mustBePositive}` | `'MATLAB:validators:mustBe<Name>'` |

#### Class-level `mustBeMember` fires before setter

When a property has a `mustBeMember` validator:
```matlab
properties
	srcMode char {mustBeMember(srcMode,{'A','B'})} = 'A'
end
methods
	function set.srcMode(me, value)
		% this setter never runs for invalid values
	end
end
```

The validator rejects invalid values **before** the setter is called. To test that the old value is preserved, use try/catch:

```matlab
function testInvalidPropertyPreservesOld(testCase)
	obj = someClass('verbose', false);
	obj.srcMode = 'A';  % valid — setter runs
	try obj.srcMode = 'INVALID'; catch, end
	verifyEqual(testCase, obj.srcMode, 'A', 'invalid value preserves previous');
end
```

### Running tests

```matlab
% Run all tests in a folder
runtests('tests/');

% Run a specific test file
runtests('tests/HSMOption1Test.m');

% Run a specific test method
runtests('HSMOption1Test/testFlatModeIdenticalToBase');

% Get results programmatically (use full package path!)
suite = matlab.unittest.TestSuite.fromFolder('tests/');
results = run(suite);
disp(table(results));

% Run with JUnit XML output (for CI)
import matlab.unittest.plugins.XMLPlugin
runner = matlab.unittest.TestRunner.withTextOutput;
runner.addPlugin(XMLPlugin.producingJUnitFormat('test-results/junit'));
suite = matlab.unittest.TestSuite.fromFolder('tests/');
results = runner.run(suite);
```

**Important**: Always use the full package path `matlab.unittest.TestSuite` and `matlab.unittest.TestRunner` — bare `TestSuite.fromFolder()` will fail with "Unable to resolve the name" if the package is not on the MATLAB path.

### Batch mode (no display)

```bash
matlab -batch "addOptickaToPath; runtests('tests/')"
```

## GitHub Actions integration

### Workflow file (`.github/workflows/matlab-tests.yml`)

```yaml
name: MATLAB Tests
on:
  push:
    branches: [master]
    paths: ['core/**', 'tests/**']
  pull_request:
    branches: [master]
    paths: ['core/**', 'tests/**']

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - uses: matlab-actions/setup-matlab@v3
        with:
          release: latest
          cache: true
      - uses: matlab-actions/run-tests@v3
        with:
          select-by-folder: tests
          junit-results: test-results/junit
          code-coverage: true
          code-coverage-source: core
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: matlab-test-results
          path: test-results/
```

### matlab-actions key points

- `setup-matlab@v3`: installs MATLAB on the runner. Requires a MATLAB license (configured via MathWorks account or MATLAB Online licensing). `release` specifies the version (e.g. R2026a).
- `run-tests@v3`: runs tests from a folder, file, or by name. Supports JUnit XML output, code coverage ( Cobertura format), and automatic test discovery.
- `run-command@v3`: runs arbitrary MATLAB code in batch mode (alternative to run-tests for custom scripts).
- Supported runners: `ubuntu-latest`, `windows-latest`, `macos-latest`.
- Tests run in MATLAB's `-batch` mode (no display). Tests that require PTB screen, figures, or interactive hardware will fail in CI — guard them with `assume` or tags.

### Skipping tests in CI

Use `assume` to conditionally skip tests that need hardware/display:

```matlab
methods (Test)
    function testRequiresDisplay(testCase)
        assumeFalse(testCase, isempty(getenv('GITHUB_ACTIONS')), ...
            'Skipping display test in CI');
        % ... test that needs PTB ...
    end
end
```

Or use test tags:

```matlab
methods (Test, Tags = {'hardware'})
    function testEyeTracker(testCase)
        % ...
    end
end

% In CI, exclude tagged tests:
% runtests('tests/', '-ExcludeTag', 'hardware')
```

## Conversion checklist (legacy function test -> class-based)

1. Rename file from `myTest.m` (function) to `MyTest.m` (class, PascalCase)
2. Wrap in `classdef MyTest < matlab.unittest.TestCase`
3. Convert each `assert(condition, 'msg')` to `verifyTrue(testCase, condition, 'msg')` or `verifyEqual(testCase, actual, expected, 'msg')`
4. Move shared state (traceStore, counters) to properties
5. Move setup code to `TestClassSetup` (one-time) or `TestMethodSetup` (per-test)
6. Replace local helper functions with private methods on the testCase
7. Keep local functions that are NOT test-case methods as local functions outside the classdef (e.g. analysis helpers)
8. Ensure anonymous function handles reference `testCase.appendTrace(...)` not a local function

## Opticka-specific conventions

- Test files go in `tests/` directory
- Use `addOptickaToPath` in `TestClassSetup`
- File naming: PascalCase + `Test` suffix (e.g. `HSMOption1Test.m`)
- Method naming: `test<DescriptiveName>` (camelCase)
- Tab indentation (per AGENTS.md)
- Doxygen-style comments (`%>` for line comments)
- Tests that require PTB/GetSecs will work locally but need `assume` guards for CI
- The `tests/` folder is excluded from `addOptickaToPath` by default; tests must call `addOptickaToPath` themselves

## Pitfalls

- **Anonymous function closures**: anonymous fcns capture variables by value at creation time. For mutable shared state (like traceStore), use `testCase.appendTrace(...)` so the handle class property is mutated.
- **Local functions in classdef files**: MATLAB allows local functions after the `end` of a classdef in the same file. These are NOT methods — they are plain functions. Use this for analysis/utility code that doesn't need testCase access.
- **`isequal` vs `verifyEqual`**: `verifyEqual` provides diagnostic output on failure; raw `isequal` does not. Always prefer `verifyEqual` in tests.
- **String vs char comparisons**: `verifyEqual(testCase, 'A', "A")` will fail (char vs string). Use `string(actual)` or `char(expected)` to normalize types before comparing.
- **`assume` vs `verify`**: `assume` marks a test as filtered (not failed) — use for conditional skipping. `verify` marks as failed. `fatalAssert` stops the entire file.
- **CI without PTB**: `GetSecs`, `Screen`, etc. are not available in MATLAB-only CI. Tests using these must be tagged or guarded.
- **TestSuite/TestRunner package resolution**: Always use `matlab.unittest.TestSuite.fromFolder(...)` and `matlab.unittest.TestRunner.withTextOutput` — bare `TestSuite.fromFolder(...)` fails with "Unable to resolve the name 'TestSuite.fromFolder'" when the package is not explicitly imported or on the path. The `runtests()` function works without the package prefix because it is a top-level MATLAB function.
- **runtests results object**: `~all(results)` doesn't work on the `TestResult` array — use `sum([results.Failed]) > 0` or `any([results.Failed])` instead.
