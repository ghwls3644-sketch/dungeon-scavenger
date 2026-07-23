---
id: DESIGN-INDEX
title: Design 문서 안내
document_type: design
status: draft
source_version: management-proposal-v0.2.1
canonical_for:
  - design_document_navigation
last_reviewed:
owner: game-design
related:
  - ../GDD.md
  - ../story/README.md
  - ../reference/README.md
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

## 경계 규칙

- Story의 원인과 개연성을 Design 수치로 덮어쓰지 않는다.
- 사용자 표시 명칭은 [`../reference/glossary.md`](../reference/glossary.md)를 따른다.
- 미결정 수치와 규칙은 [`../project/open_questions.md`](../project/open_questions.md)에 연결한다.
- 현재 파일들은 골격 단계이며 아직 구현 기준으로 확정되지 않았다.

## 현재 상태

Story 이관 후 G-M3 예비 점검에서 Design 대상 규칙과 표가 남아 있음을 확인했다. `DOC-0301`에서 [`narrative_delivery.md`](narrative_delivery.md)에 정보 전달 규칙을, `DOC-0302`에서 [`repeat_exploration.md`](repeat_exploration.md)에 반복 탐험 규칙을, `DOC-0303`에서 [`item_rules.md`](item_rules.md)에 아이템 구현 규칙을 추출했다. 다음 티켓은 `DOC-0304` 경제 규칙 추출이다.
