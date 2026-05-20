# Shared Message Contract (v0)

클라이언트-서버 간 Sprint 1 최소 메시지 계약.

## Client -> Server
```json
{ "type": "client_ready" }
```

```json
{
  "type": "run_event",
  "event": "run_extract",
  "payload": { "runNumber": 1, "extractValue": 250 }
}
```

## Server -> Client
```json
{ "type": "hello", "tick": 0, "note": "서버 연결 완료" }
```

```json
{ "type": "tick", "tick": 1, "note": "런타임 heartbeat" }
```

```json
{ "type": "event_ack", "tick": 5, "note": "ack:run_extract" }
```

## 주의
- `tick`은 서버 권위형 카운터다.
- `run_event`는 1차 텔레메트리 훅이며, Sprint 2에서 서버 판정 항목으로 확장한다.
