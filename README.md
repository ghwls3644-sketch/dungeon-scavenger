# 🏚️ Dungeon Scavenger

> 이미 공략이 끝난 폐던전에 홀로 들어가, 남겨진 잡동사니와 잊혀진 유물을 챙기고 살아서 같은 길로 빠져나오는 **2D 탑다운 루팅 & 탈출형 어드벤처 게임** 기획서입니다.

---

## 📄 포함 문서

| 파일 | 설명 |
| :--- | :--- |
| `GDD (통합본).md` | ChatGPT + Gemini 기획안을 통합한 최종 게임 기획서 (GDD) |
| `docs/gdd/README.md` | GDD 분할 운영 인덱스 및 모듈 문서 안내 |
| `docs/Sprint 1 실행 보드.md` | Sprint 1 실행 상태/리스크/데일리 체크 보드 |
| `MVP 구현 백로그 (스프린트).md` | 문서 기획을 구현 태스크로 전환한 2주 스프린트 백로그 |
| `기획 하네스 프롬프트.md` | 보관본(FROZEN): 하네스 템플릿 상태/참조 안내 |
| `요청 주제 백로그.md` | 보관본(FROZEN): 설계 주제 완료 상태 요약 |
| `GDD 자동 반영 프로토콜.md` | 보관본(DEPRECATED): 자동 반영 규칙 상태 안내 |
| `archive/Dungeon scavenger(chatGPT).md` | 기획안 A — ChatGPT 초안 (아카이브) |
| `archive/Dungeon scavenger(gemini).md` | 기획안 B — Gemini 초안 (아카이브) |
| `archive/기획 하네스 프롬프트 (FROZEN-2026-05-20).md` | 하네스 프롬프트 원문 보관 |
| `archive/요청 주제 백로그 (FROZEN-2026-05-20).md` | 요청 주제 백로그 원문 보관 |
| `archive/GDD 자동 반영 프로토콜 (DEPRECATED-2026-05-20).md` | 자동 반영 프로토콜 원문 보관 |

---

## 🎮 게임 개요

- **장르**: 2D 탑다운 루팅 / 탈출형 어드벤처
- **플랫폼**: PC (Python 서버 + Node.js/Vite + React + HTML5 Canvas 기반 브라우저 클라이언트)
- **핵심 재미**: 가치 판단 · 귀환 긴장감 · 폐허 탐험 몰입감

---

## 🧱 스캐폴드 구조

- `server/`: Python + websockets 최소 서버 루프
- `client/`: React + Vite 최소 HUD/Canvas 쉘
- `shared/`: 클라이언트-서버 메시지 계약

---

## ▶️ 로컬 실행 (스캐폴드)

1. 서버 실행
```powershell
cd server
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

2. 클라이언트 실행 (새 터미널)
```powershell
cd client
npm install
npm run dev
```

3. 프로토타입 조작
- 이동: `WASD` 또는 방향키
- 달리기: `Shift`
- 루팅: `E` (아이템 근접 시)
- 드롭: `Q`
- 출구 정산: `Space` (Exit 방에서 인벤토리 보유 시)

---

## 🗂️ 기획서 주요 내용

1. 핵심 게임플레이 루프
2. 세계관 및 스토리라인
3. 소음 & 어그로 시스템
4. 단일 출구 왕복 동선 구조
5. 인벤토리 & 아이템 시스템
6. 성장 시스템
7. 아트워크 및 연출 방향
8. 기술 스택 및 개발 로드맵
