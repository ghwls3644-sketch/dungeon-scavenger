---
id: PROJECT-DECISIONS
title: 결정 기록
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - approved_decisions
  - decision_rationale
last_reviewed: 2026-10-20
owner: project-maintainer
related:
  - ../design/recovery_tax.md
  - ../GDD.md
  - project_context.md
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

- `active`는 동결 원본·통합 GDD 또는 명시적 사용자 선택에서 현재 방향으로 채택된 결정을 뜻한다. 사용자 선택은 아래에 결정일·승인 범위를 따로 기록한다.
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
| `DEC-101` | Godot 4.7.1 + GDScript + Compatibility를 Windows PC 우선 구현 기준으로 사용 | `active` | [`../GDD.md`](../GDD.md), [`project_context.md`](project_context.md) | G0 |
| `DEC-102` | 인벤토리는 제한 슬롯+무게 부담 단계를 사용 | `active` | [`../design/item_rules.md`](../design/item_rules.md) | G1 |
| `DEC-103` | 인벤토리와 지도에서 시간을 일시정지 | `active` | [`../GDD.md`](../GDD.md) | G1 |
| `DEC-104` | 기본 공격 없이 비상 무력화만 제공 | `active` | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`../design/harness_engineering.md`](../design/harness_engineering.md) | G1·G3 |
| `DEC-105` | 실패 시 런 회수품 손실, 영구 장비 유지·손상 | `active` | [`../design/item_rules.md`](../design/item_rules.md), [`../design/economy_rules.md`](../design/economy_rules.md), [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | G2·G4 |
| `DEC-106` | 거점은 메뉴형으로 시작 | `active` | [`../GDD.md`](../GDD.md), [`../design/economy_rules.md`](../design/economy_rules.md) | G2 |
| `DEC-107` | 하네스는 모듈식 탐색·회수 성장 시스템 | `active` | [`../design/harness_engineering.md`](../design/harness_engineering.md) | G1·G3 |
| `DEC-108` | 추적자는 고장 난 경비 골렘으로 시작 | `active` | [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | G1·G3 |
| `DEC-109` | 탐험 중 자유 저장을 제공하지 않음 | `active` | [`../design/item_rules.md`](../design/item_rules.md), [`../GDD.md`](../GDD.md) | G2 |
| `DEC-110` | 첫 출시 목표는 하나의 완결된 폐던전 | `active` | [`../GDD.md`](../GDD.md), [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) | G5·G7 |
| `DEC-111` | 수리는 거점에서 비용을 확인하고 사용자가 선택·확정한다. | `active` | [`../design/economy_rules.md`](../design/economy_rules.md#수리-거래-시점), [`../design/repair_rules.md`](../design/repair_rules.md), [`../GDD.md`](../GDD.md) | G4 |
| `DEC-112` | 하네스 영구 개선은 거점 직접 구매와 탐험 중 무료 발견을 함께 제공한다. 원본 등록을 구매 선행 조건으로 삼지 않는다. | `active` | [경제 규칙](../design/economy_rules.md#하네스-영구-개선의-획득), [하네스 검토안](../design/harness_engineering.md), [GDD](../GDD.md#10-5-성장-구조) | G4·G5 |
| `DEC-113` | 소음 유인물은 매 출정 기본 2개를 무료로 제공하고, 필요하면 추가 구매한다. | `active` | [경제 규칙](../design/economy_rules.md#휴대-도구의-기본분과-추가-구매), [휴대 도구 검토안](../design/tool_preparation.md), [GDD](../GDD.md#10-2-거점-기능) | G4 |
| `DEC-114` | 출정별 손익은 소모한 비용을 기준으로 크게 표시하고 실제 현금 변화는 별도로 표시한다. 영구 개선 지출과 미지불 수리 견적은 구분한다. | `active` | [경제 규칙](../design/economy_rules.md#비용-항목), [비용 표시 검토안](../design/expedition_cost_reporting.md), [GDD](../GDD.md#10-4-가격과-거래) | G4 |
| `DEC-115` | 자유 수색을 유지하고 원할 때 회수 의뢰 하나를 선택해 추가 보상을 받는다. 미달성해도 기존 회수품 정산을 유지한다. | `active` | [목표·의뢰 검토안](../design/expedition_objectives.md), [경제 규칙](../design/economy_rules.md#선택-의뢰의-추가-보상), [GDD](../GDD.md#4-2-한-런의-흐름) | G4 |
| `DEC-116` | 회수세는 판매 대금에만 부과하고 의뢰 보상은 전액 지급한다. 귀환 자동 판매와 거점 보관품 판매에 같은 과세 기준을 적용한다. | `active` | [경제 규칙](../design/economy_rules.md#회수세의-과세-대상), [회수세 검토안](../design/recovery_tax.md), [GDD](../GDD.md#10-4-가격과-거래) | G4 |
| `DEC-117` | 휴대용 감정은 횟수 제한 확정 감정이며 같은 물품은 다시 감정하지 않는다. 필요한 만큼 유료 구매해 휴대 수량을 선택하고 안전 귀환 시 미사용분을 보관한다. | `active` | [아이템 규칙](../design/item_rules.md#감정-상태), [경제 규칙](../design/economy_rules.md#휴대용-감정-도구의-구매와-보관), [검토안](../design/portable_appraisal.md), [GDD](../GDD.md#8-2-감정) | G4 |
| `DEC-118` | 안전 귀환의 고정 마모를 없애고 실패 때만 손상되는 방식을 제한적으로 시험한다. 비용 확인 후 수리 확정과 돈 부족 시 최소 복구는 유지한다. 최종 제품 규칙·수치 확정은 아니다. | `active` | [수리 검토안](../design/repair_rules.md#dev-0430-반복-수리-검토와-미적용-제안), [비교 근거](repair_choice_review.md), [Q-022·Q-023](open_questions.md#수리-규칙-검토-경계) | G4 시험 |
| `DEC-119` | 내구가0이어도 수리 없이 출정할 수 있게 하고, 실수로 출정하지 않도록 미수리 상태를 출정 전에 알린다. | `active` | [경제 규칙](../design/economy_rules.md#수리-거래-시점), [수리 후속안](../design/repair_rules.md#dev-0432-내구0-출정과-주의-안내-방향), [GDD](../GDD.md#7-4-자원-규칙-설계-결정) | G4 구현 |

### DEV-0432 내구0 출정과 주의 안내 선택

결정일 **2026-10-20**, 승인자 **사용자**. “수리 부담은 원래도 크진 않았던거 같아 문제는 수리하지 않으면 다음 출정이 막히는 게 문제였지”라고 정정한 뒤, “내구도가 0이여도 출정할 수 있지만 실수로 출정하는 경우를 생각해서 주의 할 수 있게 피드백이 있으면 좋겠어”라고 답했다. MIG-CHG-064에 먼저 기록했다.

승인된 방향은 **내구0 출정 허용과 실수를 막는 사전 주의 안내**다. DEV-0407/0431의 출정 최소 내구1 시험 제한을 후속 DEV-0433에서 바꾼다. DEC-111의 수리 선택/확정, DEC-118의 안전 귀환 마모 제외 시험은 유지하므로 두 결정을 대체하지 않는다. 돌아가기/그대로 출정을 고르는 확인 화면은 이 요구를 충족하기 위한 구현 방안이며 사용자가 지정한 최종 문구나 UI 승인으로 확대하지 않는다.

DEV-0433에서 [내구0 안내 후 선택 출정](../design/repair_rules.md#dev-0433-내구0-출정과-주의-안내-적용)을 구현했다. 위 DEV-0432 당시의 후속 구현 표기는 이력이다. 새 능력 불이익·자동 복구/결제·지원 자격·최종 수치를 이 답변에서 정하지 않는다. 수리의 가치·실패 부담·지원 기준과 최종 밸런스는 Q-022/Q-023의 후속 범위다. 방향 답변은 DEV-0432 커밋 또는 G4 전체 완료·G5 착수 승인과 구분한다.

### DEV-0430 수리 반복 보완 시험 방향 선택

결정일 **2026-10-15**, 승인자 **사용자**. 안전 귀환의 고정 마모 제외와 현행 유지 중 “실패 때만 손상되는 안 시험 (권장)”을 선택했다. `MIG-CHG-062`에 먼저 기록했다. 승인 범위는 안전 귀환의 고정 마모를 없애고 실패 손상은 유지하는 제한된 시험이며, 비용 확인/수리 확정과 돈 부족 시 최소 복구는 유지한다. DEV-0430에서 비교한 안전 귀환0·실패2의 후보를 다음 DEV-0431에서 시험한다.

DEC-111의 거래 방식은 유지한다. 최종 손상량·가격·지원 자격, 장기 경제·완전 수리의 가치와 구매 순서에 따른 지원 자격 차이는 [수리 검토안](../design/repair_rules.md)·[Q-022·Q-023](open_questions.md#수리-규칙-검토-경계)에 남긴다. 현재 게임 데이터는 미적용이며, 이 답변은 DEV-0430 문서의 커밋 승인·G4 전체 완료·G5 착수 승인이 아니다. GDD/confirmed 경제 규칙을 최종 수치로 바꾸지 않는다.

### DEV-0422 휴대용 감정 방식 선택

결정일 **2026-10-10**, 승인자 **사용자**. “필요한 만큼 유료 구매 (권장): 가져갈 수량을 선택하고, 안전 귀환 시 미사용분은 보관합니다.”를 선택했다. 확정 감정과 예비 감정의 운반 판단·거점 재감정 차이를 설명한 뒤 “횟수 제한 확정 감정 (권장): 지금 확인할 물품을 고르는 데 집중하고, 같은 물품을 다시 감정하지 않습니다.”를 선택했다. MIG-CHG-054에 먼저 기록했다.

승인 범위는 **횟수 제한 확정 감정·필요 수량 유료 구매/휴대 선택·안전 귀환 미사용분 보관**이다. 물품 분류·가치 범위의 확인은 등록·연구 해금이나 감정사의 공식적인 판별을 대신하지 않는다. 단가10·휴대/총 재고2·무게0.25·인벤토리 즉시 사용·실패/원가/저장 세부는 [검토안](../design/portable_appraisal.md)·[Q-030](open_questions.md#휴대용-감정-검토-경계)의 미적용 시험 제안과 후속 검증이다. 이 답변은 문서 커밋·구현 완료·G4 완료 승인이 아니다.

### DEV-0420 회수세 과세 대상 선택

결정일 **2026-10-10**, 승인자 **사용자**. 판매 40+의뢰 보상 10·비교 세율 10%에서 판매만 과세(세금 4) 또는 보상까지 과세(세금 5)의 질문에 “판매 대금에만 부과 (권장): 세금 4, 의뢰 보상은 전액 지급”을 선택했다. 질문에 명시한 귀환 자동 판매와 거점 보관품 판매의 동일 과세 기준도 함께 적용한다. MIG-CHG-052에 먼저 기록했다.

승인 범위는 **판매 대금 과세·의뢰 보상 전액 지급** 방향이다. 10%는 비교값이며 세율·거래별 합산/절사·최소 세액·세부 징수/저장·난이도별 보정과 최종 밸런스는 [검토안](../design/recovery_tax.md)·[Q-029](open_questions.md#회수세-검토-경계)의 미적용 제안/후속 판단으로 남긴다. 기존 판매 보호·실패 안전망·DEC-114 손익 표시를 유지한다. 이 답변은 코드 적용·문서 커밋·G4 완료 승인이 아니다.

### DEV-0417 거점 목표·의뢰 방식 선택

결정일 **2026-10-09**, 승인자 **사용자**. 자유 수색+선택 의뢰 1개/추가 보상, 보상 없는 개인 목표, 안내 유지 후 의뢰 보류의 세 방향 중 “자유 수색 + 선택 의뢰 1개·추가 보상 (권장)”을 선택했다. `MIG-CHG-049`에 먼저 기록했다. 승인한 방향은 **의뢰 없이도 자유롭게 출정할 수 있고, 원할 때 회수 의뢰 하나를 골라 추가 보상을 받으며, 미달성해도 기존 회수품 정산을 유지**하는 방식이다.

회수 실적과 납품 중 구체적 판정 방식, 대상 물품·수량·보상액, 반복/재수락·완료 시점·세부 UI/저장과 최종 밸런스는 [검토안](../design/expedition_objectives.md)·[Q-028](open_questions.md#거점-목표의뢰-검토-경계)의 미적용 제안과 후속 검증으로 남긴다. 기존 물품 보호·직접 구매/무료 발견·최소 복구를 바꾸지 않는다. 이 답변은 DEV-0417의 문서 커밋 승인이나 G4 전체 완료 승인이 아니다.

### DEV-0414 출정별 비용 표시 기준 선택

결정일 **2026-10-06**, 승인자 **사용자**. 유인물 2개를 10에 사서 1개 사용하고 회수품을 30에 팔았을 때, 소모 기준 손익 +25와 실제 현금 변화 +20을 나눠 표시하는 권장안에 “일단 권장 방식으로 채용할게”라고 답했다. `MIG-CHG-046`에 먼저 기록했다. 현재 채택한 방향은 **소모한 비용을 기준으로 손익을 계산하고 실제 현금 변화는 별도로 표시**하는 방식이다. 영구 개선 구매는 별도 투자로, 아직 지불하지 않은 수리 견적은 예상치로 구분한다. 표시 손익을 지갑에 다시 적용하여 이미 결제한 비용을 재청구하지 않는다.

이번 답변은 표시 기준의 선택이다. 집계 기간·거점 거래의 귀속, 혼합 단가 재고의 배정 순서, 원가가 없는 구형 기록 처리·세부 화면·저장 형식과 최종 밸런스는 [검토안](../design/expedition_cost_reporting.md)·[Q-027](open_questions.md#출정별-비용-표시-검토-경계)의 제한된 제안과 후속 검증으로 남긴다. 코드 적용이나 DEV-0414 문서 커밋까지 승인한 것으로 해석하지 않는다.

### DEV-0412 휴대 도구 준비 방식 선택

결정일 **2026-10-06**, 승인자 **사용자**. 소음 유인물의 준비 방식 질문에 “기본 2개 무료 + 필요하면 추가 구매 (권장)”를 선택했다. `MIG-CHG-044`에 먼저 기록했다. 승인 범위는 첫 대상인 소음 유인물의 기본 2개 무료 제공과 선택적인 추가 구매다. 무료분을 줄여서 유료로 다시 사게 만들지 않는다. 총 휴대 한도·가격·무게·미사용 추가분 반환·실패/종료 손실·저장 복구 방식은 [DEV-0412 검토안](../design/tool_preparation.md)의 미적용 제안이며 이번 답변으로 최종 확정하지 않는다. 새로운 보급 주체나 다른 도구의 지급 수량은 정하지 않았다.

### DEV-0411 영구 개선 획득 방식 선택

결정일 **2026-10-04**, 승인자 **사용자**. 직접 구매(1), 원본 등록 후 유료 구매(2), 탐험 발견으로 무료 획득(3)의 선택 질문에 “2번은 너무 번거로울 것 같고, 1번 3번을 섞어 쓸 수 있으면 좋을 것 같은데”라고 답했다. `MIG-CHG-043`에 먼저 기록했다. 승인 범위는 직접 구매와 무료 발견의 혼합 방식이다. 개별 개선의 가격·효과·발견 위치/빈도·정산 시점·중복 처리의 최종 수치/정책까지 승인한 것은 아니다. DEV-0411의 구체적인 시제품 조건과 Q-025의 잔여 평가는 하네스 문서와 개발 인계를 따른다.

### DEV-0405 수리 방식 선택

결정일 **2026-10-01**, 승인자 **사용자**. DEV-0405 진행 중 수리 방식 질문에 “거점에서 비용을 확인하고 선택 수리 (권장)”라고 답변했다. `MIG-CHG-037`에 먼저 기록하고 DEC-111을 추가했다. 기존 결정을 대체하지 않으며, GDD와 Economy Rules의 미정 거래 시점을 구체화한다.

승인 범위는 거점에서 비용을 확인하고 수리를 선택·확정하는 방식이다. 손상량·내구 상한·수리 단가·부분 수리·돈 부족 때 무료 복구 자격/양은 이 답변으로 확정하지 않았다. 이 항목들은 [Q-022·Q-023](open_questions.md#수리-규칙-검토-경계)과 `draft` [수리 검토안](../design/repair_rules.md)에 남긴다.

### DEV-0001 G0 재검토

2026-07-29에 사용자가 Godot 사용 방향과 권장 구성을 승인했다. `MIG-CHG-007`에 따라 `DEC-101`의 이전 TypeScript·HTML5 Canvas 기준안을 Godot 4.7.1, GDScript, Compatibility 렌더러와 Windows PC 우선 기준으로 교체했다. 원본 결정 문구는 동결 GDD와 Git 이력에서 추적하며, 현재 실행 기준은 [`project_context.md`](project_context.md)를 따른다.

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

## DEV-0418의 DEC-115 적용 범위

DEV-0418은 DEC-115의 자유 수색+선택 의뢰 하나/추가 보상과 미달성 정상 정산을 [제한된 시험](../design/expedition_objectives.md#dev-0418-선택-의뢰-시험-적용)으로 연결했다. 위 DEV-0417의 “미적용 제안”은 당시 이력이다. MIG-CHG-050에 기록한 폐품 2개·보상 10·선택 초기화·스키마 8은 구현 시험이며 새 사용자 정책 결정이나 최종 경제 승인이 아니다. DEC ID를 새로 만들거나 DEC-115의 승인 범위를 확대하지 않는다.
