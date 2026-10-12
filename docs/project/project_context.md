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
last_reviewed: 2026-10-12
owner: project-maintainer
related:
  - ../../AGENTS.md
  - ../../project.godot
  - ../../src/app/dev_entry.gd
  - ../../src/app/game_state.gd
  - ../../src/app/main.tscn
  - ../../src/app/game_entry.gd
  - ../../src/app/dev_main.tscn
  - ../../src/ui/title_screen.tscn
  - ../../src/ui/hub_panel.tscn
  - ../../src/ui/expedition_results_screen.tscn
  - ../../src/ui/expedition_results_screen.gd
  - ../../src/meta/hub_state.gd
  - ../../src/meta/settlement_result.gd
  - ../../src/data/economy_rule.gd
  - ../../src/data/prototype_economy.tres
  - ../../tests/smoke/settlement_smoke.tscn
  - ../../src/core/expedition_loadout.gd
  - ../../src/app/prototype_exploration.tscn
  - ../../tests/smoke/hub_departure_smoke.tscn
  - ../../tests/smoke/title_screen_smoke.tscn
  - ../../src/core/stable_id.gd
  - ../../src/data/content_definition.gd
  - ../../src/data/item_definition.gd
  - ../../src/infrastructure/game_log.gd
  - ../../src/infrastructure/input_actions.gd
  - ../../src/gameplay/interaction/interactable.gd
  - ../../src/gameplay/interaction/interaction_controller.gd
  - ../../src/gameplay/interaction/interaction_detector.gd
  - ../../src/gameplay/interaction/inspectable_pickup_interactable.tscn
  - ../../src/gameplay/hazards/broken_guard_golem.tscn
  - ../../src/gameplay/hazards/hazard_detector.gd
  - ../../src/gameplay/hazards/stabilizable_hazard.gd
  - ../../src/gameplay/hazards/unstable_debris_hazard.tscn
  - ../../src/gameplay/inventory/player_inventory.gd
  - ../../src/gameplay/inventory/inventory_item.gd
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
  - ../../tests/fixtures/inspection_unidentified_test_space.tscn
  - ../../tests/fixtures/broken_guard_golem_test_space.tscn
  - ../../tests/fixtures/interaction_test_space.tscn
  - ../../tests/fixtures/core_loop_playtest_space.tscn
  - ../../tests/fixtures/exploration_end_test_space.tscn
  - ../../tests/fixtures/hazard_harness_test_space.tscn
  - ../../tests/fixtures/harness_actions_test_space.tscn
  - ../../tests/fixtures/g1_integration_playtest_space.tscn
  - ../../tests/fixtures/movement_test_space.tscn
  - ../../tests/fixtures/recovery_result_test_space.tscn
  - ../../tests/smoke/game_state_flow_smoke.tscn
  - ../../tests/smoke/broken_guard_golem_smoke.tscn
  - ../../tests/smoke/core_loop_playtest_smoke.tscn
  - ../../tests/smoke/exploration_end_smoke.tscn
  - ../../tests/smoke/hazard_harness_smoke.tscn
  - ../../tests/smoke/harness_actions_smoke.tscn
  - ../../tests/smoke/g1_integration_playtest_smoke.tscn
  - ../../tests/smoke/inventory_system_smoke.tscn
  - ../../tests/smoke/inspection_unidentified_smoke.tscn
  - ../../tests/smoke/interaction_system_smoke.tscn
  - ../../tests/smoke/player_movement_smoke.tscn
  - ../../tests/smoke/recovery_result_smoke.tscn
  - ../README.md
  - ../GDD.md
  - module_boundaries.md
  - development_handoff.md
  - decisions.md
  - open_questions.md
  - g1_playtest_review.md
  - g2_flow_review.md
  - ../../tests/run_g2_checks.ps1
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

### G2 전체 흐름 검사

PowerShell 7 이상에서 다음 한 명령으로 기존 기능·추가 분기와 설정 저장→탐험·정산→재실행·이어하기→설정 유지 확인을 두 번 실행한다.

```powershell
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN
```

종료 코드 0과 `PASS G2`를 확인한다. 새 임시 폴더에 실행 로그와 `results.json`을 남긴다. 설정·진행 조작은 임시 파일에서 수행하며 기본 실행 검사는 기존 사용자 파일을 읽을 수 있으나 저장 동작 없이 종료한다. 기본값은 두 번 반복·프로세스당 30초 제한이고 엔진 오류·경고·통과 표시 누락·비정상 종료·시간 초과를 실패로 처리한다. 선택 인수와 체크리스트·78/78 결과·실패 판정 검증은 [G2 검사 기록](g2_flow_review.md)에 있다. 아래 개별 명령은 문제를 좁혀 확인할 때 사용한다.

### 탐험 지도 확인

기본 실행에서 새 게임 또는 이어하기 → 거점 출정 후 M으로 지도를 연다. 기본 경로와 출구는 처음부터 표시되고, 실제로 이동한 곳에는 이번 탐험의 방문 표시와 현재 위치가 붙는다. M·Esc·닫기로 닫고 Tab으로 가방에 전환할 수 있다. 두 화면은 동시에 열리지 않으며 열린 동안 플레이어와 위험의 시간이 멈춘다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 8000 res://tests/smoke/exploration_map_smoke.tscn
```

`exploration_map_passed`와 종료 코드 0·엔진 오류/경고 없음을 확인한다. 정의 복사본 분리·중복 ID 거절, 출정 전 입력 차단, 실제 이동에 따른 방문, M·Esc·마우스 닫기, 가방 전환·버리기 미확정 취소, 플레이어/골렘 정지, 기존 일시정지 보존, 탐험 종료·열린 장면 제거·새 출정의 관찰 초기화를 검사한다. 버리기 확인 창에서 지도 열기는 공개 메서드 호출로 검사하며, 그 밖의 화면 전환은 실제 키·마우스 입력을 사용한다.

화면 확인은 위 명령에서 `--headless`를 빼고 `-- --map-render-directory=<임시 출력 폴더>`를 추가한다. `map-entry.png`와 `map-visited.png`에 1152×648 출정 직후/네 구역 방문 후 화면을 저장한다. 설정·진행 파일을 쓰지 않는 독립 탐험 장면이다.

2026-09-12 `DEV-0301`에서 개별 지도 검사와 실제 그래픽 검사, 기존 전체 검사 명령의 `-Repetitions 1`을 통과했다. 새 지도 장면을 포함해 스모크 장면 18개·전체 실행 41개가 통과했으며 엔진 오류·경고가 없었다. G2 관문의 기존 78/78 기록은 그대로 유지한다. 지도 관찰은 현재 탐험에만 있으며 방문 간 저장·실패 시 정보 보존의 제품 규칙은 후속 범위다.

### 통로 관찰과 지도 표시 확인

`DEV-0302`는 기존 지도에 세 짧은 연결 구간을 표시한다. 가까운 통로 끝점까지 벽이 시야를 가리지 않으면 실제 장애물과 이동 여유 폭을 확인해 열림·막힘을 기록한다. 지도는 마지막 관찰만 표시하며, 열림은 해당 구간의 물리 통행 표시이지 위험 부재를 뜻하지 않는다.

기본 실행에서 출정한 뒤 위쪽 연결에 접근하면 열림이 기록된다. 위쪽 경로에서 가운데 벽 쪽으로 접근하면 가운데 연결이 막힘으로 바뀌고, 먼 쪽 우회로에 접근하면 그 연결의 열림을 확인할 수 있다. M으로 지도에서 미확인 점선·열림 실선/원·막힘 X와 문자, 확인한 통로 수를 비교한다. 지도·가방의 일시정지와 방문 표시는 기존 방식이다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 8000 res://tests/smoke/map_passage_smoke.tscn
```

`map_passage_passed`와 종료 코드 0·엔진 오류/경고 없음을 확인한다. 이 검사는 실제 이동과 벽 충돌, 먼 상태 비공개·시야 가림·재관찰, 폭 없는 선은 통과하지만 플레이어 몸은 못 지나는 조건, 정지·종료·새 출정, 정의 복사본과 ID 검증을 포함한다. 동적 장애물은 검사 중에만 만들고 제거한다. 설정·진행 파일은 쓰지 않는다.

화면 확인은 `--headless`를 빼고 `-- --passage-render-directory=<임시 출력 폴더>`를 추가한다. `passages-unknown.png`·`passages-observed.png`에 1152×648 미확인/열림·막힘 확인 후 화면을 남긴다. 2026-09-12 이 두 화면과 새 통로 검사를 포함한 스모크 장면 19개, 전체 검사 `-Repetitions 1`의 42개 실행을 통과했다. 방문 간 지도 저장·실패 시 정보 보존은 아직 결정하지 않는다.

### 지도 개인 표식 확인

`DEV-0303`은 이번 탐험 동안 사용할 개인 메모를 추가한다. 기본 실행에서 출정하고 M으로 지도를 연 뒤 **표식 편집**을 켠다. 지도 안 빈 곳을 왼쪽 클릭하면 번호가 붙은 마름모를 놓고, 같은 표식 근처를 클릭하면 삭제한다. 편집을 끄면 지도를 클릭해도 메모가 바뀌지 않는다.

표식은 미방문 위치에도 놓을 수 있지만 방문·통로 확인·잔여 구역 발견을 뜻하지 않는다. 지도를 닫았다 열거나 가방과 전환해도 유지하며, 새 출정은 빈 표식으로 시작한다. 화면을 닫으면 편집 모드가 해제된다. 편집 중 탐험 시간은 멈춘다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 1000 res://tests/smoke/map_marker_smoke.tscn
```

`map_marker_passed`와 종료 코드 0·엔진 오류/경고 없음을 확인한다. 이 검사는 실제 입력·잘못된 좌표·경계·복사본 보호·관찰 상태 분리·재열기·가방 전환·화면 크기 변경·일시정지·종료/새 출정을 포함한다. 설정·진행 파일은 쓰지 않는다.

화면 확인은 `--headless`를 빼고 `-- --marker-render-directory=<임시 출력 폴더>`를 추가한다. `markers-editing.png`와 `markers-viewing.png`는 1152×648 편집/조회 화면, `markers-resized.png`는 1600×900 화면이다. 2026-09-12 세 화면과 스모크 장면 20개, 전체 검사 `-Repetitions 1`의 43개 실행을 통과했다. 방문 간 지도 저장·실패 시 정보 보존은 아직 결정하지 않는다.

### 잔여 구역 단서 조사·재열람 확인

`DEV-0304`는 기존 입구 구역의 손상된 공략도를 살펴보는 시제품 조사 대상을 추가한다. 기본 실행에서 출정한 뒤 입구 오른쪽 아래의 공략도에 접근해 E로 살펴본다. 짧은 부분 단서가 표시되고, M으로 지도를 연 뒤 **단서 보기**에서 이번 탐험의 관찰 내용을 다시 읽을 수 있다. **지도 보기**로 돌아가거나 M·Esc·닫기로 닫는다.

접근과 지도 열기만으로 미조사 설명은 공개하지 않는다. 재조사는 같은 기록을 다시 보여 주며 회수품을 만들지 않는다. 단서에는 정확한 목적지나 통행 보장을 넣지 않고, 방문·통로·개인 표식은 별도 유지한다. 새 출정은 빈 기록으로 시작하며 영구 저장과 실패 시 정보 보존은 미정이다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 1000 res://tests/smoke/map_clue_smoke.tscn
```

`map_clue_passed`와 종료 코드 0·엔진 오류/경고 없음을 확인한다. 실제 이동·조사·재조사·조사 전 비공개·기록 복사본·지도 재열람·표식 편집 차단·가방 전환·시간 정지·귀환/실패·새 출정을 검사한다. 설정·진행 파일은 쓰지 않는 독립 장면이다.

화면 확인은 `--headless`를 빼고 `-- --clue-render-directory=<임시 출력 폴더>`를 추가한다. `clues-unread.png`·`clue-observed.png`·`clues-recorded.png`는 1152×648의 미조사/현장 안내/재열람 화면이고, `clues-resized.png`는 1600×900 재열람 화면이다. 2026-09-12 공략도 이름 겹침과 단서 읽기 화면을 보완한 네 화면, 스모크 장면 21개와 전체 검사 `-Repetitions 1`의 44개 실행이 통과했다.

### 잔여 구역 개방·발견 확인

`DEV-0305`는 위쪽 경로 바깥에 작은 선택 공간을 연결한다. 기본 실행에서 출정한 뒤 공략도의 방향 힌트를 살펴보거나 위쪽 경로의 북쪽 벽을 직접 탐색한다. 흔들리는 버팀대에 가까이 가면 무료 기본 분석과 **Q 입구 안정화 · 충전 1** 안내가 표시된다. 충전이 남아 있을 때 Q로 입구를 열고 안쪽으로 이동하면 잔여 구역 발견 안내가 나온다. M 지도에는 실제 진입 뒤에만 방 윤곽·현재 위치와 별도 발견 수가 생긴다.

닫힌 입구는 실제 충돌로 막히며 충전 부족·반복 입력·지도/가방 일시정지·출정 전/종료 후 행동은 개방이나 추가 비용을 만들지 않는다. 단서 조사나 입구 개방만으로는 지도에 위치를 알려주지 않는다. 발견한 방에도 지도 표식을 놓고 지울 수 있다. 같은 길로 나와 원래 입구에서 E로 귀환하며, 단서를 읽지 않거나 입구를 열지 않아도 기존 경로로 귀환할 수 있다. 이번 탐험의 발견 기록과 열림은 새 출정에서 초기화하는 시제품 범위이고 영구 발견·실패 시 정보 보존·보상 정책은 후속 범위다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/remaining_zone_smoke.tscn
```

`remaining_zone_passed`·종료 코드 0·엔진 오류/경고 없음을 확인한다. 실제 이동·Q 입력·단서 및 개방과 발견 분리·충전 부족·중복·일시정지·동일 경로 후퇴·기존 입구 귀환·실패 후 발견 차단·새 출정·복사본·지도 표식 좌표를 검사한다. 종료 후 위치 변경은 입력 차단 경계만 검사하며, 플레이 경로에서는 순간 이동을 사용하지 않는다. 독립 검사 장면은 설정·진행 파일을 쓰지 않는다.

화면 확인은 `--headless`를 빼고 `-- --zone-render-directory=<임시 출력 폴더>`를 추가한다. `zone-undiscovered-map.png`·`zone-closed.png`·`zone-entered.png`·`zone-discovered-map.png`는 1152×648 발견 전 지도·닫힌 입구·진입·발견 후 지도이고, `zone-discovered-resized.png`는 1600×900 지도다. 진입 화면은 플레이어 위치의 실제 색을 검사해 방 바닥이 캐릭터를 가리는 회귀도 잡는다.

2026-09-12 수정 후 화면 5장과 스모크 장면 22개, 전체 검사 `-Repetitions 1`의 45개 실행이 모두 통과했다. 엔진 오류·경고가 없었고 G1 비교 검사와 설정→탐험·정산→재실행·이어하기→설정 유지도 통과했다. 원본 결과는 `%TEMP%\dungeon-g2-20260912-070359-904f8dcd388f4a9989ef9cdb99ba4e75\results.json`, 검사 소스 SHA-256은 `6ef01ccd42cf4f49128d13791852671b643efe93730df92b46f7e8c0c961d754`다.

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

현재 메인 장면은 자동으로 `Boot → Title`에 진입한다. 새 게임을 누르면 거점에서 가방 2칸·3칸과 준비 조건을 확인한 뒤 시험 구역으로 출정할 수 있다. 선택한 조건은 실제 탐험의 가방·무게 단계·하네스 충전에 적용되며 생환·실패 뒤 결과 화면으로 이동한다. `정산하고 거점으로`를 누르면 판매액이 보유금에 반영되고 미판매 회수품은 거점에 보관된다. 실패는 `거점으로 돌아가기`로 기존 돈·보관품을 유지하며 복귀한다. 같은 실행에서 다시 출정할 수 있다. 타이틀 옵션에서 화면 모드·창 크기·전체 음량을 적용·저장할 수 있으며 종료는 게임 프로세스를 닫는다.

현재 정산은 별도 리소스의 시험 가격을 사용하는 임시 기능이다. 감정 전 물품·보호 물품·판매가 미설정 물품은 보관하고 실제 감정·등록·유료 서비스·마모 비용은 적용하지 않는다. 보관품을 탐험 가방으로 꺼내는 기능은 아직 없다. 새 게임의 거점 진입, 준비 변경과 정산 확인 때 돈·보관품·가방 선택을 자동 저장한다. 탐험 중 또는 정산 확인 전에 종료하면 마지막 저장된 거점에서 재개한다.

기본 실행은 진행 파일 전체가 유효할 때만 이어하기를 활성화하고, 복원을 마친 뒤 거점에 진입한다. 파일이 없거나 읽을 수 없는 경우에는 이어하기를 막는다. 기존 기록이 있으면 새 게임 전에 교체 확인 창을 띄우며 취소·Esc는 기록을 유지한다. `GameEntry.configure_continue()`의 동기식 `bool` 콜백은 실패·중첩 요청 검사에 사용할 수 있도록 유지한다. 기존 자동 검사도 `configure_progress()`로 별도 임시 경로를 주입하며 사용자 진행 파일을 읽거나 쓰지 않는다.

### 프로젝트 초기화 검사

```powershell
& $env:GODOT_BIN --headless --editor --path . --quit
```

종료 코드가 `0`이면 현재 프로젝트 설정을 Godot 4.7.1이 읽고 초기화할 수 있다는 뜻이다.

### 메인 장면 Headless 스모크

```powershell
& $env:GODOT_BIN --headless --path . --quit-after 2
```

종료 코드가 `0`이고 오류 로그가 없으면 메인 장면, `GameState` Autoload와 임시 타이틀을 초기화할 수 있다는 뜻이다.

### 타이틀 자동 검사

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-title-new.log" --quit-after 1000 res://tests/smoke/title_screen_smoke.tscn
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-title-continue.log" --quit-after 1000 res://tests/smoke/title_screen_smoke.tscn -- --title-case=continue
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-title-quit.log" --quit-after 1000 res://tests/smoke/title_screen_smoke.tscn -- --title-case=quit
```

첫 두 실행은 `title_screen_passed`와 종료 코드 `0`을 확인한다. 종료 분기는 `title_screen_quit_requested` 뒤 `GameEntry`의 `quit_requested` 로그와 종료 코드 `0`을 확인한다. 오류 로그 없이 세 조건을 모두 만족해야 통과다. 실제 마우스·Enter·Esc 입력, 옵션 포커스 복원·메뉴 차단, 저장 유무·조회 후 기록 소실·복원 실패·중첩 요청과 거점 단일 진입을 확인한다. 1152×648에서 타이틀 카드가 화면 안에 들어오는지도 검사한다.

### 설정 저장과 자동 검사

타이틀 → 옵션에서 창 모드·전체 화면, 창 크기 1152×648·1280×720·1600×900, 전체 음량 0~100을 바꿀 수 있다. `적용`은 파일 저장 성공 후 화면·음량을 반영하고, 돌아가기·Esc는 적용 전 변경을 취소한다. 음량 0은 Master 버스를 음소거하며 다시 올리면 해제한다. 기본 조작 안내도 표시한다.

`user://settings.cfg`는 설정 전용 파일이다. `settings/schema_version=1`, `display/screen_mode`는 `windowed` 또는 `fullscreen`, `display/window_size_index`는 0·1·2 순서의 위 창 크기, `audio/master_volume`은 정수 0~100을 저장한다. 크기 인덱스의 의미를 바꾸려면 버전을 변경해야 한다. 진행 데이터·보유금·보관품은 포함하지 않으며 이 파일만 있어도 이어하기는 활성화되지 않는다. 최초 로드는 파일을 만들지 않고, 적용 시 같은 폴더의 `.tmp` 파일 쓰기가 성공한 뒤 교체한다.

기본값은 창 모드·1152×648·음량 100이다. 누락·잘못된 타입·범위의 파일은 기본값으로 실행하고 옵션에 안내하며, 사용자가 적용해야 다시 저장한다. 지원하지 않는 버전은 편집을 막아 원본을 보존한다. 저장 실패는 안내와 함께 기존 파일·적용값을 유지한다. 전체 화면은 모니터 크기에 맞추고 창 크기 선택을 비활성화한다. 더 작은 모니터에서는 창을 사용 가능 영역 안으로 줄인다. UI·게임 좌표는 1152×648을 기준으로 비율을 유지해 확대·축소한다.

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settings.log" --quit-after 3000 res://tests/smoke/settings_smoke.tscn
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settings-invalid.log" --quit-after 3000 res://tests/smoke/settings_smoke.tscn -- --settings-case=invalid
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settings-future.log" --quit-after 3000 res://tests/smoke/settings_smoke.tscn -- --settings-case=future
$settingsTestDir = Join-Path $env:TEMP ("dungeon-settings-restart-" + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settings-write.log" --quit-after 3000 res://tests/smoke/settings_smoke.tscn -- --settings-case=write "--settings-test-directory=$settingsTestDir"
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settings-read.log" --quit-after 3000 res://tests/smoke/settings_smoke.tscn -- --settings-case=read "--settings-test-directory=$settingsTestDir"
```

각 실행은 `settings_passed`와 조건명, 종료 코드 `0`, 오류 로그 없음을 확인한다. `default`는 파일 교체·실패 시 보존·복사본 분리·타입과 범위·버전 검사, 실제 키보드·마우스의 수정·취소·적용·실패 안내, Master 버스 음량·음소거를 검사한다. `invalid`·`future`는 잘못된 파일과 다른 버전의 기본값·UI 안내·파일 보존을 검사한다. `write`와 `read`는 같은 임시 폴더를 사용하는 **별도 프로세스**로 전체 화면·창 크기 2번·음량 37 복원을 확인한다. 테스트는 실제 사용자 설정 경로 대신 임시 경로를 주입한다.

실제 창 전환은 위 `default`·`write`·`read`에서 `--headless`를 빼고 실행한다. `default`는 창 크기 세 종류와 전체 화면 전환을 확인하며, `read`는 부팅 직후 전체 화면 적용도 확인한다. 1600×900 창을 수용할 수 있는 모니터에서 실행한다. 마지막에 `--settings-render`를 추가하면 검사 폴더에 `options.png`를 만든다. 화면 설정 확인 시간·자동 복귀, 고급 그래픽·키 변경·접근성과 저장 복구 강화는 G6 범위다.

### 진행 저장과 이어하기 검사

현재 저장 경로는 `user://progress.json`이다. DEV-0403부터 `schema_version=2`, `content_version="g2_prototype_1"`, `resume_state="hub"`와 `hub` 데이터를 기록한다. `hub`는 돈의 십진 문자열 `money`, 가방 칸 수 `bag_slots`, 다음 출정 번호의 십진 문자열 `next_expedition_id`, 보관품 배열 `stored_items`, 원본 등록 배열 `registered_items`의 5필드다. 두 물품 배열은 안정적 ID `id`, 불리언 감정 상태 `identified`, 공개된 위험 안내 `risk_hint`를 기록한다. 등록 목록은 감정한 고유 유물·핵심 기록물만 받고 같은 ID 중복을 거절한다. 이름·분류·무게·가치·보호·등록 설명은 카탈로그의 정의로 복원한다. 미확인 물품은 복원 후에도 가치·실제 분류를 공개하지 않는다. 기존 스키마 1의 거점 4필드는 읽을 때 빈 등록 목록을 보완하며, 이어하기만으로 파일을 고치지 않고 다음 정상 저장 시 2로 전환한다.

가방 선택만 현재 변경 가능한 장비 준비 상태다. 무게 단계 2.5·4.0, 하네스 기본 구성·시작 충전 3과 빈 탐험 가방은 기존 시제품 규칙을 사용한다. 원본 등록·재열람과 확보/등록 원본의 다음 출정 제외는 DEV-0403 범위로 연결했다. 정식 연구 단계·시드/구역별 풀·던전 영구 변화는 아직 구현하지 않았다. 관련 기능을 추가할 때 저장 버전과 복원 규칙을 함께 확장한다. 출정 중 번호와 정산 대기 결과는 저장하지 않으며, 마지막으로 확정된 거점 진행만 복원한다.

자동 저장은 새 게임의 거점 진입, 가방 선택 변경, 정산·감정·판매·등록 확정 시점에 수행한다. 후보 거점 상태를 검증하고 같은 폴더의 `.tmp`에 쓰기·flush·길이 확인 후 기존 파일을 교체한다. 성공 뒤에만 실행 중 거점 상태에 반영한다. 새 게임 저장 실패는 타이틀 유지, 준비 변경 실패는 이전 선택 유지, 정산 실패는 결과 화면 유지와 같은 버튼 재시도 안내로 처리한다. 중복 입력·재시도는 돈이나 보관품을 중복 지급하지 않는다. 이어하기는 읽은 상태를 복원하며 파일을 다시 쓰지 않는다.

파일 없음·손상된 JSON·잘못된 타입·범위·알 수 없는 ID·미지원 버전은 부분 복원하지 않는다. 지원하는 버전 1→2 전환을 제외한 다른 버전 또는 손상된 파일은 자동 저장으로 덮어쓰지 않으며, 사용자가 새 게임 확인 창에서 교체를 선택한 경우에만 새 기록으로 바꾼다. 읽기·쓰기의 기술 한도는 파일당 16 MiB이며 게임 보관함 크기나 콘텐츠 수량을 확정한 값이 아니다. 설정 파일은 진행 교체와 독립적이다. DEV-0403의 버전 1→2 전환 외 백업·자동 복구·추가 버전 전환은 G6, 탐험 중 중단 저장은 기존 보류 범위를 유지한다.

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-progress.log" --quit-after 5000 res://tests/smoke/progress_save_smoke.tscn
foreach ($progressCase in @('replace', 'invalid', 'future', 'unknown_id', 'disappeared')) {
    & $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-progress-$progressCase.log" --quit-after 5000 res://tests/smoke/progress_save_smoke.tscn -- "--progress-case=$progressCase"
}
$progressTestDir = Join-Path $env:TEMP ('dungeon-progress-restart-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-progress-write.log" --quit-after 20000 res://tests/smoke/hub_departure_smoke.tscn -- --departure-case=three "--progress-test-directory=$progressTestDir"
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-progress-read.log" --quit-after 5000 res://tests/smoke/progress_save_smoke.tscn -- --progress-case=read "--progress-test-directory=$progressTestDir"
```

각 진행 검사는 `progress_save_passed`와 조건명, 출정 검사는 `hub_departure_passed`, 종료 코드 `0`, 오류 로그 없음을 확인한다. 기본 검사는 큰 정수·ID·감정·보호·복사본·잘못된 값, 새 게임·준비·정산 쓰기 실패와 재시도, 설정 파일 분리를 확인한다. 이름·보호 규칙 변경 시험은 독립된 물품 정의 복사본을 사용한다. 추가 조건은 기존 기록 교체·취소·Esc, 손상·다른 버전·알 수 없는 ID, 이어하기 직전 파일 소실을 검사한다.

마지막 두 명령은 **별도 프로세스**다. 먼저 실제 이동·회수 입력으로 생환→실패→빈손 생환을 정산해 돈 40·미확인 물품 1개·가방 3칸·다음 출정 번호 4를 저장한다. 이어하기 실행은 이 상태·위험 안내를 복원하고 다시 출정·실패 정산한 뒤 기존 재산 유지와 다음 번호 5를 확인한다. 재실행 비교는 매번 새 임시 폴더에서 시작한다. 같은 폴더에 이미 기록이 있으면 새 게임 확인 창이 필요하므로 자동 작성 조건에 재사용하지 않는다.

기본 검사와 `replace` 검사에서 `--headless`를 빼고 `--progress-render`를 추가하면 1152×648 거점, 정산 저장 실패 안내, 새 게임 확인 창을 검사 폴더에 PNG로 남긴다. 확인 창 검사는 창 안에 보조 창을 표시하도록 구성하고 실제 마우스·Esc 입력을 사용한다. 기본 검사의 회수품은 저장 실패를 재현하기 위해 인벤토리 공개 API로 주입하며, 실제 이동·회수 경로는 위 출정 검사에서 확인한다.

### 거점과 출정 수동 확인

기본 실행에서 새 게임 → 가방 선택 → 출정 순서로 이동한다. 거점에 표시된 칸 수·무게 단계·충전과 탐험 HUD·가방 화면을 비교한다. `WASD`로 이동하고 `E`로 조사·회수·입구 귀환, `Q`로 안정화·비상 방전, `Tab`으로 가방을 열고 닫는다. 분석은 기존 하네스 표시의 정밀 분석 버튼을 사용한다.

위쪽 폐품을 회수한 뒤 같은 입구로 돌아오면 생환 결과를 확인할 수 있다. 아래쪽 잔해가 경고하는 동안 대응하지 않고 범위 안에 머무르면 실패하며 현재 회수품을 잃는다. 종료 뒤 가방·하네스 입력은 탐험을 다시 진행시키지 않는다. 가방·충전·배치는 시제품 조건이며 최종 장비·비용·이동 감속을 확정한 것이 아니다. 별도의 G1 비교 장면과 사람 평가 절차는 그대로 유지한다.

### 거점과 출정 자동 검사

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-departure-two.log" --quit-after 20000 res://tests/smoke/hub_departure_smoke.tscn
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-departure-three.log" --quit-after 20000 res://tests/smoke/hub_departure_smoke.tscn -- --departure-case=three
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-departure-failure.log" --quit-after 20000 res://tests/smoke/hub_departure_smoke.tscn -- --departure-case=failure
```

각 실행에서 `hub_departure_passed`와 종료 코드 `0`, 오류 로그 없음을 확인한다. 준비 전 입력 차단·잘못된 데이터 거절·중복 출정 차단, 준비와 탐험 데이터의 복사본 분리, 실제 이동·회수·가방 일시정지·충전 소비와 종료 뒤 결과 보관·탐험 정리를 검사한다. 가방 2칸·3칸은 세 번째 물품의 적재 여부가 달라지고, 실패 분기는 손실만 남아야 한다. 결과 UI의 기본 해상도 경계도 검사한다.

`DEV-0203`부터 각 실행은 첫 정산 후 다시 출정해 실패하고 한 번 더 출정해 빈손 생환하는 세 번의 탐험을 확인한다. 최초 생환은 보유금 40 증가, 3칸 조건은 미확인 물품 1개 보관, 최초 실패는 수입·보관품 없음이 기준이다. 후속 실패·빈손 생환과 결과 버튼 중복 입력으로 기존 돈·보관품이 변하면 실패다. 재출정 시 빈 가방·같은 칸 수·시작 충전과 시험 물품 배치도 확인한다.

### 귀환 정산 자동 검사

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-settlement.log" --quit-after 1000 res://tests/smoke/settlement_smoke.tscn
```

`settlement_passed`와 종료 코드 `0`, 오류 로그 없음을 확인한다. 독립 정산 검사에서 예상가와 다른 시험 판매가, 미확인·고유 유물·핵심 기록물·보호 물품·판매가 미설정 물품, 음수 가격 거절, 확인 전 상태 유지, 복사본 변경, 중복·과거 출정 재처리와 취소를 검증한다. 실패·빈손 귀환 뒤 기존 재산 유지, 다음 정산에서 이전 보관품을 다시 판매하지 않는지, 새 거점 초기화와 숨겨진 가격·분류 비공개도 확인한다. 실제 화면 순환은 위 출정 자동 검사 세 실행을 함께 사용한다.

### 상태 전환 자동 스모크 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/game_state_flow_smoke.tscn
```

이 한 명령은 `Boot → Title → Hub → Exploration → Results → Hub`를 순서대로 검증한다. 모든 전환과 최종 상태가 맞으면 `state_flow_passed` 로그를 남기고 종료 코드 `0`을 반환하며, 실패하면 오류 로그와 0이 아닌 종료 코드를 반환한다.

### 개발 상태 직접 진입

```powershell
& $env:GODOT_BIN --path . -- --dev-state=Exploration
```

현재 사용할 수 있는 값은 `Boot`, `Title`, `Hub`, `Exploration`, `Results`다. 이 인수는 디버그 빌드에서만 동작한다. 메인 장면은 인수가 있으면 `res://src/app/dev_main.tscn`의 기존 개발 화면으로 진입하며, 요청한 상태까지 `GameState`의 허용 전환을 순서대로 요청한다. 인수 없이 개발 상태 버튼을 확인하려면 이 별도 장면을 직접 실행한다.

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

### 조사·미확인 물품 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/inspection_unidentified_test_space.tscn
```

시험 물품 가까이에서 첫 `E`로 조사해 외형·무게·위험 정보를 확인하고, 두 번째 `E`로 미확인 상태의 물품을 회수한다. `Tab` 인벤토리와 왼쪽 입구 생환 결과에서 실제 분류와 가치가 숨겨지고 미확인 개수만 표시되는지 확인한다. 시험 물품과 값은 실제 콘텐츠·밸런스가 아니다.

### 조사·미확인 물품 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/inspection_unidentified_smoke.tscn
```

조사와 회수가 한 번의 상호작용으로 합쳐지지 않는지, 조사 정보에 외형·무게·위험 정보가 남는지, 현재 탐험의 감정 상태가 인벤토리와 생환 결과까지 전달되는지 검사한다. 감정 전 실제 분류·가치와 결과 합계가 노출되지 않으면 `inspection_unidentified_passed` 로그와 종료 코드 `0`을 반환한다.

### 고장 난 경비 골렘 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/broken_guard_golem_test_space.tscn
```

갈색 긁힌 흔적과 순찰 중 발소리 단서를 확인하고 탐지 범위에 들어간다. 즉시 추적하지 않고 탐지음과 의심 상태가 먼저 나타나는지, 계속 머무르면 추적하는지, 범위를 벗어나면 마지막 위치 수색 뒤 순찰로 돌아가는지 확인한다. 장면의 탐지 범위·속도·대기 시간은 검사 전용 값이다.

### 고장 난 경비 골렘 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/broken_guard_golem_smoke.tscn
```

순찰 이동과 발소리·긁힌 흔적, 탐지음이 추적보다 먼저 나타나는지 검사한다. 지속 감지 뒤 추적, 시야 상실 뒤 마지막 위치 수색과 순찰 복귀, 외부 소음 조사와 경보 추적, 영구 처치 불가가 맞으면 `broken_guard_golem_passed` 로그와 종료 코드 `0`을 반환한다.

### 하네스 분석·비상 방전 수동 테스트

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/harness_actions_test_space.tscn
```

왼쪽 잔해와 오른쪽 골렘에 접근해 무료 기본 분석을 읽는다. 정밀 분석 버튼은 표시된 충전을 쓰며, `Q`는 현재 안내된 안정화·비상 방전을 실행한다. 충전 3을 분석과 위험 대응에 나누어 사용하고 정지한 골렘의 탐지 범위에서 벗어나 본다. 충전량·비용 1·정지 2초는 이 확인 공간의 시험 값이다.

### 하네스 분석·비상 방전 자동 검사

```powershell
& $env:GODOT_BIN --headless --path . res://tests/smoke/harness_actions_smoke.tscn
```

무료·정밀 분석, 분석 버튼과 실제 `Q` 입력, 분석·안정화·방전의 공동 충전, 중복 분석·충전 부족·잘못된 비용·범위 이탈·대상 삭제·중첩 요청·실행 거절을 검사한다. 방전 중 이동 정지, 재방전·소음·경보·재진입으로 정지가 해제되지 않는지, 일시정지 중 시간이 멈추는지, 탈출 또는 잔류에 맞게 복귀하는지도 확인한다. 모두 맞으면 `harness_actions_passed` 로그와 종료 코드 `0`을 반환한다.

### G1 통합 플레이테스트

```powershell
& $env:GODOT_BIN --path . --resolution 1280x800 res://tests/fixtures/g1_integration_playtest_space.tscn
```

시작 화면에서 가방 2칸·3칸을 골라 같은 입구로 귀환한다. 결과에서 시간·적재·충전·추적 기록을 복사하고 조건을 다시 선택할 수 있다. [G1 검토 기록](g1_playtest_review.md)에 현재 컴퓨터의 실행 명령과 사람 확인 순서가 있다.

### G1 통합 자동 검사

```powershell
& $env:GODOT_BIN --headless --fixed-fps 60 --path . --log-file "$env:TEMP/dungeon-g1-smoke.log" --quit-after 20000 res://tests/smoke/g1_integration_playtest_smoke.tscn
```

실제 이동 입력으로 위험 대응 귀환, 같은 우회 경로의 가방 2칸·3칸 비교, 붕괴 잔류 실패를 검사한다. 조사·미확인 정보·충전 사용·일시정지·결과 고정도 함께 검증한다. 성공 시 `g1_integration_playtest_passed`와 종료 코드 `0`을 반환한다. 고정 프레임 실행은 검사 가속용이며 측정 시간을 사람 플레이 시간으로 사용하지 않는다.

## 저장소 규칙

- `project.godot`은 버전 관리한다.
- Godot이 생성하는 `.godot/` 캐시는 버전 관리하지 않는다.
- 개인 내보내기 자격 증명인 `export_credentials.cfg`는 버전 관리하지 않는다.
- 엔진 실행 파일, 편집기 설정과 로컬 캐시는 저장소에 넣지 않는다.
- 최종 지원 해상도와 콘텐츠 장면은 후속 범위에서 확정한다. 현재 시제품 장면·설정 버전 1·진행 버전 1 형식은 위 실행 기준을 따르며 후속 기능에서 호환성 검토 후 확장한다.
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
- G1 검사 결과: 2026-08-31 기존 자동 검사에 회귀 없음. 별도 조사·미확인 물품·경비 골렘·하네스 분석과 비상 방전 및 사람 플레이테스트가 남음
- 다음 개발 작업: 사용자 지시에 따라 `DEV-0108 — 조사와 미확인 물품`
- 정합성 검사: 아직 아님 — 다음 검사는 `DEV-0111` 완료 뒤

## DEV-0108 조사와 미확인 물품 결과

- 현재 탐험 물품 상태: `res://src/gameplay/inventory/inventory_item.gd`가 아이템 정의와 감정 여부를 분리하며 실제 분류·가치는 정의에 유지
- 조사 대상: `res://src/gameplay/interaction/inspectable_pickup_interactable.tscn`에서 첫 상호작용은 정보 확인, 다음 상호작용은 회수로 구분
- 조사 정보: 외형을 나타내는 표시 이름, 무게와 위험 힌트만 공개하며 감정 상태를 바꾸지 않음
- 인벤토리·결과 UI: 미확인 상태에서는 실제 분류, 가치 범위와 보호 여부를 숨기고 미확인 물품임을 문자로 표시
- 생환 결과: 미확인 상태를 유지하고 숨겨진 실제 가치를 예상 가치 합계에서 제외하며 미확인 개수를 별도 표시
- 수동 테스트 공간: `res://tests/fixtures/inspection_unidentified_test_space.tscn`
- 자동 검사: `res://tests/smoke/inspection_unidentified_smoke.tscn`
- 검증: Godot 4.7.1 프로젝트 초기화, 새 조사·미확인 물품 검사와 기존 스모크 검사 8개 통과
- 제외 범위: 거점·휴대용 감정 실행, 하네스 분석, 실제 아이템 콘텐츠·밸런스, 저장 스키마
- 저장 데이터 영향: 없음. 감정 상태는 현재 탐험의 실행 중 물품에만 유지
- 다음 개발 작업: `DEV-0109 — 고장 난 경비 골렘`
- 정합성 검사: 아직 아님 — 다음 검사는 `DEV-0111` 완료 뒤

## DEV-0109 고장 난 경비 골렘 결과

- 골렘 장면: `res://src/gameplay/hazards/broken_guard_golem.tscn`
- 실행 중 상태: 지정 구간 순찰, 마지막 위치로 이동하는 의심, 적극 이동하는 추적, 시야 상실 뒤 수색과 순찰 복귀
- 사전 단서: 순찰 중 발소리·긁힌 흔적을 표시하고 감지 시 탐지음이 있는 의심 단계를 추적보다 먼저 거침
- 외부 연결: 소음 위치 조사와 경보 위치 추적을 공개 명령으로 요청하며 상태 변경·경고·추적·수색 이벤트를 공개
- 영구 처치: 허용하지 않으며 기본 공격·반복 피해·실패 판정을 구현하지 않음
- 수동 테스트 공간: `res://tests/fixtures/broken_guard_golem_test_space.tscn`
- 자동 검사: `res://tests/smoke/broken_guard_golem_smoke.tscn`
- 검증: Godot 4.7.1 프로젝트 초기화, 새 골렘 검사와 기존 스모크 검사 9개 통과
- 시제품 값: 순찰 구간, 이동 속도, 탐지 범위와 의심·수색 시간은 조정 가능하며 제품 밸런스로 확정하지 않음
- 제외 범위: 하네스 비상 방전, 문 차단·투척 유인물, 전투 피해·부상·탐험 실패 연결, 최종 인공지능·경로 탐색·콘텐츠 배치, 저장 스키마
- 저장 데이터 영향: 없음. 골렘 상태와 마지막 위치는 현재 장면 실행 중에만 유지
- 다음 개발 작업: `DEV-0110 — 하네스 분석과 비상 방전`
- 정합성 검사: 아직 아님 — 다음 검사는 `DEV-0111` 완료 뒤

## DEV-0109-R1 G1 사전 코드 검토 보완 결과

- 범위: [`development_handoff.md`](development_handoff.md#dev-0109-r1--g1-사전-코드-검토-보완)의 사용자 승인 보완 여섯 건
- 보호 물품: 실제 분류·보호 설정으로 일반 버리기를 거절한다. 미확인 상태의 실제 분류·가치를 거절 문구로 공개하지 않는다.
- 인벤토리 입력: 목록·버튼에 포커스가 있어도 Tab으로 닫으며 원래 일시정지 여부를 복원한다.
- 조사 정보: 위험 힌트를 현재 탐험 물품과 생환 결과에 유지한다.
- 골렘: 감지 중인 플레이어 정보와 경고 시간을 외부 소음·경보로 덮어쓰지 않는다. 소음만 감지한 기존 의심·수색 흐름은 유지한다.
- 결과: 귀환 당시 물품 정의·감정·위험 정보를 복사해 고정하고 조회용 복사본 변경에서도 보호한다. 거점 감정 구현은 포함하지 않는다.
- 종료: 인벤토리 변경 알림 전 잠금을 적용해 생환·실패 중첩 요청과 처리 도중 인벤토리 재연결을 거절한다.
- 검증: Godot 4.7.1 프로젝트 초기화와 스모크 장면 10개 통과. 기존 `inventory_system_smoke`, `inspection_unidentified_smoke`, `broken_guard_golem_smoke`, `recovery_result_smoke`, `exploration_end_smoke`에 경계 상황 검사를 추가하고 결과 검사의 물품 비교를 안정적 ID 기준으로 갱신했다. 위에 기록된 실행 명령을 그대로 사용한다.
- 저장 데이터 영향: 없음. 실제 콘텐츠·제품 수치·저장 스키마와 하네스 분석·비상 방전은 추가하지 않았다.
- 상태: 구현·자동 검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- 다음 기능 작업: `DEV-0110 — 하네스 분석과 비상 방전`
- 정합성 검사: 아직 아님 — 다음 검사는 `DEV-0111` 완료 뒤

## DEV-0110 하네스 분석과 비상 방전 결과

- 분석: 가까운 잔해·골렘의 기본 상태는 무료, 현재 상태와 대응 방법의 정밀 분석은 충전 사용. 같은 대상·상태의 연속 구매를 막고 대상·상태 변경 및 범위 이탈 시 이전 표시를 지움
- 공동 자원: 정밀 분석·기존 안정화·비상 방전이 같은 하네스 충전을 사용. 비용 검증·중첩 요청 차단·실행 거절 시 반환은 하네스가 소유
- 조작: 비용을 표시한 정밀 분석 버튼과 기존 `Q` 안정화·방전. 대응 가능한 대상 우선, 같은 조건에서는 가까운 대상 선택
- 골렘: 잠시 이동과 의심·수색 타이머 정지. 정지 중 재방전·소음·경보·플레이어 재진입으로 취소·연장되지 않음. 복귀 시 현재 감지한 플레이어를 경고 뒤 추적하거나 마지막 위치 수색 뒤 순찰
- 수동 테스트 공간: `res://tests/fixtures/harness_actions_test_space.tscn`
- 자동 검사: `res://tests/smoke/harness_actions_smoke.tscn`
- 검증: Godot 4.7.1 프로젝트·메인·새 수동 장면 초기화 및 새 분석·방전 검사와 기존 스모크 검사를 합친 11개 통과. 분석 버튼 포커스 중 `Q`, 빈 충전, 반복·범위 이탈·삭제·중첩 요청·실행 거절, 정지·일시정지·탈출·재진입 복귀 확인
- 제외 범위: 물품 감정·가격 공개, 모듈 성장·내구도·충전 복구, 피해·최종 인공지능·제품 수치, 통합 맵과 사람 플레이테스트
- 저장 데이터 영향: 없음. 분석 표시·충전·골렘 정지는 현재 장면 실행 중 상태이며 상세 Harness Engineering은 `draft` 유지
- 상태: 구현·자동 검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- 다음 작업: `DEV-0111 — G1 통합 플레이테스트와 수치 검토`
- 정합성 검사: 아직 아님 — 다음 검사는 `DEV-0111` 완료 뒤

## DEV-0111 G1 통합 플레이테스트 결과

- 장면: `res://tests/fixtures/g1_integration_playtest_space.tscn`. 입구·저가 통로·붕괴 통로·우회로에 기존 물품·골렘·하네스·생환·실패를 연결
- 조건 비교: 시작 시 2칸 또는 3칸. 같은 무게 단계·배치·속도·충전으로 비교하며 최종 제품 수치를 확정하지 않음
- 기록: 탐험·가방 확인 시간, 이동 거리, 최대 무게·칸 수, 부담·과적·추적·붕괴 경고 시간, 조사·회수·교체·충전·추적·우회·결과 사건. 종료 뒤 고정하고 화면에서 복사. 붕괴 경고 시간은 플레이어 노출 시간이 아닌 위험의 경고 상태 유지 시간
- 검증: Godot 4.7.1 프로젝트 초기화 후 기존 자동 검사를 유지하고, 가독성·시험 조건 보완을 포함한 스모크 장면 12개 통과. 실제 이동으로 여섯 시나리오 확인. 시작·가방·결과 렌더링 및 기본 해상도 배치 검사
- 표시 보완: 회수 결과의 긴 설명·요약 줄바꿈과 목록 최소 높이를 조정. 가방에는 선택한 물품의 상세 표시와 긴 설명 스크롤을 추가하고 미확인 분류·가치·보호 여부를 계속 숨김
- 자료: [G1 검토 기록](g1_playtest_review.md), [자동 실행 원본](g1_playtest_automated_results.json)
- 저장 데이터 영향: 없음. 측정 JSON은 테스트 자료이며 제품 저장 형식이 아님
- 상태: 통합 장면·자동 검증·검토 자료는 `eabc705`, 분석 버튼 클릭 후 Tab 가방 열기 오류 보완은 `a1aae2f`, 가독성·시험 조건 보완은 `9412620`에 사용자 승인으로 커밋. 사람 플레이테스트 미수행
- 입력 보완 검증: 가방 열기·닫기를 UI 포커스 이동보다 먼저 처리. 실제 클릭과 논리·물리 키 코드가 있는 Tab 이벤트로 수정 전 실패·수정 후 통과 확인. 분석 버튼이 비활성·활성인 두 상태에서 가방 열기와 탐험·붕괴 시간 정지·재개 확인
- 추가 화면·경로 보완: 선택한 미확인 물품의 상세 정보가 1280×800 화면과 기본 1152×648 배치에서 표시됨. 통합 시험 조건은 붕괴 경고 1.2초·골렘 의심 0.7초·추적 속도 210. 같은 경로·회수품 2개 조건에서 안정화·방전 사용 시 추적 7.28→1.38초, 경고 유지 1.20→0.05초. 충전 없이도 생환 가능하며 제품 수치·피해 규칙은 확정하지 않음
- 정합성 상태: 기술 검사 완료 — 스모크 장면 12개 통과와 현재 조건의 기록 6개 확보. GDD 20-1 사람 판단·`Q-004`·`Q-005`는 후속 확인
- 다음 절차: 2026-09-08 사용자 작업 재개 지시에 따라 `DEV-0201` 진행. [G1 검토 기록](g1_playtest_review.md)의 사람 평가를 통과한 것으로 기록하지 않음

## DEV-0201 게임 시작 처리와 임시 타이틀 결과

- 진입: `GameEntry`가 자동 `Boot → Title`과 새 게임·이어하기 요청을 기존 `GameState`에 연결. 당시의 거점 도착 안내는 후속 DEV-0202에서 준비·출정 화면으로 대체
- 표시: `TitleScreen`이 새 게임·이어하기·옵션·종료와 저장 상태 안내를 표시. 옵션은 임시 안내이며 Esc·돌아가기 버튼으로 닫으면 선택 위치 복원
- 저장 연결: 저장 유무·복원 콜백이 모두 유효할 때 조회 결과로 이어하기 상태 결정. 실행 직전 유무 재확인, 실패 시 타이틀 유지, 중첩 시작 요청 차단. 공급자 미연결 상태는 이어하기 불가
- 개발 진입: 기존 `dev_entry.gd`와 개발 상태 UI는 `dev_main.tscn`으로 유지. 기본 타이틀과 `--dev-state` 경로 분리
- 검증: Godot 4.7.1 프로젝트 초기화, 스모크 장면 13개, 이어하기·종료 별도 실행, 기본 실행·개발 진입 5종 통과. 실제 입력으로 메뉴·옵션·저장 분기를 확인하고 1152×648 타이틀·옵션·거점 안내를 렌더링
- 제외 범위: 거점·출정·정산, 화면·음량 설정 변경, 실제 저장·불러오기와 파일 형식, G1 사람 평가·최종 수치 결정
- 저장 데이터 영향: 없음. 파일 생성·삭제·덮어쓰기 없음. 새 게임도 저장 기록을 지우지 않음
- 상태: 구현·검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- 커밋: 사용자 승인으로 `f21d120`
- 후속 작업: `DEV-0202 — 임시 거점과 출정`, 아래 결과 참고
- 정합성 검사: 아직 아님 — 다음 단계 검사는 `DEV-0206` 완료 뒤 G2

## DEV-0202 임시 거점과 출정 결과

- 거점: `HubState`가 가방 선택과 준비 조건을 보관하고 `HubPanel`이 표시·출정 요청을 담당
- 데이터 인계: `ExpeditionLoadout` 복사본으로 슬롯·무게 단계·충전을 검증하고 실제 탐험 인벤토리·하네스에 적용. 탐험 중 변화가 거점 준비와 출정 당시 기록을 바꾸지 않음
- 실행 장면: `res://src/app/prototype_exploration.tscn`. 기존 G1 배치와 시제품 조건으로 이동·조사·회수·위험·하네스·입구 귀환·실패를 연결
- 흐름: `GameEntry`가 `Hub → Exploration → Results`를 요청하고 결과를 보관한 뒤 탐험 장면 정리. 출정 전·종료 후 조작과 중복 출정 차단
- 자동 검사: `res://tests/smoke/hub_departure_smoke.tscn`, 가방 2칸·3칸 생환과 붕괴 실패의 세 실행
- 검증: Godot 4.7.1 프로젝트 초기화, 스모크 장면 14개와 출정·타이틀 추가 분기 네 개, 기본 실행·개발 진입 5종 통과. 1152×648 거점·탐험·결과 렌더링과 경계 확인
- 범위: 기존 G1 비교 자료·사람 평가 대기 유지. 정산·거점 반영, 최종 장비·비용·밸런스와 실제 설정·진행 저장은 후속 작업
- 저장 데이터 영향: 없음. 준비·탐험·결과는 실행 중 상태이며 파일 생성·삭제·덮어쓰기 없음
- 상태: 구현·검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- 커밋·원격 반영: 사용자 승인으로 `6b16114`, `DEV-0201`과 함께 2026-09-08 원격 동기화
- 후속 작업: `DEV-0203 — 귀환 정산과 거점 반영`, 아래 결과 참고
- 정합성 검사: 아직 아님 — 다음 단계 검사는 `DEV-0206` 완료 뒤 G2

## DEV-0203 귀환 정산과 거점 반영 결과

- 가격: `res://src/data/prototype_economy.tres`의 ID별 시험 판매가 10·30·80. 아이템 예상가와 분리하며 실제 비용·감정·등록은 아직 적용하지 않음
- 정산: `SettlementResult`가 판매 내역·수입·비용·순이익과 보관품을 고정. 미확인·보호·판매가 미설정 물품은 상태와 위험 정보를 유지
- 거점: `HubState`가 출정 번호별 정산을 확인 시 한 번만 반영하고 보유금·미판매 회수품을 보관. 실패·빈손 귀환은 기존 재산 유지
- 화면: 순이익을 크게 표시하고 이번 판매액·비용·보관품을 구분. 확인 후 거점에 보유금·보관 목록 표시, 같은 준비 조건으로 재출정
- 검증: Godot 4.7.1 스모크 장면 15개, 출정·타이틀 추가 분기 네 개, 프로젝트 초기화·기본 실행·개발 진입 5종 통과. 실제 입력의 반복 탐험·정산과 1152×648 정산·거점·실패 화면 확인
- 저장 데이터 영향: 실행 중 보유금·보관품 추가. 실제 파일 저장·불러오기는 `DEV-0205`에서 연결하며 현재 종료 시 소실
- 제외 범위: 최종 가격·통화·비용·안전망 수치, 거래처 보정·감정·등록·연구·보관품 꺼내기, 방문별 영구 진행과 G1 사람 평가
- 상태: 구현·검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- 후속 작업: `DEV-0204 — 설정 저장`, 아래 결과 참고
- 정합성 검사: 아직 아님 — 다음 단계 검사는 `DEV-0206` 완료 뒤 G2

## DEV-0204 설정 저장 결과

- 기능: 타이틀 옵션의 화면 모드·창 크기·전체 음량 선택, 변경 대기·적용 성공·실패 안내, 취소와 포커스 복원, 기본 입력 안내
- 저장: 설정 전용 `user://settings.cfg` 버전 1. 임시 파일 쓰기 후 교체, 첫 실행·잘못된 값의 기본값 적용, 지원하지 않는 버전 보존
- 적용: 부팅과 저장 성공 후 실제 창·Master 버스 갱신. 창 크기 3종, 전체 화면, 음량 0의 음소거·복원, 고정 논리 좌표의 비율 유지
- 검증: Godot 4.7.1 스모크 장면 16개, 기존 출정·타이틀 추가 분기 4개, 잘못된 설정·다른 버전 부팅, 별도 프로세스 저장·재실행 통과. 실제 그래픽 실행에서 화면 모드·창 크기 3종·재실행 복원과 화면 배치 확인
- 저장 데이터 영향: 사용자 설정 파일만 추가. 게임 진행 기록은 아직 저장하지 않으며 `DEV-0205`에서 연결
- 상태: 구현·검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- G2 진행: 6개 작업 중 4개 완료, 2개 남음 — `DEV-0205` 진행 저장·이어하기, `DEV-0206` 전체 흐름 검사
- 정합성 검사: 아직 아님 — 다음 단계 검사는 `DEV-0206` 완료 뒤 G2

## DEV-0205 진행 저장과 이어하기 결과

- 기능: 거점 진입·준비 변경·정산 확인 자동 저장, 유효한 기록의 이어하기·거점 복원과 재출정, 기존 기록의 새 게임 교체 확인
- 저장: 설정과 별도 진행 JSON 버전 1. 돈·가방 선택·보관품 ID·감정·위험 안내·다음 출정 번호. 탐험 중 회수품과 정산 대기는 저장하지 않음
- 실패 처리: 후보 상태 저장 성공 후 반영, 저장 실패 시 기존 파일·거점 상태 유지와 재시도. 손상·잘못된 값·알 수 없는 ID·다른 버전은 이어하기 차단, 확인 없는 교체 금지
- 데이터: 시제품 물품 4개의 기존 ID·이름·값을 독립 리소스로 옮기고 맵·복원이 같은 `ItemCatalog`를 사용
- 검증: Godot 4.7.1 스모크 장면 17개, 기존 추가 분기 4개, 진행 기록 추가 조건 5개, 별도 프로세스 이어하기와 후속 실패 정산 통과. 프로젝트 초기화·기본 실행·개발 상태 5종, 거점·저장 실패·교체 확인 화면 검사 통과
- 제외 범위: 감정·등록·장비 성장·던전 영구 변화, 저장 백업·마이그레이션·중단 저장, 타이틀 복귀와 G1 사람 평가
- 상태: 구현·검증 완료, 검증 결과 검토 후 사용자 커밋 승인
- G2 진행: 6개 작업 중 5개 완료, 1개 남음 — `DEV-0206` 전체 흐름 검사
- 정합성 검사: 아직 아님 — 다음 단계 검사는 `DEV-0206` 완료 뒤 G2

## DEV-0206 전체 흐름 검사 결과

- 변경: 한 명령의 반복 검사 실행기와 기존 검사 간 임시 파일 연결. 게임 기능·저장 형식은 변경 없음
- 검증: Godot 4.7.1 버전·초기화와 반복당 38개 실행을 두 번 수행해 78/78 통과. 엔진 오류·경고·예외 적용 없음
- 연결 결과: 같은 파일로 설정 저장·탐험·정산·재실행·이어하기·설정 유지 확인. 두 반복의 돈·보관품·가방·다음 출정 번호와 파일 해시 일치
- 실행기 검증: 통과 표시 누락·오류·경고·비정상 종료·시간 초과가 실패로 기록되고 정상 실행만 통과
- 근거: [G2 검사 기록과 자동 실행 원본](g2_flow_review.md)
- 상태: 승인된 G2 시제품 순환 범위의 기술 검사 완료·통과, 결과 검토 후 사용자 커밋 승인
- G2 진행: 6개 작업 중 6개 완료, 남은 작업 0개. 다음 개발 단계는 G3 탐험 확장의 첫 작업 범위 확정
- 정합성 검사: 지금 — G2 결과 확인 완료·통과. 다음 정기 단계 검사는 G5 반복성 완료 후이며 G1 사람 평가는 기존 후속 확인으로 유지

## DEV-0306 빠른 버리기 검사

기본 실행에서 출정하고 물품을 회수한다. Tab 가방에서 물품 행을 직접 클릭하거나 방향키로 선택한 뒤 가방을 닫는다. 화면에 표시된 대상에 G를 길게 누르면 한 개를 버리고 슬롯·무게가 갱신된다. 짧게 누르거나 메뉴를 열면 취소되고, 보호 물품 선택은 대상을 비운다. 획득 직후의 자동 강조만으로는 빠른 버리기 대상을 정하지 않는다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/quick_drop_smoke.tscn
```

성공 표시는 `quick_drop_passed`와 종료 코드 0이다. 실제 이동·회수·클릭·키 입력, 동일 정의의 서로 다른 개체, 보호 물품·감정 전 상태·보호 변경, 짧은 누르기·반복 입력·메뉴·정지·포커스 이탈·일반 버리기·귀환/실패·재출정을 검사한다. 누르기 시간 0·음수·비유한 값도 거절한다. `QuickDropController.hold_duration`과 시제품 장면의 0.6초는 제품 확정 수치가 아니다.

그래픽 확인은 같은 명령에서 `--headless`를 빼고 끝에 `-- --quick-drop-render-directory=<임시 폴더>`를 붙이면 가방 선택·진행 중·버린 뒤 화면 3장을 저장한다. 검사는 기존 사용자 저장·설정 파일을 수정하지 않는다. 전체 검사 실행기는 새 스모크 장면을 자동 포함하며 한 번 실행할 때 총 46개 프로세스(스모크 장면 23개 포함)를 확인한다.


2026-09-19 최종 검증: Godot 4.7.1에서 `-Repetitions 1` 전체 46/46 실행, 별도 그래픽 검사와 1152×648 화면 3장 확인 통과. 엔진 오류·경고가 없고 설정·진행 저장 순환이 유지되었다. 활성 Markdown 상대 링크·앵커와 보존 원본 SHA-256 6개, `git diff --check`도 통과했다. 구현·검증 완료, 결과 검토 후 사용자 로컬 커밋 승인.

## DEV-0307 무게 단계의 이동 영향 검사

현재 출정 장면의 플레이어에 [시험 감속 리소스](../../src/data/prototype_load_movement.tres)를 연결했다. 기본 이동 속도 240 px/s와 출정 무게 경계 2.5·4.0은 그대로 사용한다. 정상은 기본 속도, 부담은 0.8배, 과적은 0.55배로 이동한다. 이 값은 검사용이며 `Q-005`의 최종 밸런스가 아니다. 공통 플레이어와 과거 G1 비교 장면에는 리소스가 기본 연결되지 않아 기존 이동 조건을 유지한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/load_movement_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

새 검사 성공 표시는 `load_movement_passed`와 종료 코드 0이다. 경계 무게의 바로 아래·정확한 값·초과, 실제 속도와 이동 거리, 대각선 정규화, 잘못된 감속 데이터, 데이터 미연결, 실제 E 회수, 슬롯 거절, 일반·빠른 버리기 후 회복, 가방·지도 정지, 벽 충돌, 귀환/실패·새 출정을 확인한다. 그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --load-render-directory=<임시 폴더>`를 붙이면 부담·과적·회복 화면 3장을 저장한다.

수동 확인은 새 게임/이어하기 → 거점 → 출정 후 위쪽 경로의 가벼운 폐품과 무거운 폐품을 회수한다. 합계 무게 3.0에서 HUD의 부담·이동 80%와 이동 감속을 확인한다. 가방에서 무거운 물품을 선택하고 닫은 다음 G 길게 누르기로 버리면 정상·이동 100%로 돌아온다. 3칸 가방에서 세 번째 회수품까지 적재하면 과적·이동 55%도 확인할 수 있다. 보호 물품의 폐기 차단과 기존 확인 창 규칙은 유지된다.

2026-09-19 검증: 전체 47/47 실행(스모크 장면 24개 포함), 별도 그래픽 검사와 1152×648 화면 3장 통과. 그래픽 실행과 병행한 첫 전체 검사는 초기화의 30초 제한을 넘겨 중단됐고, 그래픽 종료 후 60초 제한으로 실행한 최종 검사는 엔진 오류·경고 없이 통과했다. 제품 코드나 검사 판정 조건을 완화하지 않았다. 활성 Markdown 링크·앵커, 보존 원본 SHA-256 6개와 `git diff --check`도 통과했다. 구현·검증 완료, 결과 검토 후 사용자 로컬 커밋 승인.


## DEV-0308 적재 이동 소음과 골렘 반응 검사

현재 출정 장면에 [시험 소음 리소스](../../src/data/prototype_load_noise.tres)를 연결했다. 실제 이동 48 px마다 최대 한 번 소음을 내며 정상/부담/과적 반경은 96/180/260 px다. 과적 소음을 2초 안에 3회 들으면 기존 골렘 경고 후 마지막 소음 위치를 추적한다. 조정 가능한 시험 값이며 벽 차음·새 길찾기·오디오·유인 도구와 최종 밸런스를 구현하거나 확정하지 않는다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/movement_noise_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `movement_noise_passed`와 종료 코드 0이다. 유효하지 않은 수치, 직선/대각선 실제 이동 거리·적재 반경·큰 소음 여부, 정지·순간 위치 변경·벽 막힘·메뉴·활성 상태, 수신 반경 경계·범위 밖, 단발 의심→수색→순찰, 반복 큰 소음→경고→추적, 추가 발소리로 경고 시간을 연장하거나 추적 대상을 바꾸지 않는지 확인한다. 누적 만료·메뉴 중 시간 보존·방전·기존 탐지/경보 우선순위, 발생 순간 위치와 실제 대상 분리, 실제 이동의 HUD·빠른 버리기·귀환/실패·새 출정도 검사한다. 소음 검사에서 수신 경계를 고정할 때만 검사 골렘의 이동 속도를 0으로 두며 제품 장면의 속도는 변경하지 않는다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --noise-render-directory=<임시 폴더>`를 붙인다. 소음 감지·반복 경보·버린 뒤 화면 3장을 저장한다. 수동 확인은 3칸 가방으로 출정해 과적 적재를 만든 뒤 골렘 주변을 이동하고, 경고 안내와 소음 단계를 확인한다. 가방에서 무거운 일반 물품을 선택한 뒤 닫고 G를 길게 눌러 버리면 이후 발소리 범위와 HUD 소음 단계가 줄어든다. 이미 시작한 경고나 추적은 물품을 버렸다는 이유만으로 취소되지 않는다.

2026-09-19 검증: 전체 **48/48 실행**(스모크 장면 25개 포함)과 별도 그래픽 검사·1152×648 화면 3장 통과, 엔진 오류·경고 없음. 첫 소음 검사에서 검사 플레이어의 벽 충돌 마스크 누락과 장면 해체 중 골렘 탐지 이탈의 타이머 오류를 발견해 각각 설정·해체 가드를 보완했다. 최종 검사의 판정 조건을 완화하지 않았다. 활성 Markdown 링크·앵커, 보존 원본 SHA-256 6개와 `git diff --check`도 통과했다. 구현·검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/makist_code_04/AppData/Local/Temp/dungeon-g2-20260919-043307-50844caed0494547981fb3798ba89e65/results.json`
- 검사 소스 SHA-256: `538cdb2bab57e577ee0ffbf8139917810427902dcb84d6be2b85a3d59ed525a0`
- 화면 원본: `C:/Users/makist_code_04/AppData/Local/Temp/dungeon-noise-render-18366c053ee6411aab6aebbcdc3f9795/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. `DEV-0309`의 이름과 범위는 다음 착수 때 확정한다.


## DEV-0309 소음 유인 도구 검사

현재 출정 장면의 [소음 유인 시험 데이터](../../src/data/prototype_noise_lure.tres)는 출정당 2회, 최소/최대 거리 24/300 px, 벽 여유 8 px, 비행 0.3초, 청취 반경 320 px, 착지 표식 1초다. 최종 밸런스가 아닌 조정 가능한 값이며 현재 장면의 별도 시험 지급이다. 도구 구매·준비 선택·회수품 슬롯/무게·하네스 충전·진행 저장과 기존 G1 비교 장면은 바꾸지 않는다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/noise_lure_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `noise_lure_passed`와 종료 코드 0이다. 수치 유효성, 마우스 목표와 실제 F 입력, 가까운 목표 거절·벽 앞 착지·최대 거리, 닫힌/열린 잔여 구역 입구, 투척에 의한 미방문 구역 비공개, 한 개 소비·비행 중 중복 거절·키 반복·출정 때 누른 키·소진을 확인한다. 메뉴 중 비행 정지·대기 요청 취소·포커스 이탈, 이동 중 고정 착지, 골렘의 실제 접근과 의심→수색→순찰, 수신 반경 경계·이동 소음 누적 분리·경보 경고/직접 탐지/방전 우선순위·소리 위치 추적의 유인, 귀환/실패·새 출정과 자원 분리도 검사한다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --lure-render-directory=<임시 폴더>`를 붙인다. 투척 중·유인 반응·소진 화면 3장을 저장한다. 검사 입력은 실제 키·마우스 이벤트를 보내며 조준은 수신한 마우스 이벤트의 뷰포트 좌표와 현재 카메라 변환을 사용한다. 운영체제 포인터를 직접 이동하지 않아 headless 검사에서도 같은 좌표 경로를 검증한다.

수동 확인은 새 게임/이어하기 → 거점 → 출정 후 우측 도구 안내의 2/2를 확인한다. 마우스로 골렘 주변의 빈 바닥을 가리키고 F를 누른다. 벽에 막힌 방향은 벽 앞에서 떨어지고, 너무 가까우면 소모하지 않는다. 골렘이 플레이어를 직접 탐지하지 않는 거리에서 사용하면 착지 후 해당 위치로 움직인다. 이미 플레이어를 직접 탐지했거나 경보 경고 중이면 유인으로 그 반응을 취소하지 않는다. 수량이 0이면 사용이 거절되며 메뉴·종료·새 출정의 처리도 확인한다.

2026-09-19 최종 검증: **49/49 실행**(스모크 장면 26개 포함), 별도 그래픽 검사와 1152×648 화면 3장 통과. 엔진 오류·경고가 없고 기존 저장·재실행 흐름도 유지되었다. 초기 검사에서 입력 버퍼·마우스 위치 조회 차이를 확인해 이벤트 좌표 기반 조준과 즉시 전달하는 검사 입력으로 보완했다. 활성 Markdown 링크·앵커, 보존 원본 SHA-256 6개와 `git diff --check`도 통과했다. 구현·검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/makist_code_04/AppData/Local/Temp/dungeon-g2-20260919-053125-3565397d121c4369aea81039c4ae5533/results.json`
- 검사 소스 SHA-256: `45126acc1d088880e2353f71cd7facc493e657e8e488bcade7b15bc6bfe02374`
- 화면 원본: `C:/Users/makist_code_04/AppData/Local/Temp/dungeon-lure-render-1a79cd016ee742ac85f599b9fbaa8989/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0310`이며 작업명·범위는 착수 때 확정한다.

## DEV-0310 골렘 시야 차단과 재탐지 검사

현재 출정 장면만 `use_sight_occlusion`을 켠다. 기존 탐지 반경 안에서 골렘 중심과 플레이어 중심 사이를 실제 충돌체로 검사한다. 차단 마스크 9는 기존 문(층 1)과 벽·잔여 구역 입구(층 8)를 포함한다. 자기 몸과 대상 몸, 조사·위험 Area2D는 시야를 가리지 않는다. 전방 시야각·벽 차음·길찾기나 새 문 배치는 추가하지 않는다. G1 비교 장면은 기존 반경 탐지를 유지한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/golem_sight_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `golem_sight_passed`와 종료 코드 0이다. 실제 이동으로 중앙 벽에 숨기·노출·범위 이탈을 검사하며, 같은 반경 안에서 E로 시험 문을 열고 닫아 경고 취소·재탐지를 확인한다. 가려진 이후의 위치 비공개, 경고 시간과 중복 통지, 방전 후 숨기/재노출, 소음·유인물·경보 우선순위, 지도·가방 정지, 대상 제거·출정 전·귀환/실패·새 출정도 검사한다. 시험 문은 검사 장면에서만 추가한다. 기존 소리 기반 추적이 이미 시작됐다면 직접 탐지로 진행 중인 추적을 낮추지 않는다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --sight-render-directory=<임시 폴더>`를 붙인다. 가림·경고·수색·분석 화면 4장을 저장한다. 실제 이동은 입력으로 실행하며, 화면 캡처 뒤에도 벽 모서리를 충분히 벗어나는 경로로 검사한다. 하네스 기본·정밀 분석의 긴 설명과 도구 안내는 세로 배치로 서로 겹치지 않는다.

수동 확인은 출정 후 골렘 주변 벽의 끝을 이용한다. 골렘이 보이는 쪽에 계속 서 있으면 경고 후 추적한다. 벽 반대쪽으로 숨으면 마지막으로 본 위치를 수색하고, 다시 드러나면 새 경고가 시작된다. 과적 소음이나 유인물은 벽 너머로 들릴 수 있으므로 시야 차단과 소음 차단은 다르다. 가까이서 하네스 기본 분석으로 대응 안내를 읽을 수 있다.

2026-09-21 최종 검증: **50/50 실행**(스모크 장면 27개 포함), 별도 그래픽 검사와 1152×648 화면 4장 통과. 엔진 오류·경고가 없고 기존 정산·저장·재실행 흐름을 유지했다. 첫 샌드박스 초기화는 인증서·편집기 설정 폴더 권한 때문에 실패했으며 정상 권한으로 재실행해 통과했다. 대상 제거 검사는 항상 플레이어가 있는 앱 계약과 분리하고, 그래픽 검사에서 드러난 모서리 경로의 한 프레임 차이를 보완했다. G1 사람 평가·최종 수치와 다음 정기 검사 시점은 유지한다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260920-233511-2f8048655b4945d0a93d974db89e2def/results.json`
- 검사 소스 SHA-256: `417a32adfa5092b1242b736b6a560f6bcaeff99a94ceaf4329fcf29780eb3152`
- 문서 검사: 활성 Markdown 43개 내 상대 링크·앵커 1,065개, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-sight-0c5823adfb1840908bf9685ec92ee527/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0311`이며 이름·범위는 착수 때 확정한다.

## DEV-0311 함정 오작동과 임시 안정화 검사

현재 출정의 기존 잔여 구역 오른쪽에 시험 함정을 둔다. 구역을 실제 발견해야 보이고 작동하며 문 개방만으로는 공개하지 않는다. [함정 주기 시험 데이터](../../src/data/prototype_trap_cycle.tres)는 대기 1.8/2.6초 교대·경고 1.2초·작동 0.45초·안정화 4초·충전 비용 1이다. [함정 장면](../../src/gameplay/hazards/malfunctioning_trap.tscn)의 범위는 64×64다. 모두 조정 가능한 시험 값이며 새 건강·부상·최종 피해량을 정하지 않는다. 작동 범위 진입·잔류는 기존 붕괴와 같은 시험 실패·회수품 손실 처리에 연결한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/malfunctioning_trap_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `malfunctioning_trap_passed`와 종료 코드 0이다. 잘못된 수치·데이터 복사본, 서로 다른 대기 간격과 경고 순서·긴 프레임의 경고 보존, 실제 이동의 무료 통과·옆길 우회·작동 중 진입과 잔류 실패를 검사한다. Q의 공유 충전·중복·부족·정지 만료 뒤 전체 경고, 가방·지도 정지와 입력 차단, 무료 분석의 실시간 갱신, 미발견 정보 비공개·귀환/실패 정지·새 출정 초기화도 포함한다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --trap-render-directory=<임시 폴더>`를 붙인다. 대기·경고·임시 정지·작동 화면 4장을 저장한다. 색상 외에도 문자로 상태와 대응을 알리며 점멸은 느린 주기를 사용한다. 수동 확인은 출정 후 위쪽 잔여 구역 입구에서 Q로 문을 열고 실제로 안에 들어간다. 방의 오른쪽 함정에 접근해 안내를 읽고, 불빛이 꺼졌을 때 통과하거나 왼쪽 길로 돌아간다. 가까이서 Q를 누르면 공유 충전이 1 줄고 잠시 멈춘다. 다시 점멸하면 범위 밖으로 물러나야 한다.

2026-09-21 최종 검증: **51/51 실행**(스모크 장면 28개 포함), 별도 그래픽 검사와 1152×648 화면 4장 통과. 엔진 오류·경고가 없고 기존 정산·저장·재실행 흐름을 유지했다. 첫 화면 검사에서 함정 상태가 바뀌어도 하네스의 무료 기본 분석이 이전 상태를 표시하는 문제를 발견했다. 위험 감지기의 비교 대상을 기본·정밀 분석으로 넓혀 수정하고 분석 갱신 검사를 추가한 뒤 전체 검사와 화면 검사를 다시 통과했다. G1 비교 조건·저장 형식·최종 수치는 유지한다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260920-235916-f1b89098c10748dc8c89a398208d9ca1/results.json`
- 검사 소스 SHA-256: `186b0700de39c491a46f466d9c48d332b5660d35ace943edbd24b7848de651aa`
- 문서 검사: 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-trap-d5b1d6c8282545c38091660e1cc82d68/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0312`이며 작업명·범위는 착수 때 정한다.

## DEV-0312 문 임시 고정과 추적 지연 검사

현재 출정의 기존 오른쪽 우회 통로에 [시험 문](../../src/gameplay/interaction/temporary_door.tscn)을 처음에는 열린 상태로 둔다. E로 무료 개폐하며 플레이어나 골렘의 몸이 문에 걸리면 닫지 않는다. [시험 고정 데이터](../../src/data/prototype_door_hold.tres)는 공유 충전 1·고정 6초·해제 전 경고 1초·골렘 개방 경고 1.2초다. 문은 이동·시야·유인물과 현장 지도 관찰에 같은 충돌층 8을 사용한다. 새 방·보상·길찾기·벽 차음·저장 형식·최종 밸런스를 확정하지 않는다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/door_hold_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `door_hold_passed`와 종료 코드 0이다. 수치 유효성·실행 데이터 복사·기존 문 기본 동작, 출정 전 차단·실제 이동/E 개폐·몸이 걸린 문 닫힘 방지·충전 없는 무료 개방을 검사한다. Q 고정·공유 비용·중복·부족·만료 예고·고정 해제 후에도 닫힌 상태 유지, 골렘의 실제 이동 충돌·시야 차단·연속 접촉 경고·이탈과 방전 취소·만료 뒤 전체 경고·문 통과도 포함한다. 지도 관찰·유인물 투척 차단, 가방·지도 중 고정 및 개방 경고 정지, 거절 안내 갱신·귀환/실패·새 출정을 검사한다.

골렘 압력 비교는 두 별도 출정에서 검사 시작 위치와 이동 속도를 맞춘다. 이후 실제 이동·충돌 신호와 경고를 사용하며 검사에서만 경보 위치를 지정해 같은 문에 접근시킨다. 사람의 추적 난이도나 최종 시간 값을 판단한 자료가 아니다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --door-render-directory=<임시 폴더>`를 붙인다. 문 닫힘·고정·해제 임박·골렘 차단·개방 경고 화면 5장을 저장한다. 수동 확인은 위쪽 경로에서 오른쪽 우회로의 열린 문을 지나 몸을 충분히 뺀 뒤 E로 닫는다. 가까이서 Q를 누르면 충전 1을 써 잠시 고정한다. 문을 미는 골렘은 고정 중 통과할 수 없으며, 해제 뒤 다시 개방 경고가 나오므로 거리를 벌리거나 다른 경로로 돌아간다. 고정이 풀리면 E로도 무료 개방할 수 있다.

2026-09-21 최종 검증: **52/52 실행**(스모크 장면 29개 포함), 별도 그래픽 검사와 1152×648 화면 5장 통과. 엔진 오류·경고 없음. 기존 G1 비교·정산·저장·재실행 흐름을 유지했다. 첫 화면 검사에서 골렘 상태 글자가 문에 가려지고 문을 닫은 뒤 이전의 행동 거절 문구가 남는 문제를 발견해 표시 순서·글자 윤곽선·문맥 변경 시 거절 안내 해제를 보완했다. 같은 문맥의 거절 안내 유지와 문맥 변경 뒤 해제 검사를 추가하고 전체 검사를 다시 통과했다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260921-005532-d2897b921c5b49a28f94072feb010127/results.json`
- 검사 소스 SHA-256: `10b9a395c38c3d912e4ca381e98adfc8fd6f006d9c2bb75398e128ccc33e53f2`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-door-cb9f8b88a3914b5bb6229c6952a9cc56/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0313`이며 작업명·범위는 착수 때 정한다.

## DEV-0313 입구 방향과 관찰한 퇴로 안내 검사

현재 출정 HUD의 [입구 방향 안내](../../src/ui/return_route_status.gd)는 기존 지도의 입구·플레이어 위치와 마지막으로 관찰한 통로 수만 읽는다. 화면 변환을 반영한 화살표와 여덟 방향 문구를 표시하고, 실제 입구가 상호작용 대상으로 선택되면 E 귀환 안내로 바꾼다. 화살표는 통행 경로나 안전한 길을 보장하지 않는다. 열림·막힘·미확인 기록은 M 지도에서 위치와 함께 확인한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/return_route_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `return_route_passed`와 종료 코드 0이다. 여덟 방향·카메라 회전/이동·반전/비균일 배율·영벡터·잘못된 지도 바인딩과 표시 중 지도 상태 불변성을 검사한다. 실제 출정과 이동, 입구 선택·E 귀환, 열림/막힘 관찰과 지도 일치, 멀리서 달라진 문 비공개·재접근 갱신, 잔여 구역 발견·카메라 추적, 메뉴 숨김/정지, 귀환/실패 후 비우기·새 출정 초기화도 포함한다. 먼 문을 직접 여는 호출은 정보 경계를 검증하기 위한 검사 전용 설정이다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --return-render-directory=<임시 폴더>`를 붙인다. 입구·아래쪽 이동·문 관찰·잔여 구역·넓은 화면 5장을 저장한다. 기본 화면에서 붕괴 경고 범위·아래쪽 플레이어·경로 설명, 두 크기에서 뷰포트와 기존 조작 안내와의 겹침을 검사한다. 수동 확인은 출정 뒤 화면 왼쪽 아래의 방향을 보며 이동하고, 문을 가까이서 관찰한 뒤 M 지도와 기록을 비교한다. 입구에 돌아와 E 안내가 나타나면 실제 귀환한다.

2026-09-22 최종 검증: **53/53 실행**(스모크 장면 30개 포함), 별도 그래픽 검사와 1152×648·1600×900 화면 5장 통과. 엔진 오류·경고 없음. 첫 화면에서 안내판이 붕괴 위험을 가리는 문제를 발견해 작게 줄여 하단으로 옮기고 기존 경로 설명 위치를 보완했다. 기존 G1 비교·정산·저장·재실행 흐름을 유지했다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260921-223823-711fc9eb5670401e982fbb320f4672f4/results.json`
- 검사 소스 SHA-256: `98ea79a5270baa7c3c3745eef62b705fca6e45f3aa4dc5acdc84f56a55fce312`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-return-756fa45b63c444a5b15c4119f02c92ff/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0314`이며 작업명·범위는 착수 때 정한다.

## DEV-0314 인벤토리 무게 대비 가치 비교 검사

현재 출정 가방에서 확인된 일반 회수품의 `예상 가치 ÷ 무게`를 [Meta 계산](../../src/meta/item_value_comparison.gd)으로 구하고 목록·선택 상세에 표시한다. 무게 1당 소수 첫째 자리 근삿값이며 판매가를 바꾸지 않는다. 미확인 물품은 가치·실제 분류·보호 여부와 비교값을 숨긴다. 등록·정보 보상은 금전 비교에서 제외하고 무게 0은 나누지 않는다. 제외 문구·표시 자릿수는 시제품 방식이며 미정인 최종 표시·통화·정산 반올림 규칙은 유지한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/value_comparison_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `value_comparison_passed`와 종료 코드 0이다. 분수 무게·동일/범위 가치·0가치/0무게·잘못된 값과 계산 오버플로, 모든 분류의 미확인 상태·보호 물품·비금전 보상을 검사한다. 실제 이동·E 회수 뒤 목록과 상세의 비교값, 열람에 따른 순서·선택·명시적 빠른 버리기 대상·가치/가격 불변, 키보드와 마우스 선택, 일반 버리기 확인/취소·보호 거절·빠른 버리기의 개체 일치, 메뉴 정지·재열기·빈 가방·귀환/실패·새 출정을 확인한다. 검사 전용 물품과 감정 변경은 제품 콘텐츠나 서비스에 추가하지 않는다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --value-render-directory=<임시 폴더>`를 붙인다. 일반 회수품 비교·미확인/등록/무게 0·넓은 화면·빈 가방 4장을 저장한다. 두 줄 목록은 가방 너비에 맞추고 긴 위험 설명은 선택 상세에서 스크롤한다. 미확인 정보가 툴팁으로 노출되지 않는지도 검사한다. 수동 확인은 출정 후 위쪽 경로의 두 폐품을 E로 회수하고 Tab을 열어 총가치와 무게 1당 값을 함께 비교한다. 직접 고른 물품만 기존 G 길게 누르기의 대상이 된다. 기존 G1 장면은 이 표시를 켜지 않는다.

2026-09-22 최종 검증: **54/54 실행**(스모크 장면 31개 포함), 별도 그래픽 검사와 1152×648·1600×900 화면 4장 통과. 최종 실행의 엔진 오류·경고 없음. 초기 검사 스크립트의 타입 지정과 극단값 자료를 보완했고, 목록의 두 번째 줄이 잘리는 문제는 다중 행 표시 모드와 가방 너비 연결로 해결했다. 기존 탐험·정산·저장·재실행 검사를 유지했다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260921-225543-94551cdda5c047feb7b5f4b0ae3951ee/results.json`
- 검사 소스 SHA-256: `d7ca2fe52bdaccf7a119ccc0afc3ff267e6bb311d3dd4bcb87157f842d3e376b`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-value-e4f6668a25404a1aaba3c95bb9ef0d90/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0315`이며 작업명·범위는 착수 때 정한다.

## DEV-0315 인벤토리 분류 아이콘과 테두리 표시 검사

현재 출정 가방에서 [분류 표식 선택기](../../src/ui/item_category_icon.gd)가 미확인 회색·폐품 갈색·잔재 파란색·고유 유물 보라색·핵심 기록물 초록색 테두리의 서로 다른 모양을 표시한다. 기존 분류명·보호·가치 비교 문구를 함께 읽을 수 있다. 미확인 물품은 실제 분류·가격·보호와 관계없이 같은 물음표 아이콘을 사용한다. 감정 갱신은 기존 소유 시스템의 상태를 반영할 뿐 새 감정 기능을 만들지 않는다. 벡터 모양·색조·크기·배치는 시제품 UI다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 res://tests/smoke/item_category_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `item_category_passed`와 종료 코드 0이다. 모든 분류·보호 조합에서 미확인 표식이 같은지, 확인된 네 분류와 미확인 모양이 테두리 색 없이도 다른지 검사한다. 아이콘 조회·가방 열람의 상태 불변, 키보드 선택·버리기 확인·보호 거절·재구성 뒤 개체와 빠른 버리기 대상 일치, 감정 후 아이콘·문구 갱신, 빈 가방·재열기·일시정지 복구·실패 종료와 G1 기본 표시를 확인한다. 기존 가치 비교 검사도 전체 검사에 포함해 실제 회수·마우스 선택·빠른 버리기와 귀환/새 출정을 확인했다.

그래픽 확인은 첫 명령에서 `--headless`를 빼고 끝에 `-- --category-render-directory=<임시 폴더>`를 붙인다. 미확인/폐품/잔재·유물/기록물/보호 폐품·넓은 화면·긴 목록의 마지막 선택 4장을 저장한다. 기본 3칸 가방은 아이콘과 두 줄 문구 전체가 보이며 긴 목록은 선택 행이 따라 움직인다. 빠른 버리기 안내가 두 줄로 바뀌어 목록 높이가 줄어도 마지막 행 전체를 유지한다. 긴 설명은 기존 상세 스크롤로 읽는다. 수동 확인은 출정 후 위쪽 폐품을 회수해 Tab에서 갈색 표식·분류명·비교값을 확인하고, 미확인 조사 물품은 같은 회색 표식을 확인한다. 다른 분류와 8칸 긴 목록은 검사 전용 자료이며 제품 물품 배치를 추가하지 않는다.

2026-09-22 최종 검증: **55/55 실행**(스모크 장면 32개 포함), 별도 그래픽 검사와 1152×648·1600×900 화면 4장 통과. 엔진 오류·경고 없음. 초기 화면에서 발견한 기본 목록 잘림과 목록 재구성·높이 변경 후 선택 행 가림을 보완했다. 기존 탐험·정산·저장·재실행 검사를 유지했다. 구현·검증 완료, 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260921-231615-4e8c9209bc994366b3701b2d61089341/results.json`
- 검사 소스 SHA-256: `4ce746098848523ae1d7e7d0e6862eb82427c710e2d7c7fd8e779596c27839e1`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-category-ecf877b00d6e494f9e9d4b3800f024c1/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0316`이며 작업명·범위는 착수 때 정한다.

## DEV-0316 탐험 확장 통합 검증

[G3 통합 검토](g3_exploration_review.md)에 완료 조건별 근거·남은 범위와 수동 확인 순서를 기록했다. [새 통합 검사](../../tests/smoke/g3_exploration_flow_smoke.gd)는 기존 출정 데이터로 무료 우회와 제한 자원 경로를 실제 입력으로 진행한다. 회수·비교·빠른 버리기·귀환과 잔여 구역·함정·문·유인물·메뉴가 같은 출정에서 함께 작동하는지 확인한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/g3_exploration_flow_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 2 -TimeoutSeconds 60
```

성공 표시는 `g3_exploration_flow_passed`와 종료 코드 0이다. 화면 저장은 첫 명령의 `--headless`를 빼고 `-- --g3-render-directory=<새 임시 폴더> --g3-report-path=<새 임시 JSON 경로>`를 붙인다. 검사에서 원래 물품을 직접 회수하며 적 속도·자원·위험을 바꾸거나 순간 이동하지 않는다. 기존 `value_comparison_smoke.gd`의 도우미를 사용하지만 두 경로만 실행한다.

2026-09-22 최종 검증: 스모크 장면 33개를 포함한 전체 검사 두 차례 **110/110 실행**, 별도 그래픽 실행과 실제 화면 4장 확인. 두 경로 모두 회수품 2개·예상 가치 90~130으로 생환했고, 버리기 뒤 속도 132→192 px/s·소음 반경 260→180 px가 일치했다. 기본값으로 두는 시험 수치를 최종 밸런스로 확정하지 않는다. 엔진 오류·경고 및 예외 적용은 없었다. 소스는 검사 전후 동일하며 제품 코드와 저장 스키마는 변경하지 않았다. 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

골렘 접촉 손실·실패와 건강·부상은 미구현이므로 G3 전체 완료·실제 포착 회피 효과를 선언하지 않는다. 다음 보완 후보는 **DEV-0317 — 골렘 접촉 위험과 생존 피드백**이다.

- 전체 원본: [g3_automated_results.json](g3_automated_results.json), 당시 임시 경로 `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260921-233753-1ed903a2afe7486a8d410e33e1f55776/results.json`
- 그래픽 경로 측정: [g3_route_results.json](g3_route_results.json)
- 검사 소스 SHA-256: `d17b96de4ff05179c21e7b905f2619023287d84259370cedca96b2b13ff3ca4c`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개와 아카이브 사본 3개 일치, `git diff --check` 통과.
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-g3-52490ec93bfb4fdaa5a9a7785d4a9ccd/`
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. G1 사람 평가와 Q-004/Q-005는 유지한다.

## DEV-0317 골렘 접촉 위험과 생존 피드백 검사

현재 출정에 별도 접촉 판정을 연결했다. 시험 데이터는 중심 거리 34 px·연속 경고 1초다. 실제 가시 추적 때만 누적하고 첫 틱은 시간을 쓰지 않는다. 거리/시야 이탈·방전은 취소, 재접촉은 전체 경고, 메뉴는 정지, 종료 후에는 재활성화되지 않는다. 골렘의 기존 탐지·속도·비상 방전과 G1 비교 장면은 유지한다. `golem_capture` 원인은 이번 결과 화면에만 전달하며 저장 스키마에 추가하지 않는다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/golem_contact_smoke.tscn
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/g3_exploration_flow_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

각 성공 표시는 `golem_contact_passed`·`g3_exploration_flow_passed`이며 종료 코드 0과 엔진 오류·경고 없음도 함께 확인한다. 첫 검사는 의심 중 포착 금지·경고 선행·연속 접촉·취소/재접촉·방전/부족·메뉴 정지, 데이터 유효성·실행 복사본·출정 전후·적 삭제·중복 실패를 확인한다. 넓은 검사 전용 반경으로 문/벽의 시야 차단을 거리 조건에서 분리한다. 실제 물품 두 개를 회수한 뒤 같은 추적 배치와 기본 속도로 짐 유지 시 포착·버리기 시 탈출을 비교한다. 이 검사 배치는 제품 콘텐츠가 아니다.

타이틀 이어하기→출정→포착 실패→결과→거점 저장→새 출정도 검사한다. 기존 거점 보유분을 먼저 정산·저장한 자료를 사용하고, 이번 미확인·보호 물품 두 개는 손실되되 과거 보유금·보관품은 저장·복원 후 그대로인지 확인한다. 새 출정에서 접촉 경고와 가방·충전이 초기화되며 이후 안전 귀환에 포착 원인이 남지 않는다.

그래픽 확인은 접촉 명령의 `--headless`를 빼고 `-- --contact-render-directory=<새 임시 폴더>`를 붙인다. 접촉 경고·Q 방전·짐 버리기 후 계속 이동하는 탈출·포착 실패 결과의 4장을 저장한다. 두 번째 명령은 `-- --g3-render-directory=<새 임시 폴더> --g3-report-path=<새 임시 JSON 경로>`로 수정한 통합 경로 화면 4장과 측정값을 저장한다. 경고 UI는 평상시 안내와 자리를 공유하고 적재 HUD 및 캐릭터를 가리지 않는다.

2026-09-24 최종 검증: Godot 4.7.1 **57/57 실행**, 스모크 장면 34개와 출정·정산·저장·별도 프로세스 복원 분기 통과. 엔진 오류·경고 및 예외 적용 없음. 별도 그래픽 검사 두 개와 1152×648 화면 8장을 확인했다. 통합 경로는 두 개 모두 생환·2개 회수·예상 가치 90~130이며 속도/소음·충전/도구 결과가 headless와 일치한다. 구현·검증 완료, 검증 결과 검토 후 사용자가 로컬 커밋을 승인했다.

- 전체 검사 원본: [dev0317_automated_results.json](dev0317_automated_results.json), 임시 경로 `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260924-091500-7e6e77bb5e464c28b30f7fc1a3cef33d/results.json`
- 검사 소스 SHA-256: `36adfb1a4176151190da6cebd1c680cf07a4d0c28d37d6aa8f4a9ebba37d0d49` — 검사 전후 같은 바이트. 문서 및 다른 환경의 줄바꿈까지 보증하는 해시가 아니다.
- 그래픽 경로 측정: [dev0317_route_results.json](dev0317_route_results.json)
- 화면 원본: `C:/Users/user/AppData/Local/Temp/dungeon-dev0317-d62d861e461440628aeb029c687f4198/`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개, `git diff --check` 통과.
- 정합성 검사: 아직 아님 — 다음 정기 검사는 G5 완료 후. 다음 번호는 `DEV-0318`이며 남은 생존 규칙과 시제품 범위를 착수 때 정리한다. G3 전체 완료는 선언하지 않으며 사람 평가·Q-004/Q-005·최종 수치는 기존 후속 상태를 유지한다.

## DEV-0318 생존 규칙과 시제품 범위 정리 검사

2026-09-24 [생존 규칙 검토안](../design/survival_rules.md)을 `draft`로 작성했다. GDD·confirmed Design의 요구, 현재 구현과 새 제안의 경계를 [G3 대조표](g3_exploration_review.md#dev-0318-생존-규칙-범위-대조)에 기록했고, Q-019~Q-021과 [후속 작업 순서](development_handoff.md#dev-0318--생존-규칙과-시제품-범위-정리)를 연결했다. 기존 DEC-103~105·109와 Q-014를 새 피해/치료/탈출 수치의 승인 근거로 확장하지 않았다.

이번 검증 대상은 문서다. `src`·`tests`·`project.godot`와 기존 검증 JSON을 변경하지 않았으며 게임·그래픽 자동 검사를 재실행하지 않았다. DEV-0317의 57/57과 화면 8장은 이전 작업에서 얻은 근거다. 소스 일치는 다음과 같이 확인한다.

```powershell
. ./tests/run_g2_checks.ps1
$survivalSourceHash = Get-G2SourceHash (Get-Location).Path
$survivalBaseline = Get-Content -Raw ./docs/project/dev0317_automated_results.json | ConvertFrom-Json
if ($survivalSourceHash -ne $survivalBaseline.source_tree_sha256) {
    throw 'DEV-0317 검증 소스와 현재 소스가 다릅니다.'
}
git diff --check
git diff --name-only
```

검증 시점 소스 SHA-256은 `36adfb1a4176151190da6cebd1c680cf07a4d0c28d37d6aa8f4a9ebba37d0d49`로 기존 보고서와 같다. 바이트 기준 해시이므로 다른 환경의 줄바꿈까지 보증하지 않는다. 문서 대조에서는 건강 잔량과 부상 시간, 함정 주기별 중복 통지, 기존 골렘/붕괴 실패, 즉시 E 처리와 향후 작업 시간, 실제 통로와 마지막 관찰 기록, 실패 손실과 저장 소유권을 확인했다. 검토안을 구현 완료나 확정 설계로 표기하지 않았고 새 질문의 근거·후속 검토 시점을 적었다.

활성 Markdown 상대 링크·앵커, 새 문서의 Front Matter/상태·책임·진입 링크, 동결 원본 SHA-256 6개·아카이브 사본 3개 및 `git diff --check`를 확인했다. 다음은 `DEV-0319 — 건강·부상 상태와 HUD`다. 문서 작성·검증 완료, 사용자 로컬 커밋 승인. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후이며 G3 전체 완료·사람 평가·최종 수치를 새로 승인하지 않는다.

## DEV-0319 건강·부상 상태와 HUD 검사

건강 2·함정 피해 1·부상 6초·이동 0.9는 현재 출정의 시험 데이터다. [생존 검사](../../tests/smoke/player_survival_smoke.gd)는 유효/잘못된 값·실행 복사본, 출정 전/종료 뒤 입력 차단, 반복 부상의 시간 갱신, 만료 뒤 건강 미회복을 확인한다. 정상/부담/과적의 실제 직선·대각선 속도/거리와 기존 걸음 소음, 실제 가방 선택·이동 중 버리기·메뉴 정지를 검사한다. 이동 측정에 한해 골렘을 정지해 영향을 분리한다.

함정 재진입 검사는 기본 작동 시간 0.45초 안에 실제 이동으로 나갔다 들어와도 피해가 한 번인지 확인한다. 이 검사는 플레이어를 함정 근처에 배치하고 함정을 활성화해 경계를 분리하며, 기존 `malfunctioning_trap_smoke`는 원래 입구에서 실제 이동·Q·발견을 거치는 경로도 그대로 검사한다. 첫 피해는 건강 1·탐험 계속, Q 정지 뒤 다음 피해는 건강 0·실패다. 방전·버리기는 치료하지 않고, 종료 경합은 먼저 수락된 결과를 유지한다.

앱 검사는 임시 저장을 이어하기→출정→실제 함정의 두 번 피해→결과→거점 정산/저장→새 출정으로 진행한다. 첫 피해는 현재 회수품을 유지하고 두 번째 피해는 미확인·보호 물품 2개를 잃는다. 이전 보유금·보관품은 저장·복원 후 같고 저장 키 집합도 같다. 새 출정에서 건강 2·부상 없음·빈 가방·충전 3을 확인하고 붕괴가 기존 경고 뒤 건강 잔량과 무관하게 실패시키는 것도 확인한다. 골렘의 경고·포착/취소와 G1·기본 통합 경로는 전체 회귀 검사에서 확인한다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/player_survival_smoke.tscn
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/malfunctioning_trap_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `player_survival_passed`·`malfunctioning_trap_passed`와 종료 코드 0, 엔진 오류·경고 없음이다. 첫 명령에서 `--headless`를 빼고 끝에 `-- --survival-render-directory=<새 임시 폴더>`를 붙이면 화면 7장을 저장한다. 부상/짐 버리기/만료/넓은 화면, 실제 함정 Q 대응, 부상과 골렘 접촉 경고, 건강 소진 실패 결과를 확인한다. 건강 줄을 맨 위로 옮겨 기존 북쪽 경로 설명과 캐릭터를 가리지 않게 했고 접촉·적재·버리기 표시도 분리했다.

2026-09-25 최종 검증: Godot 4.7.1 **58/58 실행**, 스모크 장면 35개 포함. 엔진 오류·경고 및 예외 적용 없음, 검사 전후 소스 동일. 별도 그래픽 검사와 1152×648·1600×900 화면 7장 통과. 자동 검사는 시험 규칙의 동작 근거이며 사람 평가·최종 수치의 근거로 대신하지 않는다. 구현·검증 완료, 사용자 로컬 커밋 승인.

- 전체 검사 원본: [dev0319_automated_results.json](dev0319_automated_results.json)
- 검사 임시 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260925-121940-e865c97e5e884e678c7d97dc2f1be8da/results.json`
- 검사 소스 SHA-256: `cf8b1fb1c8932a17959ab2759b4e3466e3a36e798b92a27cd8fb8e43f38f6345` — 실행 소스의 바이트 기준이며 문서·다른 환경의 줄바꿈까지 보증하지 않는다.
- 최종 화면/실행 로그: `C:/Users/user/AppData/Local/Temp/dungeon-dev0319-final-a19f1c6c72604ec18a786eec7442a6a8/`
- 문서 검사: 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개, `git diff --check` 통과.
- 다음은 DEV-0320 — 부상의 조사·회수 시간. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후. G3 전체 완료·사람 평가·최종 밸런스는 후속이다.

## DEV-0320 부상의 조사·회수 시간 검사

[시간 검사](../../tests/smoke/interaction_timing_smoke.gd)는 현재 출정의 실제 E 입력으로 물품 조사→별도 회수, 공략도 읽기, 정상/부상 시간과 도중 효율 변화를 확인한다. 시험 값은 조사 0.8초·회수 0.4초·부상 효율 0.5다. 데이터 유효성·복사본, 완료 전 정보/물품 미지급과 미확인 상태 보존, E 취소·키 반복 무시, 범위 이탈·대상 교체/삭제/비활성화·외부 조사 단계 변경·가방 공간 변화·메뉴·종료 취소를 검사한다. 취소 뒤 재시작은 0부터이고 완료 신호의 제어기/대상 재호출은 중복 지급하지 않는다.

기능 검사의 일부 위치와 골렘 정지는 시간·취소 조건을 분리한 배치다. 기본 통합 탐험 경로의 적·이동·자원·작업 시간은 그대로 유지했다. 기존 현재 출정 검사 9개 파일에는 [완료 대기 도우미](../../tests/helpers/interaction_test_input.gd)를 사용하고 즉시 회수 가정을 제거했다. 버퍼에 남은 입력을 먼저 처리하며, 공략도 안내 검사는 추가된 시간 표시까지 확인한다. G1 비교 장면과 문·귀환·Q·G의 기존 처리는 유지했다.

```powershell
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/interaction_timing_smoke.tscn
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 18000 res://tests/smoke/g3_exploration_flow_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `interaction_timing_passed`·`g3_exploration_flow_passed`, 종료 코드 0과 엔진 오류·경고 없음이다. 첫 명령에서 `--headless`를 빼고 `-- --timing-render-directory=<새 임시 폴더> --timing-report-path=<새 임시 JSON 경로>`를 붙이면 화면 6장과 물리 프레임 측정을 저장한다. 정상/부상의 조사·회수 진행, 1600×900 조사, 취소 후 안내를 확인했다. 진행률·남은 시간·취소 문구와 상단 건강/효율이 잘리지 않고 기존 위험·적재·귀환 안내를 가리지 않는다.

2026-09-25 최종 검증은 Godot 4.7.1 전체 **59/59 실행**, 스모크 장면 36개 포함이다. 엔진 오류·경고·예외 적용 없음, 검사 전후 소스 동일. 그래픽 검사는 1152×648·1600×900 화면 6장을 확인했다. 측정은 정상 조사/회수 48/25 프레임, 부상 조사/회수 97/48 프레임이며 60 fps의 프레임 경계 오차를 허용한다. 부상 발생/해제 도중에는 현재 속도만 반영하고 건강·진행량을 임의 복원하지 않는다. 기본 통합 경로 두 개의 생환·회수/속도/소음/자원 결과와 기존 저장·재출정 검사를 통과했다.

- 전체 검사 원본: [dev0320_automated_results.json](dev0320_automated_results.json)
- 전체 임시 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260925-134715-58e20df9fa9b473bac8abec6163f7f8b/results.json`
- 검사 소스 SHA-256: `c5ef5a9071e2f05a74ad10cc715d85d071c4cc6f3d1d40c463eaa5c0305ae59c` — 실행 소스 바이트 기준이며 문서·다른 환경 줄바꿈까지 보증하지 않는다.
- 그래픽 시간 측정: [dev0320_timing_results.json](dev0320_timing_results.json)
- 화면·로그 원본: `C:/Users/user/AppData/Local/Temp/dungeon-dev0320-289e392795a84e2984eca392ffcdfef2/`
- 문서 검사: 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.
- 구현·검증 완료, 사용자 로컬 커밋 승인. 다음은 **DEV-0321 — 퇴로 변화와 대체 길**이다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후. 사람 평가·최종 수치는 후속이며 G3 전체 완료를 선언하지 않는다.

## DEV-0321 퇴로 변화와 대체 길 검사

[직접 플레이 장면](../../tests/fixtures/retreat_route_test_space.tscn)은 기존 기본 출정을 상속해 위쪽 연결의 변화만 추가한 별도 공간이다. 직접 열면 가방 3칸·충전 3으로 출정하고 귀환/실패 결과 뒤 새 시험 출정을 할 수 있다. 기본 거점 출정은 바꾸지 않았다. [자동 검사](../../tests/smoke/retreat_route_smoke.gd)는 같은 공간의 실제 WASD·E·Q·Tab·M 입력으로 경고 중 복귀와 차단 후 우회·원래 입구 귀환을 비교한다.

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/retreat_route_test_space.tscn
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 12000 res://tests/smoke/retreat_route_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `retreat_route_passed`와 종료 코드 0, 엔진 오류·경고 없음이다. 두 번째 명령에서 `--headless`를 빼고 `-- --retreat-render-directory=<새 임시 폴더> --retreat-report-path=<새 임시 JSON 경로>`를 붙이면 화면 6장과 경로 측정을 저장한다. 열린 통로·3초 경고·관찰 전 지도·차단 재관찰·넓은 화면·귀환 결과를 확인한다.

2026-09-25 최종 자동 검사 **60/60 실행**, 스모크 장면 37개 포함. 직접 플레이 장면 시작도 별도 실행에서 오류 없이 통과했다. 그래픽 검사의 1152×648·1600×900 실제 화면 6장을 확인했고 결과 화면은 불투명 패널로 배경 글자와 구분했다. 2026-09-26 문서 검증을 마쳤다. 경고 중 귀환은 약 0.8초를 남겼고, 차단 후 우회는 측정 1472 물리 프레임에 물품 1개·예상 가치 10~20·건강 2/2·충전 2로 생환했다. 프레임 수는 자동 입력·대기 길이이며 사람의 플레이 시간이나 최종 난이도 근거가 아니다.

- 데이터 검사: 0·음수·비유한 경고 시간 거절, 실행 복사본 보존, 중복 시작/종료 후 재시작 거절.
- 차단 경계: 플레이어/골렘 충돌 계층의 몸이 통로 안에 있으면 보류, 몸이 빠진 뒤 물리 차단. 이 구성 요소 비교만 별도 배치를 사용한다.
- 경로 검사: 실제 이동·회수·문 닫기/열기·Q 방전·붕괴 통과·입구 E 귀환. 골렘·위험·이동 수치를 바꾸거나 순간 이동해 우회하지 않았다. 물품과 건강·자원 결과를 확인했다.
- 정보/수명: 멀리서 차단된 길의 옛 열림 기록과 재관찰 갱신, 메뉴 정지/재개, 실패·귀환 후 사건 정지, 새 출정의 열린 통로·미관찰 지도. 막힌 통로 하나나 닫힌 문만으로 탐험을 실패시키지 않는다.
- 전체 결과: [dev0321_automated_results.json](dev0321_automated_results.json)
- 그래픽 경로 측정: [dev0321_route_results.json](dev0321_route_results.json)
- 전체 임시 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260925-145746-7fc1edf132c74577a58c63ec1cf57447/results.json`
- 검사 소스 SHA-256: `479469116b739d55ccfcedadacbd9a3b3f8d738ace3f448acf881a79431a6292` — 실행 소스 바이트 기준이며 문서·다른 환경 줄바꿈까지 보증하지 않는다.
- 화면·로그: `C:/Users/user/AppData/Local/Temp/dungeon-dev0321-final-d349fdf3c7f84ac68813c84bd898c2e4/`
- 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개, `git diff --check` 통과.
- 구현·검증 완료, 사용자 로컬 커밋 승인. 다음 **DEV-0322 — 비상 탈출**, 이후 **DEV-0323 — G3 보완 통합 검토** 통과 후 G4 전환 계획. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후이며 사람 평가·최종 수치는 후속이다.

## DEV-0322 비상 탈출 검사

[직접 플레이 장면](../../tests/fixtures/emergency_escape_test_space.tscn)은 기존 퇴로 공간을 상속하고 위·아래 연결의 차단과 탈출 지점을 추가한 별도 공간이다. 직접 열면 가방 3칸·충전 3으로 출정한다. 위쪽 길로 안쪽에 진입하면 두 연결이 3초 경고 후 차단되며, 퇴로 상실 후 20초 안에 청록색 탈출 지점에서 E로 4초 준비를 마친다. 성공 시 충전 1을 써 회수품을 유지하며 결과 뒤 새 시험 출정을 할 수 있다. 기본 거점 출정의 자동 사건으로 적용한 것은 아니다.

```powershell
& $env:GODOT_BIN --path . res://tests/fixtures/emergency_escape_test_space.tscn
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 12000 res://tests/smoke/emergency_escape_smoke.tscn
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

두 번째 명령의 성공 표시는 `emergency_escape_passed`, 종료 코드 0과 엔진 오류·경고 없음이다. `--headless`를 빼고 `-- --escape-render-directory=<새 임시 폴더> --escape-report-path=<새 임시 JSON 경로>`를 붙이면 경고·퇴로 상실·준비·넓은 화면·성공·시간 초과 화면 6장과 결과를 저장한다. 탈출 안내에는 불투명 배경과 두 줄 높이를 주어 배경 글자와의 겹침·화면 경계 잘림을 방지했다.

2026-09-28 최종 Godot 4.7.1 전체 **61/61 실행**, 스모크 장면 38개 포함. 검사 전후 실행 소스 동일, 엔진 오류·경고·예외 적용 없음. 직접 플레이 장면 시작과 그래픽 검사도 종료 코드 0이며 1152×648·1600×900 실제 화면 6장을 확인했다. 첫 전체 실행은 새 스크립트 UID 생성으로 소스 동일성 검사를 통과하지 못해 최종 근거에서 제외했고, 화면 보완과 UID 생성이 끝난 소스로 전체 검사를 확정했다.

- 실제 경로: WASD·E 입력으로 한 길 차단·두 길 차단·입구 쪽 후퇴·회수와 탈출을 비교했다. 한 길이 남거나 다시 열 수 있는 내부 문만 닫히면 제한 시간이 시작되지 않는다. 지도에는 미관찰 차단을 자동 기록하지 않는다.
- 취소·시간: E 재입력·이동·메뉴·피해·대상 비활성/범위 변경·다른 충전 사용을 확인했다. 메뉴는 제한 시간을 정지하고 준비를 취소하며 다시 시작하면 4초다. 실제 연결 복구는 제한을 지우고 재차단은 20초로 시작한다. 같은 틱에 만료와 완료가 걸리면 실패 우선이다.
- 성공: 실제 가벼운 폐품 회수와 별도 경계 자료인 미확인/보호 물품을 합쳐 3개 상태를 보존했다. 충전 3→2, 결과 1회, 정산 보유금 10·보관 2개를 확인했다. 시간 초과에서는 이번 물품 1개만 잃고 기존 돈·보관품과 거점 저장 데이터 변환을 유지했다. 새 방문은 충전 3·빈 가방·제한 없음이다.
- 경계 자료: 보호 여부는 기존 카탈로그의 검사 전용 복사본에만 적용한다. 피해·다른 자원 소비·대상 이동·실제 연결 복구·기존 실패 경합은 각 조건을 직접 발생시켜 분리 검사하고, 같은 틱 판정은 한 큰 물리 틱으로 검증한다. 실제 위험 접근·함정/골렘/붕괴와 파일 저장·이어하기는 전체 회귀 검사에서 별도로 확인한다. 이 경계 배치를 사람 플레이나 최종 난이도 근거로 해석하지 않는다.
- 전체 원본: [dev0322_automated_results.json](dev0322_automated_results.json)
- 탈출 결과: [dev0322_escape_results.json](dev0322_escape_results.json)
- 전체 임시 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260928-072545-bf67034c2c6d4aea9b412e8f188ded93/results.json`
- 검사 소스 SHA-256: `7892143ca6a25a9199b46d8fa25f45b62558b31b42a51be78d819f898f3e990b` — 실행 소스 바이트 기준이며 문서·다른 환경 줄바꿈까지 보증하지 않는다.
- 화면·로그: `C:/Users/user/AppData/Local/Temp/dungeon-dev0322-final-a6b0654e9e524e5db0a0cece15326bc9/`
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.
- **구현·검증 완료, 사용자 로컬 커밋 승인.** 다음이자 마지막 **DEV-0323 — G3 보완 통합 검토** 통과 후 G4 전환 계획. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후이며 사람 평가·최종 수치는 후속이다.

## DEV-0323 G3 보완 통합 검토 검사

[통합 스모크](../../tests/smoke/g3_survival_flow_smoke.gd)는 [검사 전용 앱](../../tests/fixtures/g3_review_entry.gd)에서 실제 앱의 출정·결과·정산·저장 흐름을 사용한다. 이전 거점 자료(돈 40·가방 3칸·미확인 보관품 1개)를 독립 임시 파일로 준비하고, 현재 회수품은 실제 이동과 E 입력으로 얻는다. 기본 출정에서 함정 피해·부상 중 회수·원래 입구 귀환을, 기존 비상 탈출 공간에서는 실제 두 연결 차단·탈출 성공/제한 시간 초과를 진행한다. 제품 코드에는 출정 생성 메서드만 분리했으며 기본 거점 출정의 자동 사건은 추가하지 않았다.

```powershell
$reviewDirectory = Join-Path $env:TEMP ('dungeon-g3-review-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/g3_survival_flow_smoke.tscn -- "--review-progress-directory=$reviewDirectory"
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/g3_survival_flow_smoke.tscn -- --review-continue "--review-progress-directory=$reviewDirectory"
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 2 -TimeoutSeconds 60
```

쓰기 검사는 새 폴더만 받으며 `flow-results.json`을 남긴다. 다음 명령은 같은 폴더의 실제 저장 파일을 **새 프로세스**에서 이어하고 `continue-results.json`을 남긴다. 성공 표시는 각각 `g3_survival_flow_passed write`·`g3_survival_flow_passed continue`, 종료 코드 0이다. 첫 실행에서 `--headless`를 빼고 `--` 뒤에 `"--review-render-directory=$reviewDirectory"`를 추가하면 실제 화면 6장을 저장한다. 검사 폴더의 임시 저장 경로에 빈 디렉터리를 잠깐 만들어 실제 쓰기 실패를 발생시키고 같은 경로만 제거한 뒤 재시도한다. 사용자 진행 파일은 읽거나 덮어쓰지 않는다.

2026-09-28 Godot 4.7.1 최종 **124/124 실행**, **2회 반복**, 스모크 장면 **39개**를 포함한다. 공통 버전/프로젝트 import 2개와 반복마다 61개씩이며, 기존 실행기에 새 통합 장면과 파일 이어하기를 넣었다. 실행 소스는 검사 전후 동일하고 엔진 오류·경고·진단 예외 적용은 없다. 결과 JSON의 `scope` 문자열은 재사용한 G2 실행기의 역사적 이름이며 검증 범위는 실제 `checks` 목록을 따른다. 거점 안내 정정 전의 첫 124개 통과 결과는 최종 소스 근거로 사용하지 않았다.

- 정상 귀환: 실제 함정 피해 뒤 건강 1, 부상 중 가방 취소/정지와 회수 시간 감소율 확인, 회수 2개·충전 1, 보유금 40→80.
- 비상 탈출: 실제 회수 1개 보존·충전 3→2·결과 1회. 결과 확인 전후 저장 파일 동일. 저장 실패 때 결과와 돈 80/기존 파일 유지, 재시도·중복 클릭 후 돈 90·미확인 보관품 1개 유지.
- 시간 초과: 이번 회수품 1개만 손실·충전 3·결과 1회, 돈 90·기존 보관품 유지. 이어서 기본 출정은 건강 2·부상 0·충전 3·빈 가방·관찰 0·시험 통로 사건 없음.
- 새 프로세스 이어하기: 돈 90·가방 3칸·미확인 상태/위험 안내 유지, 새 출정/빈 귀환까지 통과. 쓰기 경로의 다음 출정 ID 5, 이어하기 후 6. 저장 키는 기존 4개를 유지.
- 그래픽: 종료 코드 0·표준 오류 없음. 1152×648·1600×900 화면 6장에서 건강·진행, 탈출 성공, 시간 초과 손실, 저장 재시도, 돈/보관품과 정정된 적재 안내를 확인했다. 시험 지형 라벨과 진행 안내 일부 겹침은 후속 화면 다듬기로 명시했으며 사람 가독성/난이도 평가는 미실시다.
- 전체 원본: [dev0323_automated_results.json](dev0323_automated_results.json)
- 그래픽 통합 결과: [dev0323_flow_results.json](dev0323_flow_results.json)
- 새 프로세스 결과: [dev0323_continue_results.json](dev0323_continue_results.json) — 전체 검사 1회차의 독립 프로세스 기록이다.
- 전체 임시 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260928-093843-52dbbfdd02a7467ba3a9e0801f349d69/results.json`
- 검사 기준 HEAD: `8278e7d`와 이번 작업 트리. 소스 SHA-256: `26118e5bfa12704bec012df4412ce651a176f50b45b768015fcb3ba97a4446df` — `src`·`tests`·`project.godot` 바이트 기준이며 문서나 다른 환경의 줄바꿈까지 보증하지 않는다.
- 화면·로그: `C:/Users/user/AppData/Local/Temp/dungeon-dev0323-final-92db1e60eb424decb7547c4811f2f30d/`
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.

**DEV-0323 검토 완료·사용자 로컬 커밋 승인, 시제품 기술 범위에서 G3 완료.** 다음은 **DEV-0401 — 거점 감정과 미확인 물품 처리**다. 기본 출정과 별도 퇴로 공간의 적용 범위·최종 수치·사람 평가 후속은 [G3 판정](g3_exploration_review.md#dev-0323-g3-보완-통합-검토)을 따른다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0401 거점 감정과 미확인 물품 처리 검사

[감정 스모크](../../tests/smoke/hub_appraisal_smoke.gd)는 실제 `main.tscn`의 거점·출정·정산·저장을 사용한다. 초기 돈 10·같은 종류의 미확인 3개·가방 3칸은 임시 저장 자료다. 실제 출정에서는 기존 두 일반 회수품과 미확인 물품을 이동·E 조사/회수·Q 대응·입구 귀환으로 얻는다. 보호·고유 유물·핵심 기록물·가격 변경 경계는 제품 카탈로그를 바꾸지 않는 검사 전용 복사본을 사용한다.

```powershell
$appraisalDirectory = Join-Path $env:TEMP ('dungeon-appraisal-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_appraisal_smoke.tscn -- "--appraisal-directory=$appraisalDirectory"
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_appraisal_smoke.tscn -- --appraisal-continue "--appraisal-directory=$appraisalDirectory"
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `hub_appraisal_passed write`와 `hub_appraisal_passed continue`, 종료 코드 0이다. 첫 실행은 새 폴더만 사용하고 두 번째는 같은 파일을 새 프로세스에서 이어한다. 화면 검사는 첫 명령의 `--headless`를 빼고 `--` 뒤에 `--appraisal-render`를 추가한다. `insufficient`·`quote`·`retry`·`identified` 화면을 각각 1152×648·1600×900으로 저장한다. 저장 실패는 이 검사 폴더의 `progress.json.tmp`에 빈 디렉터리를 만들고 재시도 전에 그 디렉터리만 제거해 재현한다. 기본 사용자 진행 파일을 읽거나 덮어쓰지 않는다.

2026-09-29 최종 소스의 Godot 4.7.1 전체 **65/65 실행**, 스모크 장면 **40개**와 새 프로세스 이어하기를 포함한 1회 검사가 통과했다. 실행 전후 소스 해시가 같고 엔진 오류·경고·진단 예외 적용은 없다. 그래픽 실행도 종료 코드 0이며 두 해상도 화면 **8장**에서 목록 줄바꿈·선택 강조·비용·부족 금액·실패 재시도·완료 안내를 확인했다. 목록은 스크롤하여 나머지 보관품을 읽는다. 초기 검사에서 찾은 줄바꿈/키 안내 문제와 검사 자료 공유 문제는 보완 후 재검증했으며 이전 실행을 최종 근거로 합산하지 않는다.

- 감정 계산: 빈/잘못된/중복 위치, 이미 감정한 대상, 탐험 중 요청을 거절한다. 복사본 분리·같은 종류 중 정확한 개체·오래된 거점/가격 견적·잔액 부족·0 비용·정확한 잔액·정수 최댓값/초과를 확인했다.
- 보호/정보: 감정 전 숨은 분류·가치·보호 비공개, 감정 후 실제 분류·기존 예상 가치 공개, 비금전 물품의 등록·정보 보상, 보호 분류의 기존 판매 차단과 저장 후 보호 유지를 확인했다.
- 실제 UI: Ctrl+클릭 복수 선택·Space 선택 전환·전체 선택, Esc/거점으로 취소·재열기 초기화, 감정 중 출정/가방 변경 차단, 이미 감정한 물품과 대상 없음의 재결제 차단을 확인했다.
- 저장/순환: 3개 비용 15·돈 10의 전체 거절 → 두 번째 물품 1개 비용 5 확인 → 취소 → 다시 확인 → 파일 쓰기 실패에서 돈 10/모든 미확인/기존 파일 보존 → 재시도·중복 요청 뒤 돈 5/선택한 1개만 감정 → 실제 탐험 정산으로 돈 45/보관 4개 → 남은 3개 비용 15로 감정하여 돈 30/감정 완료 4개 보관. 재출정·빈 귀환과 새 프로세스 이어하기 뒤에도 같은 돈·물품·위험 안내가 유지된다.
- 기존 저장 스키마 1·거점 4필드·물품 3필드를 유지하며 설정 파일은 변하지 않았다. 새 실행에서도 감정 비용이나 기존 정산액을 다시 반영하지 않는다.
- 원본: [전체 자동 검사](dev0401_automated_results.json), [그래픽 실행의 감정/저장 결과](dev0401_appraisal_results.json), [새 프로세스 이어하기](dev0401_continue_results.json).
- 전체 결과 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260929-095911-a674601ca7e146089a4731eaa41ef2b7/results.json`
- 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0401-verified-8b77fe5173834f06a3dc7b48ebae89a1/`
- 검사 기준 HEAD: `43414c6`와 이번 작업 트리. `src`·`tests`·`project.godot` 소스 SHA-256: `e854fe8147b83a5a5bd2aba51c425e4a0d0ffdcd4e565809f4e6a99803d6e5cb`.
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.

**DEV-0401 구현·검증 완료, 사용자 로컬 커밋 승인.** 개당 비용 5·즉시 처리는 시제품이며 최종 가격·시간·일괄 보정·Q-017 비용 명칭은 확정하지 않는다. 자동 판매·보관품 판매 서비스·등록·연구·수리·성장·휴대용 감정은 후속이다. 다음 **DEV-0402**의 이름·범위는 다음 착수 때 정한다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0402 거점 보관품 판매 검사

[판매 스모크](../../tests/smoke/hub_sale_smoke.gd)는 실제 앱의 감정·판매·출정·정산·저장을 사용한다. 초기 돈 10·가방 3칸·보관품 4개(미확인 1·감정한 같은 종류 2·가벼운 폐품 1)는 독립 임시 저장 자료다. 추가 물품은 실제 WASD 이동·E 조사/회수·Q 대응·입구 귀환으로 얻는다. 보호/비금전 분류·가격 변경·정수 한도는 제품 자원을 바꾸지 않는 별도 검사 복사본에 적용한다.

```powershell
$saleDirectory = Join-Path $env:TEMP ('dungeon-sale-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_sale_smoke.tscn -- "--sale-directory=$saleDirectory"
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_sale_smoke.tscn -- --sale-continue "--sale-directory=$saleDirectory"
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `hub_sale_passed write`·`hub_sale_passed continue`, 종료 코드 0이다. 첫 실행은 새 폴더를 사용하며 다음 명령은 같은 파일을 새 프로세스에서 이어한다. 첫 명령에서 `--headless`를 빼고 `--` 뒤에 `--sale-render`를 추가하면 `quote`·`retry`·`sold`·`empty` 화면을 각각 1152×648·1600×900으로 저장한다. 저장 실패는 검사 폴더의 `progress.json.tmp`에 빈 디렉터리를 만들어 재현하고 재시도 전에 그 빈 디렉터리만 제거한다. 기본 사용자 진행 파일은 읽거나 덮어쓰지 않는다.

2026-09-29 최종 Godot 4.7.1 전체 **67/67 실행**, 스모크 장면 **41개**와 새 프로세스 이어하기를 포함한 1회 검사가 통과했다. 버전/프로젝트 가져오기 2개와 흐름 검사 65개이며, 기존 실행기의 역사적 `scope` 표기보다 실제 `checks` 목록을 따른다. 검사 전후 소스 해시는 같고 엔진 오류·경고·진단 예외 적용은 없다. 그래픽 검사도 종료 코드 0이며 실제 화면 **8장**에서 선택 강조·판매가/수입·실패 재시도·완료·빈 보관함 안내와 버튼을 확인했다. 긴 목록은 스크롤한다. 초기 키보드 검사에서는 Home의 동작을 잘못 가정한 검사 코드를 수정했고, 화면 안내대로 방향키/Space의 선택·해제를 확인했다. 실패했던 초기 실행은 최종 통과 횟수에 합산하지 않는다.

- 계산/대상: 선택 없음·범위 밖·중복·미확인·미확인 혼합·보호·비금전·가격 미설정·음수 가격을 거절한다. 명시적 0 가격은 처리하고 정확한 정수 최댓값·합계/잔액 초과를 검사했다. 반환 복사본 수정과 같은 종류의 다른 개체가 원본에 영향을 주지 않는다.
- 재검증: 같은 수입 합계라도 개별 가격이 달라지면 거절한다. 감정·가방 변경·출정 이후의 오래된 견적과 재사용을 거절한다. 미확인에는 숨은 보호/분류/가격을 노출하지 않는다.
- 입력: 실제 클릭·Ctrl+클릭·방향키/Space, Esc·선택으로 돌아가기·거점으로 취소, 재열기 초기화, 감정/판매 상호 배제와 출정/가방 변경 차단을 확인했다.
- 저장/순환: 돈 10/보관 4개에서 첫 감정품의 판매를 취소한 뒤 다시 확인한다. 저장 실패에서 기존 파일/돈/물품을 유지하고 재시도·중복 요청 뒤 돈 210/보관 3개가 된다. 같은 종류의 남은 개체와 폐품을 복수 판매해 돈 420/미확인 1개, 감정 비용 5 후 판매 200으로 돈 615/빈 보관함을 확인했다. 실제 탐험에서 폐품과 미확인을 회수하여 돈 625/미확인 1개, 감정·판매 뒤 돈 820/빈 보관함이 된다. 이후 실제 회수품이 있는 탐험 실패에서도 기존 돈 820과 빈 보관함을 유지한다.
- 새 프로세스 이어하기와 새 출정/빈 귀환에서도 돈 820·빈 보관함을 유지하며 팔았던 물품이나 수익이 복원되지 않는다. 쓰기 후 다음 출정 ID는 3, 이어하기/빈 귀환 후 4다. 기존 저장 스키마 1·거점 4필드·물품 3필드를 유지하고 설정 파일은 변하지 않았다.
- 원본: [전체 자동 검사](dev0402_automated_results.json), [그래픽 실행의 판매/저장 결과](dev0402_sale_results.json), [새 프로세스 이어하기](dev0402_continue_results.json).
- 전체 결과 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20260929-132610-e2ab4e63a44946f5b7acdc7987c4bdca/results.json`
- 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0402-verified-a12628be9daf4537bb121b51345ab32e/`
- 검사 기준 HEAD: `b4a975a`와 이번 작업 트리. `src`·`tests`·`project.godot` 소스 SHA-256: `cb26019a822bed3e5eec908d557abeb8041e61c8716b9e73705fe54c74a938cd` — 실행 소스 바이트 기준이며 문서나 다른 환경 줄바꿈까지 보증하지 않는다.
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.

**DEV-0402 구현·검증 완료, 사용자 로컬 커밋 승인.** 시험 잔재 판매가 200은 최종 가격이 아니며 감정 비용을 재차 차감하지 않는다. 자동/전체 판매·등록·연구·구매·수리·성장·휴대용 감정은 후속이다. 다음 **DEV-0403**의 이름·범위는 다음 착수 때 정한다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0403 원본 발견물 등록과 재열람 검사

[등록 스모크](../../tests/smoke/hub_registration_smoke.gd)는 실제 앱의 출정·회수·실패/귀환·정산·등록·재열람을 사용한다. 처음에는 돈 10·가방 3칸·빈 보관함의 스키마 1 파일만 임시로 준비하며 원본 두 개는 실제 이동과 E 회수로 얻는다. 미확인/일반품/중복 ID·이름 변경·등록 불가 데이터와 최대 정수의 구형 저장은 별도 경계 자료다.

```powershell
$registrationDirectory = Join-Path $env:TEMP ('dungeon-registration-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_registration_smoke.tscn -- "--registration-directory=$registrationDirectory"
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_registration_smoke.tscn -- --registration-continue "--registration-directory=$registrationDirectory"
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `hub_registration_passed write`·`hub_registration_passed continue`, 종료 코드 0이다. 첫 실행은 새 폴더만 사용하고 다음 실행은 같은 파일을 새 프로세스에서 이어한다. 첫 명령의 `--headless`를 빼고 `--` 뒤에 `--registration-render`를 추가하면 거점·등록 확인·저장 실패·재열람 화면을 1152×648·1600×900으로 저장한다. 저장 실패는 검사 폴더의 `progress.json.tmp`에 빈 디렉터리를 만들어 재현하며 재시도 전에 그 빈 디렉터리만 제거한다. 실제 사용자 파일은 읽거나 덮어쓰지 않는다.

2026-10-01 최종 Godot 4.7.1 **69/69 실행**, 스모크 장면 **42개**와 새 프로세스 이어하기를 포함한 1회 검사 통과. 버전/프로젝트 가져오기 2개와 흐름 검사 67개이며 실제 `checks` 목록을 검증 범위로 삼는다. 실행 전후 소스 해시가 같고 엔진 오류·경고·진단 예외 적용은 없다. 별도 그래픽 실행도 종료 코드 0이며 실제 화면 **8장**에서 서비스 버튼·원본 구분·확인·재시도·등록 목록·설명과 화면 경계를 확인했다. 초기 저장 버전 비교에서 JSON 숫자와 정수 배열의 타입 차이를 발견해 수치 비교로 수정했으며 그 이전 실패 실행은 통과 횟수에 합산하지 않는다.

- 원본 흐름: 첫 출정에서 유물을 회수하고 붕괴로 실패하면 등록/보관 모두 0개다. 다음 출정에는 두 원본 모두 있고 실제 유물·기록물 회수와 입구 귀환 뒤 2개가 거점에 보관된다. 첫 원본의 등록을 취소·재열기·재확인한 뒤 쓰기 실패에서 파일과 보관품을 보존한다. 재시도·중복 요청 후 정확히 1개만 등록되고 다른 원본은 보관함에 남는다.
- 다음 출정: 등록된 유물과 아직 거점에 보관한 기록물 모두 제외하고 일반 폐품은 유지한다. 빈 귀환 뒤 기록물을 키보드로 선택·등록하고 다시 출정해 일반 물품을 회수한 뒤 실패해도 원본 등록 2개·돈 10을 유지한다.
- 재열람: 실제 목록 선택으로 고유 유물은 수집 등록, 기록물은 연구자 보관의 안내를 읽는다. 재열람·중복 확정은 파일을 다시 쓰지 않는다. 새 프로세스 이어하기·추가 출정/빈 귀환에서도 돈 10·빈 일반 보관함·등록 2개를 유지한다. 다음 출정 ID는 쓰기 후 5, 이어하기/빈 귀환 후 6이다. 설정 파일은 변하지 않았다.
- 데이터: 미확인/일반품/잘못된 위치·중복 ID·오래된 견적·탐험 중 요청은 거절한다. 감정한 원본의 등록과 비용 재차 차감 없음, 같은 종류의 다른 개체 보존·복사본 분리·이름 변경 후 안정적 ID 복원/제외를 검사했다. 중복/미확인/일반품/없는 ID가 들어간 등록 목록은 복원하지 않는다.
- 저장 전환: 스키마 1을 읽으면 메모리에서 빈 등록 목록을 보완하고 원본 파일은 그대로다. 최대 정수 돈과 기존 미확인 상태/위험 안내가 유지된다. 전환 쓰기 실패는 구형 파일을 보존하고 재시도 성공 때만 2로 저장한다. 버전 1에 새 필드가 섞인 파일, 버전 2에 필드가 빠진 파일과 미지원 버전은 덮어쓰지 않는다.
- 원본: [전체 자동 검사](dev0403_automated_results.json), [그래픽 실행의 등록/저장 결과](dev0403_registration_results.json), [새 프로세스 이어하기](dev0403_continue_results.json).
- 전체 결과 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261001-054636-99fbdddd1ee44d54add7ceee6313975e/results.json`
- 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0403-verified-2b6e4e174e0745ccaf421f90c7a39204/`
- 검사 기준 HEAD: `fb2e3a2`와 이번 작업 트리. `src`·`tests`·`project.godot` 소스 SHA-256: `0c3d4a82289e2fe3f4e8491593e38738fc5184eb543f78d10d3426dbace4d427` — 실행 바이트 기준이며 문서나 다른 환경 줄바꿈까지 보증하지 않는다.
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.

직접 확인할 때는 새 게임/이어하기 → 거점에서 출정 → 입구 아래 남서쪽의 **고유 유물·핵심 기록물**을 E로 회수 → 원래 입구 귀환·정산 → **원본 등록 · 목록**에서 선택·확인·등록 → 오른쪽 목록에서 다시 읽기를 진행한다. 원본 하나는 입구 아래, 다른 하나는 그 오른쪽에 있으며 기존 벽/위험 경로를 바꾸지 않았다. 다음 출정에서는 확보한 원본이 없어지고 실패해 회수하지 못한 원본은 다시 등장한다. 정상 저장으로 2로 전환한 파일은 스키마 1만 지원하는 과거 코드에서 이어할 수 없다.

**DEV-0403 구현·검증 완료, 사용자 로컬 커밋 승인.** 시험 원본의 설명은 보관·등록 안내에 한정하며 정식 세계관 해설·연결 연구 단계·화폐 보상은 후속이다. 다음 **DEV-0404**의 이름·범위는 다음 착수 때 정한다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0404 등록 조건에 따른 연구 해설 해금 검사

[연구 스모크](../../tests/smoke/hub_research_smoke.gd)는 등록 검사의 실제 이동·회수·실패·귀환 도우미를 사용한다. 시험 시작 파일은 돈 10·가방 3칸·빈 보관함/등록 목록의 스키마 2다. 원본은 실제 출정에서 회수하며 별도 경계 자료로 조건·순서·구형 저장·이름 변경을 검사한다.

```powershell
$researchDirectory = Join-Path $env:TEMP ('dungeon-research-' + [guid]::NewGuid().ToString('N'))
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_research_smoke.tscn -- "--research-directory=$researchDirectory"
& $env:GODOT_BIN --headless --path . --fixed-fps 60 --quit-after 20000 res://tests/smoke/hub_research_smoke.tscn -- --research-continue "--research-directory=$researchDirectory"
& ./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 60
```

성공 표시는 `hub_research_passed write`·`hub_research_passed continue`, 종료 코드 0이다. 첫 실행은 새 임시 폴더만 사용한다. 첫 명령에서 `--headless`를 빼고 `--` 뒤에 `--research-render`를 추가하면 잠김·저장 실패·부분 해금·전체 해금·실패 후 재열람을 각각 1152×648·1600×900으로 저장한다. 쓰기 실패는 격리된 `progress.json.tmp` 빈 디렉터리로 재현하고 재시도 전에 그 빈 디렉터리만 제거한다. 기본 사용자 진행 파일은 읽거나 덮어쓰지 않는다.

2026-10-01 최종 Godot 4.7.1 **71/71 실행**, 스모크 장면 **43개**와 별도 프로세스 이어하기를 포함한 1회 전체 검사 통과. 버전/프로젝트 가져오기 2개·나머지 흐름 검사 69개이며 실제 `checks` 목록을 검증 범위로 삼는다. 소스 해시는 실행 전후 같고 엔진 오류·경고·진단 예외 적용은 없다. 별도 그래픽 실행의 성공 결과와 화면 **10장**을 확인했다. 초기 이름 변경 검사의 외부 리소스 공유를 발견해 각 아이템 정의를 명시적으로 복사하도록 수정하고 최종 소스로 전체 검사를 다시 실행했다. 초기 실행은 최종 횟수에 합산하지 않는다.

- 조건: 빈 등록·거점 보관/감정·회수 후 실패는 0/2, 기록물만 등록하면 1/2, 두 원본을 모두 등록하면 2/2다. 유물만 등록하면 같은 1개 등록이어도 0/2이며 등록 순서를 바꿔도 최종 결과는 같다. 미확인 원본·중복/빈/없는 요구 ID·일반 물품 참조·빈 설명/ID·중복/없는 해설 정의를 검사했다.
- 공개: 잠긴 조회에는 해설 ID·제목·본문·필요 원본 이름을 포함하지 않는다. 실제 마우스/방향키 선택은 잠금 안내 또는 해금된 설명을 표시한다. 조회 반환값 변경은 정의를 바꾸지 않고 이름을 바꿔도 등록 ID 조건은 유지된다.
- 저장: 실제 원본 회수 실패 뒤 재출정하여 두 원본을 확보한다. 기록물 등록을 취소한 뒤 재확인하고 파일 쓰기 실패에서 0/2·보관 2개를 유지한다. 재시도와 중복 확정 뒤 돈 10·등록 1개·해설 1/2가 된다. 부분 해금 상태로 출정/빈 귀환 후 남은 원본을 등록하여 2/2가 되며, 이후 일반 물품을 회수한 출정에 실패해도 기존 해설을 보존한다.
- 재열람/이어하기: 읽는 동안 파일 바이트·돈·물품·설정은 그대로다. 새 프로세스의 이어하기 자체는 저장을 다시 쓰지 않으며 추가 출정/빈 귀환 뒤에도 해설 2개·원본 2개·돈 10을 유지한다. 다음 출정 ID는 쓰기 후 5, 이어하기/빈 귀환 후 6이다. 구형 스키마 1의 빈 등록 목록은 해설을 열지 않고 기존 파일을 보존한다. 신규 저장 필드는 없다.
- 입력/화면: 확인 중 연구 선택은 확인 문구를 덮어쓰지 않는다. 해설 선택은 물품 선택과 등록 버튼을 해제하고 서비스/출정/가방 변경을 막는다. Esc로 거점에 돌아가 버튼 포커스를 복구한다. 두 해상도에서 한국어 이름·설명·목록·확인/취소 버튼과 화면 경계를 확인했다.
- 원본: [전체 자동 검사](dev0404_automated_results.json), [그래픽 실행의 연구/저장 결과](dev0404_research_results.json), [새 프로세스 이어하기](dev0404_continue_results.json).
- 전체 결과 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261001-061334-ebe5681d977c41cea8ebce8b01f59898/results.json`
- 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0404-verified-c510b71b4d13426eadd1aad79f483574/`
- 검사 기준 HEAD: `95617cc`와 이번 작업 트리. `src`·`tests`·`project.godot` 소스 SHA-256: `acbcfba384bb88dbf88a8888b1f64aa37b638e7dd654a5db04d3e6ed07ca301d` — 실행 바이트 기준이며 문서나 다른 환경 줄바꿈까지 보증하지 않는다.
- 활성 Markdown 상대 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과.

직접 확인할 때는 거점의 **원본 등록 · 목록**을 연 뒤 오른쪽 연구 목록을 선택한다. 기존 두 원본 중 기록물만 등록하면 첫 설명, 두 원본을 등록하면 두 번째 설명이 열린다. 자료의 보관/함께 열람을 설명하는 시험 문장으로, 정식 연구자 지식 단계·세계관 해설·최종 해금 조합을 확정하지 않는다. 현재 조건은 삭제되지 않는 등록 상태에서 조회하므로 해설을 따로 저장하지 않는다. 향후 조건 데이터나 등록 삭제 정책 변경은 별도 이관 검토가 필요하다.

**DEV-0404 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음 **DEV-0405**의 이름·범위는 G4 잔여 범위를 대조해 다음 착수 때 정한다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0405 장비 내구·수리와 재출정 안전망 규칙 정리 검사

2026-10-01 문서 작업이다. [수리 검토안](../design/repair_rules.md)의 기존 요구와 현재 구현을 `ExplorationOutcome`, `HubState`, `SettlementResult`, `EconomyRule`, `ExpeditionLoadout`, `GameEntry`, `ProgressStore` 및 결과/거점 화면과 대조했다. 현재 내구 상태·수리 거래는 없고 정산 비용은 0이며, 거점 서비스의 후보 저장 후 교체와 스키마 1→2 읽기 경계가 존재함을 확인했다.

- 사용자 답변에 따른 거점 비용 확인·선택 수리만 DEC-111·confirmed Economy Rules·GDD 개요에 반영했다. 새 검토안은 `draft`이며 손상량·복구량·가격·출정 제한·무료 최소 복구는 미적용 제안이다.
- 다음 DEV-0406의 손상 상태/저장과 이후 수리/최소 복구를 구분했다. 수리 안전망이 없는 단계에서 출정을 막지 않도록 인계했다. Q-019~Q-021의 건강·부상·비상 탈출과 Q-022·Q-023의 내구·수리 범위가 중복 확정되지 않는지 대조했다.
- 실제 비용과 예상 수리비의 분리, 정산/수리 중복 차감 방지, 저장 실패·취소·재시도, 돈 0/판매품 없음에서 재출정, 등록/연구 진행 보존과 자원 분리를 후속 완료 조건으로 남겼다.
- `src`·`tests`·`project.godot` 변경 0건. 현재 소스 SHA-256은 `acbcfba384bb88dbf88a8888b1f64aa37b638e7dd654a5db04d3e6ed07ca301d`로 [DEV-0404의 최종 71/71 기록](dev0404_automated_results.json)과 같다. 이 71회와 화면 10장은 기존 결과이며 이번 작업에서 새로 수행한 검사가 아니다.
- 이번에 수행한 검사는 활성 Markdown 상대 링크·앵커, 동결 원본 6개 SHA-256·아카이브 사본 3개, 결정/질문 ID·문서 상태·변경 범위와 `git diff --check`다. [검증 결과](dev0405_document_results.json)에 기록한다.

**DEV-0405 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 다음은 **DEV-0406 — 장비 손상 상태와 저장**이며 이번 문서로 수리 구현 완료나 G4 전체 완료를 선언하지 않는다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0406 장비 손상 상태와 저장 검사

2026-10-01 Godot 4.7.1로 구현·검증했다. 전체 실행은 기존 명령 `./tests/run_g2_checks.ps1 -GodotBin <Godot 4.7.1 콘솔 실행 파일> -Repetitions 1`로 재현한다. 장비 전용 장면은 `res://tests/smoke/equipment_wear_smoke.tscn`이며 `--wear-directory=<새 임시 경로>`로 저장을 격리한다. 첫 실행 뒤 같은 경로와 `--wear-case=continue`로 별도 실행의 이어하기를 검사한다. `--wear-case=legacy1`, `legacy2`, `invalid`는 각각 새 경로를 사용한다. 화면은 그래픽 실행에 `--wear-render`를 더한다.

- 최종 전체 **76/76 실행**, 스모크 장면 44개 포함. 최종 실행은 인증서 예외 없이 종료 코드 0·실패 진단 없음으로 통과했다. 소스 import의 최초 샌드박스 경로 제한은 정상 권한 재검사에서 해소했다. 초기 실패에서 JSON 숫자의 버전 비교·내구 정규화와 기존 검사 자료의 저장 필드 기대값을 보완했다.
- 내구 0/1/2/3에서 정상·빈 귀환·비상 탈출·실패 손상, 0 하한·최대 정수 손상·잘못된 데이터, 취소/오래된 출정·중복 정산·미리보기 복사·규칙 변경 후 결과 보존·수입 정수 초과 시 부분 손상 없음까지 검사했다.
- 실제 앱은 빈 입구 귀환 3→2, 별도 비상 탈출 2→1, 실제 골렘 접촉 실패 1→0을 통과했다. 첫 정산 쓰기를 두 번 실패시켜 원본 파일·내구 3을 보존했고 재시도/중복 확정 뒤 2가 됐다. 실패의 기본 손상 2는 독립 경계 검사에서 확인하며 실제 1→0에서는 남은 1만 손상으로 표시한다.
- 돈 0·보관/판매품 없음·내구 0에서 실제 새 출정과 빈 귀환을 확인했다. 가방 3칸·새 출정 충전 3·건강 2·등록 원본 2개와 연구 해설을 보존한다. 그래픽 실행의 최종 출정 ID는 5, 별도 이어하기/귀환 뒤 6이며 내구 0·돈 0은 그대로다. 읽기·메뉴·설정 파일은 내구를 바꾸지 않는다.
- 구형 스키마 1·2의 실제 이어하기는 파일 바이트를 유지한 채 내구 3을 보완한다. 가방 저장 실패에도 구형 파일/선택을 보존하고 재시도 때 스키마 3으로 전환한다. 이어서 정상 귀환 손상 1을 확인했다. 1의 빈 등록 목록과 2의 기존 등록 원본을 구별한다. 잘못된 내구/누락/추가 필드·미지원 파일은 자동 덮어쓰지 않고, 잘못된 내구의 타이틀은 이어하기를 비활성화한다.
- 화면 **12장**: 일반 귀환·비상 탈출·실패·정산 저장 실패·내구 0 거점·새 실행 거점의 1152×648 및 1600×900 화면을 직접 확인했다. 내구 전후·실제 손상·수리비 미차감·출정 가능 안내·저장 오류·버튼이 잘리지 않으며 마우스/Enter 정산을 검사했다.
- 원본: [전체 자동 검사](dev0406_automated_results.json), [그래픽 검사/화면 목록](dev0406_render_results.json), [손상 순환 결과](dev0406_wear_results.json), [새 실행 이어하기](dev0406_continue_results.json), [문서·보존 검사](dev0406_document_results.json).
- 전체 결과 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261001-065956-68ee737eb2e548338d74102a408fe861/results.json`
- 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0406-render-745a86e6fabc40158768d1d1f9ec4df2/`
- 검사 기준 HEAD: `d967633`와 이번 작업 트리. `src`·`tests`·`project.godot` 소스 SHA-256: `42efc42ce6eccc7f77d87f831a6ae3a9d0c426a6d4fd56bd18d10da9c3996e95` — 실행 바이트 기준이며 문서나 다른 환경 줄바꿈까지 보증하지 않는다.
- 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check` 통과. 검토안은 `draft`, Q-022·Q-023은 `provisional`을 유지한다.

**DEV-0406 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음은 **DEV-0407 — 거점 선택 수리와 최소 복구**다. 이번 수치/출정 허용은 시제품 연결이며 최종 밸런스·수리 결제·무료 복구·출정 제한을 확정하지 않는다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0407 거점 선택 수리와 최소 복구 검사

2026-10-01 Godot 4.7.1로 검증했다. 전체는 `./tests/run_g2_checks.ps1 -GodotBin <Godot 4.7.1 콘솔 실행 파일> -Repetitions 1`로 재현한다. 전용 장면 `res://tests/smoke/hub_repair_smoke.tscn`에 `--repair-directory=<새 임시 경로>`를 준 뒤 같은 경로로 `--repair-case=continue`를 별도 실행한다. 지원 검사는 다른 새 경로의 `--repair-case=support`와 같은 경로의 `--repair-case=continue-support`다. 그래픽 실행에는 `--repair-render`를 더한다.

- 최종 **80/80 실행**(45개 스모크 장면)·인증서 예외 없이 종료 코드 0·실패 진단 없음. 처음 전체 검사에서 기존 골렘 포획 검사의 수리 없는 재출정 기대를 발견하여 생존 검사와 함께 서비스 경유로 갱신했다. 최종 소스에서 전체 검사를 다시 통과했다.
- 내구 0/1/2/3·돈 0/4/5/6/15/최대 정수, 부분/완전 수리·지원 자격 경계·양 0/음수/초과·가격 정수 초과/0·최소 내구 오류·상태/가격 변경·활성 출정·중복 확정을 검사했다. 무료 복구는 기존 돈을 유지하며 내구 1 이후 추가 지원을 거절한다.
- 실제 앱 유료 경로: 돈 20·내구 0에서 출정이 수리 안내로 연결된다. 완전 수리 견적을 취소해 파일/상태를 보존하고 부분 +1/비용 5 확정은 두 번의 저장 실패 후 한 번만 적용한다(돈 15·내구 1). 실제 빈 귀환 1→0 뒤 완전 수리 +3/비용 15(돈 0), 정상 귀환 3→2, 실제 위험 실패 2→0, 무료 지원 0→1을 확인했다.
- 지원 경로: 돈 4·내구 0에서 무료 복구 저장을 두 번 실패시킨 뒤 재시도해 돈 4·내구 1을 저장했다. 실제 실패 후 지원을 다시 선택해도 돈/물품을 늘리지 않는다. 두 경로 모두 새 프로세스 이어하기가 파일을 다시 쓰지 않고 내구 1을 읽으며 실제 재출정·손상 후 최소 복구로 돌아온다.
- 돈 0·보관/판매품 없음의 재출정은 기존 `equipment_wear_smoke`의 최소 복구 서비스와 실제 출정/귀환에서 확인한다. 등록 원본 2개·연구 해설·가방 3칸·새 출정 건강 2/충전 3을 보존한다. 기존 판매/등록/연구/생존/저장 흐름도 필요한 수리 결제만 반영하며 구형 1/2·손상/미지원 파일 검사를 유지한다.
- 결과의 귀환 순이익 +0과 완전 수리 예상액 5/15, 서비스의 예상 비용/실제 지불액을 구분했다. 수리 뒤 빈 귀환은 같은 비용을 다시 차감하지 않는다. 선택 중 다른 서비스/출정/가방 변경, 탐험 중 수리, 마우스·방향키/Enter 선택/확정·Esc 취소도 검사했다.
- 그래픽 검사 **2회·화면 20장**: 내구 0 거점, 완전 견적, 부분/완전 수리 완료, 저장 실패, 잔액 부족, 무료 복구 견적/완료, 귀환/실패 결과를 1152×648·1600×900에서 확인했다. 실제 지불액과 다음 견적을 구분하도록 문구를 보완한 최종 화면이다. 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0407-render-50022b87792e4cc4af264771d6ccc99e/`.
- 원본: [전체 자동 검사](dev0407_automated_results.json), [그래픽 검사/화면 목록](dev0407_render_results.json), [유료/지원 순환](dev0407_repair_results.json), [새 실행 이어하기](dev0407_continue_results.json), [잔액 4 지원](dev0407_support_results.json), [지원 새 실행](dev0407_support_continue_results.json), [문서·보존 검사](dev0407_document_results.json).
- 전체 로그 경로: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261001-073426-a5f0387370cd44eda457ba41a0bf11f3/results.json`. 기준 HEAD `c82d23d`와 이번 작업 트리의 `src`·`tests`·`project.godot` SHA-256은 `556d6766746bfff50f72ed7e891013e01c435c3c877da69b982839bf34096686`다. 전체/그래픽 검사 해시가 일치하며 실행 파일 바이트 기준이다.
- 활성 Markdown 링크·앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개·`git diff --check` 통과. `repair_rules.md`는 `draft`, Q-022·Q-023은 `provisional`, 경제 규칙은 `confirmed`를 유지한다.

**DEV-0407 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음 DEV-0408의 이름·범위는 G4 잔여 준비·성장·비용 통합을 대조해 다음 착수 때 정한다. 시험 단가·최소 복구는 최종 밸런스 승인이 아니며 사람 평가는 후속이다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0408 하네스 준비·성장 규칙 정리 검사

2026-10-04 문서 작업을 검증했다. 기준 HEAD는 DEV-0407 `a2a93a6`이며 착수 fetch 뒤 뒤처짐 0·로컬 7커밋 앞섬·깨끗한 작업 트리를 확인했다. 기존 장착/성장 공백을 정리한 작업으로 게임 코드·장면·데이터·저장 형식을 수정하지 않았다.

- GDD 4-2·7-1~7-6·10-2·10-5·20-3의 기존 요구와 DEC-104·105·107·111, confirmed Item/Economy/Repeat Exploration을 대조했다. Story/Reference의 공식 하네스 의미·감정 제한과 충돌하지 않으며 새로운 세계관·공식 명칭은 추가하지 않았다. 동결 개발 제안서의 G4는 준비·성장·경제 완료 범위의 역사적 대조에만 사용했다.
- 현재 `ExpeditionLoadout`/`HubState`는 장착/해금이 없고, `HarnessController`가 세 행동과 공유 충전을 처리한다. `MalfunctioningTrap`/`DoorHoldTarget`/`RemainingZoneEntrance`의 공통 안정화 경로, 별도 `NoiseLureController` 횟수 2, `EmergencyEscape`의 별도 충전 결제, 등록 원본으로 해설만 여는 연구와 스키마 3·6필드를 확인했다.
- 장착 세 행동 중 두 개의 미적용 비교안, 무료 기본 정보·기본 탐색과 정밀 분석/물품 감정의 경계, 모듈 행동 대응·거점/런/내구 분리, 후보 저장·실제 행동/충전·새 실행/구형 전환 검증 계약을 정리했다. Q-024·Q-025 ID 중복 없음과 `provisional`, Harness Engineering의 `draft` 유지를 확인했다. GDD·confirmed 경제/아이템 규칙의 상태를 변경하지 않았다.
- 활성 Markdown 상대 링크/앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개와 `git diff --check`를 검사했다. `docs/README.md`와 `migration_manifest.md`의 정합성 검사 표는 HEAD와 같으며 다음 시점은 G5 완료 후다.
- `src`·`tests`·`project.godot`의 SHA-256은 `556d6766746bfff50f72ed7e891013e01c435c3c877da69b982839bf34096686`으로 [DEV-0407 전체 검사](dev0407_automated_results.json)·[화면 검사](dev0407_render_results.json)와 일치한다. 80/80 실행·화면 20장은 그 작업의 기존 근거이며 이번 작업에서 재실행한 횟수가 아니다. 소스 해시는 해당 실행 바이트 기준이다.
- 상세 결과: [DEV-0408 문서 검사](dev0408_document_results.json). 재현은 활성 Markdown 링크 대상/앵커 확인, 이관 대장의 6개 원본 해시와 3개 아카이브 비교, `tests/run_g2_checks.ps1`의 `Get-G2SourceHash`와 기존 보고서 비교, `git diff --check` 순서로 수행한다.

**DEV-0408 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 다음은 **DEV-0409 — 거점 하네스 장착 선택**이다. 실행 시험 조건은 해당 착수 때 기록하며 이번 문서 승인으로 제안 전체를 제품 규칙으로 승격하지 않는다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0409 거점 하네스 장착 선택 검사

2026-10-04 Godot 4.7.1로 검증했다. 전체 재현은 `./tests/run_g2_checks.ps1 -GodotBin <Godot 4.7.1 콘솔 실행 파일> -Repetitions 1`이다. 전용 장면 `res://tests/smoke/hub_harness_smoke.tscn`에 `--harness-directory=<새 임시 경로>`를 주고 같은 경로의 `--harness-case=continue`를 새 프로세스로 실행한다. 별도 새 경로의 `--harness-case=legacy1`, `legacy2`, `legacy3`, `support`도 실행기에 포함했다. 그래픽 검사는 `--harness-render`를 더한다.

- 최종 **86/86 실행·46개 스모크 장면**이 인증서 예외 없이 종료 코드 0, 경고/오류 진단 없이 통과했다. 초기 전체 검사에서 생존 저장 필드 기대값과 등록/연구의 구형 파일에 새 필드가 남은 자료 오류를 발견하여 현행 7필드/실제 구형 형식으로 갱신했다. 최종 소스로 전체를 다시 통과했다.
- 세 장착 조합×다섯 대상(잔해·골렘·문 고정·잔여 구역 입구·함정)의 15개 경계: 실제 감지 대상·분석 버튼/Q·장착별 효과·공유 충전·미장착 안내·정지/반복 입력을 확인했다. 대상 경계는 실제 월드 위치에 플레이어를 놓고 위험 상태를 준비한다. 골렘 이동/접촉은 이 고립 검사에서 정지하며 전체 기본 행동 검사는 별도로 유지한다.
- 실제 앱 경로는 각 조합을 저장하고 이동/E 입력으로 기본 경로의 두 회수품을 가져와 원래 입구에서 귀환한다. 하네스 충전은 3, 기존 정산 수입은 회당 40이다. 별도 F 소음 유인은 각 구성에서 2→1회, 하네스 충전은 보존했다. 장착 미선택 경로에서도 실제 탐색/귀환 가능성을 확인했다.
- 변경 시 돈·내구·기존 미확인 보관품·등록 원본 2개/연구·가방 3칸·출정 번호를 유지한다. UI 선택 중 서비스/가방/출정을 차단하며 마우스 클릭·방향키/Enter 선택/확정·Esc 검토 취소/닫기, 두 번의 저장 실패 후 재시도·중복 확정을 검사했다. 도메인은 잘못된 개수/ID/타입/중복·오래된 원본·기존 수리 견적 무효화·활성 런 변경·복사본 변조를 검사했다.
- 세 번의 실제 회수 뒤 기본이 아닌 정밀 분석+안정화로 유료 최소 수리·실제 잔해 실패·다시 수리·별도 E 비상 탈출을 진행했다. 비상 방전 미장착이어도 E 탈출은 기존 조건으로 귀환한다. 장착·거점 보관/등록/연구를 보존한다. 별도 돈 0/내구 0 경로는 무료 최소 복구로 내구 1을 만든 뒤 같은 장착으로 실제 회수/귀환한다.
- 새 프로세스 이어하기는 정밀 분석+안정화·내구 0 기록을 다시 쓰지 않고 읽어 수리/출정을 이어간다. 구형 1/2/3도 실제 타이틀 이어하기에서 기본 조합/거점 안내, 읽기/실패한 쓰기 바이트 보존, 정상 확정 후 스키마 4 전환을 확인했다. 구형 1 빈 등록과 2/3 기존 등록, 3의 내구를 구분하며 누락/잘못된 장착·미지원 파일은 덮어쓰지 않는다.
- 그래픽 검사 **2회·화면 20장**을 1152×648·1600×900에서 렌더링하고 직접 검토했다. 세 조합의 거점/완료, 변경 검토·저장 실패, 현장 미장착 거절/무료 정보, 이어하기 내구 0/수리 안내가 잘리거나 버튼과 겹치지 않는다. 화면 경로: `C:/Users/user/AppData/Local/Temp/dungeon-dev0409-render-580b6daf00ef42c9a7285826310f0810/`.
- 원본: [전체 자동 검사](dev0409_automated_results.json), [그래픽 검사/화면 목록](dev0409_render_results.json), [장착/행동/순환](dev0409_harness_results.json), [새 실행 이어하기](dev0409_continue_results.json), [구형 전환/무료 지원](dev0409_migration_support_results.json), [문서·보존 검사](dev0409_document_results.json).
- 전체 로그: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261004-001326-a7cb33f7790343f7a0ccbad141e77727/results.json`. 기준 HEAD `dff3930`과 작업 트리의 `src`·`tests`·`project.godot` SHA-256은 `2a31dcc5bf89a2f5b41ef8618b0148805b88abdb27c87ed10cf22cd0a0eea780`이며 전체/그래픽 검사와 일치한다. 실행 바이트 기준이며 문서나 다른 환경 줄바꿈까지 보증하지 않는다.
- 활성 Markdown 상대 링크/앵커·동결 원본 6개 SHA-256·아카이브 사본 3개·`git diff --check` 통과. 정합성 검사 시점 표는 HEAD와 같고 Harness Engineering은 `draft`, Q-024·Q-025는 `provisional`이다. 영구 성장/최종 장착 한도·사람 체감은 자동 검사로 확정하지 않는다.

**DEV-0409 구현·검증 완료, 사용자 로컬 커밋 승인.** 이번 작업은 사용자 로컬 커밋 승인 상태이며 push하지 않았다. 커밋 전에는 로컬 8커밋 앞섬·뒤처짐 0이었다. 다음은 **DEV-0410 — 하네스 영구 성장 규칙 정리**다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0410 하네스 영구 성장 규칙 정리 검사

- 2026-10-04 DEV-0409 `40545f2` 뒤 착수 fetch와 깨끗한 작업 트리·뒤처짐 0/로컬 9커밋 앞섬을 확인했다. GDD 7장·10장·20-3, confirmed 경제/아이템/반복 탐험과 Story/Reference의 정보·장비 의미를 대조했다.
- [성장 검토안](../design/harness_engineering.md#dev-0410-영구-성장-제안--미적용)은 `draft`, Q-025는 `provisional`이다. 관찰 정보/비상 시간·각 1단계·시험가 60은 미적용 제안이며 직접 구매는 사용자 응답 전 가정이다. GDD·confirmed 경제·기존 결정·Story/Reference를 바꾸지 않았다.
- 현재 코드에서 정밀 분석 즉시 처리와 정보 문자열 비교, 골렘 클래스 기본 1.5초/앱 2초, 문 6초, 판매가 10/30과 수리비 5를 확인했다. 동적 표시의 유료 재분석 방지·일시정지, 대상별 시간 가산·반복 연장 방지, 59/60/61 구매 경계와 저장/실패/재출정의 후속 증거를 계약으로 기록했다. 제안된 효과를 실행 검사한 결과가 아니다.
- 활성 Markdown 상대 링크/앵커, 동결 원본 SHA-256 6개/아카이브 사본 3개, Q-024/Q-025 상태·중복 ID, 변경 파일 범위와 `git diff --check` 결과는 [문서 검사 원본](dev0410_document_results.json)에 기록한다. 두 정합성 검사 시점 표는 HEAD와 동일하게 유지한다.
- `src`·`tests`·`project.godot` 해시를 `tests/run_g2_checks.ps1`의 `Get-G2SourceHash`로 구해 [DEV-0409 전체 검사](dev0409_automated_results.json)·[화면 검사](dev0409_render_results.json)의 `2a31dcc5bf89a2f5b41ef8618b0148805b88abdb27c87ed10cf22cd0a0eea780`과 대조한다. 문서 작업의 신규 게임/화면 실행은 0회다. 이전 86/86·화면 20장은 기존 근거이며 이번 검사를 대신 실행했다고 기록하지 않는다.
- 재현 순서: 활성 문서의 상대 링크 대상/앵커 확인 → 이관 대장의 6개 원본 해시 및 3개 사본 바이트 비교 → 현행 소스 해시와 DEV-0409 결과 비교 → HEAD 대비 두 시점 표/공식 문서 보존 확인 → `git diff --check`. 후속 게임 구현 검사는 DEV-0411 범위다.

**DEV-0410 문서 검토안 작성·검증 완료, 사용자 로컬 커밋 승인.** 세부 검증 결과는 연결된 JSON을 따른다. 다음은 **DEV-0411 — 거점 하네스 영구 개선 구매**다. 획득 방식 응답·최종 수치·사람 평가·G4 전체 완료는 후속이며 **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0411 하네스 영구 개선 구매·발견 획득 검사

2026-10-04 Godot 4.7.1로 검증했다. 전체 재현은 `./tests/run_g2_checks.ps1 -GodotBin <Godot 4.7.1 콘솔 실행 파일> -Repetitions 1`이다. 전용 장면 `res://tests/smoke/hub_upgrade_smoke.tscn`에 `--upgrade-directory=<새 임시 경로>`를 주고 같은 경로의 `--upgrade-case=continue`를 새 프로세스로 실행한다. 별도 새 경로의 `--upgrade-case=purchase`, `support`도 실행기에 포함했다. 그래픽 검사는 `--upgrade-render`를 더한다.

- 최종 **90/90 실행·47개 스모크 장면**이 인증서 예외 없이 종료 코드 0·오류/경고 진단 없이 통과했다. 초기 전체 검사에서 생존 검사의 저장 필드 기대 목록이 새 필드를 누락한 것을 고쳐 최종 소스로 다시 전체를 통과했다.
- 실제 앱에서는 두 차례 회수/귀환으로 40씩 벌어 관찰 개선 60을 구매하고, 정밀 분석+안정화를 장착해 선택 잔여 구역을 열고 E로 비상 개선을 발견한다. 발견 후 위험 실패→수리/재도전→발견/안전 귀환→정산 저장 실패/재시도→두 개선 보유→다음 출정의 발견 제외를 검사했다. 현장 발견은 그 출정의 능력을 바꾸지 않으며 기존 구매는 실패 후 유지한다.
- 구매 잔액 0/59/60/61/120/64비트 정수 상한·두 구매 순서·1회 상한, 알려지지 않은 ID/타입/중복·원본/가격/효과가 달라진 견적·활성 출정·복사본 변조를 검사했다. 실제 마우스/키보드 선택·확정·Esc 취소, 저장 실패/재시도와 다른 서비스/출정 차단을 확인했다. 별도 `purchase`는 두 개선 모두 구매, `support`는 돈 60/내구 0에서 전액 구매 뒤 무료 최소 복구와 실제 빈손 귀환으로 영구 보유를 확인했다.
- 효과 경계는 기본 앱에 플레이어 위치와 위험 상태를 준비하여 실제 분석/Q 입력으로 측정한다. 골렘 2→3초·문 6→8초, 잔해 경고 1.2초 유지, 충전 비용/만료·효과 중 반복 입력·메뉴 정지, 분석 완료 후 실시간 표시와 대상/상태/범위 이탈 무효화를 확인했다. 골렘 의심/수색 타이머 재시작은 같은 상태 관찰 구간의 정보를 갱신하며 상태 전환은 만료한다. 세 장착 조합별 보유/미장착 효과도 확인했다. 위치/상태를 준비한 경계를 사람의 자연 플레이 평가로 계산하지 않는다.
- 새 프로세스 이어하기는 두 개선을 읽기만 하고 재출정한다. 전용 도메인 검사는 구형 1~4를 읽고 기존 등록/내구/장착 보완과 빈 개선, 읽기 바이트 보존·정상 저장 후 스키마 5, 잘못된 현재 파일의 거절/원본 보존을 확인한다. 구형 타이틀 이어하기는 기존 회귀 경로도 함께 통과했다. 감정·판매·수리·가방/장착 변경과 실패가 기존 개선을 보존한다.
- 실제 그래픽 검사 **3회(write/continue/purchase)·두 해상도 화면 44장**을 직접 검토했다. 구매/완료/저장 실패, 현장 발견 대기, 실패/귀환 결과, 분석 시간 유무와 거점/이어하기 보유 상태의 글자 잘림·버튼 겹침이 없다. 전체 화면 묶음과 이어하기 원본 크기를 확인했다. 화면 경로: `C:/Users/user/AppData/Local/Temp/dev0411-render-61104fff28814886b7d78ed003934ed0/`.
- 원본: [전체 자동 검사](dev0411_automated_results.json), [구매/발견/효과](dev0411_upgrade_results.json), [새 실행 이어하기](dev0411_continue_results.json), [직접 구매/최소 지원](dev0411_purchase_support_results.json), [그래픽 검사/화면 목록](dev0411_render_results.json), [문서·보존 검사](dev0411_document_results.json).
- 전체 로그: `C:/Users/user/AppData/Local/Temp/dungeon-g2-20261004-011822-706bb1d45a264d1395689d9305d1b33a/results.json`. 기준 HEAD `564eb0c`, `src`·`tests`·`project.godot` SHA-256은 `df6f1670fad74d1cf6418842280de987d0ea3760a74a4a3dd4cadd7cd0dad310`이며 전체/그래픽 검사 뒤 같은 값임을 확인했다. 실제 실행 바이트 기준이고 다른 환경 줄바꿈은 포함하지 않는다.
- 활성 Markdown 링크/앵커·동결 원본 SHA-256 6개/사본 3개·`git diff --check` 통과. 두 정합성 시점 표는 HEAD와 같고 Story/Reference·동결 파일은 변경하지 않았다. 사용자 승인인 혼합 획득 방향과 미확정 시험 가격/효과/발견 배치를 구분했다.

**DEV-0411 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음은 **DEV-0412 — 휴대 도구 준비 규칙 정리**다. 이번 작업은 사용자 로컬 커밋 승인 상태이며 커밋 전에는 로컬 10커밋 앞섬·뒤처짐 0이었다. push하지 않았다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0412 휴대 도구 준비 규칙 정리 검사

- 2026-10-06 DEV-0411 `210858e` 뒤 착수 fetch와 깨끗한 작업 트리·뒤처짐 0/로컬 11커밋 앞섬을 확인했다. 기본 2개 무료+추가 구매의 사용자 선택만 DEC-113·GDD·confirmed 경제 규칙에 반영했다.
- [도구 검토안](../design/tool_preparation.md)은 `draft`, Q-026은 `provisional`이다. 총수량 0~4·추가 단가 5·개당 무게 0.25, 부족분 구매/생환 반환·실패/종료 손실·출정 예약 저장은 미적용 제안으로 표시했다. Story·Reference·기존 결정과 동결 원본은 유지한다.
- 실제 코드에서 최초 활성화 2개·유효 투척 시작 1개 소비·메뉴/포커스/비행 취소, 별도 수량·현재 도구 무게 0, 준비 수량/가격/재고 저장의 부재, 출정 번호는 런에서 증가하지만 시작 저장이 없는 점을 확인했다. 새 프로세스·구형 전환과 재지급 방지 계약은 후속 검증 요구이며 실행 결과가 아니다.
- 활성 Markdown 링크/앵커·동결 원본 6개 SHA-256/아카이브 사본 3개·질문/결정 ID 중복·두 정합성 시점 표 보존·변경 범위·공백 검사 결과는 [문서 검사 원본](dev0412_document_results.json)에 기록한다. 검사 시점은 G5 완료 후다.
- `src`·`tests`·`project.godot`은 수정하지 않았다. `tests/run_g2_checks.ps1`의 `Get-G2SourceHash`로 측정한 `df6f1670fad74d1cf6418842280de987d0ea3760a74a4a3dd4cadd7cd0dad310`은 [DEV-0411 전체](dev0411_automated_results.json)·[화면](dev0411_render_results.json) 보고서와 같다. 이전 90/90 실행·화면 44장은 기존 근거이며 **이번 신규 게임/그래픽 실행은 0회**다. 해시는 실제 작업 트리의 실행 바이트 기준이다.
- 재현: 활성 Markdown 링크/앵커 → 이관 대장의 원본 6개/사본 3개 → Q/DEC ID와 상태·승인 범위·검토안/인계의 수량 관계 및 코드 소유자 대조 → 소스 해시와 DEV-0411 보고서 대조 → HEAD 대비 검사 시점 표·Story/Reference·변경 범위 → `git diff --check`. 유료 수량/저장/무게의 게임 검사는 DEV-0413에서 수행한다.

**DEV-0412 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 다음은 **DEV-0413 — 거점 소음 유인물 준비**다. 이번 작업은 사용자 로컬 커밋 승인 상태이며 커밋 전에는 로컬 11커밋 앞섬·뒤처짐 0이었다. push하지 않았다. **정합성 검사: 아직 아님** — 다음 정기 검사는 G5 완료 후다.

## DEV-0413 거점 소음 유인물 준비 검사

- 기준: DEV-0412 `2a1e744` 뒤 미커밋 변경의 실행 소스 SHA-256 `304c47fe2d3be7bedfc1f0f334e580371717c826fb80fec69866fbc4ffa816fb`. 원본 실행 바이트 기준이며 운영체제 줄바꿈 정규화 뒤의 Git blob 해시와 구분한다.
- [전체 자동 검사 원본](dev0413_automated_results.json): Godot 4.7.1 headless, 49개 스모크 장면과 기존 새 프로세스/구형/분기 검사 포함 **92/92** 통과. 실제 앱 준비→구매/수량 축소→돈 0 최소 복구→F 소비→입구 귀환/위험 실패→정산/재출정과 0개 무료 출정을 실행했다. 기존 비상 탈출·감정/판매/등록/연구/수리/하네스/발견·보호/빠른 버리기·역사적 무료 2개 시험도 유지한다.
- 새 도메인 검사는 잔액 0/4/5/9/10/int64최대 × 재고 0/1/2 × 총량 0~4 **90조합**, 무료 먼저 사용/정상·비상·실패 **45조합**, 잘못된 타입/분수/한도·단가 곱셈 초과·오래된 견적/가격·구형 1~5 읽기 보존과 정상 저장 전환을 확인한다. 임의 상태로 준비한 경계이며 이 수치를 모두 실제 플레이한 것으로 세지 않는다.
- 적재 경계는 2.5/4.0 바로 아래·동일·위를 검사했다. 별도 준비한 실제 월드에서 무게 2.0 회수품+무료 도구 0.5로 부담 단계에 놓고, F 한 번으로 2.25·정상 단계가 되며 이동 속도 증가/소음 반경 감소·회수품 슬롯 보존을 확인했다. 포커스 상실/비행 중 비활성/재활성은 소비를 취소하지 않았다. 실제 앱 메뉴 중 투척 정지·연타 거절도 검사했다.
- [출정 경계 검사 원본](dev0413_boundary_results.json): 예약·시작 표식·정산 저장의 **각 직전/직후 6곳**에서 테스트 저장소가 신호 파일을 만들고, 감독 프로세스가 그 자식 Godot만 강제 종료했다. 이어하기 **10회**에서 예약 반환/시작 후 미반환/정산 후 중복 반환 방지·ID 보존·복구 쓰기 두 번 실패 후 재시도를 검사했다. 파일 읽기는 바이트를 유지한다. 직접 구성한 거점 재고로 시작하되 출정/반환은 실제 앱 이벤트와 E 귀환을 쓴다. 시작 저장 실패+복구 저장 실패는 별도 스모크에서 다른 서비스 잠금과 재시도 후 출정/정산을 검사한다.
- [화면 검사 원본](dev0413_render_results.json): Compatibility 그래픽 실행 2회, 1152×648/1600×900 화면 **32장**. 준비 선택/가격·잔액·구매 실패 재시도·무게/수량·귀환/복구 안내·키보드 선택/Enter/Esc/마우스를 검사하고 화면을 직접 확인했다. 플레이어의 난도/경제 체감 평가는 별도다.
- 기존 회귀의 `출정 시 파일 불변` 가정은 예약/시작 기록 검증과 영구 보유/내구 불변 검증으로 바꿨다. 탐험 중 회수/결과 미리 보기가 저장하지 않는 검사는 시작 기록 이후 바이트를 기준으로 유지했다. 신규 숫자 필드를 구형 보완/JSON 재읽기에서 같은 정수로 정규화했다. 초기 검사 실패는 해당 원인을 보완한 뒤 전체를 다시 실행한 결과로 대체했다. 이전 작업 보고서는 변경하지 않았다.
- [문서 검사 원본](dev0413_document_results.json): 활성 링크/앵커, 동결 6개 SHA-256·아카이브 사본 3개, 두 정합성 시점 표·범위·미결정 상태와 `git diff --check`를 검사한다. 이번 최종 실행 자료는 기존 DEV-0411/0412 자료와 구분한다.

재현 명령:

```powershell
./tests/run_g2_checks.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe -Repetitions 1 -TimeoutSeconds 90
./tests/run_lure_boundaries.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe
# 독립된 새 출력 디렉터리로 실제 화면 검사
& C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --path . res://tests/smoke/lure_preparation_smoke.tscn -- --lure-render --lure-directory=C:/tmp/dev0413-new-render
& C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --path . res://tests/smoke/lure_departure_smoke.tscn -- --lure-render --lure-directory=C:/tmp/dev0413-new-recovery
```

실행 원본 위치: `C:\Users\user\AppData\Local\Temp\dungeon-g2-20261006-022526-58319f3fb59a42efadce590dda7ac044`, `C:\Users\user\AppData\Local\Temp\dungeon-lure-boundaries-c6bbf670199f45bab6fb1f8606a8d320`, `C:\Users\user\AppData\Local\Temp\dev0413-render-d47e39911e2541f9a0b8012534f79c59`. 소스와 JSON 요약은 저장소에서 재현할 수 있고 임시 스크린샷/엔진 로그의 영구 보관을 약속하지 않는다.

**DEV-0413 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음 **DEV-0414 — 출정별 비용 표시 규칙 정리**. 커밋 전에는 로컬 12커밋 앞섬·뒤처짐 0이었다. 사용자 로컬 커밋 승인, push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0414 출정별 비용 표시 규칙 정리 검사

2026-10-06 문서 작업이다. 코드·장면·데이터·저장 스키마 6을 변경하지 않는다. 직전 DEV-0413 `7419244`에서 착수했고 fetch 뒤 로컬 13커밋 앞섬·뒤처짐 0·깨끗한 작업 트리를 확인했다.

- [검토안](../design/expedition_cost_reporting.md)은 현재 결제/정산과 미래 표시 계약을 나누며 `draft`다. 사용자가 선택한 소모 원가 기준 손익과 실제 현금 변화 별도 표시를 DEC-114로 기록했다. Q-027에는 집계 기간·재고 배정·구형 원가·세부 화면/저장·사람 검토를 남기고 세부 제안까지 일괄 승인한 것으로 처리하지 않는다.
- 활성 Markdown 링크/앵커, 원본 6개 SHA-256·아카이브 사본 3개, 문서 상태·ID·범위·두 정합성 시점 표, 숫자 예의 손익/현금/재고 관계와 `git diff --check`를 검사한다.
- 실행 소스 SHA-256은 `304c47fe2d3be7bedfc1f0f334e580371717c826fb80fec69866fbc4ffa816fb`다. `tests/run_g2_checks.ps1`의 `Get-G2SourceHash`를 새로 실행하여 DEV-0413 결과와 일치함을 확인했다. DEV-0413의 92/92 실행·두 해상도 화면 32장은 기존 근거이며 이번 재실행은 게임 0회·그래픽 0회다.
- [이번 문서 검사 원본](dev0414_document_results.json)은 활성 문서 49개·상대 링크/앵커, 동결 원본 6개·사본 3개와 숫자 예 10개의 손익/현금·재고 대조 결과를 기록한다. 두 정합성 시점 표·소스 해시·문서 상태/ID·범위·공백 검사도 통과했다. 이전 실행/문서 JSON은 유지한다. 원가가 없는 과거 재고를 0이나 현재 단가로 채우지 않는 계약, 사용 원가와 실패의 휴대 전체 소실을 중복 합산하지 않는 계약을 직접 대조했다.

**DEV-0414 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 사용자 선택을 반영한 최종 문서 검사도 통과했다. 다음 DEV-0415 — 출정별 비용 표시 연결. 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0415 출정별 비용 표시 연결 검사

2026-10-08, DEV-0414 `653ed9d`에서 착수했다. fetch 후 로컬 14커밋 앞섬·뒤처짐 0·깨끗한 작업 트리 확인, `MIG-CHG-047` 선기록 뒤 제한된 [비용 시험](../design/expedition_cost_reporting.md#dev-0415-비용-표시-시험-적용)을 연결했다. 최종 실행 소스 SHA-256은 `28a056c1731106c8585c37040424a0c8746a1bacc3aa0d4c433637094b323d5b`다.

| 검사 | 결과와 범위 |
|---|---|
| 전체 실행 | [자동 기록](dev0415_automated_results.json): Godot 4.7.1, 1회 95/95 프로세스·52개 스모크 장면. 기존 기능/구형 저장/실패 경로와 새 비용 검사 포함, 진단 없음. 반복 2회 또는 사람 플레이 평가로 부풀리지 않음 |
| 계산/저장 | `expedition_costs_smoke`: 문서 숫자 예 10개, 단가 5/7 FIFO·두 출정·예약 복구·미정산 종료, 원가 미기록과 신규 재고 혼합, 무료 지원/발견, int64 합계/잔액 경계·구형 1~6·손상 필드/완료 보고/ID·재시도. 모르는 원가는 현재 가격이나 0으로 확정하지 않음 |
| 거래 실패/재시도 | `cost_boundary_smoke`: 구매·감정·판매·수리·개선·예약·시작·정산·예약 복구·시작 후 종료 복구 10종의 후보 저장을 두 번 실패시킨 뒤 성공, 원본 바이트·돈/원가/거래/최근 결과를 비교 |
| 프로세스 경계 | [경계 기록](dev0415_boundary_results.json): 위 10종 × 저장 전/후 20곳에서 해당 자식 프로세스만 강제 종료하고 독립된 새 실행 20회로 읽음. 5/7 혼합 재고·서비스 금액·시작/예약·최근 결과·다음 기간과 원본 바이트 보존 확인. 실제 앱이 아닌 준비된 도메인 후보 경계임 |
| 실제 앱 | `cost_flow_smoke`: 마우스로 준비·비용 탭·출정·정산, 키보드 수량/확정/스크롤과 F 세 번 투척, 무거운 시험 회수품만 회수해 입구 귀환. 두 출정에서 +25/+20/120 → +25/+30/150 확인. 정산 저장 실패/재시도·중복 요청, 앱 재생성의 열린 준비/최근 결과 복구 포함. 이 재생성은 동일 프로세스의 테스트 전역 상태 초기화임 |
| 화면 | [화면 기록](dev0415_render_results.json): 그래픽 실행 1회·1152×648/1600×900·60장 생성. 실제 경로와 준비된 음수·미기록·int64 양/음수·재시도 화면을 구분. 모든 캡처에서 패널 범위 검사, 대표 경계 이미지를 직접 열어 읽기/버튼/스크롤 확인. 최종 가격·사람 이해도 통과를 뜻하지 않음 |
| 문서/보존 | [문서 기록](dev0415_document_results.json): 활성 Markdown 링크/앵커·동결 SHA-256 6개와 사본 3개·두 시점 표 보존·최종 실행 해시 일치·`git diff --check` |

초기 집중 검사에서 테스트 재생성 시 전역 Boot 초기화 누락과 Variant 추론 경고, 전체 검사에서 이전 저장 필드 목록 1곳을 발견해 검사 장면을 바로잡았다. `hub_upgrade`에 기본 고정 프레임 인자를 빼고 실행한 예비 검사 1회는 시간 제한에 걸렸고, 정규 `--fixed-fps 60` 실행과 최종 전체 검사에서는 통과했다. 최초 제한 환경에서는 기존 원자적 파일 교체가 실패해 승인된 엔진 실행 환경에서 검증했다. 실패한 예비 실행을 최종 성공 횟수에 포함하지 않는다.

재현 명령(저장소 루트, 기존 Godot 경로 사용):

```powershell
./tests/run_g2_checks.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe -Repetitions 1 -TimeoutSeconds 90
./tests/run_cost_boundaries.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe
& 'C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe' --path . --rendering-method gl_compatibility --fixed-fps 60 --quit-after 20000 res://tests/smoke/cost_flow_smoke.tscn -- --cost-render
```

원시 로그/이미지 위치는 각 JSON의 `evidence_directory`에 남겼다. 실행 파일·개인 진행 기록·이미지 전체는 저장소에 추가하지 않았다. 이전 DEV 자료와 동결 원본을 변경하지 않았다. **DEV-0415 구현·검증 완료, 사용자 로컬 커밋 승인.** 다음 **DEV-0416 — G4 완료 조건 검토**. 커밋 전에는 로컬 14커밋 앞섬·뒤처짐 0이었다. 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0416 G4 완료 조건 검토 검사

2026-10-09 한국 시각, DEV-0415 `27c068434937e0ec6545fc85152fa7c269c3c72c`의 실행 소스를 변경하지 않고 검토했다. 착수 fetch 뒤 로컬 15커밋 앞섬·뒤처짐 0·깨끗한 작업 트리를 확인했다. `MIG-CHG-048` 뒤 [G4 검토 기록](g4_meta_review.md)에 기능/조건 대조·자동 근거의 한계·목표/의뢰 공백과 사람 평가 잔여를 기록했다.

| 검사 | 결과와 범위 |
|---|---|
| 이번 전체 회귀 | [자동 기록](dev0416_automated_results.json): Godot 4.7.1, 1회 반복 **95/95 프로세스·52개 스모크 장면**, 오류/무시 진단 없음. 기존 기능·새 프로세스 이어하기·구형 저장 분기와 비용 계산/실제 두 출정/후보 저장 실패·재시도 포함 |
| 소스 동일성 | `Get-G2SourceHash` 결과 `28a056c1731106c8585c37040424a0c8746a1bacc3aa0d4c433637094b323d5b`. DEV-0415 최종 기록·이번 실행·현재 트리 일치. src·tests·project.godot 실행 바이트 기준 |
| 이전 검사 자료 | DEV-0415의 별도 강제 종료 20경계와 두 해상도 화면 60장을 같은 코드의 기존 근거로 유지. 이번 그래픽/외부 강제 종료 실행은 0회. 실제 앱 검사와 준비된 상태/효과 경계·같은 프로세스 앱 재생성을 구분 |
| 문서·범위 | [문서 기록](dev0416_document_results.json): 활성 Markdown 상대 링크/앵커, 원본 6개 SHA-256·아카이브 사본 3개, 두 정기 검사 표, 소스/이전 결과/GDD/Design/Story/Reference 보존, 단일 작업 범위와 `git diff --check` |

재현 명령(저장소 루트):

```powershell
./tests/run_g2_checks.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe -Repetitions 1 -TimeoutSeconds 90
. ./tests/run_g2_checks.ps1
Get-G2SourceHash (Get-Location).Path
```

이번 원시 실행 로그는 `C:\Users\user\AppData\Local\Temp\dungeon-g2-20261008-215752-415038815f3049dfbee774fa3be4ed5b`에 있다. JSON의 시각은 UTC이며 한국 시각으로 2026-10-09다. 임시 로그의 영구 보관을 약속하지 않으며 저장소의 검사 코드와 JSON 요약으로 재현한다. 공용 실행기의 원래 scope는 G2이지만 이번 사본에는 DEV-0416 검토 범위와 원래 scope를 함께 기록했다. 이전 결과 파일은 덮어쓰지 않았다.

**DEV-0416 검토·검증 완료, 사용자 로컬 커밋 승인. G4 전체 완료 보류.** 다음 **DEV-0417 — 거점 목표·의뢰 최소 범위 정리**. 코드나 제품 규칙을 바꾸지 않았고 G5는 시작하지 않았다. 커밋 전에는 로컬 15커밋 앞섬·뒤처짐 0이었다. 2026-10-09 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0417 거점 목표·의뢰 최소 범위 정리 검사

2026-10-09 문서 작업이다. DEV-0416 `58b481e` 뒤 fetch와 로컬 16커밋 앞섬·뒤처짐 0·깨끗한 작업 트리를 확인하고 `MIG-CHG-049`을 먼저 기록했다. 사용자 선택을 DEC-115에 한정해 반영하고 [목표·의뢰 검토안](../design/expedition_objectives.md)과 Q-028에 세부 미적용 제안을 남겼다.

- [문서 검사 원본](dev0417_document_results.json): 활성 Markdown 상대 링크/앵커, 원본 SHA-256 6개·아카이브 사본 3개, 두 정기 검사 시점 표 보존, 결정/질문 ID·상태·승인 범위, 소스/이전 근거/Story/Reference 보존, 단일 작업 범위와 `git diff --check`를 검사한다.
- 수치 예 6개는 기존 판매가 10+30, 제안 보상 10, 도구 취득 원가 5를 사용했다. 판매+보상·운영비/투자·현금과 지갑 반영을 구분하고 `손익-현금 = 투자+기말 재고 원가-기초 재고 원가`를 대조했다. 런타임 의뢰 구현 검사가 아니라 문서 계산 예의 확인이다.
- 상태 사례는 자유 수색/달성/미달성, 버리기 뒤 수량 감소·미확인/보호 물품 제외, 비상 귀환·실패/시작 후 종료·예약 복구·정산 저장 실패/재시도·중복 지급·구형/미지원의 계약을 대조했다. 후속 실제 앱/저장 경계 검사를 이미 수행했다고 계산하지 않는다.
- `Get-G2SourceHash` 결과는 `28a056c1731106c8585c37040424a0c8746a1bacc3aa0d4c433637094b323d5b`이며 DEV-0416 최종 실행과 같다. 코드·장면·데이터·tests·project.godot 및 저장 스키마 7을 유지한다. 이번 게임/그래픽 실행은 0회다. DEV-0416의 95/95와 이전 화면/강제 종료 자료는 기존 근거로 보존했다.

검증 순서: 활성 링크/앵커 → 이관 대장의 원본/사본 → DEC-115·Q-028·검토안/GDD/경제/인계의 방향과 미적용 상태 → 수치/상태 사례 → 실행 소스 해시/이전 근거 → HEAD 대비 두 시점 표·변경 범위 → `git diff --check`. 후속 DEV-0418에서 실제 목표/보상/저장 기능과 기존 회귀를 실행한다.

**DEV-0417 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 다음 **DEV-0418 — 거점 선택 의뢰 연결**. G4 전체 완료·최종 밸런스·사람 평가는 보류한다. 커밋 전에는 로컬 16커밋 앞섬·뒤처짐 0이었다. 2026-10-09 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0418 거점 선택 의뢰 연결 검사

2026-10-09, DEV-0417 `1fd4dba26c39f6623507a7f7ef58f289a8e45a24` 뒤 fetch와 로컬 17커밋 앞섬·뒤처짐 0·깨끗한 작업 트리를 확인했다. MIG-CHG-050 뒤 DEC-115·confirmed 규칙과 Q-028의 제한된 시험을 구현했다. 자유 수색·선택 의뢰 하나, 확인된 비보호 일반 폐품 2개 안전 귀환·보상 10·미달성 정상 정산·선택 초기화를 연결했다.

| 검사 | 결과와 범위 |
|---|---|
| 전체 회귀 | [자동 기록](dev0418_automated_results.json): Godot 4.7.1, **98/98 프로세스·55개 스모크 장면**, 1회 반복. 오류/무시 진단 없음. 기존 감정/판매/등록/연구·수리·장착/성장·도구/비용·생존·설정·새 프로세스 이어하기와 구형 저장 분기 포함 |
| 의뢰 계산·저장 | [도메인 기록](dev0418_objective_results.json): 자유/선택 × 0~3개 × 일반/비상 귀환/실패의 **24개 분기**, 문서 숫자 예 **6개** 통과. 같은 종류·미확인/보호/잔재/원본/거점 재고 제외·부분 성공의 보관/판매, 선택 사본/오래된 요청·예약/시작 복구·반복 ID, 원가 미기록·지갑/수입 int64 초과 검사. 구형 1~6은 기존 비용 검사, 7은 최근 보고·예약/시작/정산 보존을 검사하고 손상/미지원 기록은 보존 |
| 저장 원자성 | [종료 기록](dev0418_boundary_results.json): 선택·해제·예약·시작·정산·예약 복구·시작 복구의 저장 직전/직후 **14경계**에서 테스트 자식 프로세스만 종료한 뒤 새 프로세스로 검증. 전체 회귀 안의 별도 의뢰 경계 스모크는 각 거래에서 두 번 저장 실패 후 재시도. 보상/돈/선택/최근 보고/도구/다음 기간 일치와 중복 거절 확인 |
| 실제 앱·화면 | [화면 기록](dev0418_render_results.json): 마우스 탭/버튼과 키보드 선택, 실제 이동/E 회수·두 개 회수 뒤 가벼운 물품 버리기·귀환/실패·자유 수색의 **4출정**, 선택/정산 저장 실패·재시도·앱 재생성/최근 보고 유지. 1152×648·1600×900의 경계 검사와 PNG **42장**, 선택/자유/저장 실패·진척·달성/미달성·최근 실패 보고·스크롤 끝 대표 화면 직접 확인. 같은 프로세스의 앱 재생성과 위 강제 종료/새 프로세스 검사를 구분 |
| 문서·보존 | [문서 기록](dev0418_document_results.json): 활성 링크/앵커, 동결 원본 SHA-256 6개·아카이브 사본 3개, 두 검사 시점 표·기존 증거/Story/Reference 보존, 문서 상태·단일 작업 범위, 소스 해시와 `git diff --check` |

최종 실행 소스 SHA-256은 **`947eea08391530d0863c7892f3bb4f77f1a10dc5862150043c7fa50de30ec543`**다. 전체 회귀·종료 경계·화면 기록과 현재 src/tests/project.godot가 같은 소스다. 최초 검사 중 누락된 규칙 검증 메서드와 JSON 숫자 정규화를 보완했다. 기존 G3 검사 한 곳의 저장 필드 목록도 스키마 8에 맞춰 갱신했으며 최종 98/98을 통과했다. 초기 실패 실행을 통과 건수에 포함하지 않았다.

재현 명령(저장소 루트, 화면 출력 폴더는 새 임시 폴더 사용):

```powershell
./tests/run_g2_checks.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe -Repetitions 1 -TimeoutSeconds 90
./tests/run_objective_boundaries.ps1 -GodotBin C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe
& C:/tmp/godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe --path . --rendering-method gl_compatibility --fixed-fps 60 --quit-after 20000 res://tests/smoke/objective_flow_smoke.tscn -- --objective-render --objective-directory=C:/tmp/dev0418-new-render
. ./tests/run_g2_checks.ps1
Get-G2SourceHash (Get-Location).Path
```

원시 실행 위치는 `C:\Users\user\AppData\Local\Temp\dungeon-g2-20261009-000024-aa6745cfb27041969c60f1b9b97f7f9c`, `C:\Users\user\AppData\Local\Temp\dungeon-objective-boundaries-a02eedefb93e4050998cbb83a751132e`, `C:\Users\user\AppData\Local\Temp\dev0418-final-render`다. 임시 이미지/로그의 영구 보관을 약속하지 않으며 저장소 검사 코드와 JSON으로 재현한다. 전체 실행기의 원래 scope는 G2이며 이번 JSON 사본은 원래 scope와 DEV-0418 범위를 함께 기록했다. 이전 검사 결과를 덮어쓰지 않았다.

**DEV-0418 구현·검증 완료, 사용자 로컬 커밋 승인.** 2026-10-09 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. 다음 **DEV-0419 — G4 보완 완료 조건 검토**다. 최종 보상/반복 경제·메뉴 사용성·사람 판단·G4 전체 완료는 보류한다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0419 G4 보완 완료 조건 검토 검사

2026-10-10, 기준 DEV-0418 93d2b5a. 시작 fetch에서 앞섬/뒤처짐 0·깨끗한 main을 확인했고 MIG-CHG-051을 먼저 기록했다. [G4 검토](g4_meta_review.md#dev-0419-보완-완료-조건-검토)는 구현·현재 기준·여섯 조건·후속 범위를 대조하는 Project 작업이다.

| 검사 | 결과와 범위 |
|---|---|
| 이번 전체 회귀 | [새 자동 기록](dev0419_automated_results.json): Godot 4.7.1, 1회 반복 98/98 프로세스·55개 스모크 장면. 오류/무시 진단 없음. 의뢰 계산·실제 4출정·실패/재시도와 기존 거래·저장·새 프로세스 이어하기 포함 |
| 이번 실행 소스 | 실행 전후 Get-G2SourceHash: e013691444f7c1e21f687b9c75daa2b4939bb1b8456c7ae9dae69ffcf3f38cb1. 이번 작업은 src·tests·project.godot를 변경하지 않음 |
| 이전 소스와 구분 | DEV-0418 기록 원시 해시 947eea08391530d0863c7892f3bb4f77f1a10dc5862150043c7fa50de30ec543와 다름. 현재 환경은 core.autocrlf=true이며 파일별 줄바꿈이 섞여 있다. 이전 환경의 파일별 바이트 목록은 없어 차이 원인을 줄바꿈만으로 단정하지 않음. 현재 HEAD의 모든 추적 실행 파일과 줄바꿈 정규화 내용 일치, 소스 미변경 및 이번 실행 전후 해시 일치를 따로 확인 |
| 이전 외부 종료/화면 | DEV-0418 저장 직전/직후 14경계·두 해상도 42장 등 기존 JSON 근거 보존. 이번 별도 그래픽/외부 강제 종료 0회. 이전 PNG를 이 환경에서 새로 보거나 사람 평가한 것으로 세지 않음 |
| 문서·보존 | [문서 검사](dev0419_document_results.json): 활성 링크/앵커·Front Matter 경로, 동결 원본 6개·사본 3개, 두 정기 검사 표, 기존 결과·GDD/Design/Story/Reference 보존·단일 작업 범위·git diff --check |

재현 명령(저장소 루트, GodotBin은 설치 경로로 바꾼다):

    ./tests/run_g2_checks.ps1 -GodotBin C:/Users/makist_code_04/AppData/Local/Temp/codex-godot-4.7.1/Godot_v4.7.1-stable_win64_console.exe -Repetitions 1 -TimeoutSeconds 90
    . ./tests/run_g2_checks.ps1
    Get-G2SourceHash (Get-Location).Path
    git diff --exit-code HEAD -- src tests project.godot
    git diff --check

이번 원시 로그: C:\Users\makist_code_04\AppData\Local\Temp\dungeon-g2-20261010-034436-ea375d2efd3e410295382868ffb8ef7a. JSON 시각은 UTC이고 사용자 보고일은 한국 시각 2026-10-10이다. 임시 로그의 영구 보관을 약속하지 않는다. 새 사본은 원래 G2 scope와 DEV-0419 검토 범위를 함께 기록하고 checks·flows·시각·소스 해시·종료 결과는 원본 그대로 보존한다. 이전 결과를 덮어쓰지 않는다.

문서 검사 절차: 코드 펜스를 제외한 활성 Markdown 링크·앵커와 Front Matter related 경로 확인 → 이관 대장의 SHA-256과 동결 원본/사본 대조 → HEAD 대비 두 검사 시점 표·이전 결과·규칙 보존 → 실행 파일의 HEAD 내용/새 실행 해시 및 새 결과의 원시 보고 일치 → 여섯 조건·다음 작업·상태 확인 → 공백 검사. 원시 해시 불일치를 숨기거나 기존 기록을 새 해시로 수정하지 않는다.

첫 실행은 기능 검사 98건이 모두 통과했지만 Godot 초기 가져오기가 아이콘 .svg.import 5개의 줄바꿈을 바꿔 실행 전후 소스 해시 검사에서 실패했다. Git의 실제 내용 차이는 없음을 확인했고 초기화가 끝난 상태에서 전체 검사를 새로 실행했다. 첫 실행은 전체 통과 건수에 합산하지 않는다. 첫 원시 기록은 C:/Users/makist_code_04/AppData/Local/Temp/dungeon-g2-20261010-033737-f3b22923facc417f9209bbf05db9ca4d/results.json이며 문서 검사 JSON에도 실패 원인과 개수를 보존한다.

**DEV-0419 — G4 보완 완료 조건 검토·검증 완료, 사용자 로컬 커밋 승인.** 선택 의뢰의 기술 공백 해소와 기존 여섯 완료 조건을 대조하고 최신 코드의 전체 자동 검사 98/98건을 통과했다. 회수세·휴대용 감정의 기능 보완과 사람 평가가 남아 G4 전체 완료는 보류한다. 다음은 **DEV-0420 — 회수세 최소 규칙 정리**다. 기준 DEV-0418 93d2b5a에서 원격과 동기화된 상태로 시작했으며 2026-10-10 사용자가 검토 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0420 회수세 최소 규칙 검사

2026-10-10 기준 DEV-0419 215fdd0에서 문서만 변경했다. [회수세 검토안](../design/recovery_tax.md)·DEC-116·Q-029와 개발 인계가 같은 과세 대상/미적용 경계를 가리키는지 확인한다. 이번 [문서 검사 JSON](dev0420_document_results.json)은 활성 Markdown 51개·상대 링크/앵커 1777개·related 547개, 동결 원본 6개·사본 3개, 두 정기 시점 표, 이전 결과/Story/Reference 보존, HEAD 대비 실행 소스·단일 작업 범위와 공백 검사를 기록한다.

수치 예 T01~T09는 순수 정수 계산으로 세금·운영 손익·현금 변화·보유금·이번 입금을 대조한다. 거래 7+7의 합산/분할·버림 대안, 0/최대 정수/잘못된 요율/범위 초과와 재고 보존 등식을 확인한다. 이는 **문서의 계산 검증**이며 아직 없는 회수세 기능을 실행한 결과가 아니다.

코드와 저장 형식 변경이 없어 Godot 전체 검사는 새로 실행하지 않는다. DEV-0419의 [기존 98/98 결과](dev0419_automated_results.json)와 현재 소스 해시 일치 및 HEAD 내용 동일성을 확인하고 기존 보고 파일은 보존한다. 새 그래픽·외부 종료·사람 평가 결과는 생성하지 않는다. 회수세 적용 뒤 필요한 기능/저장/화면 검사는 DEV-0421 수용 기준이다.

검사 순서: 활성 링크/앵커·related → 동결 SHA-256/사본 → 두 검사 표/기존 상태·결정·근거 보존 → 수치 표/정수 경계 → 실행 소스 SHA-256/HEAD 내용 → 현재 인계와 git diff --check. 계산 예 9개·정수 경계 28개·잘못된 입력 7개 및 모든 문서/보존 검사를 통과했다. 상세 계산 입력/기대값과 결과는 JSON에 남겼다. 이번 소스 SHA-256은 e013691444f7c1e21f687b9c75daa2b4939bb1b8456c7ae9dae69ffcf3f38cb1로 DEV-0419 결과와 같다.

**DEV-0420 — 회수세 최소 규칙 정리 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 판매 대금만 과세하고 의뢰 보상은 전액 지급하는 사용자 방향을 DEC-116·GDD·경제 규칙에 반영했다. 10%·거래별 합산/절사·저장 전환은 미적용 시험 제안이며 Q-029에서 최종 판단을 추적한다. 코드·스키마 8은 그대로이며 회수세 구현·휴대용 감정·사람 평가가 남아 G4 전체 완료는 보류한다. 다음은 **DEV-0421 — 회수세 정산·보고 연결**이다. 기준 DEV-0419 215fdd0, 커밋 전 로컬 1커밋 앞섬·뒤처짐 0. 계산 예·정수 경계·문서 링크·원본/소스 보존·공백 검사 통과. 2026-10-10 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0421 회수세 정산·보고 연결 검사

2026-10-10, 기준 DEV-0420 aef0d2b에서 fetch 후 로컬 2커밋 앞섬·뒤처짐 0·깨끗한 작업 트리로 시작했다. MIG-CHG-053 뒤 DEC-116의 판매 과세·의뢰 보상 전액 지급을 [제한된 시험 적용](../design/recovery_tax.md#dev-0421-회수세-시험-적용)으로 연결했다.

- [자동 검사 JSON](dev0421_automated_results.json): Godot 4.7.1 전체 **99/99 실행·56개 스모크 장면·1회 전체 순환** 통과. 인증서 예외·엔진 오류/경고 없음. recovery_tax_smoke의 실제 도메인 T01~T09와 정수 경계 28건, 잘못된/누락 요율·분할 판매·가격/요율 변경·거부/중복·구형 1~8/혼합 기간을 검사했다. 이전 DEV-0420의 독립 비교식 검사와 구분한다.
- 실제 앱 비용 흐름: 두 출정의 손익/현금/잔액 **+22/+17/117 → +22/+27/144**. 의뢰 달성은 판매 40+보상 10에서 회수세 4·정산 입금 46·손익 +41·현금 +36·잔액 136. 세율 20%로 변경하면 정산 확정 대신 새 입금/잔액을 보여주고, 다시 10%로 돌려도 재확인 전 저장하지 않는다.
- 외부 종료 경계 **34/34**: 구매·감정·판매·수리·개선·예약·시작·정산·예약/시작 복구 10종 × 저장 전후 20건, 의뢰 선택·취소·예약·시작·정산·예약/시작 복구 7종 × 전후 14건. 각 지점에서 테스트 프로세스를 종료하고 새 프로세스로 기존값 또는 완성된 새 값을 읽었다. 물품/지갑/세금/보상의 부분 반영·재징수 없음.
- 그래픽 **3회 통과, 1152×648·1600×900의 118장**: 보관품 판매 8장·의뢰/재확인 50장·비용 60장. 자동 레이아웃/입력/스크롤 검사를 수행하고 대표 10장을 직접 열어 판매 총액/세금/입금, 긴 금액·음수·원가 미기록, 저장 오류/재시도와 재확인 안내를 확인했다. 모든 118장을 직접 열어 보았다는 뜻은 아니며 사람 플레이 평가를 대신하지 않는다.
- [문서 검사 JSON](dev0421_document_results.json): 활성 상대 링크/앵커/related, 동결 원본 6개·사본 3개, 두 정기 시점 표·이전 결정/질문 상태·Story/Reference/기존 결과 보존, 단일 작업 변경 범위와 공백을 검사한다.

최종 전체/그래픽 실행 소스는 **29d190874f93e8d3edbdeae7b55774acbe5d5b790a7a4816dadb425244c050ae**, src/tests/project.godot 514개다. 외부 종료 검사는 **c2f7a4ae9050d8a6d41c5f82812ddf7d26274d05bcda45ca015ab2f6b764b9e9**로 실행했다. 그 뒤 바뀐 것은 g3_survival_flow_smoke의 세금 적용 전 예상 잔액/기록과 파일 줄바꿈뿐이며, 현재 소스에서 그 파일만 이전 바이트로 대체해 이전 해시를 재구성했다. 제품 코드와 종료 검사 코드가 같음을 확인했으며 두 해시를 같은 것으로 표시하지 않는다.

초기 검사에서 구형 무세금 예상값과 JSON 숫자 정규화·복사 경계를 보완했다. 실패한 초기 진단은 최종 통과 99건에 포함하지 않는다. 검사 중 개인 진행 파일을 쓰지 않고 매번 별도 임시 저장소를 사용했다. 구형 파일은 읽기만으로 변경하지 않으며 정상 저장 시 9로 전환한다. 전환한 파일은 스키마 8만 지원하는 이전 앱에서 열 수 없다.

재현 명령은 저장소 루트에서 아래와 같다. GODOT_BIN은 Godot 4.7.1 콘솔 실행 파일 경로다. 그래픽은 Compatibility 렌더러로 실행하며 세 임시 디렉터리를 서로 다르게 지정한다.

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 90
./tests/run_cost_boundaries.ps1 -GodotBin $env:GODOT_BIN
./tests/run_objective_boundaries.ps1 -GodotBin $env:GODOT_BIN
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/hub_sale_smoke.tscn -- --sale-render --sale-directory=<fresh-sale-directory>
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/objective_flow_smoke.tscn -- --objective-render --objective-directory=<fresh-objective-directory>
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/cost_flow_smoke.tscn -- --cost-render --cost-directory=<fresh-cost-directory>
```

**DEV-0421 — 회수세 정산·보고 연결 구현·검증 완료, 사용자 로컬 커밋 승인.** 판매 대금에만 시험 회수세 10%를 적용하고 의뢰 보상은 전액 지급한다. 귀환/거점 판매·손익/현금 표시·스키마 9와 구형 1~8의 소급 없는 전환을 연결했다. 최종 세율·분할 절사와 사람 평가는 Q-029에 남는다. 전체 99/99·외부 종료 경계 34/34·그래픽 3회/두 해상도·문서/원본 보존·공백 검사를 통과했다. 다음은 **DEV-0422 — 휴대용 감정 최소 규칙 정리**이며 휴대용 감정·사람 평가가 남아 G4 전체 완료는 보류한다. 기준 aef0d2b, 기존 로컬 2커밋 앞섬·뒤처짐 0. 2026-10-10 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0422 휴대용 감정 최소 규칙 검사

기준 커밋은 DEV-0421 `0650530dab987533d3164882a8ed243e455b633f`다. 시작 fetch에서 main 로컬 3커밋 앞섬·원격 뒤처짐 0과 깨끗한 작업 트리를 확인했다. [검토안](../design/portable_appraisal.md)·DEC-117·Q-030과 관련 문서만 변경한다.

문서의 독립 기대 계산 P01~P10, 준비 수량/가격/잔액의 정수 경계 144개·무효 입력 11개·두 도구 잔량 무게 조합 90개를 검사한다. 이는 미적용 시험 제안의 계산 검산이며 게임 로직·저장·UI 실행 결과가 아니다. 실제 대상 검증·상태 전환/중복·구형 변환·종료/저장 원자성은 DEV-0423의 수용 기준으로 남긴다.

활성 Markdown 상대 링크/앵커·related, 동결 원본 6개 SHA-256·사본 3개, 기존 Story/Reference·결정/질문·이전 결과, 두 정기 검사 표와 작업 범위·공백을 확인한다. `Get-G2SourceHash`로 514개 소스 파일의 해시가 DEV-0421 결과의 `29d190874f93e8d3edbdeae7b55774acbe5d5b790a7a4816dadb425244c050ae`와 같은지 검사한다. 코드·데이터·스키마 변경이 없어 새 Godot/그래픽/외부 종료 검사는 실행하지 않는다. 기존 99/99는 DEV-0421의 과거 실행 근거이며 이번 새 결과로 계산하지 않는다.

최종 검사는 활성 Markdown 52개·상대 링크/앵커 1,870개·related 567개, 계산 예 10개·준비 경계 144개·무효 입력 11개·합산 무게 90개와 원본/소스 보존·공백 검사 모두 통과했다. [DEV-0422 문서 검사 JSON](dev0422_document_results.json)에 결과를 기록했다. 가격/휴대 한도·거점/현장 서비스 역할·운반 판단에 대한 사람 평가는 Q-030에 남기고 다른 열린 질문을 해결 처리하지 않는다.

**DEV-0422 — 휴대용 감정 최소 규칙 정리 문서 작성·검증 완료, 사용자 로컬 커밋 승인.** 사용자 선택인 횟수 제한 확정 감정·유료 구매/휴대 수량 선택·안전 귀환 미사용분 보관을 DEC-117·GDD·아이템/경제 규칙에 반영했다. 같은 물품은 재감정하지 않는다. 단가10·휴대/총 재고2·무게0.25·사용/실패/저장 세부는 미적용 시험 제안이며 Q-030에서 후속 검증·최종 수치와 사람 평가를 추적한다. 코드·시험 데이터·스키마 9는 유지한다. 다음은 **DEV-0423 — 휴대용 감정 준비·사용·정산 연결**이며 실제 구현과 사람 평가가 남아 G4 전체 완료는 보류한다. 기준 0650530, 커밋 전 승인된 로컬 3커밋 앞섬·뒤처짐 0. 2026-10-10 사용자가 검토된 DEV-0422 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0423 휴대용 감정 연결 검사

MIG-CHG-055·DEC-117의 제한된 시험이다. Godot 4.7.1에서 [전체 검사](../../tests/run_g2_checks.ps1)는 새 감정 계산/구형/실제 흐름/현장 경계/저장 실패 검사와 별도 프로세스 이어하기를 포함한다. [감정 경계 장면](../../tests/smoke/portable_appraisal_boundary_smoke.gd)은 구매·선택·예약·시작·생환 정산·실패 정산·예약 복구·시작 후 복구의 저장 전후16경계를 외부에서 종료/재시작한다. [앱 종료 검사](../../tests/run_lure_boundaries.ps1)는 두 종류의 도구를 함께 배정한 실제 GameEntry에서 예약/시작/정산 저장 전후6경계의 종료와 복구를 검사한다.

실제 화면 입력으로 구매20, 유인물1개 사용, 미확인 잔재 회수/확정1회, 폐품2개 포함 귀환·판매240·세금24·보상10·입금226·기말돈306·감정도구1개 원가10 반환을 확인한다. 손익216과 현금206은 서로 다르다. 구매/정산 저장 실패 뒤 재시도·중복 요청·선택 부족 시 재견적도 포함한다. 별도 준비 사례로 일반 폐품 감정의 의뢰 갱신, 보호 원본/잔량0, 무게2.75→2.5→2.25의 부담 해제/이동·소음, 일반/비상 귀환·실패 보존 경계를 검사한다. 준비 사례의 종료 API를 실제 퇴로 플레이로 보고하지 않는다.

실제 그래픽 렌더러에서1152×648·1600×900의 견적/실패/미확인/감정 후/결과/최근 보고/재고 부족·긴 금액/잔액 부족·보호/잔량0을 캡처해 확인한다. 자동 동작과 화면 검사는 사람의 가격 적절성·운반 판단·거점/현장 서비스 역할 평가를 대신하지 않는다.

최종 결과: **전체104/104 프로세스·60개 스모크 장면·별도 프로세스 이어하기, 외부 종료22/22경계, 그래픽2회·두 해상도24장**을 통과했다. P01~P10 실제 계산, 준비 경계54개·구형/손상 저장65개와 실제 현장/보호/의뢰/무게 검사를 포함한다. 활성 Markdown52개·링크/앵커1,899개·related567개, 동결 원본6개·사본3개·이전 결과/Story/Reference/결정·열린 질문 상태·두 검사 표·공백 검사도 통과했다. 전체 실행 뒤에는 GameEntry 끝의 빈 줄 하나만 제거했다. 실행 소스와 최종 작업 트리의 해시를 모두 기록했으며 실행 내용은 동일하다.

재현 명령은 아래와 같다. 그래픽 검사는 `--headless` 없이 실행하고 시험 자료/캡처는 TEMP의 별도 디렉터리에 저장한다.

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1
./tests/run_cost_boundaries.ps1 -GodotBin $env:GODOT_BIN -Scene 'res://tests/smoke/portable_appraisal_boundary_smoke.tscn' -Marker '\[SmokeTest\] portable_appraisal_boundary_passed' -Actions @('purchase','selection','reserve','start','settle','failure','recover_reserved','recover_started')
./tests/run_lure_boundaries.ps1 -GodotBin $env:GODOT_BIN
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/portable_appraisal_flow_smoke.tscn -- --portable-render
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/portable_appraisal_field_smoke.tscn -- --portable-field-render
```

최종 프로세스 결과·소스 해시와 경계/화면 근거는 [자동 검사 JSON](dev0423_automated_results.json), 활성 링크·원본/사본·두 시점 표·이전 결과/Story/Reference 보존·변경 범위·공백 검사는 [문서 검사 JSON](dev0423_document_results.json)에 기록한다. 이전 DEV-0422 계산/문서 기록은 수정하지 않는다.

**DEV-0423 — 휴대용 감정 준비·사용·정산 연결 구현·검증 완료, 사용자 로컬 커밋 승인.** 유료 수량 선택/부족분 구매, 가방의 확정 감정과 잔량·합산 무게·의뢰 갱신, 안전 귀환 반환/실패 소실·비용 보고·저장/이어하기를 연결했다. 시험값은 단가10·휴대/총 재고2·기본0·개당 무게0.25이며 최종 수치와 사람 평가는 Q-030에 남긴다. 스키마10·거점15필드로 구형1~9를 보존 전환한다. 기준 3dc19c7, 승인된 로컬 4커밋 앞섬·뒤처짐 0에서 시작했다. 2026-10-10 사용자가 검토된 DEV-0423 결과의 로컬 커밋을 승인했으며 push하지 않았다. 다음은 **DEV-0424 — G4 보완 완료 조건 검토**다. G4 전체 완료와 G5 착수는 보류한다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0424 G4 보완 완료 조건 검토 검사

2026-10-11 한국 시각, 기준 DEV-0423 `1b6e90d5a080056998bde3bf6e1ca166a17ee0e1`. MIG-CHG-056 뒤 현재 코드를 변경하지 않고 G4 기능과 이전 보완의 연결을 검토했다.

- [전체 자동 검사](dev0424_automated_results.json): Godot 4.7.1, 1회 전체 순환 **104/104 프로세스·60개 스모크 장면**, 오류/경고·무시 진단 0. 새 프로세스 이어하기·구형1~9·후보 저장 실패/재시도와 현재 회수세/휴대 감정 경로를 포함한다.
- 실제 앱 자동 입력에서 판매240·세금24·보상10·입금226·기말돈306·손익216·현금206·미사용 감정 도구1개/원가10 반환을 다시 확인했다. 경계 검사의 직접 준비 잔액/상태와 실제 이동/조작을 구별한다.
- 실행 전후 원시 소스 SHA-256은 `385fdc871193842ebad4dccd980157821fbd6e516071337365fa55249de558a5`로 같다. HEAD 대비 src/tests/project.godot의 Git 내용은 동일하다. 환경별 줄바꿈 때문에 이전 작업의 원시 소스 해시와 같다고 가정하지 않는다.
- 이번 별도 그래픽·외부 강제 종료·사람 플레이는 0회다. DEV-0421·DEV-0423의 저장 종료/그래픽 자료는 이전 근거로 보존하며 새 실행 건수에 더하지 않는다.
- [문서 검사](dev0424_document_results.json)는 활성 Markdown의 상대 링크/앵커·related, 기록된 동결 원본6/사본3의 SHA-256, 소스/기존 결과·GDD/Design/Story/Reference/결정의 내용 보존, 30개 질문 상태·두 정기 시점 표·작업 범위와 `git diff --check`를 확인한다. Q-027·Q-030의 현재 시험 진행 표현만 정정하며 질문 상태는 보존한다.

첫 제한 환경 실행은 engine-version 뒤 project-import에서 실패했다. 출력에 기록된 sandbox 임시 로그 경로를 다음 명령에서 읽을 수 없어 정확한 원인을 확인하지 못했으며 이 시도를 통과104건에 합산하지 않는다. 일반 권한으로 같은 검사를 다시 실행해 104건과 실행 전후 해시 검사를 모두 통과했다. 진단을 무시하는 옵션은 사용하지 않았다.

재현 명령(저장소 루트, PowerShell 7, GODOT_BIN에 Godot 4.7.1 콘솔 경로 지정):

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 90 -OutputRoot 'C:/tmp/dev0424-review'
git diff --check
```

이번 성공 실행의 원시 보고서는 `C:/tmp/dev0424-review/dungeon-g2-20261011-011310-7937efda7cab431380b3154eb5f14af0/results.json`이다. 저장소 JSON은 checks/flows와 시간/해시를 그대로 보존하고 DEV-0424 범위·실패한 초기 시도·사람 평가 경계를 추가했다. 결과만 열람하는 환경에서는 저장소 JSON을 기준으로 읽고 임시 로그의 영구 보존은 가정하지 않는다.

**DEV-0424 — G4 보완 완료 조건 검토·검증 완료, 사용자 로컬 커밋 승인.** DEV-0419에서 남긴 회수세·휴대용 감정의 기술 공백 해소와 여섯 완료 조건의 기능 근거를 확인했다. 현재 코드의 전체 **104/104 실행·60개 스모크 장면**을 통과했다. 정산 이해·노련함·성장 선택·실패 뒤 재기 등 사람 평가가 남아 **G4 전체 완료와 G5 착수는 보류**한다. 다음은 **DEV-0425 — G4 사람 플레이 검토**다. 기준 DEV-0423 `1b6e90d`, 착수 시 main과 origin/main의 앞섬/뒤처짐 0. 2026-10-11 사용자가 검토된 DEV-0424 결과의 로컬 커밋을 승인했으며 push하지 않았다. **정합성 검사: 아직 아님 — G5 완료 후.**

## DEV-0425 G4 사람 플레이 검토 환경 검사

**DEV-0425 — G4 사람 플레이 검토·보완 인계 완료, 사용자 로컬 커밋 승인.** 실제 두 탐험과 사용자 답변에서 정산 가독성, 비상 방전의 효과 전달, 유인 후 활용 여유의 보완 필요를 확인했다. 도구·의뢰는 기본값을 사용했고 가방 칸은 이번 보완에서 보류한다. 서비스·성장 비교·돈0 최소 복구 등 미평가를 유지해 **G4 전체 완료와 G5 착수는 보류**한다. 검토 환경 포함 자동 **105/105 실행·61개 스모크 장면**, 문서/원본 보존·공백 검사를 통과했다. 기준 `13db00e`, 승인된 로컬 1커밋 앞섬·뒤처짐 0. 2026-10-11 사용자가 검토된 결과의 로컬 커밋을 승인했으며 push하지 않았다. 다음은 **DEV-0426 — 정산 화면 가독성 개선**이다. **정합성 검사: 아직 아님 — G5 완료 후.**

[검토 장면과 여섯 사례 실행 방법](g4_playtest_review.md#저장과-실행-방법)을 따른다. 실제 앱에 테스트 전용 진행/설정 저장소를 주입하며 제품 코드·스키마10·시험 가격/요율은 보존한다. 개별 스모크는 여섯 사례, 재실행/불일치/손상/불완전 세션 보존과 타이틀→거점→탐험의 분리 저장을 통과했다. 최초 검사는 JSON 정수/실수 표현을 직접 비교한 예상값 때문에 실패했으며, 도메인으로 복원한 값을 비교하도록 검사만 수정한 뒤 통과했다. 실패한 초기 실행을 성공 횟수에 합산하지 않는다.

2026-10-11 경제 사례를 그래픽 창으로 1회 열었다. 렌더러 시작과 탐험 진입 로그만 확인했으며 화면 배치나 사람의 이해도 통과로 세지 않는다. 이번 별도 외부 종료 검사는 0회다. 이전 작업의 강제 종료·그래픽 검사 자료를 이번 결과에 합산하지 않는다.

전체 회귀를 새로 1회 실행해 **105/105 프로세스·61개 스모크 장면**을 통과했다. 오류/경고·무시 진단은 0이며 실행 전후 소스 해시는 `0e324441a2651ecec8730d27990d8994b10403acb77517bb277dcd92ada5c74b`로 일치했다. [저장소 보고서](dev0425_automated_results.json)는 원시 보고서 `C:/tmp/dev0425-review/dungeon-g2-20261011-062300-ab53607def384b8c951db20517631796/results.json`의 checks/flows·시간·해시를 보존하고 작업 범위와 사람 평가 미완료를 덧붙였다.

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 90 -OutputRoot 'C:/tmp/dev0425-review'
git diff --check
```

[문서 검사](dev0425_document_results.json)는 활성 상대 링크/앵커·related, 동결 원본6/사본3, 기존 제품/테스트 소스와 이전 결과·GDD/Story/Design/Reference/결정, 30개 질문 상태·두 정기 시점 표·범위/공백을 확인한다. 새 테스트 6파일과 Project 기록은 DEV-0425에만 속하며 기존 내용 보존 검사를 새 코드가 없다는 의미로 읽지 않는다. 첫 실패 뒤 재출정·안전 귀환·종료와 사용자 답변은 [사람 기록](g4_playtest_review.md#사람-관찰-기록)에 남겼다. 정산 가독성·추적 대응의 보완 인계까지 DEV-0425에서 마무리하며 미실시 관점은 미평가로 유지한다. 답변 반영 뒤 코드를 바꾸지 않아 전체 실행을 반복하지 않고 현재 소스 해시 일치와 문서/보존 검사를 다시 확인했다.

## DEV-0426 정산 화면 가독성 검사

**DEV-0426 — 정산 화면 가독성 개선 구현·검증 및 재검토 의견 기록 완료, 사용자 로컬 커밋 승인.** 손익·이번 입금·현금 변화/정산 후 보유금을 분리하고 비용·도구 상세와 회수품 보기를 열어 읽도록 바꿨다. 계산·가격·세율·스키마10은 유지한다. 전체 **106/106 실행·62개 스모크 장면**, 10사례×두 해상도 화면/조작 검사와 최종31장 캡처를 통과했다. 사용자는 뜻을 이해했다고 답했고 어려운 용어와 몰입감을 후속 검토 의견으로 남겼다. **G4 전체 완료와 G5 착수는 보류**한다. 기준 `7aa117c`, 승인된 로컬2커밋 앞섬·뒤처짐0에서 착수했다. 2026-10-11 사용자가 검토된 DEV-0426 결과의 로컬 커밋을 승인했으며 push하지 않았다. 다음은 **DEV-0427 — 골렘 대응 수단 안내·활용성 검토**다. **정합성 검사: 아직 아님 — G5 완료 후.**

- Godot 4.7.1 전체 회귀를 새로 1회 실행해 106/106 프로세스·62개 스모크 장면을 통과했다. 오류/경고·무시 진단0, 새 프로세스 이어하기·구형 저장·정산 저장 실패/재시도·중복 반영 방지와 기존 출정/생존 흐름을 포함한다. [실행 보존본](dev0426_automated_results.json)은 원시 checks/flows·시각·기준 커밋·소스 해시를 유지한다.
- [표시 검사 결과](dev0426_readability_results.json)는 유료 도구 일부 사용/반환·실패·의뢰 미달성·빈손·원가 미기록·구형 회수세·긴 정수·음수·보호품·영구 투자의 10사례를 1152×648/1600×900에서 확인한다. 핵심 금액/설명·요약 무스크롤·상세 끝·회수품 보기/Esc·포커스 복귀·확정/종료·저장 오류 안내와 열람의 무변경을 검사했다.
- 최종 실제 렌더링1회·31장 중 일반/미기록/긴 금액1152 화면, 보호품 회수 화면, 실패 상세 끝, 투자1600 화면과 저장 오류 안내를 직접 확인했다. 초기 레이아웃 검사에서 설명 폭 초과를 수정했고 첫 렌더링 뒤 기본 요약의 마지막 줄 잘림과 포커스된 확정 버튼의 글자 대비를 개선해 다시 검사했다. 초기 시도는 최종 성공31장에 합산하지 않는다.
- 초기 전체 실행 두 번은 비상 탈출과 거점 출발 흐름의 숨겨진 회수 패널 배치 검사에서 각각 멈췄다. 새 회수품 보기 버튼으로 실제 패널을 열고 크기를 확인한 뒤 닫아 정산하도록 기존 검사를 갱신했다. 계산/정산 기대값은 유지하고 최종 전체 순환을 다시 통과했다.
- 이번 별도 외부 강제 종료 검사는0회다. 이전 기록을 새 실행에 합산하지 않는다. 사람이 새 화면을 이해했는지는 [재평가 기록](g4_playtest_review.md#dev-0426-정산-화면-재평가)에서 별도로 추적한다.
- [문서/보존 검사](dev0426_document_results.json)는 활성 상대 링크/앵커·related, 동결 원본6/사본3, 이전 보고서·도메인 계산/저장·GDD/Story/Reference/결정, 질문30개 상태·정기 검사 두 표·변경 범위·공백과 최종 소스 해시를 확인한다. 표시 설명을 추가한 비용 보고 draft 외 Design 본문은 보존한다.

재현 명령(저장소 루트, PowerShell7):

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 90 -OutputRoot 'C:/tmp/dev0426-review'
& $env:GODOT_BIN --path . --rendering-method gl_compatibility res://tests/smoke/results_readability_smoke.tscn -- --readability-render
git diff --check
```

최종 실행 소스 SHA-256: `eb31c78d6f25f7c89cede37b43f50ae3cff9e985b39ced7846e04ec798ea77b6`.
원시 전체 보고서: `C:/tmp/dev0426-review/dungeon-g2-20261011-071548-3e41a68131d9436384e9b6ce5af9f710/results.json`. 화면 파일/로그는 `.godot/dev0426-review/render-2`의 임시 근거이며 저장소 JSON에 결과·파일별 해시를 보존한다. 임시 파일의 영구 보존을 가정하지 않는다.

## DEV-0427 골렘 대응 검토 검사

**DEV-0427 — 골렘 대응 수단 안내·활용성 검토·재현 완료, 사용자 로컬 커밋 승인.** 무료 안내의 방전 효과/충전 부족 전달과 유인 이동 중 수색 시간 소모를 보완 대상으로 확인했다. 통제된15사례, 전체 **107/107 실행·63개 스모크 장면**, 기존 안내 관찰용 그래픽1회/14장과 문서·원본 보존 검사를 통과했다. 제품 동작·수치·스키마10은 유지한다. 새 사람 플레이는0회이며 기존 의견을 대조했을 뿐 최종 밸런스나 G4 전체 완료를 승인하지 않는다. 기준 `5a3fa05`, 승인된 로컬3커밋 앞섬·뒤처짐0에서 착수했다. 2026-10-12 사용자가 검토된 DEV-0427 결과의 로컬 커밋을 승인했으며 push하지 않았다. 다음은 **DEV-0428 — 골렘 대응 안내·유인 조사 흐름 보완**이다. **정합성 검사: 아직 아님 — G5 완료 후.**

[전용15사례](dev0427_response_results.json)는 실제 출정 설정의 Q 조건/정지·재가동, 적재별 추적/방전 이탈, 시야 차단/유인·G 선택/버리기를 재현한다. 유인 거리별 이동은 분리 통로에 AI 착지 위치를 직접 전달한다. 실제 사람이 던지거나 자연스럽게 도주한 사례로 세지 않는다. 실제 F 입력/비행/벽·거리/잔량·소음 우선순위·문 시야·접촉/일시정지/저장 경계는 기존 회귀와 함께 확인했다.

- Godot4.7.1, [전체 회귀](dev0427_automated_results.json) 107/107프로세스·63개 스모크 장면, 오류/경고·무시 진단0. 최초 전체 실행은 동작 검사107건을 통과했으나 import 중 새 검사 .gd.uid가 생성되어 실행 전후 해시 불일치로 전체 실패 처리됐다. 생성 파일을 포함해 재실행한 최종 전체 순환만 성공 근거로 센다.
- 그래픽 OpenGL Compatibility/NVIDIA RTX4060,1152×648에서14장 캡처. 기본 Q/충전0/벽 뒤 재가동 전후의 기존 HUD를 직접 관찰했다. 새 UI나 두 해상도 개선 수용 검사로 세지 않는다. 캡처와 로그는 `.godot/dev0427-review/render`의 임시 근거이며 저장소 JSON에 파일별 해시를 남겼다. 최초 그래픽 JSON의 방법 설명은 모든 주입을 hearing API로 표현했으나 실제 통로는 골렘 API이고 벽/시야 사례만 청취 API다. 최종 검사 문구와 저장소 결과의 방법 설명에서 구분했다. 동작 코드 변화는 없다.
- [문서/보존 검사](dev0427_document_results.json)는 활성 링크/앵커·related, 동결 원본6/사본3, 기존 소스와 GDD/Design/Story/Reference/결정·이전 보고서, 질문30개 상태·정기 검사 두 표·작업 범위·공백과 최종 실행 소스 일치를 확인한다. 새 테스트3파일은 제품 동작 변경과 구분한다.
- 이번 새 사람 플레이·별도 외부 강제 종료는 각각0회다. 기존 사람 발언과 과거 강제 종료/화면 근거를 이번 실행 횟수에 더하지 않는다. 미평가와 최종 수치 판단은 유지한다.

재현(저장소 루트, PowerShell7, GODOT_BIN에 Godot4.7.1 콘솔 경로):

```powershell
./tests/run_g2_checks.ps1 -GodotBin $env:GODOT_BIN -Repetitions 1 -TimeoutSeconds 90 -OutputRoot 'C:/tmp/dev0427-review'
& $env:GODOT_BIN --path . --rendering-method gl_compatibility --fixed-fps 60 res://tests/smoke/golem_response_review_smoke.tscn -- --response-render
git diff --check
```

최종 소스 SHA-256: `d3a0d579596be1c9b478c8e9e6ab8ae3ccdfd2d9fdd633e2c93fa1fbc825d1a7`.
원시 전체 보고서: `C:/tmp/dev0427-review/dungeon-g2-20261012-094313-914e1ff35c8845ff9f3d3fd3f5d3f3c5/results.json`. 저장소 결과는 checks/flows·시각·기준 커밋·해시와 최종15사례를 보존한다. 임시 로그/캡처의 영구 보존을 가정하지 않는다.
