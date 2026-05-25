# AGENTS Harness Guide

This repository uses a lightweight, rippable harness.
Keep rules minimal and add constraints only when repeated failures occur.

## Project Layout

- `client/`: React + TypeScript + Vite game client
- `server/`: Python websocket authority server
- `shared/`: Cross-boundary protocol references
- `docs/`: Product and sprint documents

## Build And Run

- Client dev: `cd client && npm run dev`
- Client build/typecheck: `cd client && npm run build`
- Client deterministic core harness: `cd client && npm run harness:core`
- Server run: `cd server && py -3 app.py`
- Server contract tests: `cd server && py -3 -m unittest discover -s tests -p "test_*.py"`
- Replay harness: `cd server && py -3 harness/replay_runner.py harness/scenarios/smoke_run.json`
- Replay harness (additional): `cd server && py -3 harness/replay_runner.py harness/scenarios/fail_recovery.json`
- Replay harness (clamp): `cd server && py -3 harness/replay_runner.py harness/scenarios/clamp_stress.json`

## Non-Negotiable Guardrails

- Treat `shared/MESSAGE_CONTRACT.md` as the source of truth for message names.
- Do not introduce protocol-breaking field changes without updating harness tests.
- Keep server `run_event` transition matrix tests in sync with rule changes.
- Keep `dangerScore` within `[0, 100]` and ensure `threatState` transitions remain explicit.
- Treat replay scenario `expect` blocks as acceptance criteria unless intentionally updated.
- Prefer additive, focused changes; avoid broad refactors without a failing test signal.

## Agent Working Loop

1. Implement the smallest viable change.
2. Run local checks (build/tests/replay) for touched areas.
3. If a repeated failure pattern appears, add one narrow rule to this file or a test.
4. Remove stale rules when they no longer protect meaningful failures.
