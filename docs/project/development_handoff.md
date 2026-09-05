---
id: PROJECT-DEVELOPMENT-HANDOFF
title: 개발 문서 인계 안내
document_type: project
status: draft
source_version: development-proposal-v0.1+gdd-v2.1
canonical_for:
  - development_document_handoff
  - development_ticket_routing
last_reviewed: 2026-08-31
owner: project-maintainer
related:
  - ../README.md
  - ../GDD.md
  - project_context.md
  - module_boundaries.md
  - ../story/README.md
  - ../design/README.md
  - ../reference/README.md
  - decisions.md
  - open_questions.md
  - migration_manifest.md
  - ../../게임 기획 파일/게임 개발 단계별 제안서 v0.1.md
---

# 개발 문서 인계 안내

## 목적

동결된 [`게임 개발 단계별 제안서 v0.1`](<../../게임 기획 파일/게임 개발 단계별 제안서 v0.1.md>)의 단계·티켓 구조를 새 공식 Story·Design·Reference 문서와 연결한다. 원본 제안서는 수정하지 않으며, 개발 작업을 시작할 때는 이 안내에서 현재 기준 문서로 이동한다.

## 개발 작업 읽기 순서

1. 저장소 작업 규칙인 [`../../AGENTS.md`](../../AGENTS.md)를 읽는다.
2. 전체 문서 입구인 [`../README.md`](../README.md)에서 현재 단계와 정합성 검사 시점을 확인한다.
3. 엔진·언어·실행 명령은 [`project_context.md`](project_context.md)에서 확인한다.
4. 코드 파일을 추가할 때는 [`module_boundaries.md`](module_boundaries.md)에서 소유 폴더와 의존 방향을 확인한다.
5. 제품과 시스템 연결은 [`../GDD.md`](../GDD.md)에서 확인한다.
6. 작업 규칙은 [`../design/README.md`](../design/README.md)에서 관련 `confirmed` Design 문서를 선택한다.
7. 세계관 이유와 표시 명칭이 필요하면 [`../story/README.md`](../story/README.md), [`../reference/README.md`](../reference/README.md)를 함께 읽는다.
8. 확정·미정 여부는 [`decisions.md`](decisions.md), [`open_questions.md`](open_questions.md)에서 확인한다.
9. 개발 단계와 기존 티켓 ID가 필요할 때만 동결 개발 제안서를 참고한다.

상세 내용이 다르면 최신 사용자 결정, 결정 기록, 해당 책임의 `confirmed` 문서, GDD 개요, 동결 제안서 순서로 판단한다. `provisional` 문서는 문서에 적힌 제한 범위에서만 사용하고 `draft` 문서는 단독 구현 기준으로 사용하지 않는다.

## 작업별 기준 문서

| 개발 작업 | 먼저 읽을 기준 | 함께 확인할 문서 |
|---|---|---|
| 엔진·언어·렌더러·실행·검증 | [`project_context.md`](project_context.md) | [`../GDD.md`](../GDD.md) 14장, [`decisions.md`](decisions.md)의 `DEC-101` |
| 소스 폴더·모듈 책임·의존 방향 | [`module_boundaries.md`](module_boundaries.md) | [`../GDD.md`](../GDD.md) 14장, 해당 기능의 `confirmed` Design 문서 |
| 제품 목표·핵심 루프·MVP 범위 | [`../GDD.md`](../GDD.md) | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`decisions.md`](decisions.md) |
| 반복 탐험·방문 상태·퇴각 | [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../reference/glossary.md`](../reference/glossary.md) |
| 아이템·감정·판매 보호·저장 상태 | [`../design/item_rules.md`](../design/item_rules.md) | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../reference/glossary.md`](../reference/glossary.md) |
| 정산·비용·실패 안전망 | [`../design/economy_rules.md`](../design/economy_rules.md) | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`open_questions.md`](open_questions.md) |
| 발견·등록·NPC 반응·정보 노출 | [`../design/narrative_delivery.md`](../design/narrative_delivery.md) | [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) |
| 이름·UI 표기·대사 어휘 | [`../reference/glossary.md`](../reference/glossary.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) | 관련 Story·Design 문서 |
| 인물·조직·장소·사건 추적 | [`../reference/entity_index.md`](../reference/entity_index.md), [`../reference/timeline.md`](../reference/timeline.md) | 두 문서의 `provisional` 제한과 관련 Story 문서 |
| 하네스 | [`../GDD.md`](../GDD.md) 7장 | [`../design/harness_engineering.md`](../design/harness_engineering.md)는 상세 이관·검증 전 `draft`이므로 단독 구현 기준으로 사용하지 않음 |

## 기존 개발 단계와 연결

| 동결 제안서 범위 | 현재 문서에서 확인할 내용 |
|---|---|
| 단계 0, `DEV-0001`~`DEV-0006` | [`project_context.md`](project_context.md)의 Godot 실행 기준, [`module_boundaries.md`](module_boundaries.md)의 코드 배치·의존 규칙, AGENTS 작업 규칙, 결정·질문 기록, GDD 제품 개요와 테스트·로그 관문 |
| 단계 1, `DEV-0101`~`DEV-0107` | GDD 핵심 탐험 범위와 관련 Design 문서, Story 핵심 전제 |
| 단계 2, `DEV-0201`~`DEV-0206` | GDD 제품 흐름과 저장·상태 기준, 반복 탐험·아이템·경제 Design |
| 단계 3~5 | 위험·인벤토리·지도·거점·경제·반복 데이터에 해당하는 `confirmed` Design 문서 |
| 단계 6~8 | GDD의 제품 기능·접근성·출시 범위와 동결 제안서의 검토 관문 |
| 테스트 전략·위험·체크리스트 | 동결 제안서 7장·8장·부록 A와 [`../README.md`](../README.md)의 현재 정합성 검사 지점 |

동결 제안서의 단계와 티켓 ID는 개발 순서를 추적하는 참고 구조다. 실제 티켓을 시작할 때는 현재 저장소 상태와 해당 Design 문서의 확정·미정 범위를 다시 확인한다.

## 사용 제한

- 동결 제안서의 `스토리 정리 v1.5` 직접 참조는 현재 세부 기준으로 사용하지 않는다.
- `게임 기획 파일/`과 `docs/archive/`는 수정하지 않는다.
- Harness Engineering의 빈 상세 규칙을 추정으로 채우지 않는다.
- `open_questions.md`의 항목을 구현 편의를 이유로 임의 확정하지 않는다.
- 새 기능, 수치, 이름, 코드 ID 또는 저장 키는 해당 개발 티켓 범위와 승인 없이 추가하지 않는다.

## 현재 상태

`DOC-0603`에서 동결 개발 제안서의 단계·티켓 구조를 새 공식 문서 체계에 연결했다. 이 문서는 개발 작업의 탐색과 인계를 돕는 Project 문서이며, 게임 규칙의 상세 기준은 각 `confirmed` Story·Design·Reference 문서가 소유한다.

G-M6는 2026-07-29 정합성 검사에서 통과했다. `DEV-0001`은 Godot 4.7.1, GDScript, Compatibility 렌더러와 Windows PC 우선 기준을 [`project_context.md`](project_context.md)에 기록하고 최소 프로젝트 설정의 headless 초기화를 검증했다.

`DEV-0002`는 실제 모듈 경계 9개와 책임·의존 방향을 [`module_boundaries.md`](module_boundaries.md)에 고정했다. 게임 코드와 장면은 추가하지 않았다.

`DEV-0003`은 `GameState` Autoload와 개발용 메인 장면에서 `Boot`, `Title`, `Hub`, `Exploration`, `Results` 흐름을 연결했다. 중복·현재 상태·허용되지 않은 전환은 중앙 관리자가 거절하며 UI는 상태를 직접 변경하지 않는다.

`DEV-0004`는 GDD 12장의 행동을 `InputMap`에 등록하고 `res://src/infrastructure/input_actions.gd`에 행동 이름과 조회 API를 모았다. 키보드·마우스 기본 입력은 프로젝트 설정 한곳에서만 물리 키를 사용하며 컨트롤러 입력은 `Q-006` 결정 전까지 추가하지 않는다.

`DEV-0005`는 `res://src/core/stable_id.gd`에 공용 안정적 ID 검증을, `res://src/data/content_definition.gd`와 `item_definition.gd`에 표시 이름과 분리된 ID 및 아이템 기본 필드를 추가했다. 아이템 분류는 확정된 네 분류만 사용하고 실제 콘텐츠·밸런스 값과 저장 형식은 추가하지 않았다.

`DEV-0006`은 `res://tests/smoke/game_state_flow_smoke.tscn`에서 기본 상태 흐름을 자동 검증하고, `GameLog`가 상태 전환 로그를 공통 형식으로 남기도록 했다. 메인 개발 장면은 `--dev-state` 인수로 현재 구현된 상태까지 중앙 전환 규칙을 따라 진입한다.

`DEV-0006` 완료 뒤 프로젝트 기반, 모듈 경계, 입력·데이터 기반, 테스트·로그와 다음 개발 순서를 대조했다. 이상이 없음을 확인하고 2026-08-01 사용자의 진행 지시에 따라 G0를 통과했다.

`DEV-0101`은 `res://src/gameplay/player/`에 `CharacterBody2D` 이동과 자식 `Camera2D`를 추가했다. 이동은 `InputActions`를 사용하며 시제품 속도는 플레이어 장면에서 조정한다. `res://tests/fixtures/movement_test_space.tscn`은 이동과 일시정지를 직접 확인하고, `res://tests/smoke/player_movement_smoke.tscn`은 실제 플레이어 장면의 이동 속도 정규화, 카메라 추적과 일시정지 중 정지를 자동 검증한다.

`DEV-0102`는 `res://src/gameplay/interaction/`에 공통 `Interactable`, 감지기와 입력 실행기를 추가하고 `res://src/ui/interaction_prompt.tscn`에 안내 표시를 분리했다. 플레이어 장면은 감지기와 실행기를 조립한다. 시험용 회수품과 문은 같은 인터페이스를 사용하며 자동 검사에서 감지, 안내, 회수와 문 열림·닫힘을 확인한다.

`DEV-0103`은 `res://src/gameplay/inventory/player_inventory.gd`에 획득, 슬롯 한도, 무게 합계·단계, 선택과 일반 버리기 규칙을 추가했다. `res://src/ui/inventory_panel.tscn`은 같은 상태를 표시하고 열려 있는 동안 시간을 멈추며, 일반 버리기 전에 확인을 요청한다. 실제 콘텐츠와 제품 밸런스 값은 추가하지 않았고, `Q-005`가 열려 있으므로 이동 감속과 빠른 버리기도 구현하지 않았다. 시험용 한도·무게 값은 테스트 자료 안에서만 사용한다.

`DEV-0104`는 `res://src/gameplay/recovery/recovery_result.gd`가 현재 인벤토리 물품을 회수 결과로 고정하고 화폐 가치 범위를 합산하도록 했다. `res://src/ui/inventory_panel.tscn`과 `recovery_result_panel.tscn`은 개별 예상 가치와 결과 합계를 표시한다. 고유 유물·핵심 기록물은 화폐 합계에서 제외하고 등록·정보 보상으로 구분한다. 버린 물품과 슬롯 한도로 획득이 거절된 물품이 결과에서 빠지는지는 자동 검사로 확인한다. 판매·비용·순이익, 저장과 귀환·실패 판정은 추가하지 않았다.

`DEV-0105`는 `res://src/gameplay/hazards/`에 먼지·진동 징후 뒤 붕괴하는 불안정한 잔해와 하네스 대상 감지를 추가하고, `res://src/harness/harness_controller.gd`가 `use_harness` 입력과 시험 충전을 사용해 경고 중인 위험을 안정화하도록 했다. 이 범위는 GDD 5장·7장과 티켓 완료 조건을 따르며 `draft`인 Harness Engineering의 빈 상세 규칙을 채우지 않는다. 충전량·비용·경고 시간은 조정 가능한 시제품 값이고, 포착 이벤트를 피해·부상·실패로 바꾸는 처리는 추가하지 않았다.

`DEV-0106`은 `res://src/gameplay/recovery/`에 입구 상호작용, 한 번만 확정되는 탐험 종료 상태와 생환·실패 결과를 추가했다. 생환은 현재 인벤토리를 기존 `RecoveryResult`로 넘기고, 실패는 현재 탐험 물품을 비운 뒤 회수 결과 없이 손실 개수만 남긴다. 시험 공간에서는 불안정한 잔해의 공개 포착 이벤트를 실패 명령에 연결한다. `res://src/ui/exploration_outcome_panel.tscn`은 확정된 결과만 표시하며 종료나 손실을 계산하지 않는다. 피해·부상, 퇴로 상실 시간, 장비 손상·수리비, 저장과 거점 정산은 후속 범위로 남겼다.

`DEV-0107`은 `res://tests/fixtures/core_loop_playtest_space.tscn`에서 기존 이동·상호작용·인벤토리·위험·하네스·귀환·실패 모듈을 안전 경로와 위험 보상 경로로 조립했다. 시험 슬롯이 찬 뒤 고가 잔재를 위해 기존 물품을 버리는 적재 선택, 하네스 충전을 써서 붕괴를 안정화할지 돌아갈지의 위험 선택, 같은 입구 생환과 미대응 실패를 한 장면에서 재현한다. 자동 검사는 안전 생환, 위험 대응 생환과 미대응 실패를 모두 확인한다. 시험 값은 제품 밸런스로 확정하지 않으며 출시 코드는 이 장면을 참조하지 않는다.

`DEV-0107` 완료 뒤 2026-08-31 G1 정합성 검사에서 Godot 4.7.1 프로젝트 초기화, 메인 장면과 기존 스모크 검사 8개가 모두 통과했다. 단계 1의 기존 개발 작업에는 회귀가 없지만 GDD 15-2의 별도 조사·미확인 물품·고장 난 경비 골렘·하네스 분석과 비상 방전은 아직 구현되지 않았고, GDD 20-1의 주관적 재미·안도감과 `Q-004`·`Q-005`는 사람 플레이테스트가 필요하다. 사용자는 `DEV-0201 — Boot와 임시 타이틀`보다 G1 누락 범위를 먼저 보완하도록 지시했다.

## G1 보완 개발 작업

GDD 15-2의 누락 범위와 사람 검토 항목은 다음 순서로 한 작업씩 진행한다. 기존 단계 1 코드를 임의로 확장하지 않고 각 작업의 제외 범위와 자동 검사 자료를 분리한다.

- [x] `DEV-0108 — 조사와 미확인 물품`: 같은 상호작용 체계에서 정보 확인과 회수를 구분하고, 감정 전 물품의 실제 분류·가치를 숨긴 채 외형·무게·위험 정보와 감정 상태를 현재 탐험에 유지한다. 거점 감정, 저장과 실제 콘텐츠·밸런스는 추가하지 않는다.
- [x] `DEV-0109 — 고장 난 경비 골렘`: 사전 징후와 제한된 순찰·의심·추적 상태를 가진 시험용 경비 골렘을 추가한다. 영구 처치, 전투 피해와 최종 인공지능 수치는 추가하지 않는다.
- [ ] `DEV-0110 — 하네스 분석과 비상 방전`: GDD에 확정된 최소 분석과 짧은 비상 무력화를 기존 충전 자원에 연결한다. `draft`인 Harness Engineering의 모듈 성장·최종 수치를 추정하지 않는다.
- [ ] `DEV-0111 — G1 통합 플레이테스트와 수치 검토`: 보완한 조사·미확인 물품·골렘·하네스 행동을 작은 테스트 맵에 조립하고 GDD 20-1 및 `Q-004`·`Q-005` 판단 자료를 남긴다. 사람 판단 없이 제품 수치를 확정하지 않는다.

`DEV-0108`은 `InspectablePickupInteractable`의 첫 상호작용으로 외형·무게·위험 정보를 조사하고, 다음 상호작용으로 `InventoryItem`을 미확인 상태로 회수하도록 했다. 실행 중 물품 상태는 `ItemDefinition`의 실제 분류·가치와 분리되며 인벤토리와 생환 결과까지 유지된다. UI는 미확인 상태의 실제 분류·가치와 보호 여부를 숨기고, 회수 결과는 숨겨진 가치를 합계에서 제외하며 미확인 개수를 별도 표시한다. Godot 4.7.1에서 새 자동 검사와 기존 스모크 검사 8개를 모두 통과했다.

`DEV-0109`는 `BrokenGuardGolem`이 지정 구간을 순찰하며 발소리·긁힌 흔적을 먼저 노출하고, 플레이어 감지·외부 소음·경보에 공개 명령으로 반응하도록 했다. 플레이어 감지는 탐지음이 있는 의심 단계를 건너뛰지 않으며, 지속 감지 또는 경보 뒤 추적하고 시야를 잃으면 마지막 위치를 수색한 뒤 순찰로 돌아간다. 영구 처치 가능 여부는 거짓으로 고정했고 기본 공격·피해, 실패 연결과 최종 인공지능·탐지·이동 수치는 추가하지 않았다. Godot 4.7.1 자동 검사에서 순찰 이동, 단서와 상태 순서, 마지막 위치, 소음·경보 분기를 확인했다.

## DEV-0109-R1 — G1 사전 코드 검토 보완

2026-09-06 사용자 승인으로 검토에서 재현된 여섯 문제를 하나의 보완 티켓으로 처리한다. `DEV-0109`는 `4ca9731`로 커밋되어 있다.

- 보호 물품은 실제 분류와 보호 설정으로 일반 버리기를 차단하며 감정 여부로 보호를 우회하지 못하게 한다.
- 인벤토리 목록·버튼에 포커스가 있어도 Tab으로 닫고 기존 일시정지 상태를 복원한다.
- 조사한 위험 정보는 현재 탐험 물품과 생환 결과에 유지하고 UI에서 다시 확인한다.
- 골렘은 현재 감지 중인 플레이어를 소음·경보 요청으로 잊거나 경고 시간을 다시 시작하지 않는다.
- 회수 결과는 생성 시점의 물품 정의·감정·위험 정보를 복사해 고정한다. 이후 원본 또는 조회용 복사본 변경이 결과의 개별 표시·합계를 바꾸지 않는다.
- 탐험 종료는 인벤토리 변경 알림을 내기 전에 잠그며, 처리 도중 들어오는 생환·실패·인벤토리 재연결을 거절한다.

각 문제의 재현 조건과 정상 경로를 기존 스모크 검사에 추가한다. 하네스 분석·비상 방전, 거점 감정·정산·저장, 실제 콘텐츠·제품 수치와 새로운 세계관 규칙은 범위에 포함하지 않는다.

Godot 4.7.1에서 여섯 문제의 회귀 검사를 포함한 스모크 장면 10개가 모두 통과했다. 보호 대상 세 종류를 감정 전후 각각 검사하고 일반 물품의 확인·취소·버리기도 확인했다. 키 입력은 실제 `InputEventKey`를 전달해 목록·버튼 포커스와 기존 일시정지 복원을 검사했다. 골렘은 감지 중 반복 소음·경보와 소음만 있는 기존 수색 경로를, 결과는 원본·조회용 복사본 변경을, 종료는 생환·실패 양쪽 재진입을 검사했다.

`DEV-0109-R1`은 구현·자동 검증을 완료하고 검증 결과 검토 후 사용자가 커밋을 승인했다. 다음 기능 티켓은 `DEV-0110 — 하네스 분석과 비상 방전`이다. 정합성 검사는 아직 아니며 다음 검사 시점은 `DEV-0111` 완료 뒤다. 이번 보완은 사람 플레이테스트나 `Q-004`·`Q-005`의 제품 수치 결정을 대신하지 않는다.
