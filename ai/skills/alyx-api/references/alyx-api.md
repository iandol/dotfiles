# Alyx API Reference Notes

## Schema Discovery

The Redoc page at `https://openalyx.internationalbrainlab.org/docs/` points to `/api/schema`.
Fetch JSON directly:

```bash
curl -s 'https://openalyx.internationalbrainlab.org/api/schema?format=json'
```

Useful one-liner to inspect sessions parameters:

```bash
curl -s 'https://openalyx.internationalbrainlab.org/api/schema?format=json' \
| python3 -c "import sys,json; d=json.load(sys.stdin); s=d['paths']['/sessions']['get']; print(json.dumps(s.get('parameters', []), indent=2))"
```

## `/sessions` Query Parameters Seen In Schema

Confirmed session filters include:

- `subject`
- `lab`
- `location`
- `project`
- `projects`
- `date_range`
- `start_time`
- `end_time`
- `users`
- `number`
- `task_protocol`
- `qc`
- `dataset_types`
- `datasets`
- `limit`
- `offset`

Use `date_range` as `YYYY-MM-DD,YYYY-MM-DD` for a start/end date UI.

## Opticka `alyxManager` Notes

`alyxManager.getData(endpoint, varargin)` performs read-only GET requests and handles paginated Alyx responses. It expects login state:

```matlab
am = alyxManager('verbose', false);
success = am.login();
assert(success && am.loggedIn);
[sessions, statusCode] = am.getData('sessions', 'subject', subjectName);
```

`alyxManager.postData`, `createSession`, `closeSession`, `updateNarrative`, `registerFile`, and `registerALFFiles` perform write operations. Avoid these unless the user explicitly asks for writes.

## Safe Live Smoke Test

A safe live test can log in and perform one read-only request:

```matlab
addOptickaToPath;
am = alyxManager('verbose', false);
assert(am.hasSecrets(), 'No Alyx secrets available');
success = am.login();
assert(success && am.loggedIn);
[data, statusCode] = am.getData('users', 'limit', 1);
assert(statusCode == 200 && ~isempty(data));
am.logout();
```

This does not create, patch, register, or delete data.

## Programmatic MATLAB GUI Pattern

For a simple read-only browser:

- use `uifigure` as the app root
- use `uigridlayout` with left filters and right results
- use `uieditfield` for text filters such as subject/lab/location/project
- use `uidatepicker` for start/end dates
- use `uibutton` callbacks for search/clear
- use `uitable` with a stable empty table schema before results exist
- show errors with a status `uitextarea` or `uialert`

Do not run live searches in tests unless explicitly requested. A construction smoke test can create the app, assert `isvalid(app.figure)`, and immediately delete it.
