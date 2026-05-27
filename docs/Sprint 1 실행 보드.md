# Sprint 실행 보드

기간: `2026-05-19 ~ 2026-06-01`  
목표: `코어 루프 안정화 + ThreatPack Lite 진입`

## 보드 상태 정의
- `TODO`: 아직 시작하지 않음
- `IN_PROGRESS`: 현재 작업 중
- `BLOCKED`: 의존 작업/결정 대기
- `DONE`: 완료 조건(DoD) 충족

## 작업 카드

| ID | 상태 | 작업명 | DoD | 결과물 |
| :--- | :--- | :--- | :--- | :--- |
| S1-01 | DONE | PlayerController | 이동/충돌 정상, 입력 지연 100ms 이하 | `client/src/game/` |
| S1-02 | DONE | RoomGraph v1 | 5~8개 방, 단일 출구 왕복 경로 보장 | `client/src/game/`, `server/` |
| S1-03 | DONE | LootInteraction | 조사/획득/버리기/중량 반영 동작 | `client/src/game/`, `shared/` |
| S1-04 | DONE | NoiseCore v1 | 행동 소음 + 중량 보정 + 티어 변화 동작 | `client/src/game/` |
| S1-05 | DONE | RunLoop v1 | 1회 런 완주(진입 -> 귀환 -> 정산) | `server/`, `client/src/` |
| S2-01 | IN_PROGRESS | ThreatPack Lite | 함정 1종+추적자 1종+소음 연동+체력 감소/실패 루프 | `server/`, `client/src/game/`, `shared/` |
| S2-02 | IN_PROGRESS | FailureRule v1 | 런 실패 시 부분 회수(35%) + 손실(65%) 반영, 즉시 재도전 루프 | `client/src/game/`, `shared/` |
| S2-06 | DONE | Harness Engineering v1 | 계약/전이/리플레이/코어 하네스 + CI 게이트 구성 완료 | `AGENTS.md`, `server/tests/`, `server/harness/`, `client/harness/`, `.github/workflows/` |
| S2-07 | IN_PROGRESS | Zone+Door Prototype | 복도 독립 구역화 + 문 상태/행동 + 해정 도구 루프 + 입구 귀환 정산 | `client/src/game/`, `server/`, `shared/`, `GDD (통합본).md` |

## 리스크 / 결정 로그
- [ ] 추적자 판정(서버 권위/클라이언트 보간) 분리 범위 확정
- [ ] 함정 배치 랜덤화 적용 여부 (Sprint 2 후반)
- [ ] 실패 시 손실 규칙(`S2-02`) 정량 수치 확정
- [ ] 문 상태별 밸런스(소음/시간/도구 소모) 1차 튜닝
- [x] 하네스 산출물(`*.trace.json`) Git 추적 제외 정책 반영

## 데일리 체크
- [x] Day 1: 서버/클라 연결 확인
- [x] Day 3: 이동 + 방 이동 데모
- [x] Day 5: 루팅 + 중량 + 소음 데모
- [x] Day 8: 귀환/정산 1사이클
- [x] Day 9: 하네스 체계(계약/리플레이/전이/CI) 구축
- [x] Day 10: 구역+문 프로토타입 1차 구현
- [ ] Day 11: 내부 플레이테스트 10회
