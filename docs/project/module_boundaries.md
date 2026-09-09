---
id: PROJECT-MODULE-BOUNDARIES
title: 폴더와 모듈 경계
document_type: project
status: confirmed
source_version: development-proposal-v0.1+gdd-v2.1+dev-0002
canonical_for:
  - source_tree_layout
  - module_responsibilities
  - module_dependency_rules
last_reviewed: 2026-09-09
owner: project-maintainer
related:
  - ../../AGENTS.md
  - ../../project.godot
  - ../README.md
  - ../GDD.md
  - ../design/README.md
  - project_context.md
  - development_handoff.md
  - g2_flow_review.md
  - decisions.md
---

# 폴더와 모듈 경계

## 목적

`DEV-0002`부터 사용하는 Godot 소스 폴더와 각 모듈의 책임을 고정한다. 새 파일을 만들 때 어느 폴더에 둘지 판단하고, 화면·저장·게임 규칙이 서로의 책임을 가져가지 않도록 하는 개발 기준이다.

이 문서는 코드 배치와 의존 방향만 소유한다. 실제 게임 규칙은 관련 `confirmed` Design 문서가, 제품과 시스템 연결은 GDD가 소유한다.

## 실제 폴더 구조

```text
res://
  src/
    app/
    core/
    gameplay/
    harness/
    meta/
    infrastructure/
    ui/
    data/
  tests/
```

동결 개발 제안서의 `App`, `Core`, `Gameplay`, `Meta`, `Infrastructure`, `UI`, `Data`, `Tests`를 Godot 경로 관례에 맞춰 소문자로 배치했다. 현재 GDD가 하네스를 독립 시스템으로 구분하므로 `src/harness/`도 함께 둔다.

이번 티켓은 위 최상위 경계만 만든다. 각 모듈 안의 기능별 하위 폴더는 실제 기능 티켓에서 필요한 것만 추가한다.

## 모듈별 책임

| 경로 | 맡는 책임 | 맡지 않는 책임 |
|---|---|---|
| `res://src/app/` | 부팅, 장면 흐름, 전역 게임 상태, 모듈 조립 | 탐험·경제 규칙 계산, 화면 표시 세부 |
| `res://src/core/` | 안정적 ID 기반, 이벤트, 시간, 여러 모듈이 공유하는 최소 타입 | 특정 기능의 규칙, 장면과 UI |
| `res://src/gameplay/` | 플레이어, 탐색, 상호작용, 위험, 인벤토리, 회수와 탈출 | 거점 경제, 화면 전환, 저장 입출력 |
| `res://src/harness/` | 하네스 모듈, 충전, 분석, 작업과 비상 행동 | 하네스 세부 규칙의 임의 확정, 일반 탐험 흐름 |
| `res://src/meta/` | 거점, 경제, 감정, 연구, 장비와 성장 | 탐험 조작, 저장 파일 처리, 화면 그리기 |
| `res://src/infrastructure/` | 저장, 설정, 입력, 오디오, 현지화와 로그의 기술 연결 | 실패 손실·가격·진행처럼 게임이 결정할 규칙 |
| `res://src/ui/` | 타이틀, HUD, 지도, 인벤토리, 거점, 정산과 옵션 표시·사용자 명령 전달 | 게임 규칙 계산, 저장 처리, 직접 장면 전환 |
| `res://src/data/` | 아이템·방·루트·위험·경제·텍스트의 정의와 콘텐츠 값 | 실행 중 상태 변경, 화면 흐름, 저장 시점 결정 |
| `res://tests/` | 단위·통합·스모크 검사와 테스트 전용 자료 | 출시 게임 기능과 실제 콘텐츠 |

`src/harness/`는 GDD에 확정된 하네스 행동과 충전을 구현한다. [`harness_engineering.md`](../design/harness_engineering.md)가 `draft`인 동안 비어 있는 모듈·성장·최종 수치를 추정해 구현하지 않는다.

## 의존 방향

1. `core`는 다른 프로젝트 모듈을 참조하지 않는다.
2. `data`는 공통 ID나 타입이 필요할 때 `core`만 참조한다.
3. `gameplay`, `harness`, `meta`는 `core`와 `data`의 공개 정의를 사용한다. 서로 협력할 때는 공개 명령·상태·이벤트를 통하고 상대 모듈의 내부 파일을 직접 조작하지 않는다.
4. `infrastructure`는 전달받은 상태를 읽고 쓰는 기술 처리를 맡는다. 게임 규칙 모듈은 구체적인 저장·입력·오디오 구현을 직접 만들지 않고 `app`에서 연결한다.
5. `ui`는 공개 상태를 표시하고 사용자 명령을 전달할 수 있지만 결과를 계산하거나 장면을 직접 바꾸지 않는다.
6. `app`은 모듈을 조립하고 중앙 상태·장면 흐름을 관리한다. 여러 모듈을 연결해야 하는 조정 코드는 `app`에 둔다.
7. `tests`는 필요한 모듈을 참조할 수 있지만 출시 코드에서는 `tests`를 참조하지 않는다.
8. 순환 의존은 만들지 않는다. 두 모듈이 서로를 필요로 하면 공유 정의를 `core`로 옮기거나 조정을 `app`에 둔다.

## 파일 배치 판단 순서

새 파일을 추가할 때 다음 순서로 위치를 정한다.

1. 하나의 기능 규칙이면 그 기능을 소유한 `gameplay`, `harness`, `meta`에 둔다.
2. 저장·입력·오디오처럼 엔진이나 운영체제와 연결하는 코드면 `infrastructure`에 둔다.
3. 표시와 사용자 명령 전달이면 `ui`에 둔다.
4. 콘텐츠 정의나 조정 가능한 값이면 `data`에 둔다.
5. 여러 모듈을 연결하거나 화면 흐름을 바꾸면 `app`에 둔다.
6. 둘 이상에서 정말 같은 의미로 쓰는 최소 정의만 `core`에 둔다. 편의를 위해 기능 코드를 `core`로 옮기지 않는다.

## 개발 진행과 인계

- `DEV-0002`에서 위 9개 경계를 만들고 각 폴더는 `.gitkeep`만 둔 상태로 시작했다.
- `DEV-0003`에서 `src/app/`에 `GameState` Autoload와 최소 조립 장면을, `src/ui/`에 개발용 상태 표시 UI를 추가했다.
- `GameState`만 현재 상태와 허용 전환을 바꾸며, 메인 장면의 UI는 공개 전환 인터페이스에 요청만 보낸다.
- `DEV-0004`에서 `src/infrastructure/input_actions.gd`가 행동 이름과 Godot 입력 조회를 소유하고, `project.godot`이 키보드·마우스 기본 연결을 소유하도록 했다.
- 게임 규칙과 UI는 실제 키 코드를 참조하지 않고 `InputActions`의 공개 행동 이름과 조회 API만 사용한다.
- `DEV-0005`에서 `src/core/stable_id.gd`는 여러 모듈이 공유할 최소 ID 검증만 소유하고, `src/data/`는 공통 콘텐츠와 아이템 데이터 정의를 소유하도록 했다.
- 표시 이름과 안정적 ID는 `ContentDefinition`의 독립 필드이며 `ItemDefinition`에는 실행 중 획득 상태나 저장 상태를 두지 않는다.
- `DEV-0006`에서 `src/infrastructure/game_log.gd`는 엔진 로그 연결과 공통 형식을, `src/app/dev_entry.gd`는 개발 상태 진입 조정을 소유하도록 했다.
- `tests/smoke/`는 출시 장면이 참조하지 않는 상태 전환 스모크 장면을 소유하며 종료 코드로 결과를 전달한다.
- `DEV-0006` 완료 뒤 정합성 검사에서 위 경계와 프로젝트 기반이 일치함을 확인했고, 2026-08-01 사용자의 진행 지시에 따라 G0를 통과했다.
- `DEV-0101`에서 `src/gameplay/player/`가 `CharacterBody2D` 기반 플레이어 이동과 자식 `Camera2D`를 소유하도록 했다. 이동 제어기는 `InputActions`의 공개 조회 API에만 의존한다.
- `tests/fixtures/`는 이동·카메라와 일시정지를 직접 확인하는 개발 공간을, `tests/smoke/`는 실제 플레이어 장면을 자동 검증하는 장면을 소유한다. 테스트 공간의 일시정지 조작은 출시 플레이 흐름이 참조하지 않는다.
- `DEV-0102`에서 `src/gameplay/interaction/`이 공통 대상 인터페이스, 대상 감지와 상호작용 실행을 소유하도록 했다. 플레이어 장면은 감지기와 실행기를 조립하고 실제 입력 키 대신 `InputActions.INTERACT`를 사용한다.
- `src/ui/interaction_prompt.*`는 현재 대상의 안내 문구만 표시하며 대상 선택이나 상호작용 결과를 결정하지 않는다. 시험용 회수품과 문은 같은 `Interactable` 인터페이스를 사용한다.
- `tests/fixtures/interaction_test_space.tscn`은 수동 확인 공간을, `tests/smoke/interaction_system_smoke.tscn`은 감지·안내·실행과 두 대상의 공통 인터페이스 검증을 소유한다.
- `DEV-0103`에서 `src/gameplay/inventory/`가 실행 중 아이템 목록, 슬롯·무게 합계와 단계, 선택·버리기 규칙을 소유하도록 했다. 시험용 회수품은 공개 `PlayerInventory` 명령으로 획득을 요청하며 슬롯 한도 거절 여부를 직접 결정하지 않는다.
- `src/ui/inventory_panel.*`는 공개 인벤토리 상태를 표시하고 열기·닫기·일반 버리기 명령을 전달한다. 슬롯·무게 규칙은 계산하지 않으며 `DEC-103`에 따라 화면이 열린 동안 `SceneTree` 일시정지만 제어한다.
- `tests/fixtures/inventory_test_space.tscn`은 시험용 한도·무게 값으로 직접 확인할 공간을, `tests/smoke/inventory_system_smoke.tscn`은 획득·한도 거절·무게 단계·화면 표시·버리기와 일시정지를 자동 검증하는 장면을 소유한다. 출시 코드는 이 테스트 값과 장면을 참조하지 않는다.
- `DEV-0104`에서 `src/gameplay/recovery/`가 인벤토리에서 전달받은 현재 회수품 목록과 예상 가치 합계를 고정하도록 했다. 실제 판매·비용·순이익 계산은 `meta`의 후속 책임으로 남겨 둔다.
- `src/ui/item_value_text.gd`는 예상 가치 범위와 비화폐 보상 문구를, `src/ui/recovery_result_panel.*`는 회수품별 가치와 결과 합계 표시를 소유한다. UI는 포함 물품이나 합계를 결정하지 않는다.
- `tests/fixtures/recovery_result_test_space.tscn`은 회수 결과 표시를 직접 확인하는 공간을, `tests/smoke/recovery_result_smoke.tscn`은 들고 나온 물품만 포함되는지와 가치 합계·비화폐 보상 분리를 자동 검증하는 장면을 소유한다.
- `DEV-0105`에서 `src/gameplay/hazards/`가 위험 대상의 사전 징후, 경고 상태, 안정화 가능 여부, 붕괴와 범위 안 포착 이벤트를 소유하도록 했다. 실제 피해·부상·실패 판정은 이 모듈이 임의로 결정하지 않는다.
- `src/harness/harness_controller.gd`는 플레이어의 공개 위험 감지 결과를 받아 `use_harness` 입력, 시험 충전과 안정화 명령을 소유한다. `DEV-0110`에서 정밀 분석·비상 방전과 공통 충전 처리를 확장했다. 위험은 하네스 내부 상태를 직접 바꾸지 않으며 하네스는 대상의 공개 조회·명령만 사용한다.
- `src/ui/harness_status.*`는 현재 충전·기본 분석·구매한 정밀 분석과 `Q` 행동을 표시하고 분석 버튼을 공개 명령에 연결한다. 버튼 활성 여부도 하네스에 조회하며 충전 소모와 대상 규칙을 결정하지 않는다.
- `tests/fixtures/hazard_harness_test_space.tscn`은 사전 징후와 `Q` 안정화를 직접 확인하는 공간을, `tests/smoke/hazard_harness_smoke.tscn`은 안정화와 미대응 분기를 자동 검증하는 장면을 소유한다. 충전·비용·경고 시간은 테스트와 장면에서 조정하는 시제품 값이다.
- `DEV-0106`에서 `src/gameplay/recovery/`가 입구 생환 명령, 탐험의 단일 종료 상태와 생환·실패 결과를 소유하도록 했다. `PlayerInventory`는 현재 탐험 물품을 공개 명령으로 인계하고 비우며, 회수 모듈은 생환 물품만 기존 `RecoveryResult`에 넣는다.
- `src/gameplay/recovery/entrance_exit.*`는 공통 `Interactable`을 통해 활성 탐험의 생환만 요청한다. 위험 모듈은 계속 포착 이벤트만 내며, 시험 공간의 조립 코드가 이 공개 이벤트를 탐험 실패 명령에 연결한다.
- `src/ui/exploration_outcome_panel.*`은 생환의 회수 결과와 실패의 손실 개수를 표시할 뿐 종료 상태, 포함 물품이나 손실을 결정하지 않는다.
- `tests/fixtures/exploration_end_test_space.tscn`은 입구 생환과 위험 포착 실패를 직접 확인하는 공간을, `tests/smoke/exploration_end_smoke.tscn`은 두 종료 분기, 물품 인계·손실과 종료 상태 잠금을 자동 검증하는 장면을 소유한다.
- `DEV-0107`에서 `tests/fixtures/core_loop_playtest_space.tscn`이 기존 공개 모듈을 안전 경로·위험 보상 경로가 있는 작은 던전으로 조립했다. 시험용 아이템·슬롯·무게·가치·하네스 충전과 경고 시간은 `tests` 안에만 있으며 출시 코드와 제품 데이터가 참조하지 않는다.
- `tests/smoke/core_loop_playtest_smoke.tscn`은 같은 플레이테스트 장면으로 안전 생환, 위험 대응과 적재 교체 뒤 생환, 미대응 실패를 자동 검증한다. 테스트 조립 코드는 모듈 내부 상태를 직접 바꾸지 않고 공개 명령·상태·이벤트를 사용한다.
- `DEV-0108`에서 `src/gameplay/inventory/inventory_item.gd`가 불변 아이템 정의와 현재 탐험의 감정 여부를 분리한다. `ItemDefinition`에는 실행 중 상태를 추가하지 않으며 `PlayerInventory`와 회수 모듈은 공개 실행 중 물품 상태를 전달한다.
- `src/gameplay/interaction/inspectable_pickup_interactable.*`은 같은 `Interactable` 경계 안에서 첫 조사와 다음 회수를 구분한다. 조사 대상은 인벤토리 한도나 감정 상태를 직접 결정하지 않고 공개 인벤토리 명령에 미확인 상태의 회수를 요청한다.
- `src/ui/inventory_panel.gd`, `item_value_text.gd`, `recovery_result_panel.gd`는 공개 감정 상태를 읽어 숨겨야 할 분류·가치를 표시하지 않는다. 숨겨진 가치를 합계에서 제외하는 규칙은 `RecoveryResult`가 소유하며 UI는 다시 계산하지 않는다.
- `tests/fixtures/inspection_unidentified_test_space.tscn`은 조사·회수·생환을 직접 확인하는 개발 공간을, `tests/smoke/inspection_unidentified_smoke.tscn`은 조사 정보와 미확인 상태 전달·정보 비노출을 자동 검증한다. 시험 물품·무게·가치와 위험 힌트는 테스트 전용이다.
- `DEV-0109`에서 `src/gameplay/hazards/broken_guard_golem.*`이 골렘의 순찰·의심·추적·수색 상태, 마지막 위치와 외부 소음·경보 요청을 소유하도록 했다. 골렘은 공개 상태·이벤트를 제공하며 전투 피해나 탐험 실패를 직접 결정하지 않는다.
- `tests/fixtures/broken_guard_golem_test_space.tscn`은 사전 흔적, 탐지음과 상태 하강을 직접 확인하는 개발 공간을, `tests/smoke/broken_guard_golem_smoke.tscn`은 순찰·탐지·추적·수색·소음·경보 흐름을 자동 검증한다. 이동·탐지·대기 수치는 조정 가능한 시제품 값이다.
- `DEV-0109-R1`에서 `ItemDefinition.is_protected()`가 실제 분류·보호 설정을 판별하고 `PlayerInventory`가 버리기를 거절하도록 했다. UI는 이 규칙을 다시 계산하지 않고 거절 메시지와 공개된 정보만 표시한다.
- `InventoryItem`은 조사로 알게 된 위험 정보도 소유한다. 조사 회수품이 이 정보를 공개 획득 명령으로 전달하고 인벤토리와 회수 결과 UI가 표시한다.
- `RecoveryResult`는 생성 시 물품 정의·감정·위험 정보를 복사하고 조회에서도 분리된 복사본을 반환한다. 회수품 일치 검사는 객체 참조 대신 안정적 ID를 사용한다. `ExplorationRun`은 인벤토리 변경 알림 전에 종료 처리를 잠근다.
- 인벤토리의 열기 입력은 미처리 입력 경로를 유지하고, 열린 화면의 닫기 입력만 GUI 포커스 처리 전에 받는다. 골렘은 감지 중인 대상을 외부 소음·경보로 교체하지 않는다.
- `DEV-0110`에서 `HazardDetector`가 범위 안 잔해·골렘 중 대응 가능 여부와 거리에 따라 하네스 대상을 공개한다. 기존 안정화 대상 조회도 유지한다. 각 위험은 기본·정밀 분석 정보와 물리적 행동 가능 여부를 소유한다.
- `BrokenGuardGolem`은 비상 방전에 따른 임시 정지·복귀와 현재 탐지 여부를 소유한다. `HarnessController`는 비용 검증·공동 충전·중첩 명령 차단·정밀 분석 표시 수명을 소유하며 골렘 내부 타이머나 추적 대상을 직접 변경하지 않는다.
- `tests/fixtures/harness_actions_test_space.tscn`은 분석·안정화·방전 확인 공간을, `tests/smoke/harness_actions_smoke.tscn`은 공동 충전과 임시 정지·복귀의 자동 검사를 소유한다. 제품 수치와 통합 플레이테스트의 사람 판단을 대신하지 않는다.
- `DEV-0111`에서 `tests/fixtures/g1_integration_playtest_space.*`가 고정 시험 맵의 벽·배치와 기존 모듈을 조립하고 가방 조건 선택·측정·결과 복사·다시 시작을 소유한다. 공개 명령·상태·이벤트를 사용하며 출시 모듈이 시험 자료를 참조하지 않는다.
- 시험 기록의 시간·최대 적재·사건 순서는 `tests` 안에서만 수집한다. 자동 실행과 사람 실행의 출처를 구분하고 제품 저장 스키마나 최종 밸런스로 사용하지 않는다.
- `tests/smoke/g1_integration_playtest_smoke.tscn`은 실제 이동 입력으로 위험 대응·우회 비교·붕괴 실패를 확인한다. `src/ui/recovery_result_panel.tscn`의 설명 줄바꿈과 목록 최소 높이 조정은 기존 결과 표시 책임 안에 둔다.
- `DEV-0111`은 사용자 승인으로 커밋했다. 추가 정합성 검사에서 발견한 분석 버튼 클릭 후 Tab 가방 열기 오류는 사용자 지시에 따라 `InventoryPanel`의 입력 처리 안에서 보완했다. 실제 클릭·키 입력 재현 검사는 `tests`가 소유하며 스모크 장면 12개가 통과했다. 이번 보완은 검증 결과 검토 후 사용자가 커밋을 승인했다. 당시 `DEV-0201`은 사람 평가·진행 지시 대기로 보류했다.
- 이어진 가독성·시험 조건 보완에서 `InventoryPanel`은 선택한 물품의 공개 정보와 긴 설명 스크롤을 표시한다. 통합 시험 장면만 경고 시간·골렘 추적 속도를 조정하고 추적·경고 시간을 수집하며, 같은 경로에서 충전 사용 전후를 비교하는 자동 검사는 `tests`가 소유한다. 새로운 피해·감속 규칙이나 제품 수치를 추가하지 않았다. 스모크 장면 12개와 화면 확인을 마쳤으며 이번 보완은 검증 결과 검토 후 사용자가 커밋을 승인했다.
- 2026-09-08 사용자 작업 재개 지시에 따라 `DEV-0201`을 진행했다. G1 기술 검사는 완료로, 사람 평가와 미정 수치는 후속 확인으로 구분한다.
- `src/app/game_entry.gd`는 부팅·시작 요청과 중앙 상태 전환, 저장 상태 공급자 연결을 소유한다. `src/ui/title_screen.*`은 버튼·표시·옵션 안내와 포커스만 소유하며 저장·장면 전환을 수행하지 않는다. DEV-0201의 거점 도착 안내는 DEV-0202의 `src/ui/hub_panel.tscn`으로 대체했다.
- 저장 유무 조회·복원 요청은 `GameEntry.configure_continue()`로 연결한다. 실제 디스크 읽기·쓰기는 후속 `infrastructure` 구현이 맡으며, 이번 작업의 공급자 테스트는 `tests/smoke/title_screen_smoke.*` 안에서만 수행한다. 복원 성공 전에 거점으로 전환하지 않는다.
- 기존 개발 상태 화면·진입 코드는 `src/app/dev_main.tscn`에 조립하며 디버그 인수가 있을 때 `GameEntry`가 이 장면으로 연결한다. 출시 코드가 `tests`를 참조하지 않는다.
- `DEV-0202`의 `src/meta/hub_state.gd`는 거점의 준비 선택과 시험용 기본 조건을 소유한다. `src/core/expedition_loadout.gd`는 가방 한도·무게 단계·충전의 유효성 검사와 복사를 제공하는 작은 데이터 경계이며 노드·UI·저장을 참조하지 않는다.
- `GameEntry`는 거점 선택 요청을 준비 상태에 반영하고 출정 시 복사본을 `src/app/prototype_exploration.*`에 전달한다. 이 조립 장면은 기존 플레이어·물품·위험·하네스·회수 모듈에 데이터를 적용하고 시작·종료 시 조작을 관리한다. 거점 상태를 참조하거나 수정하지 않는다.
- `src/ui/hub_panel.*`은 준비 조건 표시와 선택·출정 요청을, `src/ui/expedition_results_screen.tscn`은 기존 종료 결과 표시와 후속 기능 안내를 맡는다. `GameEntry`는 결과를 보관하고 탐험 장면을 정리하며 정산·거점 반영은 `DEV-0203`에 둔다.
- 시제품 배치와 값은 기존 G1 조건을 재사용하지만 실행 코드에서 `tests`를 참조하지 않는다. G1 비교 장면·측정 원본은 유지하고, 출정 데이터 분리·실제 입력 경로·종료 정리는 `tests/smoke/hub_departure_smoke.*`가 검사한다. 실제 저장 파일과 최종 장비·비용·밸런스 규칙은 추가하지 않는다.
- `DEV-0203`의 `src/data/economy_rule.gd`와 `prototype_economy.tres`는 안정적 ID별 시험 판매가를 소유한다. 기존 아이템의 예상 가치 범위를 수정하거나 예상가를 실제 판매가로 자동 전환하지 않는다. 세율·수리비 등 아직 없는 비용 시스템은 포함하지 않는다.
- `src/meta/settlement_result.gd`는 기존 `ExplorationOutcome`의 공개 회수 결과를 읽어 판매 내역·수입·비용·순이익과 보관품을 계산한다. 미확인·보호·가격 미설정 물품을 보관 대상으로 분리하고 결과는 복사본으로 조회한다. 탐험 모듈은 거점·경제 모듈을 참조하지 않는다.
- `HubState`는 실행 중 돈·보관품과 출정 번호를 소유하며 정산 준비와 반영을 구분한다. 같은 출정의 중복 정산과 이전 출정 요청을 거절하고 실패는 기존 돈·보관품을 바꾸지 않는다. 가격·보호 판정은 `SettlementResult`와 기존 공개 아이템 정의를 따른다.
- `GameEntry`는 탐험 종료 결과·출정 번호를 거점 정산에 연결하고 확인 요청 후 중앙 상태 관리자를 통해 거점으로 돌아온다. `ExpeditionResultsScreen`과 `HubPanel`은 계산된 결과와 공개 물품 정보만 표시한다. 거점 감정·등록·연구·보관품 꺼내기·디스크 저장을 수행하지 않는다.

- `DEV-0204`의 `src/core/game_settings.gd`는 화면 모드·창 크기 선택·전체 음량의 기본값, 유효성 검사와 복사만 소유한다. 엔진 적용·파일 입출력은 참조하지 않는다.
- `src/infrastructure/settings_store.gd`는 설정 전용 버전 1 파일의 읽기·검증·임시 파일 교체와 지원하지 않는 버전 보존을 맡는다. `settings_runtime.gd`는 검증된 값을 실제 Window·AudioServer에 적용한다. 진행 데이터와 거점 규칙은 소유하지 않는다.
- `GameEntry`가 부팅 시 설정을 읽어 적용하고, 타이틀의 적용 요청은 파일 저장 성공 후 엔진에 전달한다. `TitleScreen`은 적용 전 선택·안내·포커스와 요청 전달만 맡는다. 테스트는 `configure_settings()`로 임시 경로를 연결하며 실제 사용자 설정을 바꾸지 않는다.
- 정산 계산·중복 방지·복사본 보호는 `tests/smoke/settlement_smoke.*`, 실제 입력의 세 번 출정과 재산 유지는 기존 `hub_departure_smoke.*`가 확인한다. 반복 방문은 같은 시제품 장면을 새로 조립하며 기존 G1 비교 자료와 제품의 방문별 영구 상태 설계는 유지한다.

- `DEV-0205`의 `src/data/item_catalog.gd`와 `prototype_item_catalog.tres`는 기존 물품 ID와 독립 정의의 대응을 소유한다. `prototype_light`·`prototype_heavy`·`prototype_known`·`prototype_unknown` 리소스는 기존 시제품 장면의 값·이름·ID를 그대로 옮겼다. 탐험과 저장 복원이 같은 정의를 사용하며 G1 테스트 원본은 유지한다.
- `HubState`가 저장 가능한 거점 상태의 범위·검증과 ID 기반 복원을 소유한다. 실행 중 탐험·정산 대기는 저장용 상태로 내보내지 않는다. `copy()`로 만든 후보 상태에 정산·준비 변경을 적용하고, 기존 상태는 저장 성공 전까지 유지한다. UI나 디스크를 참조하지 않는다.
- `src/infrastructure/progress_store.gd`는 설정과 별도 파일의 JSON 입출력·크기 한도·버전 검사·임시 파일 교체만 맡는다. 물품 생성·정산·자동 저장 시점은 결정하지 않는다. 게임 노드나 리소스를 파일에서 실행·생성하지 않고 원시 데이터만 읽는다.
- `GameEntry`가 실제 저장 유무·복원을 기존 이어하기 연결부에 공급하고, 거점 후보 상태의 검증·저장 성공 후에만 반영한다. 새 게임 교체 확인·재시도·중복 요청 차단과 중앙 상태 전환도 조정한다. `TitleScreen`은 확인 창과 요청 전달, `HubPanel`·`ExpeditionResultsScreen`은 저장 결과 안내만 맡는다.
- `tests/smoke/progress_save_smoke.*`는 임시 파일로 큰 정수·ID 복원·설정 분리·손상·버전·교체 확인·쓰기 실패 재시도를 검사한다. 기존 `hub_departure_smoke.*`의 실제 입력으로 만든 파일을 별도 프로세스에서 읽어 복원·재출정도 검사한다. 테스트는 `configure_progress()`로 임시 경로를 주입하며 사용자 진행을 바꾸지 않는다.

- `DEV-0206`의 `tests/run_g2_checks.ps1`은 Godot 프로세스 실행·시간 제한·로그·통과 판정과 반복 결과 기록만 소유한다. 게임 규칙은 구현하지 않는다. 저장·정산 조작은 임시 경로를 주입한 검사 장면에서 수행하고, 기본 실행 검사는 실제 메인 장면의 읽기·부팅만 확인한다. 기존 세 검사 장면이 같은 임시 설정·진행 파일을 이어 사용해 실행 사이의 연결을 확인한다.
- [G2 검사 기록](g2_flow_review.md)은 체크리스트·원본 결과·완료 범위를 소유한다. 게임 기능·저장 스키마·모듈 간 제품 의존 방향은 변경하지 않았다.
