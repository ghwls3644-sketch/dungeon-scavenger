---
id: PROJECT-CONTEXT
title: 프로젝트 컨텍스트
document_type: project
status: confirmed
source_version: development-proposal-v0.1+user-decision-2026-07-29
canonical_for:
  - development_environment
  - engine_and_language
  - development_commands
last_reviewed: 2026-08-24
owner: project-maintainer
related:
  - ../../AGENTS.md
  - ../../project.godot
  - ../../src/app/dev_entry.gd
  - ../../src/app/game_state.gd
  - ../../src/app/main.tscn
  - ../../src/core/stable_id.gd
  - ../../src/data/content_definition.gd
  - ../../src/data/item_definition.gd
  - ../../src/infrastructure/game_log.gd
  - ../../src/infrastructure/input_actions.gd
  - ../../src/gameplay/interaction/interactable.gd
  - ../../src/gameplay/interaction/interaction_controller.gd
  - ../../src/gameplay/interaction/interaction_detector.gd
  - ../../src/gameplay/hazards/hazard_detector.gd
  - ../../src/gameplay/hazards/stabilizable_hazard.gd
  - ../../src/gameplay/hazards/unstable_debris_hazard.tscn
  - ../../src/gameplay/inventory/player_inventory.gd
  - ../../src/gameplay/player/player_controller.gd
  - ../../src/gameplay/player/player.tscn
  - ../../src/gameplay/recovery/entrance_exit.tscn
  - ../../src/gameplay/recovery/exploration_outcome.gd
  - ../../src/gameplay/recovery/exploration_run.gd
  - ../../src/gameplay/recovery/recovery_result.gd
  - ../../src/harness/harness_controller.gd
  - ../../src/ui/debug_state_panel.tscn
  - ../../src/ui/exploration_outcome_panel.tscn
  - ../../src/ui/harness_status.tscn
  - ../../src/ui/inventory_panel.tscn
  - ../../src/ui/interaction_prompt.tscn
  - ../../src/ui/item_value_text.gd
  - ../../src/ui/recovery_result_panel.tscn
  - ../../tests/fixtures/inventory_test_space.tscn
  - ../../tests/fixtures/interaction_test_space.tscn
  - ../../tests/fixtures/core_loop_playtest_space.tscn
  - ../../tests/fixtures/exploration_end_test_space.tscn
  - ../../tests/fixtures/hazard_harness_test_space.tscn
  - ../../tests/fixtures/movement_test_space.tscn
  - ../../tests/fixtures/recovery_result_test_space.tscn
  - ../../tests/smoke/game_state_flow_smoke.tscn
  - ../../tests/smoke/core_loop_playtest_smoke.tscn
  - ../../tests/smoke/exploration_end_smoke.tscn
  - ../../tests/smoke/hazard_harness_smoke.tscn
  - ../../tests/smoke/inventory_system_smoke.tscn
  - ../../tests/smoke/interaction_system_smoke.tscn
  - ../../tests/smoke/player_movement_smoke.tscn
  - ../../tests/smoke/recovery_result_smoke.tscn
  - ../README.md
  - ../GDD.md
  - module_boundaries.md
  - development_handoff.md
  - decisions.md
  - open_questions.md
---

# 프로젝트 컨텍스트

## 목적

새 작업자가 같은 엔진과 명령으로 저장소를 열고 최소 검증을 수행할 수 있도록 `DEV-0001`에서 확정한 개발 환경을 한곳에 기록한다. 게임 규칙은 GDD와 관련 Story·Design·Reference 문서가 소유하며, 이 문서는 개발 도구와 실행 방법만 소유한다.

## 확정 개발 기준

| 항목 | 기준 |
|---|---|
| 게임 엔진 | Godot 4.7.1 stable Standard |
| 개발 언어 | GDScript |
| 렌더러 | Compatibility |
| 우선 플랫폼 | Windows PC x86-64 |
| 게임 형태 | 2D 탑다운 싱글플레이 |
| 버전 관리 | Git |
| 엔진 라이선스 | MIT. 배포 문서 또는 크레딧에 Godot 저작권·라이선스 고지를 포함 |

Standard 빌드는 GDScript 기준이며 .NET 빌드는 사용하지 않는다. 버전 차이로 생기는 장면·리소스 변환을 막기 위해 개발과 검증은 정확히 4.7.1에서 수행한다. 엔진 업그레이드는 별도 검토와 승인 없이 진행하지 않는다.

Python은 문서 검사, 데이터 변환과 같은 저장소 보조 도구에만 사용할 수 있다. React, Node.js, HTML5 Canvas, Docker와 PostgreSQL은 현재 게임 실행 스택에 포함하지 않는다. 웹사이트, 온라인 서비스 또는 자동 빌드 서버가 실제 범위에 들어올 때만 다시 검토한다.

## Godot 준비

1. [Godot 4.7.1 공식 다운로드](https://godotengine.org/download/archive/4.7.1-stable/)에서 Windows Standard x86-64 압축 파일을 받는다.
2. 원하는 로컬 도구 폴더에 압축을 푼다. 엔진 실행 파일은 저장소에 복사하거나 커밋하지 않는다.
3. 저장소 루트에서 현재 PowerShell 세션에 console 실행 파일 경로를 지정한다.

```powershell
$env:GODOT_BIN = "C:\Tools\Godot\Godot_v4.7.1-stable_win64_console.exe"
```

설치 위치가 다르면 오른쪽 경로만 실제 위치로 바꾼다. 이 환경 변수는 개인 컴퓨터의 실행 위치이므로 저장소에 기록하지 않는다.

## 실행과 검증 명령

모든 명령은 `project.godot`이 있는 저장소 루트에서 실행한다.

### 버전 확인

```powershell
& $env:GODOT_BIN --version
```

출력의 시작이 `4.7.1.stable`과 다르면 프로젝트를 열거나 리소스를 저장하지 않는다.

### 편집기 열기

```powershell
& $env:GODOT_BIN --editor --path .
```

이 명령으로 프로젝트가 오류 없이 편집기에 열리는지 확인한다. 폴더·모듈 경계는 [`module_boundaries.md`](module_boundaries.md)를 따른다.

### 프로젝트 실행

```powershell
& $env:GODOT_BIN --path .
```

현재 메인 장면은 실제 게임 플레이가 아니라 `DEV-0003` 상태 전환을 확인하는 개발 화면이다. 버튼을 누르면 `Boot → Title → Hub → Exploration → Results → Hub` 순서로 현재 상태가 바뀐다.

### 프로젝트 초기화 검사

```powershell
& $env:GODOT_BIN --headless --editor --path . --quit
```

종료 코드가 `0`이면 현재 프로젝트 설정을 Godot 4.7.1이 읽고 초기화할 수 있다는 뜻이다.

### 메인 장면 Headless 스모크

```powershell
& $env:GODOT_BIN --headless --path . --quit-after 2
```

종료 코드가 `0`이고 오류 로그가 없으면 메인 장면, `GameState` Autoload와 개발 UI를 초기화할 수 있다는 뜻이다.

### 상태 전환 자동 스모크 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/game_state_flow_smoke.tscn
```

이 한 명령은 `Boot → Title → Hub → Exploration → Results → Hub`를 순서대로 검증한다. 모든 전환과 최종 상태가 맞으면 `state_flow_passed` 로그를 남기고 종료 코드 `0`을 반환하며, 실패하면 오류 로그와 0이 아닌 종료 코드를 반환한다.

### 개발 상태 직접 진입

```powershell
& $env:GODOT_BIN --path . -- --dev-state=Exploration
```

현재 사용할 수 있는 값은 `Boot`, `Title`, `Hub`, `Exploration`, `Results`다. 이 인수는 디버그 빌드에서만 동작한다. 메인 개발 장면은 요청한 상태까지 `GameState`의 허용 전환을 순서대로 요청하며 중앙 상태 관리자를 우회하지 않는다.

### 이동·카메라 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/movement_test_space.tscn
```

`WASD`로 이동하고 `Esc`로 테스트 공간의 일시정지를 전환한다. 플레이어를 따라가는 카메라와 일시정지 중 이동 정지를 직접 확인한다. 이 장면은 개발 검사 전용이며 실제 던전이나 제품 전체의 일시정지 흐름이 아니다.

### 이동·카메라 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/player_movement_smoke.tscn
```

실제 플레이어 장면의 수평 이동, 대각선 속도 정규화, 자식 카메라 추적과 `SceneTree` 일시정지 중 정지를 검사한다. 모두 맞으면 `player_movement_passed` 로그와 종료 코드 `0`을 반환한다.

### 상호작용 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/interaction_test_space.tscn
```

플레이어를 회수품과 문 가까이 이동해 안내가 나타나는지 확인하고 `E`로 상호작용한다. 회수품은 제거되고 문은 열림·닫힘에 따라 통행과 안내가 바뀐다. 시험용 대상이므로 실제 아이템 적재나 문 잠금 규칙은 포함하지 않는다.

### 상호작용 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/interaction_system_smoke.tscn
```

실제 플레이어의 감지기·실행기와 안내 UI를 사용해 회수품과 문이 공통 인터페이스를 따르는지, 가까운 대상 감지와 안내, 회수품 제거, 문 상태·충돌·안내 갱신이 일치하는지 검사한다. 모두 맞으면 `interaction_system_passed` 로그와 종료 코드 `0`을 반환한다.

### 아이템·인벤토리 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/inventory_test_space.tscn
```

플레이어를 시험용 회수품 가까이 이동해 `E`로 획득하고 `Tab`으로 인벤토리 화면을 연다. 슬롯 한도, 무게 합계와 정상·부담·과적 표시가 실제 적재 상태와 일치하는지, 일반 버리기의 확인 창과 화면을 연 동안 일시정지를 직접 확인한다. 한도와 무게 단계는 검사 전용 값이며 제품 밸런스가 아니다.

### 아이템·인벤토리 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/inventory_system_smoke.tscn
```

실제 플레이어, 회수품과 인벤토리 화면을 사용해 획득, 슬롯 한도 초과 거절, 무게 합계·단계와 화면 표시, 버린 뒤 갱신, 화면을 열고 닫을 때의 일시정지를 검사한다. 모두 맞으면 `inventory_system_passed` 로그와 종료 코드 `0`을 반환한다.

### 회수 결과 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/recovery_result_test_space.tscn
```

일반 회수품의 개별 예상 가치 범위와 합계, 고유 유물의 등록·정보 보상 분리 표시를 직접 확인한다. 이 장면의 물품과 가치 범위는 검사 전용 자료이며 실제 콘텐츠나 제품 밸런스가 아니다.

### 회수 결과 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/recovery_result_smoke.tscn
```

현재 인벤토리 물품으로 회수 결과를 만들고, 버린 물품과 슬롯 한도로 거절된 물품이 제외되는지, 일반 회수품의 가치 합계와 비화폐 보상 구분이 화면 표시와 일치하는지 검사한다. 모두 맞으면 `recovery_result_passed` 로그와 종료 코드 `0`을 반환한다.

### 위험·하네스 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/hazard_harness_test_space.tscn
```

플레이어를 불안정한 잔해로 이동해 붕괴 전에 먼지·진동 징후가 표시되는지 확인하고, 안내가 보일 때 `Q`로 하네스 안정화를 실행한다. 장면의 충전량, 안정화 비용과 경고 시간은 검사 전용 시제품 값이며 제품 밸런스가 아니다.

### 위험·하네스 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/hazard_harness_smoke.tscn
```

사전 징후와 하네스 안내가 붕괴보다 먼저 표시되는지, 경고 중 안정화하면 시험 충전이 줄고 붕괴가 멈추는지, 대응하지 않고 범위 안에 남으면 붕괴와 포착 이벤트가 발생하는지 검사한다. 모두 맞으면 `hazard_harness_passed` 로그와 종료 코드 `0`을 반환한다.

### 탐험 종료 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/exploration_end_test_space.tscn
```

왼쪽 입구로 이동해 `E`로 생환하거나 오른쪽 불안정한 잔해 범위에 남아 실패한다. 생환은 시험용 회수품을 정산 대상으로 표시하고, 실패는 같은 물품을 잃어 회수 결과가 생기지 않는지 직접 확인한다. 이 장면은 종료 흐름 검사 전용이며 실제 던전 구성이나 제품 밸런스가 아니다.

### 탐험 종료 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/exploration_end_smoke.tscn
```

실제 플레이어의 감지기와 상호작용 실행기를 사용해 입구 생환, 현재 물품의 회수 결과 인계, 위험 징후 뒤 포착과 실패, 현재 탐험 물품 손실, 실패 결과의 회수 목록 부재와 종료 상태 덮어쓰기 방지를 검사한다. 모두 맞으면 `exploration_end_passed` 로그와 종료 코드 `0`을 반환한다.

### 첫 핵심 루프 수동 플레이테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/core_loop_playtest_space.tscn
```

입구에서 안전 경로와 위험 보상 경로를 선택한다. 안전 경로의 저가 회수품 두 개로 시험 슬롯을 채운 뒤 그대로 귀환하거나, 위험 경로의 붕괴 징후를 `Q`로 안정화하고 `Tab` 인벤토리에서 기존 물품 하나를 버려 고가 잔재로 교체한 뒤 같은 입구로 돌아온다. 위험에 대응하지 않으면 현재 회수품을 잃고 실패한다. 슬롯·무게·가치·충전·경고 시간은 선택 재현을 위한 테스트 전용 값이다.

### 첫 핵심 루프 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/core_loop_playtest_smoke.tscn
```

실제 플레이테스트 장면으로 안전 경로 회수와 생환, 위험 경로의 사전 징후·하네스 충전 사용·안정화, 슬롯 한도 거절 뒤 저가품 버리기와 고가품 교체, 입구 생환 결과, 미대응 위험의 실패와 회수품 손실을 검사한다. 모두 맞으면 `core_loop_playtest_passed` 로그와 종료 코드 `0`을 반환한다.

## 저장소 규칙

- `project.godot`은 버전 관리한다.
- Godot이 생성하는 `.godot/` 캐시는 버전 관리하지 않는다.
- 개인 내보내기 자격 증명인 `export_credentials.cfg`는 버전 관리하지 않는다.
- 엔진 실행 파일, 편집기 설정과 로컬 캐시는 저장소에 넣지 않는다.
- 현재 기본 해상도, 실제 게임 플레이 장면, 저장 형식과 테스트 플러그인은 아직 확정하지 않는다.
- 입력 행동과 키보드·마우스 기본 연결은 `DEV-0004`에서 추가했다. 컨트롤러의 첫 출시 포함 여부는 `Q-006` 결정 전까지 확정하지 않는다.
- 안정적 ID와 표시 이름을 분리한 공통 콘텐츠·아이템 정의는 `DEV-0005`에서 추가했다. 실제 콘텐츠와 밸런스 값은 아직 추가하지 않는다.
- 상태 전환 스모크 장면, 공통 로그 형식과 개발 상태 진입 인수는 `DEV-0006`에서 추가했다. 테스트 장면은 출시 코드가 참조하지 않는다.
- 기능·장면·폴더를 추가하기 전에 해당 개발 티켓의 범위와 [`module_boundaries.md`](module_boundaries.md)를 확인한다.

## DEV-0001 검증 결과

- Godot 버전: `4.7.1.stable.official.a13da4feb`
- `project.godot` Compatibility 설정 로드: 통과
- Headless 편집기 초기화와 종료 코드 `0`: 통과

## DEV-0002 구조 결과

- `DEV-0002` 폴더·모듈 경계: [`module_boundaries.md`](module_boundaries.md)
- 장면·스크립트·리소스와 테스트 코드: 추가하지 않음

## DEV-0003 상태 관리자 결과

- 중앙 상태 관리자: `res://src/app/game_state.gd`의 `GameState` Autoload
- 최소 메인 장면: `res://src/app/main.tscn`
- 개발용 상태 UI: `res://src/ui/debug_state_panel.tscn`
- 활성 상태: `Boot`, `Title`, `Hub`, `Exploration`, `Results`
- 안전 장치: 전환 중 중복 요청, 현재 상태 재요청, 허용되지 않은 전환과 알 수 없는 상태 거절
- Headless 메인 장면 실행과 상태 전환 검사: 통과

## DEV-0004 입력 추상화 결과

- 행동 이름: `move_left`, `move_right`, `move_up`, `move_down`, `aim_look`, `interact`, `use_harness`, `use_tool`, `inventory`, `map`, `quick_drop`, `pause`
- 키보드 기본 연결: 이동 `WASD`, 상호작용 `E`, 하네스 `Q`, 도구 `F`, 인벤토리 `Tab`, 지도 `M`, 빠른 버리기 `G`, 일시정지 `Esc`
- 조준·대상 방향: `aim_look` 행동 ID와 포인터 위치 조회 API를 제공하며 별도 키는 연결하지 않음
- 입력 API: `res://src/infrastructure/input_actions.gd`의 `InputActions`
- 검증: Godot 4.7.1에서 행동 12개, 기본 키 연결 11개, Headless 프로젝트 초기화와 메인 장면 실행 통과

## DEV-0005 데이터 ID와 기본 정의 결과

- 공용 ID 검증: `res://src/core/stable_id.gd`의 `StableId`
- 공통 콘텐츠 정의: `res://src/data/content_definition.gd`의 `ContentDefinition`
- 아이템 기본 정의: `res://src/data/item_definition.gd`의 `ItemDefinition`
- 분리 원칙: `stable_id`와 `display_name`은 서로를 자동 변경하지 않는 독립 필드
- 아이템 필드: 분류, 무게, 슬롯 크기, 가치 최솟값·최댓값, 판매 보호
- 검증: Godot 4.7.1에서 클래스 등록, 유효성 검사, 표시 이름 변경 후 ID 유지와 Headless 메인 장면 실행 통과

## DEV-0006 테스트·로그·디버그 진입점 결과

- 로그 API: `res://src/infrastructure/game_log.gd`의 `GameLog`
- 상태 전환 로그: 시작·완료·거절 이벤트와 현재·요청 상태 및 거절 사유
- 개발 진입점: 메인 장면의 `--dev-state=<상태>` 사용자 인수
- 스모크 장면: `res://tests/smoke/game_state_flow_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 메인 장면, 상태 전환 스모크 명령과 `Exploration` 직접 진입 통과
- 저장 데이터 영향: 없음
- 다음 절차: 2026-08-01 G0 정합성 검사 통과 후 `DEV-0101 — 플레이어 이동과 카메라`

## DEV-0101 플레이어 이동과 카메라 결과

- 플레이어 장면: `res://src/gameplay/player/player.tscn`
- 이동 제어기: `res://src/gameplay/player/player_controller.gd`
- 입력 의존: 실제 키 코드 없이 `InputActions.get_move_vector()`만 사용
- 이동 방식: `CharacterBody2D`의 속도와 `move_and_slide()`를 물리 프레임마다 갱신
- 시제품 속도: 장면에서 조정 가능한 `240 px/s`; 확정 밸런스 값이 아님
- 카메라: 플레이어 장면의 활성 자식 `Camera2D`
- 수동 테스트 공간: `res://tests/fixtures/movement_test_space.tscn`
- 자동 검사: `res://tests/smoke/player_movement_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 이동·카메라 자동 검사, 기존 상태 전환 자동 검사와 테스트 공간 초기화 통과
- 일시정지 범위: 테스트 공간이 `SceneTree.paused`를 전환하고 플레이어는 정지함. 제품 전체 일시정지 흐름은 추가하지 않음
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0102 — 상호작용 시스템`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0102 상호작용 시스템 결과

- 공통 대상 인터페이스: `res://src/gameplay/interaction/interactable.gd`
- 대상 감지: `res://src/gameplay/interaction/interaction_detector.gd`
- 입력 실행: `res://src/gameplay/interaction/interaction_controller.gd`
- 안내 UI: `res://src/ui/interaction_prompt.tscn`
- 플레이어 연결: 실제 키 코드 없이 `InputActions.INTERACT`를 사용하는 감지기와 실행기를 플레이어 장면에 조립
- 공통 구현 예: 시험용 회수품과 문이 모두 `Interactable`을 상속
- 수동 테스트 공간: `res://tests/fixtures/interaction_test_space.tscn`
- 자동 검사: `res://tests/smoke/interaction_system_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 상호작용 자동 검사, 기존 이동·카메라 및 상태 전환 자동 검사와 테스트 공간 초기화 통과
- 제외 범위: 인벤토리 적재, 실제 아이템 콘텐츠, 문 잠금·하네스 우회, 저장 상태
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0103 — 최소 아이템·인벤토리`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0103 최소 아이템·인벤토리 결과

- 실행 중 인벤토리: `res://src/gameplay/inventory/player_inventory.gd`
- 인벤토리 UI: `res://src/ui/inventory_panel.tscn`
- 플레이어 연결: 플레이어 장면의 `Inventory` 자식과 회수품의 공개 획득 요청
- 상태와 명령: 아이템 목록, 사용·전체 슬롯, 전체 무게, 정상·부담·과적 단계, 선택과 일반 버리기
- 한도 처리: 슬롯 한도 초과 시 획득을 거절하고 회수품을 남기며, 무게가 과적 단계여도 획득과 이동 가능 상태는 유지
- 화면 동작: `Tab`으로 열고 닫으며 열린 동안 `SceneTree`를 일시정지하고, 일반 버리기는 확인 창을 거침
- 제품 값 분리: 플레이어 장면에는 슬롯·무게 기준을 확정하지 않고, 시험용 한도와 무게 단계는 테스트 자료에만 둠
- 수동 테스트 공간: `res://tests/fixtures/inventory_test_space.tscn`
- 자동 검사: `res://tests/smoke/inventory_system_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 아이템·인벤토리 자동 검사, 기존 상호작용·이동·카메라·상태 전환 자동 검사와 두 상호작용 테스트 공간 초기화 통과
- 제외 범위: 실제 아이템 콘텐츠, `Q-005`의 과적 이동 감속, 빠른 버리기 유지 시간, 저장 상태
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0104 — 가치와 회수 결과`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0104 가치와 회수 결과

- 회수 결과: `res://src/gameplay/recovery/recovery_result.gd`
- 가치 표시: `res://src/ui/item_value_text.gd`
- 결과 UI: `res://src/ui/recovery_result_panel.tscn`
- 포함 기준: 결과를 만드는 시점의 현재 인벤토리 물품만 고정하며 버린 물품과 획득 거절 물품은 제외
- 가치 처리: 일반 회수품의 최솟값·최댓값을 각각 합산하고 고유 유물·핵심 기록물은 화폐 합계 대신 등록·정보 보상으로 구분
- 수동 테스트 공간: `res://tests/fixtures/recovery_result_test_space.tscn`
- 자동 검사: `res://tests/smoke/recovery_result_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 회수 결과와 기존 아이템·인벤토리·상호작용·이동·카메라·상태 전환 자동 검사, 회수 결과와 기존 테스트 공간 초기화 통과
- 제외 범위: 실제 판매액, 감정·거래처 보정, 회수세·감정료·수리비, 순이익, 저장, 귀환·실패 판정
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0105 — 최소 위험 요소`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0105 최소 위험 요소

- 공통 안정화 대상: `res://src/gameplay/hazards/stabilizable_hazard.gd`
- 위험 감지: `res://src/gameplay/hazards/hazard_detector.gd`
- 시험 위험: `res://src/gameplay/hazards/unstable_debris_hazard.tscn`
- 하네스 사용: `res://src/harness/harness_controller.gd`
- 상태 UI: `res://src/ui/harness_status.tscn`
- 위험 흐름: 플레이어 진입 → 먼지·진동 징후와 경고 시간 → `Q` 안정화 또는 붕괴·범위 안 포착
- 수동 테스트 공간: `res://tests/fixtures/hazard_harness_test_space.tscn`
- 자동 검사: `res://tests/smoke/hazard_harness_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 위험·하네스와 기존 회수 결과·인벤토리·상호작용·이동·카메라·상태 전환 자동 검사, 새 장면과 기존 테스트 공간 초기화 통과
- 시제품 값: 시험 충전량, 안정화 비용과 경고 시간은 조정 가능하며 제품 밸런스로 확정하지 않음
- 제외 범위: 피해·건강·부상, 행동 불능·실패 연결, 최종 하네스 모듈 구성·충전 밸런스·내구도
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0106 — 출구·귀환·실패`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0106 출구·귀환·실패 결과

- 탐험 종료 상태: `res://src/gameplay/recovery/exploration_run.gd`
- 종료 결과: `res://src/gameplay/recovery/exploration_outcome.gd`
- 입구 생환 상호작용: `res://src/gameplay/recovery/entrance_exit.tscn`
- 결과 UI: `res://src/ui/exploration_outcome_panel.tscn`
- 생환 처리: 입구 상호작용으로 현재 인벤토리를 비우고 그 물품을 기존 `RecoveryResult`에 고정
- 실패 처리: 공개 실패 명령으로 현재 인벤토리를 비우고 손실 개수만 남기며 회수 결과는 만들지 않음
- 종료 잠금: 활성 탐험의 첫 생환 또는 실패만 확정하고 이후 반대 결과 요청을 거절
- 수동 테스트 공간: `res://tests/fixtures/exploration_end_test_space.tscn`
- 자동 검사: `res://tests/smoke/exploration_end_smoke.tscn`
- 검증: Godot 4.7.1에서 프로젝트 초기화, 탐험 종료와 기존 위험·하네스·회수 결과·인벤토리·상호작용·이동·카메라·상태 전환 자동 검사 통과
- 제외 범위: 실제 피해·건강·부상, 퇴로 상실 시간과 비상 탈출, 영구 장비 손상·수리비, 저장과 거점 정산·반영, 완성 던전 구성
- 저장 데이터 영향: 없음
- 다음 개발 작업: `DEV-0107 — 첫 핵심 루프 플레이테스트 장면`
- 다음 정합성 검사: `DEV-0107` 완료 뒤

## DEV-0107 첫 핵심 루프 플레이테스트 결과

- 플레이테스트 장면: `res://tests/fixtures/core_loop_playtest_space.tscn`
- 자동 검사: `res://tests/smoke/core_loop_playtest_smoke.tscn`
- 공간 구성: 같은 입구에서 갈라지는 안전 경로와 위험 보상 경로, 위험을 통과해야 닿는 고가 잔재
- 적재 선택: 시험 슬롯 두 개가 찬 뒤 저가품 하나를 버려 고가품으로 교체하거나 안전 회수품만 들고 귀환
- 위험 선택: 시험 하네스 충전 하나를 써서 붕괴를 안정화하거나 돌아가며, 미대응 시 실패
- 종료: 안전 경로와 위험 대응 경로는 같은 입구 생환, 위험 미대응은 현재 회수품 손실과 실패
- 검증: Godot 4.7.1에서 프로젝트·메인·플레이테스트 장면 초기화, 핵심 루프와 기존 상태 전환·이동·상호작용·인벤토리·회수 결과·위험·하네스·탐험 종료 자동 검사 통과
- 시제품 값: 슬롯 2개, 부담 2.5, 과적 4.0, 시험 아이템 무게·가치, 하네스 충전 1과 경고 시간은 테스트 전용이며 제품 값이 아님
- 저장 데이터 영향: 없음
- G1 검사 잔여: 사람 플레이테스트, `Q-004`·`Q-005`, GDD 15-2의 단계 1 티켓 밖 항목 처리 방향
- 다음 작업: 사용자 정합성 검사 검토 뒤 `DEV-0201` 또는 보완 작업
- 정합성 검사: 지금
