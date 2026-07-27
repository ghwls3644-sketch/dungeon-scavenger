---
id: PROJECT-M5-CORE-ENTITY-TIMELINE-REVIEW
title: 핵심 설정·Entity·Timeline 정합성 검토
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1+management-proposal-v0.2.1
canonical_for:
  - core_entity_timeline_consistency_review
  - entity_timeline_conflict_tracking
last_reviewed:
owner: documentation-maintainer
related:
  - migration_manifest.md
  - migration_changes.md
  - decisions.md
  - open_questions.md
  - ../GDD.md
  - ../story/00_core_pillars.md
  - ../story/01_world_history.md
  - ../story/02_dungeon_canon.md
  - ../story/03_player_and_society.md
  - ../story/04_characters_and_factions.md
  - ../story/05_items_and_discoveries.md
  - ../story/06_narrative_progression.md
  - ../reference/entity_index.md
  - ../reference/timeline.md
---

# 핵심 설정·Entity·Timeline 정합성 검토

## 목적

`DOC-0505`에서 핵심 설정, Entity Index의 개체·역할과 Timeline의 사건 순서가 Story, GDD와 결정 기록에 서로 다르게 적혀 있지 않은지 검토한다. 충돌은 원본에 없는 설명을 만들어 합치지 않고 기존 결정으로 해결하거나 사람 검토 후보로 남긴다.

## 검토 기준

- 검토일: 2026-07-27
- 핵심 제약: [`00_core_pillars.md`](../story/00_core_pillars.md)
- 상세 정설: [`01_world_history.md`](../story/01_world_history.md), [`02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 플레이어·NPC·세력: [`03_player_and_society.md`](../story/03_player_and_society.md), [`04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 발견물·진행: [`05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`06_narrative_progression.md`](../story/06_narrative_progression.md)
- 상위 제품 기준과 결정: [`GDD`](../GDD.md) 3장·11장·18장, [`decisions.md`](decisions.md)
- Reference 대상: [`entity_index.md`](../reference/entity_index.md), [`timeline.md`](../reference/timeline.md)
- 동결 원본: `스토리 정리 v1.5`

## 핵심 설정 대조

| 핵심 설정 | Story 기준 | GDD·결정 기준 | 판정 |
|---|---|---|---|
| 마왕과 던전 발생 | 마왕은 오래전에 봉인되었지만 던전의 직접 원인이 아니며 던전은 자연 발생 | GDD 3-1, `DEC-001` | 일치 |
| 던전 발생 원리 | 자연 발생만 확정하고 정확한 조건·원리는 미정 | GDD 3-1·19장, `Q-010` | 일치 |
| 코어와 폐던전 | 코어 파괴 뒤 축적·자가 복구를 잃고 자연 소멸 시작 | GDD 3-2·3-3, `DEC-004` | 일치 |
| 폐던전의 범람 위험 | 현재 규칙은 범람 위험이 사라짐 | GDD 3-3·18-1, `DEC-004` | 현재 해석은 일치하나 GDD 3-4에 옛 표현 1건 잔존 |
| 잔여 구역 | 폐던전 전체가 아니라 내부 미답파·미기록 공간 | GDD 3-5, `DEC-005` | 일치 |
| 플레이어 시작 상태 | 처음부터 수색꾼이며 초반 목표는 생계 | GDD 3-6·11-1, `DEC-002`, `DEC-003` | 일치 |
| 마왕 관련 세력 | 선택적 배경 떡밥이며 핵심 진행이나 최종 전투로 확장하지 않음 | GDD 3-1·11-2, `DEC-001`, `DEC-010` | 일치 |
| 고유 물품 | 고유 유물과 핵심 기록물은 원본이며 반복 등장·일반 판매 대상이 아님 | GDD 3-7·18-1, `DEC-007` | 일치 |
| 반복 탐험 | 고정 큰 지도, 제한적 변화와 잔존 에너지 유실에 따른 기존 물품 노출 | GDD 5장·18-1, `DEC-006`, `DEC-008` | 일치 |
| 완결 방향 | 세계 구원이 아니라 수색꾼으로서 자립 | GDD 11-2·18-1, `DEC-010` | 일치 |

### 범람 표현 판정

GDD 3-3과 부록 A, `DEC-004`, Story의 현재 기준은 폐던전의 범람 위험이 `사라진다`고 정한다. GDD 3-4와 동결 원본에 남은 `사라지거나 극히 낮다`는 문장은 현재 규칙으로 사용하지 않는다.

이 차이는 새 설정을 결정해야 하는 열린 질문이 아니다. 이미 존재하는 `DEC-004`로 현재 해석을 고정한다. 다만 `docs/GDD.md`는 동결 원본과 SHA-256을 보존해야 하므로 이번 티켓에서 문장을 고치지 않고, `DOC-0601` 사람 검토에서 후속 GDD 개정 필요성을 확인한다.

## Entity 대조

Entity Index의 문서 추적 ID 15개를 Story의 실제 역할·상태와 대조했다.

| ID | 현재 대상과 상태 | Story·결정 대조 | 판정 |
|---|---|---|---|
| `NPC-001` | 플레이어 수색꾼, `confirmed` | 게임 시작부터 수색꾼이라는 `DEC-002`와 일치 | 일치 |
| `NPC-002` | 오래전에 봉인된 마왕, `confirmed` | 역사적 존재와 직접 인과 부정이 `DEC-001`과 일치 | 일치 |
| `NPC-003` | 상인 역할, `provisional` | 기능형 NPC이며 이름·인원 미정 | 일치 |
| `NPC-004` | 감정사 역할, `provisional` | 물품 판별 역할만 확정 | 일치 |
| `NPC-005` | 연구자 역할, `provisional` | 기록 해석과 단계별 지식 변화가 Story와 일치 | 일치 |
| `NPC-006` | 길드 관리자 역할, `provisional` | 허가·의뢰·등록 기능이 Story와 일치 | 일치 |
| `NPC-007` | 튜토리얼 수색꾼 역할, `provisional` | 선배·동료 관계는 미정으로 유지 | 일치 |
| `NPC-008` | 전직 모험가 역할, `deferred` | 선택적 조언자이며 필수 NPC가 아님 | 일치 |
| `NPC-009` | 행정관 역할, `deferred` | 필요할 때만 사용하는 배경 역할 | 일치 |
| `NPC-010` | 성직자 역할, `provisional` | `DEC-017`에 따라 봉인 관리인 기능 일부만 흡수 | 일치 |
| `NPC-011` | 실패·실종 수색꾼 역할, `deferred` | 한 사람인지 여러 사례인지 미정으로 유지 | 일치 |
| `ORG-001` | 수색꾼 길드, `confirmed` | 존재와 기능은 확정, 정식 이름·인원은 미정 | 일치 |
| `ORG-002` | 마왕 부활을 믿거나 획책하는 소수 세력, `deferred` | 선택적 배경 범위를 넘지 않음 | 일치 |
| `LOC-001` | 플레이어 거점, `provisional` | 개선 대상 기능만 있고 형태·위치·이름은 미정 | 일치 |
| `DGN-001` | 주요 반복 탐험 폐던전, `confirmed` | 코어 파괴 후 천천히 소멸하는 대형 던전과 일치 | 일치 |

ID 중복과 확정된 이름 충돌은 없다. `NPC` 역할 행은 최종 인물 수나 역할 겸임을 확정하지 않으며, `NPC-011`도 한 사람이라는 새 결정을 만들지 않는다.

Story에서 역으로 Entity ID를 찾을 수 없던 `NPC-002`, `LOC-001`, `DGN-001`의 근거 링크 3건을 보완했다.

## Timeline 대조

| 검토 항목 | 확인 결과 | 처리 |
|---|---|---|
| 마왕 봉인과 던전 증가의 선후 | 원본은 둘의 인과와 선후를 확정하지 않지만 Timeline 앞 표는 봉인이 먼저라고 적고 뒤 표는 선후 미정이라고 적음 | 직접 모순. Timeline에서 마왕 봉인을 독립 과거 사건으로 분리 |
| 던전 증가와 모험가 시대 | 던전이 늘면서 모험가 직업과 산업이 성장 | 유지 |
| 모험가 공략과 폐던전 등장 | 공략이 누적된 뒤 코어가 파괴된 폐던전과 잔여 구역이 등장 | 유지 |
| `DGN-001`의 코어 파괴 | 현재 반복 탐험보다 이전이며 구체적 행위자·시점은 미정 | 유지 |
| `NPC-001`의 시작 상태 | 게임 시작 시점에 이미 수색꾼 | 유지 |
| 반복·조건부 과정 3개 | 던전 자연 발생, 주요 폐던전의 소멸·반복 탐험, 최종 소멸 | 유지 |

Timeline의 사건 행은 5개, 반복·조건부 과정은 3개로 유지한다. 새 연도, 기간, 행위자와 사건을 추가하지 않았다.

## 직접 충돌과 처리 결과

| 구분 | 건수 | 결과 |
|---|---:|---|
| Entity ID·이름·상태 직접 충돌 | 0 | 변경 없음 |
| Entity Story 역링크 누락 | 3 | `NPC-002`, `LOC-001`, `DGN-001` 링크 보완 |
| Timeline 직접 선후 모순 | 1 | 원본에 없는 선후를 제거해 해소 |
| 핵심 설정의 현재 해석 충돌 | 1 | `DEC-004`로 범람 위험 `사라짐`을 적용 |
| 동결 GDD의 후속 문구 검토 후보 | 1 | GDD 3-4 문구를 `DOC-0601` 사람 검토 후보로 전달 |
| 새 설정·개체·사건·열린 질문 | 0 | 추가하지 않음 |

## 문서 상태 검토

Entity Index와 Timeline의 직접 충돌은 해소했지만 `DOC-0506` 링크·누락 자동 검사와 `DOC-0601` 사람 검토가 남아 있다. 따라서 두 문서는 이번 티켓에서 `draft`를 유지하며 `provisional`로 승격하지 않는다.

## 후속 작업

1. `DOC-0505` 완료 후 정합성 검사에서 위 충돌과 처리 결과를 확인한다.
2. `DOC-0506`에서 활성 문서의 상대 링크, 앵커와 누락을 자동 검사한다.
3. `DOC-0601`에서 GDD 3-4의 옛 범람 표현과 기존 화자 검토 후보 2건을 사람이 확인한다.

## 검토 결과

- 판정: `DOC-0505 검토 완료`
- 핵심 설정 대조 항목: 10개
- Entity 검토: 15개
- Entity 직접 충돌: 0건
- Entity Story 역링크 보완: 3건
- Timeline 사건 행: 5개
- Timeline 직접 선후 모순: 1건 해소
- 기존 결정으로 해석을 고정한 핵심 표현: 1건
- 새 설정·개체·사건·열린 질문: 0건
- 다음 티켓: `DOC-0506 — 링크·누락 자동 검사`

이 보고서는 `DOC-0601` 사람 검토가 끝날 때까지 `draft`다.
