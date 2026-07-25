---
id: PROJECT-GDD-MAPPING
title: GDD 연결표
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - gdd_story_design_mapping
  - implementation_impact_mapping
last_reviewed:
owner: project-maintainer
related:
  - ../GDD.md
  - story_v1.5_inventory.md
  - ../story/README.md
  - ../design/README.md
  - ../reference/README.md
---

# GDD 연결표

## 목적

세계관 설정, 공식 용어, 게임 규칙, 구현 영향이 어느 기준 문서에서 연결되는지 추적한다.

## 포함 범위

- 설정별 Story 기준과 Reference 항목
- 연결되는 Design 및 GDD 영역
- 구현 시 반드시 지켜야 할 영향

## 제외 범위

- Story나 Design 본문의 상세 정의 복제
- 코드 구현 현황
- 아직 승인되지 않은 신규 시스템

## 연결 원칙

- 통합 GDD는 제품과 시스템의 연결을 설명하는 상위 개요로 유지한다.
- Story는 세계에서 사실인 내용과 개연성, Design은 작동 규칙과 상태, Reference는 공식 명칭과 화자 표현을 소유한다.
- 이 표의 GDD 절 번호는 현재 `v2.1`의 위치다. GDD 제목을 원본 추천 목차에 맞춰 다시 번호 매기지 않는다.
- 구현 영향은 연결 문서를 함께 검토해야 하는 범위만 표시하며 새 수치, 상태, 식별자, 기능을 확정하지 않는다.
- 미결정 사항은 [`open_questions.md`](open_questions.md), 확정된 결정은 [`decisions.md`](decisions.md)가 계속 소유한다.

## 14. GDD 반영용 추천 목차

원본 `STY-0102` 14장의 추천 문장과 `FNC-001` 코드 펜스를 보존한다.

나중에 GDD의 스토리 파트를 개편한다면 아래 순서가 자연스럽다.

```text
3. 세계관 및 스토리라인

3-1. 핵심 콘셉트: 모험가 시대의 변두리 수색꾼
3-2. 마왕 봉인과 던전 자연 발생의 분리
3-3. 던전과 코어의 원리
3-4. 범람, 코어 파괴, 폐던전의 위험도
3-5. 폐던전과 내부 잔여 구역의 현재 상태
3-6. 플레이어 캐릭터: 모험가를 동경한 수색꾼
3-7. 던전 경제와 수색꾼 길드
3-8. 주요 세력 및 거점 NPC
3-9. 잔류물 분류와 수집 구조
3-10. 메인 스토리 진행 축: 생계와 세계관 발견
3-11. 서브 스토리와 발견물 구조
3-12. 반복 탐험의 서사 규칙
3-13. 톤, 용어, 화자별 표현
```

이 구조를 기준으로 잡으면, 이후 수정할 때 “마왕 설정”, “던전 자연 발생”, “플레이어 동기”, “폐던전 반복 탐험”, “아이템 재등장 규칙”, “사회 경제 구조”를 따로 검토할 수 있다.

## 연결 목록

| 원본 추천 절 | Story 기준 | Reference 기준 | Design 기준 | 통합 GDD 연결 | 구현 영향 |
|---|---|---|---|---|---|
| 3-1. 핵심 콘셉트: 모험가 시대의 변두리 수색꾼 | [`핵심 전제`](../story/00_core_pillars.md) | [`수색꾼`](../reference/glossary.md) | — | [`GDD`](../GDD.md) 1-1, 1-3, 2-1, 2-5 | 초반 목표, 탐험·귀환 판단, 성장 보상의 우선순위 |
| 3-2. 마왕 봉인과 던전 자연 발생의 분리 | [`세계의 과거사`](../story/01_world_history.md) | [`던전`](../reference/glossary.md), [`화자별 표현`](../reference/speaker_lexicon.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 3-1, 11-6 | 발견물과 NPC 대화에서 객관적 사실, 가설, 믿음을 구분하는 정보 노출 |
| 3-3. 던전과 코어의 원리 | [`던전 정설`](../story/02_dungeon_canon.md) | [`던전·코어·코어 방`](../reference/glossary.md) | [`반복 탐험 규칙`](../design/repeat_exploration.md) | [`GDD`](../GDD.md) 3-2, 3-3, 5-4 | 던전 상태, 코어 파괴, 잔존 에너지에 따른 방문 상태와 보상 노출 |
| 3-4. 범람, 코어 파괴, 폐던전의 위험도 | [`던전 정설`](../story/02_dungeon_canon.md) | [`범람·폐던전·잔존 에너지`](../reference/glossary.md) | [`반복 탐험 규칙`](../design/repeat_exploration.md) | [`GDD`](../GDD.md) 3-3, 3-4, 5-4, 9-1 | 활성 던전과 폐던전의 위험 원인 구분, 구역 위험과 보상 노출 |
| 3-5. 폐던전과 내부 잔여 구역의 현재 상태 | [`던전 정설`](../story/02_dungeon_canon.md) | [`폐던전·잔여 구역`](../reference/glossary.md) | [`반복 탐험 규칙`](../design/repeat_exploration.md), [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 3-3, 3-5, 5-3, 5-5 | 고정 지도와 제한적 변화, 방문·발견 상태, 잔여 구역 단서 |
| 3-6. 플레이어 캐릭터: 모험가를 동경한 수색꾼 | [`플레이어와 사회`](../story/03_player_and_society.md) | [`수색꾼`](../reference/glossary.md), [`수색꾼 표현`](../reference/speaker_lexicon.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 3-6, 11-1 | 시작 상태, 튜토리얼 정보, 생계형 목표와 장기 진행의 표현 |
| 3-7. 던전 경제와 수색꾼 길드 | [`플레이어와 사회`](../story/03_player_and_society.md) | [`수색꾼`](../reference/glossary.md), [`길드·행정 표현`](../reference/speaker_lexicon.md) | [`경제 규칙`](../design/economy_rules.md) | [`GDD`](../GDD.md) 3-7, 10-2~10-5 | 출입 자격, 회수품 거래, 정산·비용·손실, 거점 성장 |
| 3-8. 주요 세력 및 거점 NPC | [`인물과 세력`](../story/04_characters_and_factions.md) | [`개체 색인`](../reference/entity_index.md), [`화자별 표현`](../reference/speaker_lexicon.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 3-7, 10-2, 11-4, 11-6 | NPC 서비스, 발견물 반응 라우팅, 연구자의 지식 변화 |
| 3-9. 잔류물 분류와 수집 구조 | [`아이템과 발견물`](../story/05_items_and_discoveries.md) | [`폐품·잔재·고유 유물·핵심 기록물`](../reference/glossary.md) | [`아이템 규칙`](../design/item_rules.md), [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 8-1~8-4, 11-3~11-4 | 분류·감정·등록, 반복·1회성 스폰, 판매·폐기 보호 |
| 3-10. 메인 스토리 진행 축: 생계와 세계관 발견 | [`내러티브 진행`](../story/06_narrative_progression.md) | [`사건 순서`](../reference/timeline.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 11-1, 11-2 | 진행 단계, 정보 공개 순서, 등록과 해설의 연결 |
| 3-11. 서브 스토리와 발견물 구조 | [`아이템과 발견물`](../story/05_items_and_discoveries.md), [`내러티브 진행`](../story/06_narrative_progression.md) | [`잔재·고유 유물·핵심 기록물`](../reference/glossary.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md), [`반복 탐험 규칙`](../design/repeat_exploration.md), [`아이템 규칙`](../design/item_rules.md) | [`GDD`](../GDD.md) 5-5, 8-4, 11-3~11-6 | 발견물 후보, 등록·재열람, 연속 단서, 판매 불가 처리 |
| 3-12. 반복 탐험의 서사 규칙 | [`던전 정설`](../story/02_dungeon_canon.md), [`아이템과 발견물`](../story/05_items_and_discoveries.md) | [`폐던전·잔여 구역·잔존 에너지`](../reference/glossary.md) | [`반복 탐험 규칙`](../design/repeat_exploration.md), [`아이템 규칙`](../design/item_rules.md) | [`GDD`](../GDD.md) 5-3~5-5, 8-3~8-4 | 영구 던전 상태와 현재 방문 상태, 반복 보상과 1회성 회수 상태 |
| 3-13. 톤, 용어, 화자별 표현 | [`톤과 문체 가이드`](../story/07_tone_and_writing_guide.md), [`인물과 세력`](../story/04_characters_and_factions.md) | [`공식 용어집`](../reference/glossary.md), [`화자별 표현`](../reference/speaker_lexicon.md) | [`내러티브 전달 규칙`](../design/narrative_delivery.md) | [`GDD`](../GDD.md) 3-8, 부록 A, 부록 B | UI 표시 명칭, 대사 어휘, 발견물 설명과 공간별 톤 검수 |

## 이관 상태

`DOC-0403`에서 원본 `STY-0102`와 `FNC-001`의 추천 구조를 보존하고, 13개 추천 절을 현재 Story·Design·Reference 기준과 통합 GDD 절에 연결했다. 현행 GDD의 번호나 내용을 바꾸지 않았으며 새 설정, 수치, 상태, 식별자, 미결정 사항의 해답을 추가하지 않았다. 이 문서는 전체 전환 승인 전까지 `draft`다.
