---
id: DESIGN-INDEX
title: Design 문서 안내
document_type: design
status: confirmed
source_version: management-proposal-v0.2.1
canonical_for:
  - design_document_navigation
last_reviewed: 2026-10-01
owner: game-design
related:
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
| [`item_rules.md`](item_rules.md) | 아이템이 데이터와 시스템에서 어떻게 작동하는가? |
| [`economy_rules.md`](economy_rules.md) | 가격·비용·손실·수익은 어떻게 계산되는가? |
| [`harness_engineering.md`](harness_engineering.md) | 하네스는 어떤 자원과 모듈 규칙으로 위험에 대응하는가? |
| [`survival_rules.md`](survival_rules.md) (`draft`) | 건강·부상과 퇴로 상실의 기존 요구는 무엇이며 어떤 시제품 규칙을 검토해야 하는가? |
| [`repair_rules.md`](repair_rules.md) (`draft`) | 장비 내구·선택 수리·재출정 안전망의 기존 요구와 구현 전 제안은 무엇인가? |

## 경계 규칙

- Story의 원인과 개연성을 Design 수치로 덮어쓰지 않는다.
- [`repair_rules.md`](repair_rules.md)는 DEV-0405의 수리 검토안이며 단독 구현 기준이 아니다. 사용자가 선택한 거래 방식은 DEC-111·confirmed Economy Rules, DEV-0406의 제한된 손상 시험 적용과 아직 미적용인 수리/안전망 후보는 Q-022·Q-023과 구분한다.
- 사용자 표시 명칭은 [`../reference/glossary.md`](../reference/glossary.md)를 따른다.
- 미결정 수치와 규칙은 [`../project/open_questions.md`](../project/open_questions.md)에 연결한다.
- `confirmed` 문서는 구현 기준으로 사용할 수 있다. [`harness_engineering.md`](harness_engineering.md)는 상세 규칙 이관·검증 전까지 `draft`이므로 단독 구현 기준으로 사용하지 않는다.
- [`survival_rules.md`](survival_rules.md)는 기존 요구·DEV-0318의 제안·DEV-0319~DEV-0322의 제한된 시험 적용을 구분하는 `draft` 문서다. 상태·이동·조사/회수 시간·HUD, 별도 공간의 통로 변화·비상 탈출 시험 값과 최종 미정 규칙을 구별한다. 최종 피해·회복·퇴로 규칙의 확정 문서나 단독 구현 기준이 아니다. 실제 미정 항목은 `Q-019`~`Q-021`, 후속 작업 순서는 개발 인계가 소유한다.

## 현재 상태

Story 이관 후 확인한 Design 티켓 `DOC-0301`~`DOC-0304`와 Project 이관을 완료하고 G-M3를 통과했다. `DOC-0501` 공식 용어 검수 결과는 [`../project/m4_term_review.md`](../project/m4_term_review.md)에, `DOC-0502` 중복 탐지와 `DOC-0503` 단일 출처 전환 결과는 [`../project/m4_story_design_review.md`](../project/m4_story_design_review.md)에 기록했다. `DOC-0504` 화자 표현·NPC 지식 검수 결과는 [`../project/m4_speaker_knowledge_review.md`](../project/m4_speaker_knowledge_review.md)에 기록했다. `DOC-0505` 핵심 설정·Entity·Timeline 검수 결과는 [`../project/m5_core_entity_timeline_review.md`](../project/m5_core_entity_timeline_review.md)에 기록했으며 Design 본문 변경은 없었다. `DOC-0506` 링크·누락 검사 결과는 [`../project/m5_link_omission_review.md`](../project/m5_link_omission_review.md)에 기록했으며 Design 본문 5개는 중앙 진입점에서 모두 접근 가능하다. Design은 상태·조건·처리·계산을 상세 소유하고 Story의 이유·지식·정보 내용을 요약 링크로 참조한다. G-M5 통과와 `DOC-0601` 사람 검토 후 `DOC-0602`에서 이 README와 이관·검증을 마친 Design 본문 4개를 `confirmed`로 전환했다. 추가 골격인 [`harness_engineering.md`](harness_engineering.md)는 `MIG-CHG-005`에 따라 `draft`를 유지한다. 근거는 [`../project/m6_human_review.md`](../project/m6_human_review.md)에 있다.
