# Server Scaffold

## 목적
- Sprint 1에서 클라이언트와 연결되는 최소 서버 루프를 제공한다.

## 실행
```powershell
cd server
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

## 현재 기능
- WebSocket 서버 (`ws://127.0.0.1:8765`)
- 연결 시 `hello` 이벤트 전송
- 1초 간격 `tick` heartbeat 전송
- `client_ready` 메시지 수신 시 상태 응답
