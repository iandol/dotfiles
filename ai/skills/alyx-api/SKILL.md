---
name: alyx-api
description: Work with Alyx REST APIs and MATLAB Opticka alyxManager. Use when Codex needs to inspect Alyx API schemas, build read-only Alyx queries, add MATLAB code or GUIs that query Alyx, validate alyxManager behavior, or safely log in to Alyx without creating, patching, registering, or deleting records unless explicitly requested.
---

# Alyx API

Use this skill for Alyx REST/API work, especially in Opticka MATLAB code that uses `alyxManager`.

## Core Workflow

1. Prefer read-only operations first.
2. Inspect the live OpenAPI schema before assuming query parameters:
   ```bash
   curl -s 'https://openalyx.internationalbrainlab.org/api/schema?format=json'
   ```
3. For Opticka, route API calls through `alyxManager` unless there is a specific reason to use raw HTTP.
4. Do not create sessions, patch narratives/session metadata, register files, or delete records unless the user explicitly asks for a write operation.
5. If credentials exist locally, it is acceptable to run a read-only login smoke test and simple GET request. State clearly that no write operation was performed.
6. For MATLAB GUI work, use programmatic app components such as `uifigure`, `uigridlayout`, `uieditfield`, `uidatepicker`, `uibutton`, and `uitable`.

## Opticka Patterns

- Add the repo path before MATLAB checks:
  ```matlab
  addOptickaToPath
  ```
- Create a manager with local secrets:
  ```matlab
  am = alyxManager('verbose', false);
  am.login();
  ```
- Read sessions:
  ```matlab
  [sessions, statusCode] = am.getData('sessions', ...
    'subject', 'SUBJECT', 'lab', 'LAB', 'date_range', 'YYYY-MM-DD,YYYY-MM-DD');
  ```
- Use `date_range` for start/end date filters on sessions.
- Common session filters include `subject`, `lab`, `location`, `project`, `projects`, `date_range`, `start_time`, `end_time`, `users`, `number`, `task_protocol`, `qc`, `limit`, and `offset`.

## References

Read `references/alyx-api.md` when you need:
- exact schema discovery commands
- confirmed `/sessions` filter names
- safe live-test patterns
- MATLAB GUI and `alyxManager` implementation notes
