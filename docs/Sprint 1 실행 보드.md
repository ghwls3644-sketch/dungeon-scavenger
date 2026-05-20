# Sprint 1 실행 보드

기간: `2026-05-19 ~ 2026-06-01`  
목표: `핵심 루프 수직 슬라이스 (진입 -> 루팅 -> 귀환 -> 정산)`

## 보드 상태 정의
- `TODO`: 아직 시작하지 않음
- `IN_PROGRESS`: 현재 작업 중
- `BLOCKED`: 외부 의존성/결정 대기
- `DONE`: 완료 조건(DoD) 충족

## 작업 카드
| ID | 상태 | 작업명 | DoD | 산출물 |
| :--- | :--- | :--- | :--- | :--- |
| S1-01 | DONE | PlayerController | 이동/충돌 정상, 입력 지연 100ms 이하 | `client/src/game/` |
| S1-02 | DONE | RoomGraph v1 | 5~8개 방, 단일 출구 왕복 경로 보장 | `client/src/game/`, `server/` |
| S1-03 | DONE | LootInteraction | 조사/획득/버리기/중량 반영 동작 | `client/src/game/`, `shared/` |
| S1-04 | DONE | NoiseCore v1 | 행동 소음 + 중량 보정 + 티어 변화 동작 | `client/src/game/` |
| S1-05 | DONE | RunLoop v1 | 1회 런 완주(진입->귀환->정산) | `server/`, `client/src/` |

## 리스크/결정 로그
- [ ] 맵 생성을 완전 랜덤으로 시작할지, 고정 시드로 시작할지 결정
- [ ] 4방향/8방향 이동 중 1차 MVP 기준 확정
- [ ] 소음 티어 임계값 초기안 확정 (`Quiet/Caution/Loud/Critical`)

## 데일리 체크
- [ ] Day 1: 서버/클라 연결 확인
- [x] Day 3: 이동 + 방 탐색 데모
- [x] Day 5: 루팅 + 중량 + 소음 데모
- [x] Day 8: 귀환/정산까지 1회전
- [ ] Day 10: 내부 플레이 테스트 10회
