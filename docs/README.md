---
id: DOCS-INDEX
title: 폐던전 수색꾼 문서 안내
document_type: project
status: draft
source_version: gdd-v2.1+management-proposal-v0.2.1
canonical_for:
  - document_navigation
  - canonical_source_routing
last_reviewed: 2026-08-31
owner: documentation-maintainer
related:
  - GDD.md
  - story/README.md
  - design/README.md
  - reference/README.md
  - project/README.md
  - project/project_context.md
  - project/module_boundaries.md
---

# 폐던전 수색꾼 문서 안내

이 디렉터리는 게임 개발에 사용하는 활성 문서와 원본 아카이브를 관리한다.

## 영역별 진입점

| 영역 | 답하는 질문 | 진입점 |
|---|---|---|
| GDD | 어떤 게임이며 시스템이 어떻게 연결되는가? | [`GDD.md`](GDD.md) |
| Story | 세계에서 무엇이 사실이고 왜 그런가? | [`story/README.md`](story/README.md) |
| Design | 플레이어에게 어떤 규칙과 데이터로 작동하는가? | [`design/README.md`](design/README.md) |
| Reference | 무엇이라 부르고 어디에서 찾는가? | [`reference/README.md`](reference/README.md) |
| Project | 무엇을 확정했고 무엇이 미정이며 어떻게 이관하는가? | [`project/README.md`](project/README.md) |
| Archive | 이전 시점의 원본은 무엇인가? | [`archive/README.md`](archive/README.md) |

## 작업 진입점

- 문서 이관 현황: [`project/migration_manifest.md`](project/migration_manifest.md)
- 스토리 원본 상세 인벤토리: [`project/story_v1.5_inventory.md`](project/story_v1.5_inventory.md)
- 분할 중 변경 대기열: [`project/migration_changes.md`](project/migration_changes.md)
- 결정과 미결정 사항: [`project/decisions.md`](project/decisions.md), [`project/open_questions.md`](project/open_questions.md)
- 개발 단계·티켓 인계: [`project/development_handoff.md`](project/development_handoff.md)
- 개발 환경·실행 명령: [`project/project_context.md`](project/project_context.md)
- 소스 폴더·모듈 책임: [`project/module_boundaries.md`](project/module_boundaries.md)
- M2 Reference 검토 결과: [`project/m2_reference_review.md`](project/m2_reference_review.md)
- 공식 용어 검수 결과: [`project/m4_term_review.md`](project/m4_term_review.md)
- Story·Design 중복 검수 결과: [`project/m4_story_design_review.md`](project/m4_story_design_review.md)
- 화자 표현·NPC 지식 검수 결과: [`project/m4_speaker_knowledge_review.md`](project/m4_speaker_knowledge_review.md)
- 핵심 설정·Entity·Timeline 검수 결과: [`project/m5_core_entity_timeline_review.md`](project/m5_core_entity_timeline_review.md)
- 링크·누락 자동 검사 결과: [`project/m5_link_omission_review.md`](project/m5_link_omission_review.md)
- M6 사람 검토와 전환 결과: [`project/m6_human_review.md`](project/m6_human_review.md)

## 다른 환경에서 작업 이어가기

다른 컴퓨터나 장소에서는 GitHub의 `origin/main`과 저장소 문서를 작업 인계 기준으로 삼는다.

1. 저장소가 없다면 `git clone https://github.com/ghwls3644-sketch/dungeon-scavenger.git`으로 복제한다.
2. 저장소 루트에서 `git status`를 실행한다. 커밋하지 않은 변경이나 브랜치 분기가 보이면 이를 버리지 말고 먼저 확인한다.
3. 작업 트리가 깨끗하면 `git pull --ff-only origin main`으로 최신 내용을 받는다.
4. `git log -1 --oneline`으로 현재 커밋을 확인한다.
5. 루트의 [`AGENTS.md`](../AGENTS.md)와 이 문서를 읽고, [`project/migration_manifest.md`](project/migration_manifest.md)에서 현재 단계와 다음 티켓을 확인한다. 개발 작업이면 [`project/development_handoff.md`](project/development_handoff.md)에서 관련 공식 문서를 선택하고 [`project/project_context.md`](project/project_context.md)에서 엔진과 실행 명령을 확인한다.
6. Codex에는 “`AGENTS.md`와 `docs/README.md`, 이관 현황을 읽고 다음 티켓부터 계속 진행해”라고 요청한다.
7. 티켓을 완료하면 검증 결과를 확인한 뒤 해당 티켓의 로컬 커밋 여부를 승인한다.
8. 완료한 티켓 커밋은 로컬에 모아 두고, 사용자가 현재 작업 묶음의 종료를 선언하거나 명시적으로 push를 요청할 때만 `origin/main`에 push한다. 두 장소에서 동시에 `main`을 수정하지 않는다.

GitHub 로그인 상태, Codex 대화 기록, 앱별 로컬 설정은 저장소에 포함되지 않으므로 새 환경에서 별도로 준비한다.

## 정합성 검사 알림

여러 날짜와 장소에서 작업을 이어갈 때 진행 방향이 달라지지 않도록, 다음 단계로 넘어가기 전에 정합성 검사가 필요한 시점을 저장소에 기록한다. 여기서 정합성 검사는 지금까지 완료한 작업, 현재 기준과 다음 작업이 처음 계획대로 서로 맞는지 검사하는 작업이다.

검사 시점이 오면 완료 보고 첫머리에 아래 문구를 쓰고, 바로 뒤에 이번에 검사할 대상을 한 문장으로 설명한다.

> ⛔ **정합성 검사할 때입니다 — 완료한 작업, 현재 기준과 다음 작업이 서로 맞는지 검사합니다.**

이 표시는 오류가 발생했다는 뜻이 아니다. 검사 결과를 사용자에게 보고하고 계속 진행하라는 지시를 받기 전에는 다음 티켓을 시작하지 않는다.

| 검사 시점 | 검사할 내용 | 검사 통과 후 다음 작업 |
|---|---|---|
| `DOC-0505` 시작 전 | 완료 티켓과 커밋, 현재 단계, M4·M5 명칭과 작업 범위, 다음 티켓이 서로 일치하는지 확인 | `DOC-0505` |
| `DOC-0505` 완료 후 | 핵심 설정·Entity·Timeline 충돌이 모두 해결되었거나 열린 질문으로 분리되었는지 확인 | `DOC-0506` |
| `DOC-0506` 완료 후 | 링크·누락 검사 결과와 M5 전체 완료 조건을 확인 | G-M5 검토 후 `DOC-0601` |
| `DOC-0601` 완료 후 | 사람 검토 후보, 미결정 표기와 문서 상태 승격 범위를 확인 | 승인 후 `DOC-0602` |
| `DOC-0603` 완료 후 | 새 기준 문서와 AGENTS 작업 규칙만으로 다른 환경에서 개발을 시작할 수 있는지 확인. 2026-07-29 G-M6 통과 | `DEV-0001` |
| `DEV-0006`, `DEV-0107`, `DEV-0111`, `G2`, `G5`, `G6`, `G8` 도달 시 | 테스트·로그 기반, 첫 핵심 루프와 보완 결과, 전체 제품 순환, 반복 상태, 저장 복구, 출시 회귀 검사를 각 단계에 맞게 확인 | 해당 개발 관문의 다음 작업 |
| 완료 — `DEV-0107` 완료 후 | 2026-08-31 검사에서 기존 구현·자동 검사는 일치했지만 GDD 15-2 누락 범위와 사람 검토가 남음을 확인 | 사용자 지시에 따라 `DEV-0108`부터 G1 보완 |
| 현재 예정 — `DEV-0111` 완료 후 | 조사·미확인 물품·경비 골렘·하네스 분석·비상 방전, GDD 20-1 사람 판단과 `Q-004`·`Q-005`가 서로 맞는지 확인 | 검사 결과를 검토하고 사용자가 진행을 지시한 뒤 `DEV-0201` |

평상시 티켓 완료 보고에도 `정합성 검사: 지금` 또는 `정합성 검사: 아직 아님`을 적어 다음 검사 시점을 놓치지 않게 한다.

## 원본 보존 규칙

- `../게임 기획 파일/`은 이관이 끝날 때까지 원본 보관 위치로 유지한다.
- 원본은 직접 편집하거나 삭제하지 않는다.
- 활성 문서에 반영할 변경은 먼저 `project/migration_changes.md`에 기록한다.
- `archive/`의 문서는 근거 확인과 누락 검수에만 사용하며 현재 설정으로 인용하지 않는다.
- 문서 간 내용이 충돌하면 `GDD.md`의 "자료 충돌 시 우선순위"를 따른다.

## 현재 단계

검토 관문 G-M3, G-M4와 G-M5를 통과했다. `M5 — 중복 제거와 정합성 검토`의 `DOC-0501`~`DOC-0506`에서 공식 용어, Story·Design 책임, 화자 표현·NPC 지식, 핵심 설정·Entity·Timeline과 활성 문서 링크·누락을 모두 검사했다. G-M5 완료 조건 7개는 2026-07-28 정합성 검사에서 모두 충족함을 확인했다.

`M6 — 최종 검수와 기준 전환`은 2026-07-29 G-M6 정합성 검사 통과로 완료했다. `DOC-0601`에서 사람 검토 후보 3건을 승인 결과에 따라 처리했다. 감정사·연구자의 공동 어휘와 연구자 전용 지식·예시 범위를 구분했고, 일부 모험가 표현에 수색꾼의 사회적 위치 링크를 추가했다. 폐던전 범람 위험의 현재 규칙은 `DEC-004`의 `사라진다`를 유지한다.

`DOC-0602`에서 검증을 마친 Story 9개, Design 5개와 필수 Reference 3개 등 17개 문서를 `confirmed`로 전환했다. Entity Index와 Timeline은 미정 이름·연도·기간을 유지하는 조건으로 `provisional`로 전환했다. 상세 규칙 이관과 검증이 남은 Harness Engineering은 `draft`를 유지한다.

Archive는 현재 기준이 아니라는 경고와 새 공식 문서 링크를 [`archive/README.md`](archive/README.md)에 표시했다. 개별 보존 원문은 기록된 SHA-256을 유지하기 위해 수정하지 않았다. 자세한 전환 근거는 [`project/m6_human_review.md`](project/m6_human_review.md)에 있다.

`DOC-0603`에서 AGENTS의 문서 탐색 규칙을 새 공식 구조로 전환하고, GDD에 Story·Design·Reference와 개발 인계 링크를 추가했다. 동결 개발 제안서는 수정하지 않고 [`project/development_handoff.md`](project/development_handoff.md)에서 기존 단계·티켓을 현재 기준 문서에 연결했다. GDD 3-4의 옛 범람 표현도 승인된 `DEC-004`의 `사라진다`로 정정했다.

`DEV-0001`에서 사용자가 승인한 Godot 4.7.1, GDScript, Compatibility 렌더러와 Windows PC 우선 기준을 [`project/project_context.md`](project/project_context.md)에 기록했다. 루트의 `project.godot`을 headless 편집기 명령으로 초기화해 설정을 실제로 읽을 수 있음을 확인했다.

`DEV-0002`에서 Godot 소스를 `app`, `core`, `gameplay`, `harness`, `meta`, `infrastructure`, `ui`, `data`, `tests` 경계로 나눴다. 실제 경로, 책임과 의존 방향은 [`project/module_boundaries.md`](project/module_boundaries.md)에 기록했다.

`DEV-0003`에서 `GameState` Autoload와 최소 메인 장면을 추가했다. 개발용 버튼은 `Boot → Title → Hub → Exploration → Results → Hub` 흐름을 중앙 관리자에 요청하며, 중복·현재 상태·허용되지 않은 전환은 거절한다.

`DEV-0004`에서 이동·조준·상호작용·하네스·도구·인벤토리·지도·빠른 버리기·일시정지를 행동 ID로 등록했다. 키보드·마우스 기본 입력은 `project.godot`에만 두고, 게임 코드가 사용할 행동 이름과 입력 조회는 `InputActions`로 모았다.

`DEV-0005`에서 표시 이름과 독립된 안정적 ID 기반, 공통 콘텐츠 정의와 아이템 기본 정의를 추가했다. 실제 아이템 데이터와 밸런스 값은 넣지 않았으며 Godot 4.7.1에서 표시 이름 변경 후에도 ID가 유지됨을 확인했다.

`DEV-0006`에서 상태 전환 스모크 장면, 공통 로그 형식과 `--dev-state` 개발 진입 인수를 추가했다. Godot 4.7.1의 한 명령으로 `Boot → Title → Hub → Exploration → Results → Hub` 전환과 종료 코드 `0`을 확인했다.

`DEV-0006` 완료 뒤 프로젝트 기반, 모듈 경계, 입력·데이터 기반, 테스트·로그와 다음 개발 순서를 대조했다. 이상이 없음을 확인하고 2026-08-01 사용자의 진행 지시에 따라 G0를 통과했다.

`DEV-0101`에서 `CharacterBody2D` 기반 플레이어 이동과 자식 `Camera2D`를 추가했다. 이동은 `InputActions`의 방향 벡터만 사용하며, 시제품 속도 `240 px/s`는 플레이어 장면에 조정 가능한 값으로 둔다. 실제 플레이어 장면을 사용하는 이동·카메라·일시정지 자동 검사와 수동 테스트 공간을 Godot 4.7.1에서 검증했다. 테스트 공간의 일시정지 조작은 이번 완료 조건 확인용이며 제품 전체의 일시정지 흐름을 대신하지 않는다.

`DEV-0102`에서 상호작용 대상 감지, 안내 표시와 실행을 각각 `InteractionDetector`, `InteractionPrompt`, `InteractionController`로 분리했다. 시험용 회수품과 문은 같은 `Interactable` 인터페이스를 사용한다. 회수품 제거, 문 열림·닫힘과 충돌·안내 갱신을 Godot 4.7.1 자동 검사와 수동 테스트 공간에서 확인했다. 인벤토리 적재와 실제 콘텐츠·문 잠금 규칙은 추가하지 않았다.

`DEV-0103`에서 아이템 획득, 슬롯 한도, 무게 합계와 단계, 선택·일반 버리기를 `PlayerInventory`에 구현하고 인벤토리 화면에 같은 상태를 표시했다. 화면을 연 동안 탐험 시간을 멈추고 일반 버리기는 확인 창을 거친다. 실제 아이템 콘텐츠와 제품 밸런스 값은 추가하지 않았으며, 시험용 한도·무게 단계만 자동 검사에 사용했다. 미확정 질문 `Q-005`의 이동 감속과 빠른 버리기도 이번 범위에서 제외했다. Godot 4.7.1에서 슬롯 한도 초과 거절, 과적 표시, 버린 뒤 상태 갱신과 기존 기능 회귀 검사를 확인했다.

`DEV-0104`에서 현재 인벤토리 물품을 회수 결과로 고정하고, 일반 회수품의 예상 가치 범위와 합계를 표시했다. 버렸거나 슬롯 한도로 거절된 물품은 결과에 들어가지 않으며, 고유 유물·핵심 기록물은 화폐 합계에서 분리해 등록·정보 보상으로 표시한다. 실제 판매액, 비용, 순이익, 저장과 귀환·실패 판정은 후속 티켓 범위로 남겼다. Godot 4.7.1 자동 검사에서 회수품 포함·제외, 가치 합계, 비화폐 보상 분리와 기존 기능 회귀 검사를 확인했다.

`DEV-0105`에서 먼지와 진동을 먼저 보이는 불안정한 잔해 위험과 `Q` 하네스 안정화를 추가했다. 경고 시간 안에 안정화하면 시험 충전을 쓰고 붕괴를 막으며, 대응하지 않고 범위 안에 남으면 붕괴와 포착 이벤트가 발생한다. 피해·부상·실패 판정은 추가하지 않았고, 충전량·비용·경고 시간은 테스트 공간에서 조정하는 시제품 값으로만 사용했다. Godot 4.7.1 자동 검사에서 징후 선행, 안정화 성공, 미대응 시 붕괴, 충전·안내 표시와 기존 기능 회귀를 확인했다.

`DEV-0106`에서 입구 상호작용을 유일한 생환 지점으로 연결하고 탐험을 생환 또는 실패 한 번으로만 종료하는 `ExplorationRun`과 `ExplorationOutcome`을 추가했다. 생환하면 현재 인벤토리 물품을 회수 결과로 고정해 정산 대상으로 넘기고, 위험에 포착되어 실패하면 현재 탐험 물품을 비우며 회수 결과를 만들지 않는다. 실제 피해·부상, 퇴로 상실 시간, 장비 손상·수리비, 저장과 거점 반영은 추가하지 않았다. Godot 4.7.1 자동 검사에서 입구 감지·생환, 회수품 인계, 위험 포착·실패, 물품 손실, 종료 결과 잠금과 기존 기능 회귀를 확인했다.

`DEV-0107`에서 안전 경로와 위험 보상 경로가 갈리는 작은 플레이테스트 장면을 추가했다. 시험 슬롯을 안전 경로 물품으로 채운 뒤 하네스 충전을 써서 위험을 안정화하고, 고가 잔재를 위해 기존 물품을 버릴지 선택해 같은 입구로 생환할 수 있다. 위험에 대응하지 않으면 현재 회수품을 잃고 실패한다. 슬롯·무게·가치·충전·경고 시간은 장면과 테스트 안의 시제품 값이며 제품 밸런스로 확정하지 않았다. Godot 4.7.1 자동 검사에서 안전 생환, 위험 대응과 적재 교체, 미대응 실패 및 기존 기능 회귀를 확인했다.

`DEV-0107` 완료 뒤 2026-08-31 정합성 검사에서 기존 구현과 자동 검사에 회귀가 없음을 확인했다. GDD 15-2의 별도 조사·미확인 물품·고장 난 경비 골렘·하네스 분석과 비상 방전, GDD 20-1의 사람 판단과 `Q-004`·`Q-005`가 남아 있어 사용자는 `DEV-0201`보다 G1 보완을 먼저 진행하도록 지시했다. 보완 순서는 `DEV-0108` 조사·미확인 물품, `DEV-0109` 고장 난 경비 골렘, `DEV-0110` 하네스 분석·비상 방전, `DEV-0111` 통합 플레이테스트·수치 검토다.

`DEV-0108`에서 첫 상호작용으로 외형·무게·위험 정보를 조사하고 다음 상호작용으로 회수하는 대상을 추가했다. `InventoryItem`은 불변 아이템 정의와 현재 탐험의 감정 여부를 분리한다. 미확인 상태에서는 실제 분류·가치와 보호 여부를 인벤토리와 생환 결과에서 숨기며, 숨겨진 가치는 예상 가치 합계에서 제외하고 미확인 개수를 따로 표시한다. 거점·휴대용 감정, 하네스 분석, 실제 콘텐츠·밸런스와 저장 스키마는 추가하지 않았다. Godot 4.7.1에서 새 자동 검사와 기존 스모크 검사 8개를 모두 통과했다.

현재 다음 개발 작업은 `DEV-0109 — 고장 난 경비 골렘`이다. **정합성 검사: 아직 아님**이며 다음 검사는 `DEV-0111` 완료 뒤다.
