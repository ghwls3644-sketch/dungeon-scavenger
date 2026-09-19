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
last_reviewed: 2026-09-19
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

현재 저장 경로는 `user://progress.json`이다. `schema_version=1`, `content_version="g2_prototype_1"`, `resume_state="hub"`와 `hub` 데이터를 기록한다. `hub`에는 돈의 십진 문자열 `money`, 가방 칸 수 `bag_slots`, 다음 출정 번호의 십진 문자열 `next_expedition_id`, 보관품 배열 `stored_items`를 저장한다. 보관품은 안정적 ID인 `id`, 불리언 감정 상태 `identified`, 공개된 위험 안내 `risk_hint`만 기록한다. 이름·분류·무게·가치·보호 규칙은 `prototype_item_catalog.tres`가 가리키는 기존 물품 정의로 복원한다. 감정하지 않은 물품은 복원 후에도 가치·실제 분류를 공개하지 않는다.

가방 선택만 현재 변경 가능한 장비 준비 상태다. 무게 단계 2.5·4.0, 하네스 기본 구성·시작 충전 3과 빈 탐험 가방은 기존 시제품 규칙을 사용한다. 등록·연구·획득한 1회성 물품·던전 영구 변화는 아직 구현되지 않아 이번 형식에서 처리한 것으로 간주하지 않는다. 관련 기능을 추가할 때 저장 버전과 복원 규칙을 함께 확장한다. 출정 중 번호와 정산 대기 결과는 저장하지 않으며, 마지막으로 확정된 거점 진행만 복원한다.

자동 저장은 새 게임의 거점 진입, 가방 선택 변경과 정산 확인 시점에 수행한다. 후보 거점 상태를 검증하고 같은 폴더의 `.tmp`에 쓰기·flush·길이 확인 후 기존 파일을 교체한다. 성공 뒤에만 실행 중 거점 상태에 반영한다. 새 게임 저장 실패는 타이틀 유지, 준비 변경 실패는 이전 선택 유지, 정산 실패는 결과 화면 유지와 같은 버튼 재시도 안내로 처리한다. 중복 입력·재시도는 돈이나 보관품을 중복 지급하지 않는다. 이어하기는 읽은 상태를 복원하며 파일을 다시 쓰지 않는다.

파일 없음·손상된 JSON·잘못된 타입·범위·알 수 없는 ID·버전 불일치는 부분 복원하지 않는다. 다른 버전 또는 손상된 파일은 자동 저장으로 덮어쓰지 않으며, 사용자가 새 게임 확인 창에서 교체를 선택한 경우에만 새 기록으로 바꾼다. 읽기·쓰기의 기술 한도는 파일당 16 MiB이며 게임 보관함 크기나 콘텐츠 수량을 확정한 값이 아니다. 설정 파일은 진행 교체와 독립적이다. 백업·자동 복구·버전 마이그레이션은 G6, 탐험 중 중단 저장은 기존 보류 범위를 유지한다.

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
