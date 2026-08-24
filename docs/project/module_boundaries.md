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
last_reviewed: 2026-08-24
owner: project-maintainer
related:
  - ../../AGENTS.md
  - ../../project.godot
  - ../README.md
  - ../GDD.md
  - ../design/README.md
  - project_context.md
  - development_handoff.md
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

`src/harness/`는 코드 위치만 예약한다. [`harness_engineering.md`](../design/harness_engineering.md)가 `draft`인 동안 비어 있는 하네스 상세 규칙을 추정해 구현하지 않는다.

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
- `src/harness/harness_controller.gd`는 플레이어의 공개 위험 감지 결과를 받아 `use_harness` 입력, 시험 충전과 안정화 명령을 소유한다. 위험은 하네스 내부 상태를 직접 바꾸지 않으며, 하네스는 공개 `stabilize` 명령만 요청한다.
- `src/ui/harness_status.*`는 현재 충전과 `Q` 안정화 안내만 표시한다. 충전 소모와 대상 가능 여부는 계산하지 않는다.
- `tests/fixtures/hazard_harness_test_space.tscn`은 사전 징후와 `Q` 안정화를 직접 확인하는 공간을, `tests/smoke/hazard_harness_smoke.tscn`은 안정화와 미대응 분기를 자동 검증하는 장면을 소유한다. 충전·비용·경고 시간은 테스트와 장면에서 조정하는 시제품 값이다.
- 다음 개발 작업은 `DEV-0106 — 출구·귀환·실패`이며, 다음 정합성 검사는 `DEV-0107` 완료 뒤 진행한다.
