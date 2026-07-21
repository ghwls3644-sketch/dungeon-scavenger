---
id: DESIGN-REPEAT-EXPLORATION
title: 반복 탐험 규칙
document_type: design
status: draft
source_version: story-v1.5
canonical_for:
  - repeat_exploration_rules
  - visit_state_transitions
last_reviewed:
owner: game-design
related:
  - ../story/02_dungeon_canon.md
  - item_rules.md
  - harness_engineering.md
---

# 반복 탐험 규칙

## 목적

같은 폐던전을 반복 방문할 때 유지되는 상태와 변하는 요소의 실제 게임 규칙을 관리한다.

## 포함 범위

- 고정 지도와 문·통로 상태 변화
- 위험, 아이템, 적 배치의 랜덤 범위
- 반복 요소와 1회성 요소
- 잔여 구역 및 고유 유물 회수 후 상태 저장
- 잔존 에너지 노출량과 방문 간 상태 전환

## 제외 범위

- 반복 탐험이 가능한 세계관상 원인
- 개별 아이템의 판매·감정·저장 필드
- 실제 맵 콘텐츠와 밸런스 수치 확정

## 관련 문서

- [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- [`item_rules.md`](item_rules.md)
- [`harness_engineering.md`](harness_engineering.md)

## 이관 상태

본문 이관 전. 원본 11장의 구현 책임을 후속 티켓에서 분리한다.
