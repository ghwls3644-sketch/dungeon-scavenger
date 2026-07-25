---
id: STORY-CHARACTERS-FACTIONS
title: 인물과 세력
document_type: story
status: draft
source_version: story-v1.5
canonical_for:
  - character_knowledge
  - faction_roles
  - character_attitudes
last_reviewed:
owner: narrative-design
related:
  - ../GDD.md
  - 01_world_history.md
  - 03_player_and_society.md
  - 05_items_and_discoveries.md
  - 06_narrative_progression.md
  - ../design/economy_rules.md
  - ../design/item_rules.md
  - ../design/narrative_delivery.md
  - ../reference/glossary.md
  - ../reference/speaker_lexicon.md
  - ../reference/entity_index.md
  - ../project/open_questions.md
---

# 인물과 세력

## 목적

기능형 NPC와 세력이 무엇을 알고 어떤 태도를 가지며 무엇에 반응하는지 관리한다.

## 포함 범위

- NPC와 세력의 게임 기능
- 처음 아는 정보와 진행에 따라 알게 되는 정보
- 잘못 알고 있거나 믿는 것
- 반응하는 아이템과 사건
- 성격과 태도의 요약

## 제외 범위

- 화자별 선호 단어, 은어, 금지 표현, 대사 예문
- 정보 노출을 작동시키는 게임 조건
- 존재하지 않는 인물이나 조직의 신규 생성

## 책임 경계

- 이 문서는 NPC와 세력이 세계 안에서 맡는 기능, 알고 믿는 내용, 태도와 반응을 소유한다.
- 정보가 어느 진행 단계와 조건에서 노출되는지는 [`06_narrative_progression.md`](06_narrative_progression.md)와 [`../design/narrative_delivery.md`](../design/narrative_delivery.md)가 소유한다.
- 감정 비용은 [`../design/economy_rules.md`](../design/economy_rules.md), 감정 시간·사용 횟수·정확도와 아이템 처리 규칙은 [`../design/item_rules.md`](../design/item_rules.md)가 소유한다.
- 화자별 선호 표현과 대사 예시는 [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md)가 소유한다.
- 공식 용어는 [`../reference/glossary.md`](../reference/glossary.md), 개체 ID와 이름 상태는 [`../reference/entity_index.md`](../reference/entity_index.md)가 소유한다.

## 주요 세력과 NPC

NPC는 세계관 전체를 설명하는 인물보다, 플레이 루프를 도와주는 기능형 인물을 중심으로 둔다. 이번 게임은 거대한 세력극보다 폐던전 탐험과 생계가 중심이므로, NPC 역할도 과하게 확장하지 않는다.

### 역할 분류

| 분류 | 역할 | 스토리 기능 | 현재 방향 |
| --- | --- | --- | --- |
| 상인 | 폐품 매입, 장비 판매, 무게 대비 가치 조언 | 현실적 보상과 경제 동기 제공 | 유지 |
| 감정사 | 잔재와 유물 감정 | 물건의 원본성, 마력 흔적, 불길한 떡밥 제공 | 기능형 NPC로 유지 |
| 연구자 | 기록물 보관, 해석, 수집 목록 관리 | 세계관 정보를 선택적으로 제공 | 핵심 기록물 수집처로 사용 |
| 길드 관리자 | 허가, 의뢰, 회수품 등록 | 플레이 목표 구조화 | 행정 NPC로 유지 |
| 전직 모험가 | 유명 던전 경험, 은퇴 후 조언 | 모험가 시대의 화려함과 이면 전달 | 선택적 NPC |
| 다른 수색꾼 | 튜토리얼 조언, 동료, 실패 사례 | 수색꾼 생업의 현실감 강화 | 일반적인 동료 역할 |
| 행정관 | 회수세, 출입 제한, 사고 처리 | 제도적 통제와 책임 회피를 보여줌 | 필요 시 배경으로 사용 |
| 성직자 | 마왕, 봉인, 저주에 대한 민간적·신앙적 해석 | 마왕과 던전을 연결하는 오해나 불안을 보여줌 | 봉인 관리인 대신 성직자로 단순화 |

이 역할은 각각 상인 [`NPC-003`](../reference/entity_index.md), 감정사 [`NPC-004`](../reference/entity_index.md), 연구자 [`NPC-005`](../reference/entity_index.md), 길드 관리자 [`NPC-006`](../reference/entity_index.md), 튜토리얼 수색꾼 [`NPC-007`](../reference/entity_index.md), 전직 모험가 [`NPC-008`](../reference/entity_index.md), 행정관 [`NPC-009`](../reference/entity_index.md), 성직자 [`NPC-010`](../reference/entity_index.md)로 추적한다. 표의 `다른 수색꾼`은 일반 역할 분류이며, 그중 튜토리얼 조력자 역할만 `NPC-007`에 대응한다.

### 세력 범위

- 수색꾼 길드 [`ORG-001`](../reference/entity_index.md)의 사회적 위치와 허가 체계는 [`03_player_and_society.md`](03_player_and_society.md)가 소유하며, 길드 관리자의 개인 기능은 이 문서가 소유한다.
- 마왕 부활을 믿거나 획책하는 소수 세력 [`ORG-002`](../reference/entity_index.md)은 선택적 배경 떡밥으로만 남아 있고 현재 핵심 사건이나 고유 유물 쟁탈 세력으로 확장하지 않는다.
- 이름과 세부 인원이 정해지지 않은 집단이나 직업 분류에는 새 개체 ID를 만들지 않는다.

## 연구자

연구자 [`NPC-005`](../reference/entity_index.md)는 기록물을 보관·해석하고 수집 목록을 관리하며, 플레이어가 가져오는 발견물을 통해 세계관 정보를 선택적으로 제공하는 핵심 기록물 수집처다.

연구자는 처음부터 “마왕과 던전은 무관하다”고 확정적으로 말하는 인물이 아니다. 세계관의 진실로는 둘 사이에 직접적인 인과가 없지만, 게임 안의 연구자는 플레이어가 가져오는 기록물과 잔재를 통해 그 결론에 점진적으로 가까워지는 인물로 두는 편이 자연스럽다.

| 진행도 | 연구자의 지식과 태도 |
| --- | --- |
| 초반 | 마왕 전승과 던전 발생 기록이 함께 묶인 소문과 문헌을 구분하려 하며, 같은 원인인지 판단을 유보한다. |
| 중반 | 플레이어가 가져온 기록에서 던전 발생과 마왕 봉인의 직접 인과가 약하고 지맥 이상과 더 자주 겹친다는 정황을 발견한다. |
| 후반 | 마왕의 이름을 둘러싼 사회적 오해와 객관적 던전 현상을 분리하고, 확보한 기록만으로는 직접 원인을 말할 수 없다고 본다. |

이렇게 하면 세계관의 객관적 진실과 NPC가 아는 정보를 분리할 수 있다. 또한 연구자가 플레이어의 발견물을 보관하고 연구한다는 기능이 서사적으로도 살아난다. 단계별 실제 대사 예시는 [`../reference/speaker_lexicon.md#감정사--연구자`](../reference/speaker_lexicon.md#감정사--연구자), 노출 시점과 조건은 [`06_narrative_progression.md`](06_narrative_progression.md)와 [`../design/narrative_delivery.md`](../design/narrative_delivery.md)가 담당한다.

## 튜토리얼 수색꾼

첫 조력자 [`NPC-007`](../reference/entity_index.md)은 다른 수색꾼이 가장 자연스럽다. 같은 일을 하는 선배나 동료 수색꾼이 기본적인 조언을 해주면, 플레이어가 세계를 배우는 방식과 직업의 현실감이 잘 맞는다. 선배와 동료 중 어느 관계인지는 아직 정하지 않는다.

튜토리얼 수색꾼은 다음을 알려줄 수 있다.

- 폐품과 잔재의 차이
- 무게 대비 가치 판단
- 너무 깊이 들어가지 말라는 경고
- 코어가 파괴된 던전이라도 내부가 안전하지 않다는 점
- 감정 전 물품을 어떻게 처리해야 하는지
- 퇴각 타이밍과 욕심의 위험성

이 인물은 거대한 서사의 조력자일 필요는 없다. 플레이어에게 필요한 최소한의 생존 감각을 알려주는 동료 정도면 충분하다. 실제 튜토리얼 발생 조건과 노출 순서는 [`../design/narrative_delivery.md`](../design/narrative_delivery.md)가 담당한다.

## 감정사와 감정 방식

감정사 [`NPC-004`](../reference/entity_index.md)는 큰 임무를 가진 핵심 인물이 아니라, 미확인 물품을 확인해주는 기능형 NPC로 둔다. 플레이어는 상황에 따라 감정사에게 여러 물품을 맡기거나 휴대용 감정 아이템으로 탐험 중 확인하는 두 가지 방식을 이용할 수 있다.

감정사에게 맡기는 방식에는 비용이나 시간이, 휴대용 감정 아이템에는 사용 횟수·비용·정확도 제한이 붙을 수 있다. 이는 원본과 GDD가 제시하는 설계 방향을 보존한 것이며, 실제 수치는 이 Story 문서에서 확정하지 않는다. 감정 상태와 제약 원칙은 [`../design/item_rules.md`](../design/item_rules.md), 비용은 [`../design/economy_rules.md`](../design/economy_rules.md)가 소유한다.

이 구조는 감정사를 스토리의 중심으로 만들지 않으면서도, 미확인 아이템 시스템과 자연스럽게 연결된다.

## 상인과 행정 역할

### 상인

상인 [`NPC-003`](../reference/entity_index.md)은 폐품을 매입하고 장비를 판매하며 무게 대비 가치에 관해 조언하는 실리적·계산적 인물이다. 현실적 보상과 경제 동기를 제공하되, 아무 물건이나 사지는 않는다.

저주가 묻었다고 소문난 물건은 찝찝해서 취급하지 않을 수 있다. 반면 잔재는 저주가 아니라 감정 가능한 마력 흔적이므로, 감정서나 거래 기준이 있으면 충분히 사고팔 수 있다. 구체적인 거래 가능 조건은 [`../design/item_rules.md`](../design/item_rules.md), 가격은 [`../design/economy_rules.md`](../design/economy_rules.md)가 담당한다.

### 길드 관리자

길드 관리자 [`NPC-006`](../reference/entity_index.md)는 허가, 의뢰, 회수품 등록을 처리해 플레이 목표를 구조화하는 행정 NPC다. 수색꾼 길드 자체의 제도와 사회적 위치는 [`03_player_and_society.md#수색꾼-길드`](03_player_and_society.md#수색꾼-길드)가 담당한다.

### 전직 모험가와 행정관

- 전직 모험가 [`NPC-008`](../reference/entity_index.md)는 유명 던전 경험과 은퇴 후 조언을 통해 모험가 시대의 화려함과 이면을 전하는 선택적 NPC다.
- 행정관 [`NPC-009`](../reference/entity_index.md)은 회수세, 출입 제한, 사고 처리를 통해 제도적 통제와 책임 회피를 보여주며 필요할 때만 배경 역할로 사용한다.

## 성직자와 사회적 믿음

봉인 관리인은 현재 필요하지 않다. “무엇을 지키는 직업인가?”라는 질문이 생기고, 별도 조직을 만들면 세계관 볼륨이 커진다. 따라서 이번 버전에서는 봉인 관리인을 제거하고, 마왕·봉인·저주 관련 반응은 성직자나 민간 전승으로 통합한다.

성직자 [`NPC-010`](../reference/entity_index.md)는 다음 정도의 기능이면 충분하다.

- 오래전 마왕 봉인을 종교적으로 기억한다.
- 던전 물건을 불길하게 보는 일반인의 시선을 보여준다.
- 어떤 잔재나 유물을 보고 마왕의 징조라고 오해할 수 있다.
- 객관적 진실을 반드시 알고 있을 필요는 없다.

마왕과 던전이 객관적으로 무관하더라도, 모든 NPC가 그 사실을 아는 것은 아니다. 세계관의 진실과 사람들의 믿음은 분리한다. 성직자와 일반인의 해석은 [`01_world_history.md`](01_world_history.md)의 객관적 역사보다 우선하지 않는다.

## 고유 유물과 반응 범위

현재 방향에서는 고유 유물을 거대한 세력 갈등의 중심으로 만들지 않는다. 고유 유물은 우선 수집품, 정보 해금, 관련 NPC 보상 정도로만 사용한다.

즉, “고유 유물을 공개하면 어떤 세력이 움직이는가?” 같은 큰 사건은 보류한다. 게임 볼륨을 줄이기 위해 고유 유물은 다음 정도의 기능으로 제한한다.

- 수집 목록 채우기
- 관련 연구자나 NPC에게 전달해 설명을 듣기
- 작은 보상이나 편의 기능을 얻기
- 특정 구역의 배경 정보를 열기

같은 물건이 모든 NPC의 반응을 동시에 일으키지 않으며, 필요한 역할의 NPC만 처리한다. 어떤 발견물이 누구에게 반응하는지에 대한 사실은 이 문서와 [`05_items_and_discoveries.md`](05_items_and_discoveries.md)가 나누어 소유하고, 실제 발생 조건은 [`../design/narrative_delivery.md`](../design/narrative_delivery.md)가 담당한다.

## 태도와 표현 연결

이 문서는 각 역할의 지식과 태도까지만 정한다. 길드·행정, 상인, 수색꾼, 감정사·연구자, 일반인, 전직 모험가, 성직자의 선호 어휘와 대사 예시는 각각 [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md)의 해당 화자 항목을 따른다.

## 원본 추적

| 원본 ID | 이관 내용 | 상태와 남은 책임 |
|---|---|---|
| `STY-0044`, `STY-0045`, `TBL-009` | 기능형 NPC 중심 원칙과 역할 분류 | `moved` |
| `STY-0046`, `TBL-010` | 연구자의 지식 변화 | `split`; 지식·태도는 Story, 대사 예시는 Speaker Lexicon, 등록·해석 단계 연결은 [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `STY-0047` | 튜토리얼 수색꾼의 역할과 조언 범위 | `split`; 역할은 Story, 실제 노출 경계는 [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `STY-0048`, `TBL-011` | 감정사 역할과 두 감정 방식 | `split`; NPC 기능은 이 문서, 상태·제약 원칙은 [`../design/item_rules.md`](../design/item_rules.md), 비용은 [`../design/economy_rules.md`](../design/economy_rules.md) |
| `STY-0049` | 고유 유물의 제한된 NPC·세력 반응 | `split`; 서사 범위는 Story, 실제 반응 라우팅은 [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `STY-0050` | 성직자와 봉인 관리인 정리 | `split`; 역할·지식은 Story, 발견물 반응 라우팅은 [`../design/narrative_delivery.md`](../design/narrative_delivery.md) |
| `STY-0051`, `TBL-012` | 역할별 성격과 태도 | `split`; 태도 연결은 Story, 어휘·예시는 Speaker Lexicon |
| `STY-0099`, `TBL-026` | 마왕에 대한 지식 차이와 상인의 거래 태도 | `split`; 지식·태도는 Story, 진실·진행·표현은 관련 책임 문서 |
| `STY-0100`, `TBL-027` | 화자별 성격과 표현 | `split`; 태도 연결은 Story, 어휘·예시는 Speaker Lexicon |

`STY-0052` 추가 검토 메모는 이 문서에 확정 내용으로 넣지 않고 `DOC-0402`에서 [`../project/open_questions.md`](../project/open_questions.md)의 원본 대응표로 이관했다.

## 이관 상태

`DOC-0205`에서 원본 7장의 NPC·세력 책임과 13장의 관련 지식·태도를 이관했다. `DOC-0301`은 정보 노출 조건을 [`../design/narrative_delivery.md`](../design/narrative_delivery.md)로, `DOC-0303`은 감정 상태와 제약 원칙을 [`../design/item_rules.md`](../design/item_rules.md)로, `DOC-0304`는 감정 비용을 [`../design/economy_rules.md`](../design/economy_rules.md)로 분리했다. 문서는 전체 전환 승인 전까지 `draft`다.
