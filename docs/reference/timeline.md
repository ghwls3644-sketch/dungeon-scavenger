---
id: REFERENCE-TIMELINE
title: 사건 타임라인
document_type: reference
status: provisional
source_version: story-v1.5
canonical_for:
  - event_order
last_reviewed: 2026-07-28
owner: narrative-design
related:
  - ../story/01_world_history.md
  - ../story/02_dungeon_canon.md
  - ../story/03_player_and_society.md
  - ../story/06_narrative_progression.md
  - entity_index.md
  - ../project/decisions.md
  - ../project/m5_core_entity_timeline_review.md
---

# 사건 타임라인

## 목적

원본에 확정된 주요 사건의 상대적 순서와 상세 기준 문서를 빠르게 확인한다.

## 포함 범위

- 기존 원본에서 확인되는 사건 순서
- 시점 정확도와 확정 상태
- 상세 Story 문서 링크

## 제외 범위

- 근거 없는 정확한 연도와 날짜 생성
- 사건의 상세 서술 복제
- 게임 플레이 단계와 퀘스트 순서

## 기록 규칙

- 원본이 보장하는 상대 순서만 기록하고 연도와 기간은 `미정`으로 둔다.
- 같은 순서 그룹의 사건은 서로의 앞뒤가 정해지지 않았다는 뜻이다.
- 반복 현상과 조건부 미래는 확정 사건 순서와 별도로 기록한다.
- 이 문서는 사건의 상세 원인을 설명하지 않고 관련 Story 문서와 원본 ID를 연결한다.
- 마왕과 던전 사이의 직접 인과가 없다는 사실을 시간상 선후 관계로 확대 해석하지 않는다.

## 확정된 사건과 상대 순서

| 순서 | 사건 또는 상태 | 시간 관계 | 정확도 | 상태 | 상세 문서 | 원본 추적 |
|---|---|---|---|---|---|---|
| 독립 | [`NPC-002`](entity_index.md) 마왕이 오래전에 봉인됨 | 현재보다 오래전. 최초 던전 발생·모험가 시대와의 선후는 미정 | 현재 이전이라는 점만 확정 | `confirmed` | [`../story/01_world_history.md`](../story/01_world_history.md) | `STY-0011` |
| 1 | 자연 발생 던전이 늘고 모험가 시대와 던전 산업이 성장함 | 던전 증가와 함께 모험가 직업·산업이 성장. 마왕 봉인과의 선후는 미정 | 넓은 시대 구간만 확정 | `confirmed` | [`../story/01_world_history.md`](../story/01_world_history.md) | `STY-0012`, `STY-0013` |
| 2 | 던전 공략이 누적되고 코어가 파괴된 폐던전과 잔여 구역이 생김 | 모험가 공략 활동이 자리 잡은 뒤 | 상대 순서만 확정 | `confirmed` | [`../story/01_world_history.md`](../story/01_world_history.md), [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | `STY-0014` |
| 3A | [`DGN-001`](entity_index.md)의 코어가 파괴되어 천천히 소멸하는 폐던전이 됨 | 현재의 반복 탐험보다 이전 | 현재 이전이라는 점만 확정 | `confirmed` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | `STY-0021`, `STY-0076` |
| 3B | [`NPC-001`](entity_index.md)은 게임 시작 시점에 이미 수색꾼으로 살아감 | 게임 시작 시점의 현재 상태 | 시작 상태만 확정 | `confirmed` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md) | `STY-0031`, `STY-0032` |

`독립`은 번호가 붙은 사건과의 선후를 확정하지 않는 과거 사건이다. `3A`와 `3B`의 상호 순서도 미정이다. 플레이어가 수색꾼이 된 시점과 주요 폐던전의 코어가 파괴된 시점 중 어느 쪽이 먼저인지는 원본에서 정하지 않았다.

## 반복·조건부 과정

| 과정 | 시간 관계 | 분류 | 상세 문서 | 원본 추적 |
|---|---|---|---|---|
| 던전의 자연 발생 | 현재까지 이어지는 세계 현상. 최초 발생 시점은 미정 | 반복 현상 | [`../story/01_world_history.md`](../story/01_world_history.md) | `STY-0012` |
| 주요 폐던전의 소멸과 반복 탐험 | 코어 파괴 후 시작되어 완전 소멸 전까지 이어짐 | 진행 중 상태 | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | `STY-0021`, `STY-0076` |
| 폐던전의 최종 소멸 | 소멸 과정이 완료될 때 발생하며 게임 안에서 실제로 도달하는지는 미정 | 조건부 미래 | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | `STY-0022` |

## 순서를 확정하지 않은 항목

| 항목 | 현재 판단 | 이유 |
|---|---|---|
| 최초 던전 발생과 마왕 봉인의 선후 | 미정 | 던전과 마왕의 직접 인과는 부정되지만 최초 발생 시점은 제시되지 않음 |
| 주요 폐던전 코어를 누가 언제 파괴했는가 | 미정 | 현재 상태만 확정되고 행위자와 시점은 없음 |
| 플레이어가 수색꾼이 된 시점과 주요 폐던전 코어 파괴의 선후 | 미정 | 두 사건 모두 현재 이전이지만 상호 관계는 없음 |
| 마왕 부활 세력의 구체적 행동 | 확정 사건으로 미등록 | 선택적 배경 떡밥이며 실제 사건과 시점이 정해지지 않음 |
| 연구자의 초·중·후반 지식 변화 | Timeline에서 제외 | 사건 연대가 아니라 게임 내 정보 노출 순서이므로 [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md)가 담당함 |

## 관련 문서

- [`../story/01_world_history.md`](../story/01_world_history.md)
- [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md)
- [`entity_index.md`](entity_index.md)

## 현재 상태

`DOC-0105`에서 원본에 확정된 사건 행 5개와 반복·조건부 과정 3개를 등록했다. `DOC-0505`는 마왕 봉인과 던전 증가의 선후를 동시에 확정·미정으로 적은 모순 1건을 발견해, 마왕 봉인을 다른 사건과의 선후가 미정인 독립 과거 사건으로 정정했다. `DOC-0506` 자동 검사와 `DOC-0601` 사람 검토를 마쳐 `DOC-0602`에서 `provisional`로 전환했다. 연도·기간·행위자와 미정 선후는 새 설정으로 채우지 않는다.
