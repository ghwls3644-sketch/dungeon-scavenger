# Dungeon Scavenger

폐던전 루팅/탈출 중심의 2D 탑다운 게임 프로젝트입니다.

## 기준 문서

| 파일 | 설명 |
| :--- | :--- |
| `GDD (통합본).md` | 최종 통합 기획서 |
| `MVP 구현 백로그 (스프린트).md` | 구현 스프린트 백로그 |
| `docs/Sprint 1 실행 보드.md` | 스프린트 실행 보드 |
| `docs/gdd/README.md` | GDD 분할 문서 인덱스 |

## Archive (용도별 보관)

| 파일 | 용도 |
| :--- | :--- |
| `archive/기획안 A (ChatGPT).md` | 초기 기획안 A 원문 |
| `archive/기획안 B (Gemini).md` | 초기 기획안 B 원문 |
| `archive/기획 하네스 프롬프트 (FROZEN).md` | 하네스 템플릿 보관본 |
| `archive/요청 주제 백로그 (FROZEN).md` | 요청 주제 백로그 통합 보관본 |
| `archive/GDD 자동 반영 프로토콜 (DEPRECATED).md` | 자동 반영 프로토콜 보관본 |

## 기술 스택

- Python (`asyncio`, `websockets`)
- Node.js + Vite
- React + TypeScript
- HTML5 Canvas
- WebSocket(JSON)

## 실행

1. 서버
```powershell
cd server
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

2. 클라이언트
```powershell
cd client
npm install
npm run dev
```

3. 기본 조작
- 이동: `WASD` 또는 방향키
- 달리기: `Shift`
- 루팅: `E`
- 드롭: `Q`
- 출구 정산: `Space` (Exit 방)
