# Replay Harness

## Purpose

Run deterministic client event sequences against the websocket server and capture trace logs.

## Scenario Format

- Path: `server/harness/scenarios/*.json`
- Each scenario has:
  - `name`
  - `description` (optional)
  - `expect` (optional but recommended):
    - `requireTypes`: message types that must appear in trace
    - `ackSequence`: ordered event names expected in `event_ack`
    - `finalThreatState`: expected final server threat state
    - `dangerScoreMin` / `dangerScoreMax`: expected final score range
  - `events`: ordered `run_event` entries
  - `afterSec` per event (optional, defaults to `0`)

Use `server/harness/scenarios/_template.json` as the starting point.

## Run

1. Start server in another terminal:
   - `cd server`
   - `py -3 app.py`
2. Run scenario:
   - `py -3 harness/replay_runner.py harness/scenarios/smoke_run.json`
3. Additional scenarios:
   - `py -3 harness/replay_runner.py harness/scenarios/fail_recovery.json`
   - `py -3 harness/replay_runner.py harness/scenarios/clamp_stress.json`

The runner writes `<scenario>.trace.json` by default.
