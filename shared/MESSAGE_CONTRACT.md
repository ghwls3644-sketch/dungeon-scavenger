# Shared Message Contract (v1)

Sprint 2 contract for client/server realtime updates.

## Client -> Server

```json
{ "type": "client_ready" }
```

```json
{
  "type": "run_event",
  "event": "trap_trigger",
  "payload": { "trapId": "T-01", "health": 88 }
}
```

Other expected `event` values:
- `run_start`
- `loot_pick`
- `loot_drop`
- `chaser_spotted`
- `chaser_hit`
- `run_extract`
- `run_fail`

`run_fail` payload example:

```json
{
  "type": "run_event",
  "event": "run_fail",
  "payload": {
    "failedRuns": 1,
    "carriedValue": 420,
    "recoveredValue": 147,
    "lostValue": 273
  }
}
```

## Server -> Client

```json
{
  "type": "hello",
  "tick": 0,
  "note": "Server connected",
  "threatState": "Idle",
  "dangerScore": 0
}
```

```json
{
  "type": "tick",
  "tick": 3,
  "note": "heartbeat danger=12.0",
  "threatState": "Investigating",
  "dangerScore": 12.0
}
```

```json
{ "type": "event_ack", "tick": 3, "note": "ack:trap_trigger" }
```

```json
{
  "type": "threat_update",
  "tick": 3,
  "note": "threat update from trap_trigger",
  "threatState": "Chasing",
  "dangerScore": 28.0
}
```

## Notes

- `tick` is server-authoritative time.
- `dangerScore` is a lightweight sprint metric (0~100) that reacts to threat events.
- `threat_update` is the server feedback channel for S2-01.
- `run_fail` in S2-02 applies partial recovery (35%) and loss (65%) on carried value.
