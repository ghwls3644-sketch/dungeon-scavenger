---
id: PROJECT-DECISIONS
title: 결정 기록
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - approved_decisions
  - decision_rationale
last_reviewed:
owner: project-maintainer
related:
  - ../GDD.md
  - story_v1.5_inventory.md
  - open_questions.md
  - document_changelog.md
---

# 결정 기록

## 목적

승인된 세계관·설계·문서 운영 결정을 ID와 변경 이유로 추적한다.

## 포함 범위

- 승인된 결정과 근거
- 영향받는 Story, Design, Reference, GDD
- 대체된 결정과 후속 작업

## 제외 범위

- 아직 검토 중인 질문
- 원문 이관만을 위한 기계적 이동 기록
- 문서 구조 변경 이력

## 기록 규칙

- `active`는 동결 원본 또는 통합 GDD에서 현재 방향으로 채택된 결정을 뜻한다.
- 기존 결정을 바꿀 때는 삭제하지 않고 `superseded`로 표시한 뒤 새 결정 ID를 연결한다.
- 원본과 GDD에 결정일·승인자가 기록되어 있지 않으면 임의로 추정하지 않고 `미기록`으로 둔다.
- 이 문서는 결정과 출처, 영향 범위를 추적한다. 상세 정설과 작동 규칙은 연결된 Story·Design·Reference 문서가 소유한다.

현재 결정의 공통 메타데이터는 다음과 같다.

| 항목 | 값 |
|---|---|
| 상태 | `active` |
| 결정일 | 미기록 |
| 승인자 | 미기록 |
| 대체한 결정 | 기록 없음 |

## 세계관·제품 결정

| ID | 결정 | 원본·근거 | 영향 문서 |
|---|---|---|---|
| `DEC-001` | 마왕과 던전 발생은 직접 연결하지 않는다. | GDD 18-1; `STY-0011`, `STY-0012`, `STY-0099`, `STY-0103` | [`../story/01_world_history.md`](../story/01_world_history.md), [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) |
| `DEC-002` | 플레이어는 게임 시작부터 수색꾼이다. | GDD 18-1; `STY-0031`, `STY-0032`, `STY-0096`, `STY-0103` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../reference/glossary.md`](../reference/glossary.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) |
| `DEC-003` | 초반 목표는 사건 해결이 아니라 생계다. | GDD 18-1; `STY-0007`, `STY-0033`, `STY-0061`, `STY-0103` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) |
| `DEC-004` | 폐던전은 코어가 파괴되어 소멸 중인 던전 전체다. | GDD 18-1; `STY-0017`~`STY-0022`, `STY-0024`, `STY-0025`, `STY-0097`, `STY-0103` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../reference/glossary.md`](../reference/glossary.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `DEC-005` | 잔여 구역은 폐던전 내부의 미답파·미기록 공간이다. | GDD 18-1; `STY-0014`, `STY-0029`, `STY-0072`, `STY-0081`, `STY-0103` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `DEC-006` | 반복 지도는 고정 큰 지도와 제한적 변화로 구성한다. | GDD 18-1; `STY-0076`~`STY-0083`, `STY-0103` | [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `DEC-007` | 고유 유물과 핵심 기록물은 1회성·판매 불가다. | GDD 18-1; `STY-0053`~`STY-0056`, `STY-0074`, `STY-0103` | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../design/item_rules.md`](../design/item_rules.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `DEC-008` | 반복 보상은 잔존 에너지 유실에 따른 노출로 설명한다. | GDD 18-1; `STY-0026`, `STY-0058`, `STY-0083`, `STY-0103` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `DEC-009` | 전투보다 관찰·회피·도구·퇴각을 우선한다. | GDD 18-1; `STY-0008` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../design/harness_engineering.md`](../design/harness_engineering.md) |
| `DEC-010` | 기본 결말은 세계 구원이 아니라 수색꾼의 자립이다. | GDD 18-1; `STY-0060`~`STY-0065`, `STY-0103` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md), [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) |
| `DEC-011` | 던전 내부에서 다른 수색꾼을 직접 만나기보다 흔적으로 표현한다. | GDD 18-1; `STY-0073`, `STY-0084` | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `DEC-012` | 던전은 어둡게, 거점은 생활감 있게 표현한다. | GDD 18-1; `STY-0086`~`STY-0092`, `STY-0103` | [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) |
| `DEC-013` | 플레이어의 모험가 동경은 가볍고 건강한 막연한 동경으로 둔다. | `STY-0033`, `STY-0103` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) |
| `DEC-014` | 수색꾼 길드가 존재하며, 허가증이나 표식으로 출입 자격을 표시할 수 있고 회수품 가격은 기본적으로 길드가 주도한다. | `STY-0038`, `STY-0039`, `STY-0103` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../design/economy_rules.md`](../design/economy_rules.md) |
| `DEC-015` | 감정사는 기능형 NPC로 두고 휴대용 감정 아이템도 사용할 수 있다. | `STY-0048`, `STY-0103` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md), [`../design/item_rules.md`](../design/item_rules.md), [`../design/economy_rules.md`](../design/economy_rules.md) |
| `DEC-016` | 상인은 저주 소문이 붙은 물건은 꺼릴 수 있지만 감정된 잔재는 거래할 수 있다. | `STY-0045`, `STY-0103` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md), [`../design/economy_rules.md`](../design/economy_rules.md) |
| `DEC-017` | 봉인 관리인은 제거하고 성직자가 마왕·봉인 관련 반응을 일부 담당한다. | `STY-0050`, `STY-0103` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `DEC-018` | 아이템 분류는 테두리 색으로 구분한다. | `STY-0054`, `TBL-014`, `STY-0103` | [`../design/item_rules.md`](../design/item_rules.md) |

## 시스템 결정

| ID | 결정 | 상태 | 영향 문서 | 재검토 관문 |
|---|---|---|---|---|
| `DEC-101` | TypeScript + HTML5 Canvas를 구현 기준안으로 사용 | `active` | [`../GDD.md`](../GDD.md) | G0 |
| `DEC-102` | 인벤토리는 제한 슬롯+무게 부담 단계를 사용 | `active` | [`../design/item_rules.md`](../design/item_rules.md) | G1 |
| `DEC-103` | 인벤토리와 지도에서 시간을 일시정지 | `active` | [`../GDD.md`](../GDD.md) | G1 |
| `DEC-104` | 기본 공격 없이 비상 무력화만 제공 | `active` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../design/harness_engineering.md`](../design/harness_engineering.md) | G1·G3 |
| `DEC-105` | 실패 시 런 회수품 손실, 영구 장비 유지·손상 | `active` | [`../design/item_rules.md`](../design/item_rules.md), [`../design/economy_rules.md`](../design/economy_rules.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | G2·G4 |
| `DEC-106` | 거점은 메뉴형으로 시작 | `active` | [`../GDD.md`](../GDD.md), [`../design/economy_rules.md`](../design/economy_rules.md) | G2 |
| `DEC-107` | 하네스는 모듈식 탐색·회수 성장 시스템 | `active` | [`../design/harness_engineering.md`](../design/harness_engineering.md) | G1·G3 |
| `DEC-108` | 추적자는 고장 난 경비 골렘으로 시작 | `active` | [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | G1·G3 |
| `DEC-109` | 탐험 중 자유 저장을 제공하지 않음 | `active` | [`../design/item_rules.md`](../design/item_rules.md), [`../GDD.md`](../GDD.md) | G2 |
| `DEC-110` | 첫 출시 목표는 하나의 완결된 폐던전 | `active` | [`../GDD.md`](../GDD.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) | G5·G7 |

## `STY-0103` 원본 대응

아래 표는 원본 15장의 30개 확정 변경점을 빠짐없이 추적한다. 원문은 동결 사본에서 보존하며, 현재 적용할 상세 내용은 위 결정과 연결된 활성 문서에서 확인한다.

| 원본 줄 | 확정 변경점 | 연결 결정 |
|---:|---|---|
| 1104 | 플레이어는 처음부터 수색꾼으로 시작한다. | `DEC-002` |
| 1105 | 초반 목표는 사건형이 아니라 생계형이다. | `DEC-003` |
| 1106 | 플레이어는 모험가를 아직 동경하지만, 이 감정은 가볍고 건강한 막연한 동경으로 둔다. | `DEC-013` |
| 1107 | 마왕 부활 전조나 부활 세력은 은근한 배경 떡밥으로만 둔다. | `DEC-001`, `DEC-010` |
| 1108 | 코어는 코어 방에 눈에 보이는 형태로 존재한다. | `DEC-004` |
| 1109 | 살아 있는 던전과 폐던전의 차이는 자가 복구 능력으로 구분한다. | `DEC-004` |
| 1110 | 범람은 활성 던전의 에너지 과잉 현상이며, 코어가 파괴된 폐던전은 범람 위험이 사라진다. | `DEC-004` |
| 1111 | 폐던전은 코어가 파괴된 던전 전체를 뜻하고, 잔여 구역은 폐던전 내부의 미답파·미기록 구역을 뜻한다. | `DEC-004`, `DEC-005` |
| 1112 | 던전이 완전히 소멸하면 그 지역은 당분간 안정된다. | `DEC-004` |
| 1113 | 수색꾼 길드가 존재하며, 허가증이나 표식으로 출입 자격을 표시할 수 있다. | `DEC-014` |
| 1114 | 공식 문서에서는 수색꾼을 넓은 의미의 모험가나 정찰 파견 인원으로 처리할 수 있고, 현장 명칭은 수색꾼으로 통일한다. | `DEC-002` |
| 1115 | 수색꾼 관련 은어는 말하는 사람의 편견을 보여주는 장치로 사용한다. | `DEC-002` |
| 1116 | 폐던전 명칭은 공식 문서와 현장 대화 모두에서 폐던전으로 통일한다. | `DEC-004` |
| 1117 | 회수품 가격은 기본적으로 길드가 주도한다. | `DEC-014` |
| 1118 | 감정사는 기능형 NPC로 두고, 휴대용 감정 아이템도 사용할 수 있다. | `DEC-015` |
| 1119 | 연구자는 플레이어가 가져오는 기록물에 따라 마왕과 던전의 직접 인과를 점차 의심하고 분리해 가는 인물로 둔다. | `DEC-001` |
| 1120 | 상인은 저주 소문이 붙은 물건은 꺼릴 수 있지만, 감정된 잔재는 거래할 수 있다. | `DEC-016` |
| 1121 | 봉인 관리인은 제거하고, 성직자가 마왕·봉인 관련 반응을 일부 담당한다. | `DEC-017` |
| 1122 | 고유 유물과 핵심 기록물은 판매 불가로 둔다. | `DEC-007` |
| 1123 | 핵심 기록물은 연구자에게 맡겨 수집 목록을 채우는 방식으로 사용한다. | `DEC-007` |
| 1124 | 아이템 분류는 테두리 색으로 구분한다. | `DEC-018` |
| 1125 | 잔존 에너지는 코어 파괴 후 남은 마력이며, 폐품 노출·잔재 응축·장치 오작동·구역 변형의 원인이 된다. | `DEC-008` |
| 1126 | 메인 스토리는 세계관 해설처럼 느껴져도 괜찮으며, 큰 추가 스토리 확장은 하지 않는다. | `DEC-010` |
| 1127 | 발견물은 특정 구역 안에서 랜덤 획득하는 방식이 적절하다. | `DEC-006` |
| 1128 | 지도 관련 발견물은 공식 지도 바깥의 표식, 손상된 공략도, 좌표 조각 같은 잔여 구역 단서로 사용한다. | `DEC-005`, `DEC-006` |
| 1129 | 반복 탐험은 고정 큰 지도에 구역별 랜덤 보상과 위험 이벤트를 섞는 방향이 적절하다. | `DEC-006` |
| 1130 | 반복 보상은 보상 감소형보다 잔존 에너지 유실량을 기준으로 일정 범위 안에서 유지하는 방향이 현재 설정과 맞다. | `DEC-008` |
| 1131 | 고유 유물 회수 후에는 위험 증가보다 방 소실, 상호작용 감소, 잔향 변화가 어울린다. | `DEC-008` |
| 1132 | 던전 안은 어둡게, 게임 전체는 생활감 있게 유지한다. | `DEC-012` |
| 1133 | 폐던전의 공포는 호러가 아니라 탐험 긴장감에 가깝다. | `DEC-012` |

## 이관 상태

`DOC-0401`에서 `STY-0103`의 확정 변경점 30개와 통합 GDD 18장의 결정 22개를 대조했다. 기존 `DEC-001`~`DEC-012`, `DEC-101`~`DEC-110`은 유지하고, 기존 ID로 독립 추적할 수 없던 원본 결정에 `DEC-013`~`DEC-018`을 부여했다. 등록 과정에서 새 설정이나 수치, 날짜, 승인자를 추가하지 않았으며 이 문서는 전체 전환 승인 전까지 `draft`다.
