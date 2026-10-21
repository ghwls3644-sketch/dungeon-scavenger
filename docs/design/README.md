---
id: DESIGN-INDEX
title: Design 문서 안내
document_type: design
status: confirmed
source_version: management-proposal-v0.2.1
canonical_for:
  - design_document_navigation
last_reviewed: 2026-10-21
owner: game-design
related:
  - portable_appraisal.md
  - recovery_tax.md
  - ../GDD.md
  - ../story/README.md
  - ../reference/README.md
  - ../project/m4_story_design_review.md
  - ../project/m5_core_entity_timeline_review.md
  - ../project/m5_link_omission_review.md
  - ../project/m6_human_review.md
---

# Design 문서 안내

## 목적

플레이어에게 세계관이 어떤 규칙, 상태, 데이터로 작동하는지 찾는 중앙 색인이다. 현상의 이유와 정설은 Story, 표시 명칭과 의미 경계는 Reference에서 관리한다.

## 문서별 책임

| 문서 | 답하는 질문 |
|---|---|
| [`narrative_delivery.md`](narrative_delivery.md) | 세계관 정보가 어떤 시스템과 조건으로 전달되는가? |
| [`repeat_exploration.md`](repeat_exploration.md) | 방문 사이에 무엇이 유지되고 무엇이 변하는가? |
| [반복 상태·시드 계약 검토안](repeat_state_contract.md) (`draft`) | 기존 반복 규칙과 현재 구현을 어떻게 연결하고, 재현·확정·중단·저장 경계를 무엇으로 검사할 것인가? |
| [`item_rules.md`](item_rules.md) | 아이템이 데이터와 시스템에서 어떻게 작동하는가? |
| [`economy_rules.md`](economy_rules.md) | 가격·비용·손실·수익은 어떻게 계산되는가? |
| [`harness_engineering.md`](harness_engineering.md) (`draft`) | 하네스 준비·공유 자원의 기존 요구, 장착 및 구매/발견 성장의 시험 적용과 후속 조건은 무엇인가? |
| [`survival_rules.md`](survival_rules.md) (`draft`) | 건강·부상과 퇴로 상실의 기존 요구는 무엇이며 어떤 시제품 규칙을 검토해야 하는가? |
| [`repair_rules.md`](repair_rules.md) (`draft`) | 장비 내구·선택 수리·재출정 안전망의 기존 요구와 구현 전 제안은 무엇인가? |
| [`tool_preparation.md`](tool_preparation.md) (`draft`) | 소음 유인물의 기본 무료분·추가 구매, 수량·적재·귀환/실패·저장 계약은 어떻게 나눌 것인가? |
| [`expedition_cost_reporting.md`](expedition_cost_reporting.md) (`draft`) | 준비·탐험의 손익과 실제 현금 변화, 재고 취득 원가·투자·견적은 어떻게 구분할 것인가? |
| [`expedition_objectives.md`](expedition_objectives.md) (`draft`) | 자유 수색과 최소 목표/의뢰의 범위, 선택·진척·결과·보상/저장 계약은 무엇인가? |
| [회수세 검토안](recovery_tax.md) (draft) | 판매 과세·의뢰 보상 제외와 합산/절사·손익/현금·구형/저장의 최소 계약은 무엇인가? |
| [휴대용 감정 검토안](portable_appraisal.md) (draft) | 현장 감정의 정보·제한/준비 방식 비교와 사용·원가·귀환/저장 계약은 무엇인가? |

## 경계 규칙

- [휴대용 감정 검토안](portable_appraisal.md)은 DEV-0422 제안과 DEV-0423의 제한된 시험 적용을 구분하는 draft다. DEC-117의 횟수 제한 확정 감정·유료 구매/휴대 선택·안전 귀환 미사용분 보관을 따른다. [DEV-0423 시험 적용](portable_appraisal.md#dev-0423-준비사용정산-시험-적용)에서 가격·수량·무게·조작/저장을 제한 적용했으며 최종 수치와 사람 평가는 Q-030에 남긴다.

- [회수세 검토안](recovery_tax.md)은 DEV-0420 제안 이력과 DEV-0421의 10%·거래별 절사 시험 적용을 함께 관리하는 draft다. DEC-116의 판매 과세·의뢰 보상 전액 지급 방향을 따르며 최종 세율/분할 절사·사람 이해는 Q-029에 남긴다.

- [목표·의뢰 검토안](expedition_objectives.md)은 DEV-0417 제안 이력과 [DEV-0418 시험 적용](expedition_objectives.md#dev-0418-선택-의뢰-시험-적용)을 구분한 `draft`다. DEC-115의 자유 수색+선택 의뢰 하나/추가 보상을 연결했고 폐품 2개·보상 10·선택 초기화·스키마 8은 제한된 시험 조건이다. 최종 수치·반복 경제·사람 체감은 Q-028의 후속이며 단독 구현 권한이나 최종 경제 승인으로 읽지 않는다.

- [출정별 비용 표시 검토안](expedition_cost_reporting.md)은 `draft`다. DEC-114의 소모 원가 손익·현금 변화 별도 표시를 DEV-0415에서 [시험 연결](expedition_cost_reporting.md#dev-0415-비용-표시-시험-적용)했다. 집계·원가·저장/복구 기술 검사와 사람 이해도·최종 밸런스·G4 완료 판단을 구분하고 Q-027에서 추적한다.

- Story의 원인과 개연성을 Design 수치로 덮어쓰지 않는다.
- [`tool_preparation.md`](tool_preparation.md)는 DEV-0412 검토안과 DEV-0413 시험 적용을 구분한다. 기본 2개 무료+선택 추가 구매는 사용자 결정 DEC-113이며, 총 0~4개·추가 단가 5·무게 0.25와 보관/반환·저장 복구를 시험 구현했다. 최종 수치/체감은 Q-026으로 추적하며 `draft`를 단독 구현 권한이나 최종 경제 승인으로 읽지 않는다.
- [`repair_rules.md`](repair_rules.md)는 DEV-0405의 수리 검토안이며 단독 구현 기준이 아니다. 사용자가 선택한 거래 방식은 DEC-111·confirmed Economy Rules, DEV-0406의 손상 및 DEV-0407의 선택 수리/최소 복구 시험 적용과 최종 미정은 Q-022·Q-023으로 구분한다.
- 사용자 표시 명칭은 [`../reference/glossary.md`](../reference/glossary.md)를 따른다.
- 미결정 수치와 규칙은 [`../project/open_questions.md`](../project/open_questions.md)에 연결한다.
- `confirmed` 문서는 구현 기준으로 사용할 수 있다. [`harness_engineering.md`](harness_engineering.md)는 DEV-0408/0410 제안 이력과 DEV-0409 장착·[DEV-0411 구매/발견 시험](harness_engineering.md#dev-0411-구매발견-혼합-시험-적용)을 구분한 `draft`다. 혼합 획득 방식은 사용자 결정 DEC-112, 가격/효과/발견 배치는 시험 조건이다. Q-024·Q-025의 최종 한도/밸런스·사람 평가와 구별하며 단독 구현 기준으로 사용하지 않는다.
- [`survival_rules.md`](survival_rules.md)는 기존 요구·DEV-0318의 제안·DEV-0319~DEV-0322의 제한된 시험 적용을 구분하는 `draft` 문서다. 상태·이동·조사/회수 시간·HUD, 별도 공간의 통로 변화·비상 탈출 시험 값과 최종 미정 규칙을 구별한다. 최종 피해·회복·퇴로 규칙의 확정 문서나 단독 구현 기준이 아니다. 실제 미정 항목은 `Q-019`~`Q-021`, 후속 작업 순서는 개발 인계가 소유한다.

## 현재 상태

Story 이관 후 확인한 Design 티켓 `DOC-0301`~`DOC-0304`와 Project 이관을 완료하고 G-M3를 통과했다. `DOC-0501` 공식 용어 검수 결과는 [`../project/m4_term_review.md`](../project/m4_term_review.md)에, `DOC-0502` 중복 탐지와 `DOC-0503` 단일 출처 전환 결과는 [`../project/m4_story_design_review.md`](../project/m4_story_design_review.md)에 기록했다. `DOC-0504` 화자 표현·NPC 지식 검수 결과는 [`../project/m4_speaker_knowledge_review.md`](../project/m4_speaker_knowledge_review.md)에 기록했다. `DOC-0505` 핵심 설정·Entity·Timeline 검수 결과는 [`../project/m5_core_entity_timeline_review.md`](../project/m5_core_entity_timeline_review.md)에 기록했으며 Design 본문 변경은 없었다. `DOC-0506` 링크·누락 검사 결과는 [`../project/m5_link_omission_review.md`](../project/m5_link_omission_review.md)에 기록했으며 Design 본문 5개는 중앙 진입점에서 모두 접근 가능하다. Design은 상태·조건·처리·계산을 상세 소유하고 Story의 이유·지식·정보 내용을 요약 링크로 참조한다. G-M5 통과와 `DOC-0601` 사람 검토 후 `DOC-0602`에서 이 README와 이관·검증을 마친 Design 본문 4개를 `confirmed`로 전환했다. 추가 골격인 [`harness_engineering.md`](harness_engineering.md)는 `MIG-CHG-005`에 따라 `draft`를 유지한다. 근거는 [`../project/m6_human_review.md`](../project/m6_human_review.md)에 있다.
