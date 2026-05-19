# 03. Production Stack / Roadmap

## 기준 스택
- 서버: Python + asyncio + websockets
- 클라이언트: React + TypeScript + HTML5 Canvas
- 개발/툴링: Node.js + Vite
- 통신: WebSocket (JSON 우선)

## 단계별 구현 원칙
- Phase 1: 핵심 루프 수직 슬라이스 완성
- Phase 2: 위협/실패/회복 루프 연결
- Phase 3: 반복성/밸런스/온보딩 강화

## 실행 문서 연결
- 스프린트 상세: `MVP 구현 백로그 (스프린트).md`
- 하네스 입력 규칙: `기획 하네스 프롬프트.md`
- 자동 반영 기준: `GDD 자동 반영 프로토콜.md`

## 품질 게이트 요약
- `AUTO_MERGE`: 18~20점 + 고영향 충돌 0 + 예산 초과 0
- `HOLD`: 15~17점 또는 중영향 충돌/구현 순서 불명확
- `REJECT`: 14점 이하 또는 제약 위반
