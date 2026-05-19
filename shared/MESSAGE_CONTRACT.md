# Shared Message Contract (v0)

클라이언트-서버 간 Sprint 1 최소 메시지 계약.

## Client -> Server
```json
{ "type": "client_ready" }
```

## Server -> Client
```json
{ "type": "hello", "tick": 0, "note": "서버 연결 완료" }
```

```json
{ "type": "tick", "tick": 1, "note": "런타임 heartbeat" }
```

## 주의
- `tick`은 서버 권위형 카운터다.
- Sprint 2부터 플레이어 상태/소음/중량 payload를 확장한다.
