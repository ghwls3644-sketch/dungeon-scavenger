---
id: PROJECT-M4-STORY-DESIGN-REVIEW
title: Story·Design 중복 검수 보고서
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1+management-proposal-v0.2.1
canonical_for:
  - story_design_duplicate_audit
  - responsibility_overlap_tracking
last_reviewed:
owner: documentation-maintainer
related:
  - ../GDD.md
  - ../story/README.md
  - ../design/README.md
  - m4_term_review.md
  - migration_manifest.md
  - gdd_mapping.md
---

# Story·Design 중복 검수 보고서

## 목적

`DOC-0502`에서 Story와 Design의 상세 정의 중복, Story 내부의 상세 정의 중복, 책임 혼합과 확정도 차이를 찾고 `DOC-0503`의 단일 출처 전환 입력으로 남긴다.

이 보고서는 문제를 탐지하고 분류한다. 기준 문서를 새로 확정하거나 기존 본문을 삭제·축약하지 않으며, 설정·규칙·수치·상태·식별자를 추가하지 않는다.

## 검토 기준

- 검토일: 2026-07-25
- 검토 티켓: `DOC-0502`
- 원본 기준: `스토리 정리 v1.5`
- 제품 기준: [`GDD`](../GDD.md)
- 운영 기준: 최신 분할 제안서 3-1~3-5, M4~M5, 11-2
- 활성 기준: Story 문서 8개와 Design 문서 5개의 책임 선언, 상세 본문, 상호 링크

### 판정 규칙

- `상세 중복`: 같은 목록, 표, 상태 전환 또는 처리 규칙이 둘 이상의 문서에 상세하게 남아 있다.
- `책임 혼합`: Story가 구현 동작·상태·처리를 상세화하거나 Design이 세계관 사실·정보 내용·인물 지식을 상세화한다.
- `확정도 불일치`: 같은 내용이 한 문서에서는 현재 사실이나 규칙이고 다른 문서에서는 제안·미확정으로 쓰인다.
- `요약·링크 적정`: 다른 영역을 이해하는 데 필요한 짧은 요약만 두고 상세 기준 문서를 연결한다.

문구가 다르더라도 같은 항목 집합이나 같은 상태 관계를 다시 설명하면 상세 중복으로 본다. 반대로 Story의 원인과 Design의 동작이 같은 주제를 다루더라도 책임이 분리되어 있으면 중복으로 세지 않는다.

## 검토 범위

| 영역 | 검토 문서 | 문서 수 |
|---|---|---:|
| Story | `00_core_pillars.md`~`07_tone_and_writing_guide.md` | 8 |
| Design | `narrative_delivery.md`, `repeat_exploration.md`, `item_rules.md`, `economy_rules.md`, `harness_engineering.md` | 5 |
| 합계 | 활성 Story·Design 문서 | 13 |

## 집계

| 판정 | 건수 | 비고 |
|---|---:|---|
| Story·Design 교차 중복·책임 혼합 후보 | 9 | 같은 목록·표·흐름 또는 구현 세부가 양쪽에 남아 있음 |
| Story 내부 상세 중복 후보 | 1 | 연구자의 지식 단계가 두 Story 문서에 상세 표로 존재함 |
| 확정도 불일치 | 1 | 교차 중복 9건 가운데 경제 규칙 1건에 포함됨 |
| 서로 다른 수치·상태 전환을 요구하는 직접 충돌 | 0 | 현재 중복 값과 처리 방향은 대체로 일치함 |
| 이번 티켓에서 수정한 Story·Design 본문 | 0 | 탐지와 분류만 수행함 |

## Story·Design 교차 중복 후보

| 주제 | Story 위치 | Design 위치 | 판정 | `DOC-0503` 인계 |
|---|---|---|---|---|
| 반복 요소와 1회성 요소 | [`던전 정설`](../story/02_dungeon_canon.md#반복-탐험이-가능한-세계관상-이유) | [`반복 탐험 규칙`](../design/repeat_exploration.md#반복-요소와-1회성-요소) | Story의 반복 7개·1회성 5개 목록이 Design 표에 같은 항목으로 다시 정의되어 있다. 실제 후보 제외와 저장은 Design 책임이므로 `상세 중복`이다. | Story에는 반복이 가능한 세계관상 이유와 원본성만 남기고, 전체 후보·상태 목록의 상세 기준 위치를 정한다. |
| 고정 지도, 가변 요소와 잔여 구역 | [`던전 정설`](../story/02_dungeon_canon.md#랜덤성의-정설-경계), [`아이템과 발견물`](../story/05_items_and_discoveries.md#지도-발견물과-잔여-구역) | [`반복 탐험 규칙`](../design/repeat_exploration.md#고정-요소와-가변-요소), [`잔여 구역`](../design/repeat_exploration.md#잔여-구역) | 고정된 큰 지도, 문·통로 변화, 구역 후보, 지도 기록·소실과 흔적 예시가 Story와 Design에 함께 남아 있다. Story 일부 문장은 실제 배치와 상태 변화를 지시해 `책임 혼합`이다. | Story에는 불안정한 소멸과 잔여 구역의 의미를, Design에는 방문별 후보·개방·지도 상태를 상세 기준으로 두는 방향을 검토한다. |
| 원본 회수 후 구역 변화와 잔존 에너지 노출 | [`던전 정설`](../story/02_dungeon_canon.md#고유-유물-회수-후의-소멸-방향), [`잔존 에너지 유실`](../story/02_dungeon_canon.md#잔존-에너지-유실과-물품-노출) | [`반복 탐험 규칙`](../design/repeat_exploration.md#고유-유물핵심-기록물-회수-후-전환), [`보상 노출`](../design/repeat_exploration.md#잔존-에너지와-보상-노출) | 방 소실·봉쇄·상호작용 감소, 반복 보상 유지와 숨은 대상 노출이 양쪽에 상세하게 적혀 있다. Story의 원인 설명은 필요하지만 적용 예시와 방문 전환은 `상세 중복`이다. | 인과 설명과 상태 전환을 분리하고, Story의 구현 예시를 어느 수준까지 요약으로 남길지 정한다. |
| 아이템 분류, 기본 처리와 반복 가능성 | [`아이템과 발견물`](../story/05_items_and_discoveries.md#아이템-분류의-서사-의미), [`반복 발견`](../story/05_items_and_discoveries.md#반복-발견의-개연성) | [`아이템 규칙`](../design/item_rules.md#분류와-기본-처리), [`스폰과 반복`](../design/item_rules.md#스폰과-반복-가능-여부) | 다섯 분류의 의미·반복성·판매·연구·등록 처리가 두 표와 문단에 반복된다. Story가 처리 방식까지, Design이 세계관 의미까지 포함해 `상세 중복`과 `책임 혼합`이 함께 있다. | Story의 원본성·서사 기능과 Design의 데이터 분류·처리·스폰 규칙을 열 단위로 분리한다. |
| 감정 방식과 제약 | [`NPC와 세력`](../story/04_characters_and_factions.md#감정사와-감정-방식), [`아이템과 발견물`](../story/05_items_and_discoveries.md#감정과-연구자-보관의-의미) | [`아이템 규칙`](../design/item_rules.md#감정-상태), [`경제 규칙`](../design/economy_rules.md#비용-항목) | 거점 감정과 휴대용 감정, 일괄 처리, 비용·시간·횟수·정확도 제약이 Story와 Design에 반복된다. 감정의 서사 의미와 감정사의 태도 외 제약은 `책임 혼합`이다. | Story에는 역할과 서사 의미를, Design에는 상태·제약·비용 책임 연결을 상세 기준으로 두는 방향을 검토한다. |
| 기준가, 거래처와 비용 | [`플레이어와 사회`](../story/03_player_and_society.md#회수품의-가격-구조), [`수수료와 난이도`](../story/03_player_and_society.md#수수료와-난이도) | [`경제 규칙`](../design/economy_rules.md#기준가와-거래처), [`비용 항목`](../design/economy_rules.md#비용-항목) | 길드·상인·공방·연구자·암시장 역할과 기준가·회수세·감정 비용이 양쪽에 상세하다. Story는 길드가 감정 등급과 위험 수당을 정한다고 단정하지만 Design은 GDD에서 계산 항목으로 미확정이라고 적어 `확정도 불일치`도 있다. | 사회적 수요와 위험 외주화만 Story에 남기고 가격·거래 보정은 Design으로 모을지 검토한다. 감정 등급·위험 수당의 확정 상태를 먼저 맞춘다. |
| 발견·등록·해설·재열람 흐름 | [`아이템과 발견물`](../story/05_items_and_discoveries.md#감정과-연구자-보관의-의미), [`내러티브 진행`](../story/06_narrative_progression.md#발견물의-정보-전달-순서) | [`정보 전달 규칙`](../design/narrative_delivery.md#기본-정보-전달-흐름), [`최초 발견과 등록`](../design/narrative_delivery.md#최초-발견과-등록) | 발견, 첫 단서, 안전 귀환, 담당처 등록, 해설 해금과 재열람의 단계가 Story 번호 목록과 Design 상태 표에 함께 상세화되어 있다. | Story의 정보 깊이 순서와 Design의 발생 조건·유지 상태를 구분해 하나의 상세 흐름만 남긴다. |
| NPC 반응 라우팅과 튜토리얼 전달 목록 | [`NPC와 세력`](../story/04_characters_and_factions.md#튜토리얼-수색꾼), [`아이템과 발견물`](../story/05_items_and_discoveries.md#필요한-담당자만-반응) | [`정보 전달 규칙`](../design/narrative_delivery.md#npc-반응-라우팅), [`튜토리얼 노출`](../design/narrative_delivery.md#튜토리얼-노출) | 담당자별 발견물 표와 튜토리얼 정보 6개가 양쪽에 반복된다. Story는 인물의 역할과 지식을 소유하지만 실제 라우팅·노출 목록까지 상세해 `책임 혼합`이다. | NPC가 아는 사실과 태도, 전달해야 할 정보, 실제 반응 조건을 각각 어느 문서가 상세 소유할지 확정한다. |
| 필수·선택 정보와 연속 단서 | [`내러티브 진행`](../story/06_narrative_progression.md#필수-정보와-선택-정보), [`연속 발견물`](../story/06_narrative_progression.md#연속-발견물) | [`정보 전달 규칙`](../design/narrative_delivery.md#필수-정보와-선택-정보), [`연속 발견물과 지도 단서`](../design/narrative_delivery.md#연속-발견물과-지도-단서) | 정보 층 5개와 표식·필체·장비·지도 메모의 연속 단서가 Story와 Design에 같은 구조로 반복된다. 정보의 내용·우선순위는 Story 책임인데 Design에도 상세 내용이 남아 있다. | Story에는 정보 층과 의미를, Design에는 해금 조건·발생 순서·지도 상태만 상세화하는 방향을 검토한다. |

## Story 내부 상세 중복 후보

| 주제 | 위치 | 확인 결과 | `DOC-0503` 인계 |
|---|---|---|---|
| 연구자의 초반·중반·후반 지식 변화 | [`NPC와 세력`](../story/04_characters_and_factions.md#연구자), [`내러티브 진행`](../story/06_narrative_progression.md#연구자의-지식-변화) | 판단 유보, 지맥·마나 이상 정황, 마왕과 던전의 직접 인과 부족이라는 세 단계가 두 표에 상세 정의되어 있다. 내용 충돌은 없지만 한쪽 수정 시 다른 쪽이 어긋날 수 있다. | NPC가 아는 실제 내용과 플레이어에게 열리는 진행 순서를 분리하되, 지식 내용의 상세 표는 한곳에만 남긴다. |

## 요약과 링크가 적정한 경계

| 위치 | 판정 |
|---|---|
| [`핵심 전제`](../story/00_core_pillars.md) | 생계·생환·비영웅 방향과 금지선만 소유하며 구현 상태·수치를 상세화하지 않는다. |
| [`세계 역사`](../story/01_world_history.md) | 객관적 역사·가설·사회적 믿음의 구분을 소유하고 실제 노출 규칙은 Design으로 연결한다. |
| [`톤과 문체`](../story/07_tone_and_writing_guide.md) | 감정과 문장 작성법을 소유하며 수치·보상 지급·노출 방식은 Design 링크로 분리한다. |
| [`보호 대상의 서사 의미`](../story/05_items_and_discoveries.md#보호-대상의-서사-의미) | 판매 불가의 서사 이유만 설명하고 판매·폐기 차단은 [`item_rules.md`](../design/item_rules.md#판매폐기-보호)로 연결한다. |
| [`하네스 엔지니어링`](../design/harness_engineering.md) | 현재는 범위와 링크만 있는 골격이어서 Story와 경쟁하는 상세 정의가 없다. |

## 정합성 확인

- 교차 중복 후보의 반복·1회성 분류, 아이템 처리, 등록 흐름과 보호 방향은 서로 다른 결과를 요구하지 않는다.
- 수치가 양쪽에서 다르게 확정된 사례는 없다.
- 활성 Story·Design 문서는 모두 `draft`이므로 문서 상태 필드 자체의 충돌은 없다.
- 기준가·거래처 주제에서는 `감정 등급·위험 수당`의 확정도가 다르므로 단일 출처 전환 전에 확인이 필요하다.
- 대부분의 중복 위치에 상대 문서 링크와 책임 선언이 이미 있다. `DOC-0503`은 새 구조를 만들기보다 상세 문장을 요약과 링크로 전환하는 작업이 중심이다.

## 후속 작업

1. `DOC-0503`에서 교차 중복 9건과 Story 내부 중복 1건의 상세 기준 문서를 지정한다.
2. 기준이 아닌 위치는 필요한 한두 문장의 요약과 상세 문서 링크로 전환한다.
3. 기준가·거래처 전환 전에 감정 등급과 위험 수당의 확정 상태를 GDD 기준으로 맞춘다.
4. `DOC-0501`의 용어 누락·경계 후보는 상세 정의를 복제하지 않는 범위에서 함께 연결한다.
5. 본문 전환 후 같은 목록·표·상태 관계가 둘 이상에 남지 않았는지 다시 검색한다.

## 검토 결과

- 판정: `보완 필요`
- 검토 문서: Story 8개, Design 5개
- Story·Design 교차 중복·책임 혼합 후보: 9건
- Story 내부 상세 중복 후보: 1건
- 확정도 불일치: 1건
- 직접 수치·상태 전환 충돌: 0건
- 즉시 수정한 Story·Design 본문: 없음
- 다음 티켓: `DOC-0503 — 기준 문서 지정 및 상호 링크 전환`

이 보고서는 후속 보완이 끝날 때까지 `draft`다.
