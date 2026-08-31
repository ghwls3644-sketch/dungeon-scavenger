---
id: PROJECT-OPEN-QUESTIONS
title: 열린 질문
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - unresolved_questions
  - provisional_rules
last_reviewed: 2026-08-31
owner: project-maintainer
related:
  - ../GDD.md
  - story_v1.5_inventory.md
  - decisions.md
  - migration_changes.md
  - m4_term_review.md
  - ../reference/glossary.md
---

# 열린 질문

## 목적

미결정, 가안, 보류 항목을 기준 본문과 분리해 추적한다.

## 포함 범위

- 검토 중이거나 임시 원칙만 있는 질문
- 영향 문서와 다음 검토 조건
- 해결 후 연결할 결정 ID

## 제외 범위

- 이미 승인된 결정
- 원문에 없는 질문의 임의 생성
- 단순 문장 다듬기 요청

## 질문 목록

| ID | 질문 | 상태 | 영향 문서 | 임시 적용 원칙 | 다음 검토 조건 |
|---|---|---|---|---|---|
| `Q-001` | `Flooded` 방은 실제 침수 구역인가, 마력 침식 구역인가? | `provisional` | [`../GDD.md`](../GDD.md) | 첫 던전의 기능 중복을 줄이기 위해 마력 침식 구역 권장 | G0·레벨 데이터 정리 전 |
| `Q-002` | 봉쇄된 하층을 첫 출시에서 실제로 여는가? | `provisional` | [`../GDD.md`](../GDD.md), [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) | 결말용 짧은 최종 구역까지만 개방 | G5 콘텐츠 범위 확정 전 |
| `Q-003` | 플레이어의 이름·성별·외형을 고정하는가? | `provisional` | [`../GDD.md`](../GDD.md), [`../story/03_player_and_society.md`](../story/03_player_and_society.md) | 최소 외형 선택 또는 중성적 기본 캐릭터 | G7 아트 제작 전 |
| `Q-004` | 한 런의 정확한 목표 시간은 얼마인가? | `provisional` | [`../GDD.md`](../GDD.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | 15~25분 범위에서 G1 테스트로 결정 | G1 종료 시 |
| `Q-005` | 슬롯 수·무게 단계·감속률은 얼마인가? | `provisional` | [`../GDD.md`](../GDD.md), [`../design/item_rules.md`](../design/item_rules.md) | 수치 없이 구조만 고정 | G1 플레이테스트 |
| `Q-006` | 컨트롤러를 첫 출시 필수로 포함하는가? | `provisional` | [`../GDD.md`](../GDD.md) | 키보드·마우스 먼저, G6에서 포함 여부 결정 | G6 시작 전 |
| `Q-007` | 세션 중단용 임시 저장을 제공하는가? | `provisional` | [`../GDD.md`](../GDD.md), [`../design/item_rules.md`](../design/item_rules.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | 장기 런이 확정될 때만 추가 | G6 저장 UX 검토 |
| `Q-008` | 최종 그림체는 픽셀, 페인터리 2D, 단순 벡터 중 무엇인가? | `provisional` | [`../GDD.md`](../GDD.md) | 탑다운 가독성 표본 비교 후 결정 | 정식 아트 제작 전 |
| `Q-009` | 플레이어의 낮은 능력치를 저주나 특수 체질과 연결할 것인가? | `deferred` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) | 순수 능력치 부족으로 처리하고 생계형 수색을 중심에 둠 | 캐릭터 고유 서사가 필요해질 때 |
| `Q-010` | 던전의 정확한 발생 원리를 확정할 것인가? | `deferred` | [`../story/01_world_history.md`](../story/01_world_history.md), [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | 자연 발생하지만 정확한 원리는 불명확한 상태로 유지 | 상세 발생 원리가 콘텐츠나 시스템에 필요해질 때 |
| `Q-011` | 코어의 정체를 생명체·장치·자연 기관 중 하나로 확정할 것인가? | `deferred` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | 모호한 마력 핵으로 유지 | 코어의 시각·상호작용 규칙을 확정할 때 |
| `Q-012` | 잔존 에너지가 플레이어에게 직접 반응하는 규칙을 둘 것인가? | `deferred` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | 개연성 보강용 설정으로만 사용하고 직접 반응은 다루지 않음 | 직접 반응이 플레이 기믹에 필요해질 때 |
| `Q-013` | 플레이어의 과거 사건을 필수 서사로 만들 것인가? | `deferred` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) | 시험 탈락 장면 없이 이미 수색꾼으로 사는 현재에서 시작 | 캐릭터 과거나 시작 연출이 필요해질 때 |
| `Q-014` | 폐던전 사고 책임의 범위를 어디까지 시스템화할 것인가? | `provisional` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../design/economy_rules.md`](../design/economy_rules.md) | 허가증 약관상 폐던전 내부 사고는 기본적으로 본인 책임으로 처리 | 사망·부상·장비 손실·의뢰 실패·민간 피해를 구분해 설계할 때 |
| `Q-015` | 암시장 거래 선택지를 넣을 것인가? | `deferred` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../design/economy_rules.md`](../design/economy_rules.md) | 현재 범위에서 제외 | 경제 루프 검증 후 |
| `Q-016` | 잔재에 환청·환시 연출을 넣을 것인가? | `deferred` | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md) | 텍스트 설명 중심 | 연출 예산 확정 후 |
| `Q-017` | UI와 정산에서 감정 비용을 `감정료`와 `감정 수수료` 중 무엇으로 표시할 것인가? | `deferred` | [`../GDD.md`](../GDD.md), [`../design/economy_rules.md`](../design/economy_rules.md), [`../reference/glossary.md`](../reference/glossary.md) | 두 표기를 같은 비용 개념으로 추적하되 독립 공식 용어 등록은 보류 | 정산 UI 문구 확정 전 |
| `Q-018` | 출입 자격을 물리적 `허가증` 아이템으로 확정할 것인가, `출입 허가`나 표식으로 표현할 것인가? | `deferred` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`../reference/glossary.md`](../reference/glossary.md) | `DEC-014`의 출입 자격만 유지하고 독립 아이템명은 확정하지 않음 | 허가·출정 UI와 아이템 목록 확정 전 |

`Q-009`~`Q-011`은 GDD 19장에서 의도적으로 확정하지 않는 배경 여지로 분류한 항목이다. 현재 제품 구조를 막지 않으며 위 검토 조건이 생기기 전에는 결정을 요구하지 않는다.

`DEV-0107` 플레이테스트 장면은 적재 선택을 재현하기 위해 슬롯 2개, 부담 2.5, 과적 4.0과 짧은 시험 공간을 사용한다. `DEV-0108`의 조사·미확인 물품 공간도 상태 전달 검사용 임시 한도와 무게만 사용한다. 이 값들은 자동 검사 자료일 뿐 목표 런 시간이나 제품 슬롯·무게 단계·감속률의 근거로 확정하지 않는다. 2026-08-31 G1 정합성 검사에서도 사람 플레이테스트 자료가 없어 `Q-004`·`Q-005`를 결정하지 않았으며, `DEV-0111` 검토 전까지 두 질문은 `provisional`로 유지한다.

## 원본 추가 검토 메모 대응

아래 표는 원본의 추가 검토 메모 13개 제목에 포함된 26개 항목을 빠짐없이 추적한다. 아직 정하지 않은 내용만 위 질문 목록에 등록하고, 이미 확정된 방향은 결정 기록이나 해당 활성 문서에 연결한다.

| 원본 ID·줄 | 추가 검토 메모 | 처리 |
|---|---|---|
| `STY-0009` 85 | 플레이어의 낮은 능력치를 저주나 특수 체질과 연결할지는 보류한다. 현재는 단순한 수치 부족만으로도 캐릭터와 게임 구조가 충분히 성립한다. | `Q-009` |
| `STY-0009` 86 | 마왕 부활 세력은 선택적 배경 떡밥으로 유지한다. 핵심 게임 진행에 필수 요소로 만들면 볼륨이 커질 수 있으므로, 발견물과 소문 수준으로 다루는 편이 안전하다. | [`decisions.md`](decisions.md)의 `DEC-001`, `DEC-010` |
| `STY-0016` 146 | 던전 발생 조건을 상세한 과학처럼 확정할 필요는 없다. “자연 발생하지만 정확한 원리는 불명확하다”는 선에서 유지해도 된다. | `Q-010` |
| `STY-0016` 147 | 마왕과 던전의 관계는 세계관의 객관적 진실과 NPC들의 오해를 분리해서 다루면 된다. 어떤 NPC는 둘이 무관하다고 알고, 어떤 NPC는 여전히 마왕의 징조라고 믿을 수 있다. | [`decisions.md`](decisions.md)의 `DEC-001` |
| `STY-0023` 211 | 코어의 정체는 생명체, 장치, 자연 기관 중 하나로 확정하지 않는다. 현재는 모호한 마력 핵으로 두는 편이 가장 유연하다. | `Q-011` |
| `STY-0023` 212 | 잔존 에너지가 플레이어에게 직접 반응하는 세부 규칙은 이번 게임에서 크게 다루지 않는다. 개연성 보강용 설정으로만 유지한다. | `Q-012` |
| `STY-0030` 286 | 첫 폐던전은 “코어가 파괴되어 범람 위험이 없어졌고, 그래서 방치된 장소”로 시작하면 간단하다. | [`decisions.md`](decisions.md)의 `DEC-004` |
| `STY-0030` 287 | 폐던전의 위험 등급은 더 이상 공식적으로 세밀하게 관리하지 않는다. 다만 수색꾼들 사이에서는 “무너진 방이 많다”, “골렘이 남았다”, “마력이 아직 진하다” 같은 현장식 평판이 돌 수 있다. | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) |
| `STY-0035` 333 | 플레이어의 과거 사건은 당장 필수로 만들지 않는다. 모험가 시험 탈락 장면 없이도 “이미 수색꾼으로 살고 있다”는 현재 상태에서 바로 시작할 수 있다. | `Q-013` |
| `STY-0035` 334 | 저주나 특수 체질 설정은 확장 여지가 있지만, 초반부터 넣으면 이야기의 중심이 생계형 수색에서 특수 운명으로 옮겨갈 수 있으므로 주의한다. | `Q-009` |
| `STY-0043` 407 | “폐던전 사고 책임”은 현재 문맥에서는 너무 넓은 질문이다. 사망, 부상, 장비 손실, 의뢰 실패, 민간 피해 중 무엇을 말하는지에 따라 시스템이 달라진다. 현 단계에서는 허가증 약관상 “폐던전 내부 사고는 기본적으로 본인 책임” 정도만 설정하면 충분하다. | `Q-014` |
| `STY-0043` 408 | 암시장 선택지는 지금 당장 필수는 아니다. 나중에 넣는다면 “공식 감정소에 맡기면 수집/연구 진행, 암시장에 넘기면 즉시 돈은 받지만 기록 진행은 없음” 같은 간단한 선택지부터 시작하는 편이 좋다. | `Q-015` |
| `STY-0052` 505 | 다른 수색꾼은 경쟁자보다 일반적인 동료나 튜토리얼 조언자에 가깝게 둔다. | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md), [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `STY-0052` 506 | 성직자는 있어도 되지만 봉인 관리인은 현재 삭제하는 편이 좋다. 마왕 봉인을 직접 관리하는 직업을 만들면 이야기 규모가 커진다. | [`decisions.md`](decisions.md)의 `DEC-017` |
| `STY-0059` 585 | 고유 유물과 핵심 기록물은 판매 불가가 현재 방향과 잘 맞는다. | [`decisions.md`](decisions.md)의 `DEC-007` |
| `STY-0059` 586 | 잔재의 연출은 텍스트 설명부터 시작하고, 환청/환시 같은 연출은 후순위로 둔다. | `Q-016` |
| `STY-0066` 656 | “이 던전은 이상하다”는 단일 사건을 굳이 만들 필요는 없다. 이 세계에서는 던전 자체가 원래 이상하고, 코어가 파괴되어도 언제 사라질지 모르는 어처구니없는 현상이다. | [`decisions.md`](decisions.md)의 `DEC-010` |
| `STY-0066` 657 | 현재 기획에서는 이 이상의 추가 메인 스토리를 확장하지 않는다. 마왕 부활 세력, 던전의 진실, 대형 길드 갈등은 선택적 배경 요소로만 유지한다. | [`decisions.md`](decisions.md)의 `DEC-010` |
| `STY-0075` 761 | 서브 스토리는 메인 진행 필수가 아니라 선택적 보강으로 둔다. | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) |
| `STY-0075` 762 | 특정 구역 랜덤 획득 방식이 현재 방향에 가장 잘 맞는다. 지도 발견물은 잔여 구역을 암시하는 부분 단서로 쓰는 편이 자연스럽다. | [`decisions.md`](decisions.md)의 `DEC-005`, `DEC-006` |
| `STY-0085` 887 | 반복 탐험이 던전을 자극한다는 설정은 현재 게임에서는 시스템 설명 정도로만 처리한다. | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) |
| `STY-0085` 888 | 랜덤성은 “방 전체 절차 생성”보다 “구역별 보상과 위험 이벤트 변화”에 집중하는 편이 안전하다. 보상량은 감소형보다 잔존 에너지 유실량을 기준으로 일정 범위 안에서 유지하는 방향이 현재 설정과 더 잘 맞는다. | [`decisions.md`](decisions.md)의 `DEC-006`, `DEC-008` |
| `STY-0093` 963 | 던전 내부는 어둡게, 거점과 NPC 대화는 생활감 있게 나누면 톤 균형이 좋다. | [`decisions.md`](decisions.md)의 `DEC-012` |
| `STY-0093` 964 | 가벼운 유머는 허용해도 된다. 다만 던전 내부의 위험감이 무너지지 않는 선에서 사용한다. | [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) |
| `STY-0101` 1071 | “수색꾼”은 현장 명칭으로 유지한다. 공식 문서에서는 넓은 의미의 “모험가”나 임무 단위의 “정찰 파견”으로 처리할 수 있다. | [`decisions.md`](decisions.md)의 `DEC-002` |
| `STY-0101` 1072 | 봉인 관리인은 용어 목록에서 제거한다. 필요하다면 성직자가 그 역할의 일부를 흡수한다. | [`decisions.md`](decisions.md)의 `DEC-017` |

## 이관 상태

`DOC-0402`에서 원본 추가 검토 메모 13개 제목의 26개 항목과 GDD 19장의 질문을 대조했다. GDD의 `Q-001`~`Q-008`을 유지하고, 실제 미결정 사항 8개에 `Q-009`~`Q-016`을 부여했다. 나머지 18개 항목은 기존 결정 또는 활성 문서와 연결했으며 새 설정이나 해결 결정을 추가하지 않았다. 이 문서는 전체 전환 승인 전까지 `draft`다.
