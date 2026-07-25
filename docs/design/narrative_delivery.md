---
id: DESIGN-NARRATIVE-DELIVERY
title: 내러티브 전달 규칙
document_type: design
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - narrative_delivery_rules
  - discovery_registration_flow
last_reviewed:
owner: game-design
related:
  - ../GDD.md
  - ../story/04_characters_and_factions.md
  - ../story/05_items_and_discoveries.md
  - ../story/06_narrative_progression.md
  - ../story/07_tone_and_writing_guide.md
  - item_rules.md
  - repeat_exploration.md
  - ../reference/glossary.md
  - ../reference/speaker_lexicon.md
  - ../project/open_questions.md
---

# 내러티브 전달 규칙

## 목적

세계관 정보와 발견물이 게임 안에서 노출·등록·재열람되는 시스템 규칙을 관리한다.

## 포함 범위

- 발견물 획득과 최초 발견 흐름
- 연구자 등록, 도감 해금, 텍스트 다시 보기
- NPC 반응 조건과 튜토리얼 노출
- 필수 정보와 선택 정보의 전달 방식

## 제외 범위

- 세계관 사실과 NPC의 지식 내용
- 화자별 어휘와 문체
- 아이템의 판매·저장·스폰 데이터 규칙
- 반복 방문 사이의 지도·구역 상태 변화
- 정확한 수집 개수, 해금 수치와 최종 UI 배치

## 책임 경계

| 책임 | 기준 문서 |
|---|---|
| 발견물이 무엇이며 어떤 서사 단서를 담는가 | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md) |
| 플레이어가 정보를 어떤 순서와 깊이로 이해하는가 | [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md) |
| NPC가 무엇을 알고 어떤 태도를 보이는가 | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) |
| 최초 발견, 등록, 해설 해금, 재열람과 반응 조건 | 이 문서 |
| 스폰, 감정 상태, 판매·폐기 보호와 영구 획득 플래그 | [`item_rules.md`](item_rules.md) |
| 방문별 배치와 지도·구역 상태 변화 | [`repeat_exploration.md`](repeat_exploration.md) |
| 공식 표기와 화자별 문장 | [`../reference/glossary.md`](../reference/glossary.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) |
| 발견물 설명의 길이와 문체 | [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) |

## 기본 정보 전달 흐름

발견물은 다음 순서로 정보를 연다.

| 단계 | 발생 조건 | 플레이어에게 제공하는 결과 | 유지 범위 |
|---|---|---|---|
| 탐험 중 발견 | 발견물과 처음 상호작용함 | 짧은 이름·설명 또는 관찰 가능한 첫 단서 | 안전 귀환 전에는 현재 탐험의 임시 획득 |
| 안전 귀환 | 발견물을 가지고 탐험을 마침 | 등록 가능한 회수 결과로 전환 | 고유 유물·핵심 기록물의 영구 획득은 등록까지 완료해야 함 |
| 담당처 등록 | 연구자나 관련 NPC에게 전달하거나 반응이 필요 없는 목록 항목을 등록함 | 수집 목록·도감 항목과 짧은 해설 또는 추가 문장을 엶 | 최초 등록 결과를 영구 진행으로 저장 |
| 해석 확장 | 관련 발견물의 등록 조건을 충족함 | 연구자 해설과 연결 정보의 다음 깊이를 엶 | 해금된 정보 유지 |
| 재열람 | 이미 등록한 항목을 선택함 | 해금된 중요 설명을 다시 확인함 | 진행 상태를 추가로 바꾸지 않음 |

안전 귀환 전에 탐험에 실패하면 해당 탐험에서 주운 고유 유물과 핵심 기록물은 영구 등록하지 않는다. 이후 후보에 남기는 처리와 중복 방지는 [`item_rules.md`](item_rules.md), 방문별 재배치는 [`repeat_exploration.md`](repeat_exploration.md)가 담당한다.

첫 발견에서 긴 세계관 설명을 강제로 보여주지 않는다. 발견 시에는 짧은 단서를 제공하고, 더 깊은 설명은 등록 후 플레이어가 선택해서 확인하게 한다.

## 구역별 발견물 후보 연결

이 문서는 발견물 콘텐츠가 어떤 구역 맥락에 속할 수 있는지를 관리한다. 실제 등장 아이템과 위치를 고르는 랜덤·시드 규칙은 이 문서가 소유하지 않는다.

| 구역 맥락 | 연결 가능한 발견물 | 정보 전달 목적 |
|---|---|---|
| 기록실 | 던전 발생 기록, 코어 연구 기록, 핵심 기록물 | 던전과 코어에 관한 연구 정보 |
| 폐숙소 | 생활 흔적, 개인 기록, 실패한 수색꾼의 장비와 메모 | 탐험자의 생활과 실패 흔적 |
| 경비실 | 장치 부품, 방어 체계 기록, 열쇠 정보 | 폐던전의 장치와 과거 공략 흔적 |
| 예배실·의례 흔적 | 성직자의 경고문, 부적, 봉인과 민간 전승 | 마왕과 던전을 연결하는 사회적 오해 |
| 잔여 구역 | 고유 유물, 핵심 기록물, 지도 가장자리 표식과 좌표 조각 | 선택적 수집과 공식 지도 밖 단서 |

후보 풀은 구역의 의미를 보존한다. 기록물이 아무 구역에서나 완전 무작위로 나오게 하지 않으며, 같은 구역 안에서 무엇이 실제로 등장할지는 [`item_rules.md`](item_rules.md)와 [`repeat_exploration.md`](repeat_exploration.md)가 결정한다.

## 최초 발견과 등록

- 최초 발견 설명은 짧은 텍스트를 우선한다.
- 미확인 물품은 감정 전에는 외형과 무게처럼 확인 가능한 정보만 제공하고, 감정 후 실제 분류와 숨은 정보를 연다.
- 핵심 기록물은 연구자에게 가져가면 보관 목록에 등록하고 짧은 해설을 연다.
- 고유 유물은 관련 연구자나 NPC가 있는 경우 그 담당자에게만 설명이나 작은 반응을 연결한다.
- 일반 수집품은 특별한 NPC 반응 없이 목록에 등록할 수 있다.
- 등록된 중요 정보는 목록이나 도감에서 다시 확인할 수 있어야 한다.

정확한 화면 구성, 버튼, 알림 문구와 텍스트 길이는 이 티켓에서 확정하지 않는다.

## NPC 반응 라우팅

같은 물건을 모든 NPC에게 보여주는 반응망은 만들지 않는다. 발견물의 분류와 정보 성격에 따라 필요한 담당자만 반응한다.

| 발견물 또는 상태 | 우선 담당자 | 허용 반응 | 제한 |
|---|---|---|---|
| 폐품 | 상인 또는 길드 | 매입·정산과 실용적 안내 | 별도 세계관 해설을 강제하지 않음 |
| 미확인 물품 | 감정사 | 실제 분류와 감정 결과 확인 | 연구자 지식 단계까지 대신 설명하지 않음 |
| 핵심 기록물 | 연구자 | 보관, 목록 등록, 짧은 해설과 후속 해석 | 다른 NPC 모두에게 같은 해설을 복제하지 않음 |
| 고유 유물 | 관련 연구자 또는 관련 NPC | 수집 등록, 제한된 설명·보상·배경 정보 | 거대한 세력 반응이나 필수 사건으로 확장하지 않음 |
| 마왕·봉인 관련 발견물 | 기본 담당자, 필요하면 성직자 | 성직자의 짧은 신앙적·오해 섞인 반응 | 성직자의 해석을 객관적 진실로 확정하지 않음 |
| 일반 수집품 | 별도 반응 없음 | 목록 등록 | 불필요한 NPC 대화 분기 없음 |

등록과 최초 정보 해금은 한 번만 진행하고 이후에는 재열람으로 접근한다. 반복 방문 사이의 최초 반응 저장 여부는 [`repeat_exploration.md`](repeat_exploration.md), 실제 아이템 등록 플래그는 [`item_rules.md`](item_rules.md)가 구현 책임을 가진다.

## 연구자 해석 단계

연구자의 초반·중반·후반 지식 내용은 [`../story/04_characters_and_factions.md#연구자`](../story/04_characters_and_factions.md#연구자)와 [`../story/06_narrative_progression.md#연구자의-지식-변화`](../story/06_narrative_progression.md#연구자의-지식-변화)를 따른다.

- 연구자의 해석 변화는 플레이어가 관련 기록물과 잔재를 등록한 결과로 진행한다.
- 등록되지 않은 발견이나 단순한 시간 경과만으로 다음 해석 단계가 열렸다고 처리하지 않는다.
- 단계가 바뀌면 해당 단계의 짧은 해설과 연결된 도감 문장을 열 수 있다.
- 단계별 실제 대사와 어휘는 [`../reference/speaker_lexicon.md#감정사--연구자`](../reference/speaker_lexicon.md#감정사--연구자)가 소유한다.

원본은 각 단계에 필요한 기록물 수, 항목 조합과 정확한 전환 조건을 정하지 않았다. 이번 티켓에서도 임의의 수치를 만들지 않으며 후속 콘텐츠 설계 전까지 미확정으로 둔다.

## 튜토리얼 노출

기본 생존과 직업 정보를 선택적 랜덤 발견물에만 의존시키지 않는다. 튜토리얼 수색꾼이 알고 전달할 수 있는 내용은 [`../story/04_characters_and_factions.md#튜토리얼-수색꾼`](../story/04_characters_and_factions.md#튜토리얼-수색꾼)을 따르며, Design은 해당 정보를 초기 탐험 경험이나 짧은 조언으로 놓치지 않게 노출하는 책임을 가진다.

튜토리얼 수색꾼이 선배인지 동료인지는 Story에서도 미정이며 이 문서에서 정하지 않는다. 정확한 대화 순서, 강제 여부, 발생 횟수와 UI 형태도 아직 확정하지 않는다.

## 필수 정보와 선택 정보

정보 층의 내용과 서사적 우선순위는 [`../story/06_narrative_progression.md#필수-정보와-선택-정보`](../story/06_narrative_progression.md#필수-정보와-선택-정보)가 상세 기준을 소유한다.

Design은 기본 탐험과 생계에 필요한 정보는 초기 플레이와 기능형 NPC를 통해 보장하고, 선택 정보는 발견물 등록과 해설을 놓쳐도 핵심 진행을 막지 않게 한다.

## 연속 발견물과 지도 단서

연속 단서의 소재와 플레이어가 이해하는 순서는 [`../story/06_narrative_progression.md#연속-발견물`](../story/06_narrative_progression.md#연속-발견물), 지도 발견물의 의미는 [`../story/05_items_and_discoveries.md#지도-발견물과-잔여-구역`](../story/05_items_and_discoveries.md#지도-발견물과-잔여-구역)이 상세 기준을 소유한다.

Design은 각 단서가 단독으로도 정보를 전달하면서 여러 탐험에 걸쳐 연결될 수 있게 하고, 정답이나 완성 지도를 즉시 공개하지 않는 전달 조건만 소유한다.

단서가 잔여 구역을 직접 여는 열쇠인지 단순한 힌트인지는 원본에서 하나로 확정하지 않았다. 실제 등장 순서, 지도 표시와 구역 개방 상태는 [`repeat_exploration.md`](repeat_exploration.md)에서 이어서 정한다.

## 판매 불가 발견물 안내

고유 유물, 핵심 기록물과 특정 의뢰품은 일반 판매품과 다르게 취급한다.

- 가격 대신 등록·정보 보상 대상임을 표시한다.
- 판매와 빠른 폐기는 [`item_rules.md`](item_rules.md)에서 차단한다.
- 연구자 보관 또는 관련 등록처를 통해 진행을 계속할 수 있음을 안내한다.
- 정확한 아이콘, 색상, 경고 문구와 조작 방식은 [`item_rules.md`](item_rules.md)와 관련 UI 설계에서 정한다.

## 관련 문서

- [`../GDD.md`](../GDD.md)
- [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md)
- [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)
- [`item_rules.md`](item_rules.md)
- [`repeat_exploration.md`](repeat_exploration.md)
- [`../reference/glossary.md`](../reference/glossary.md)
- [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md)

## 원본 추적

| 원본 ID | 이관한 Design 책임 | 상태 |
|---|---|---|
| `STY-0046`, `TBL-010` | 등록 결과에 따른 연구자 해석 단계 연결 | `split` |
| `STY-0047` | 튜토리얼 정보 범위와 노출 경계 | `split` |
| `STY-0049` | 고유 유물의 제한된 담당 NPC 반응 | `split` |
| `STY-0050` | 마왕·봉인 발견물에 대한 성직자의 선택 반응 | `split` |
| `STY-0056` | 핵심 기록물의 연구자 등록, 목록과 재열람 흐름 | `split` |
| `STY-0067`, `STY-0068`, `TBL-016` | 발견물 중심 전달과 유형별 후보 연결 | `split` |
| `STY-0069`, `TBL-017` | 구역 후보 풀과 실제 획득 책임 경계 | `split` |
| `STY-0070` | 최초 발견부터 등록·해설·재열람까지의 흐름 | `split` |
| `STY-0071` | 필요한 담당 NPC만 반응하는 라우팅 | `split` |
| `STY-0072`, `TBL-018` | 지도 단서의 정보 전달과 구역 상태 책임 경계 | `split` |
| `STY-0073` | 여러 탐험에 걸친 연속 단서 전달 | `split` |
| `STY-0074`, `TBL-019` | 판매 불가 발견물의 정보 진행 보호와 안내 | `split` |

GDD의 `8-3. 획득 규칙`, `8-4. 보호 규칙`, `11-4. 전달 방식`과 거점 NPC 역할표를 함께 대조했다. 원본에 없는 수집 개수, 해금 수치, UI 구조와 내부 식별자는 추가하지 않았다.

## 이관 상태

`DOC-0301`에서 원본 7장·8-3·10장의 정보 전달 책임과 GDD의 안전 귀환·등록 흐름을 추출했다. 문서는 전체 전환 승인 전까지 `draft`다.
