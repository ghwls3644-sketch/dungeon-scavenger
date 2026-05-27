# MVP 구현 백로그 (스프린트)

기준일: `2026-05-19`  
기준 스택: `Python + Node.js + React + HTML5 Canvas + WebSocket`

## 1) 운영 원칙
- 구현 순서는 `핵심 루프 완성 -> 위협/실패 루프 -> 반복성/밸런스`를 따른다.
- 각 태스크는 `완료 조건(DoD)`이 없으면 `진행 중`으로 간주한다.
- 스프린트 종료 시 반드시 `데모 가능한 플레이 경로`를 1개 이상 유지한다.
- 핵심 규칙 변경 시 `하네스(계약/전이/리플레이/코어)`를 함께 업데이트한다.

## 2) Sprint 1 (2주) - 핵심 루프 수직 슬라이스

| ID | 작업명 | 담당 레이어 | 예상 공수(인일) | 선행조건 | 완료 조건(DoD) |
| :--- | :--- | :--- | :---: | :--- | :--- |
| S1-01 | PlayerController | Canvas Client | 2.0 | 없음 | 이동/충돌/입력 지연 100ms 이하 |
| S1-02 | RoomGraph v1 | Python Server + Data | 2.5 | S1-01 | 5~8개 방, 단일 출구 왕복 경로 보장 |
| S1-03 | LootInteraction | Client + Server | 2.0 | S1-02 | 조사/획득/버리기 + 인벤토리 반영 |
| S1-04 | NoiseCore v1 | Python Server | 2.0 | S1-03 | 행동 소음, 중량 보정, 티어 변화 동작 |
| S1-05 | RunLoop v1 | Full Stack | 1.5 | S1-04 | 진입->탐험->귀환->정산 1사이클 완료 |

## 3) Sprint 2 (2주) - 위협/실패/회복 루프

| ID | 작업명 | 담당 레이어 | 예상 공수(인일) | 선행조건 | 완료 조건(DoD) |
| :--- | :--- | :--- | :---: | :--- | :--- |
| S2-01 | ThreatPack Lite | Python Server + Canvas | 2.5 | S1-05 | 함정 1종 + 추적자 1종 + 어그로 연동 |
| S2-02 | FailureRule v1 | Python Server | 1.5 | S2-01 | 실패 손실/부분 회수 규칙 동작 |
| S2-03 | Shortcut v1 | Full Stack | 2.0 | S2-01 | 지름길 설치/실패/리스크 반영 |
| S2-04 | BasePrep v1 | React UI + Server | 2.0 | S2-02 | 거점 준비와 다음 런 선택지 연결 |
| S2-05 | Telemetry v1 | Node.js Tooling | 1.5 | S1-05 | 생환률/소음피크/과적시간 로그 저장 |
| S2-06 | Harness Engineering v1 | Full Stack Tooling | 1.5 | S2-01 | `AGENTS.md`, 계약/전이 테스트, 리플레이 시나리오, CI 게이트 구성 |
| S2-07 | Zone+Door Prototype | Client + Server + Contract | 2.0 | S2-01 | 복도 독립 구역화 + 문 상태/행동 + 해정 도구 루프 + 입구 귀환 정산 |

## 4) Sprint 3 (2주) - 반복성/밸런스/온보딩

| ID | 작업명 | 담당 레이어 | 예상 공수(인일) | 선행조건 | 완료 조건(DoD) |
| :--- | :--- | :--- | :---: | :--- | :--- |
| S3-01 | AdaptiveSpawn Lite | Python Server | 2.0 | S2-05 | 플레이 성향 기반 경량 스폰 보정 |
| S3-02 | DungeonCycle v1 | Server + Data | 2.0 | S2-02 | 소모/회복 사이클 1회 적용 |
| S3-03 | Onboarding 10m | React UI + Script | 2.0 | S1-05 | 10분 내 핵심 루프 학습 완료 |
| S3-04 | RiskHedge Lite | Server + UI | 1.5 | S2-04 | 보험/투자 최소형 1종 동작 |
| S3-05 | Balance Pass 1 | Full Stack | 2.5 | S3-01 | 악용 3케이스 이상 차단 + 수치 보정 |

## 5) 릴리즈 게이트
- Gate A: Sprint 1 종료 시 플레이 루프 완주율 `80%+` (내부 10회 테스트 기준)
- Gate B: Sprint 2 종료 시 실패 후 재도전 전환율 `70%+`
- Gate C: Sprint 3 종료 시 20~30분 세션 체류율 `60%+`
- Gate H: PR 기준 하네스 체크(`client-harness`, `server-contract-and-replay`) Green 유지

## 6) GDD 역추적
- S1-01, S1-02, S1-05 -> `GDD 2, 4-2, 8-3`
- S1-03, S1-04 -> `GDD 4-1, 4-3, 4-7`
- S2-01~S2-05 -> `GDD 4-11, 4-16, 4-21, 4-24~4-27`
- S2-06 -> `GDD 8-3 (검증/운영 체계 보강)`
- S2-07 -> `GDD 5-1~5-4, 8-4, 8-6`
- S3-01~S3-05 -> `GDD 4-29~4-37`
