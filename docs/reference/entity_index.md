---
id: REFERENCE-ENTITY-INDEX
title: 고유 개체 색인
document_type: reference
status: provisional
source_version: story-v1.5
canonical_for:
  - entity_identifiers
  - entity_source_locations
last_reviewed: 2026-07-28
owner: documentation-maintainer
related:
  - ../story/01_world_history.md
  - ../story/02_dungeon_canon.md
  - ../story/03_player_and_society.md
  - ../story/04_characters_and_factions.md
  - ../story/05_items_and_discoveries.md
  - ../project/m5_core_entity_timeline_review.md
---

# 고유 개체 색인

## 목적

인물, 조직, 장소, 개별 던전, 고유 물품의 식별자와 기준 문서 위치를 추적한다.

## 포함 범위

- 원본에 이미 존재하는 고유 개체와 역할
- 개체 유형, 상태, 기준 문서, 비고
- 이름이 미정인 기존 개체의 임시 식별

## 제외 범위

- 빈 목록을 채우기 위한 신규 인물·장소·조직 생성
- 인물의 상세 지식과 성격
- 코드·저장용 영구 ID 확정

## ID와 상태 규칙

- `NPC`, `ORG`, `LOC`, `DGN`, `ART` ID는 문서 추적용이다. 코드 ID나 저장 키로 자동 사용하지 않는다.
- ID는 한 번 발급하면 이름이 바뀌어도 유지하고 다른 개체에 재사용하지 않는다.
- `이름`의 `미정`은 실제 이름이 아직 없다는 상태 표시이며 게임 안 표시 이름이 아니다.
- `역할·현재 표기`는 원본에서 대상을 찾기 위한 설명이다. 이를 고유명으로 취급하지 않는다.
- NPC 역할 행은 원본이 정의한 역할 레코드를 추적한다. 최종 인물 수나 서로 다른 역할의 겸임 여부를 확정하지 않는다.

| 상태 | 의미 |
|---|---|
| `confirmed` | 대상의 존재와 현재 역할이 원본에서 확정됨 |
| `provisional` | 역할과 기능은 있으나 이름, 인원, 세부 구성이 미정 |
| `deferred` | 원본에 후보가 있으나 현재 게임의 필수 요소가 아니며 후순위 |

## 개체 목록

### 인물과 역할

| ID | 이름 | 유형 | 역할·현재 표기 | 상태 | 기준 문서 | 원본 추적 | 비고 |
|---|---|---|---|---|---|---|---|
| `NPC-001` | 미정 | 플레이어 캐릭터 | 폐던전 수색꾼인 플레이어 | `confirmed` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md) | `STY-0031`, `STY-0032` | 고유명과 과거 사건은 미정 |
| `NPC-002` | 미정 | 역사적 존재 | 마왕 | `confirmed` | [`../story/01_world_history.md`](../story/01_world_history.md) | `STY-0011` | `마왕`은 현재 역할 표기이며 개인 이름은 없음 |
| `NPC-003` | 미정 | 기능형 NPC 역할 | 상인 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045` | 폐품 매입과 장비 판매 역할 |
| `NPC-004` | 미정 | 기능형 NPC 역할 | 감정사 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045`, `STY-0048` | 미확인 물품과 잔재 감정 역할 |
| `NPC-005` | 미정 | 기능형 NPC 역할 | 연구자 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045`, `STY-0046` | 기록물 보관·해석과 지식 진행만 확정 |
| `NPC-006` | 미정 | 행정 NPC 역할 | 길드 관리자 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045` | 허가, 의뢰, 회수품 등록 역할 |
| `NPC-007` | 미정 | 조력자 역할 | 튜토리얼 수색꾼 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045`, `STY-0047` | 선배 또는 동료 여부와 이름은 미정 |
| `NPC-008` | 미정 | 선택적 NPC 역할 | 전직 모험가 | `deferred` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045` | 선택적 조언자이며 필수 NPC가 아님 |
| `NPC-009` | 미정 | 배경 NPC 역할 | 행정관 | `deferred` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045` | 필요할 때 제도적 통제를 보여주는 배경 역할 |
| `NPC-010` | 미정 | 신앙 NPC 역할 | 성직자 | `provisional` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0045`, `STY-0050` | 마왕·봉인·저주에 대한 사회적 믿음을 보여줌 |
| `NPC-011` | 미정 | 선택적 서브 스토리 역할 | 흔적을 남긴 실패·실종 수색꾼 | `deferred` | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md) | `STY-0073` | 한 사람인지 여러 사례인지 확정하지 않음 |

### 조직

| ID | 이름 | 유형 | 역할·현재 표기 | 상태 | 기준 문서 | 원본 추적 | 비고 |
|---|---|---|---|---|---|---|---|
| `ORG-001` | 미정 | 직업 조직 | 수색꾼 길드 | `confirmed` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md) | `STY-0038` | `수색꾼 길드`는 기능 표기이며 정식 조직명은 미정 |
| `ORG-002` | 미정 | 선택적 배경 세력 | 마왕 부활을 믿거나 획책하는 소수 세력 | `deferred` | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | `STY-0004`, `STY-0064` | 발견물과 소문 수준의 선택적 떡밥으로만 유지 |

### 장소와 던전

| ID | 이름 | 유형 | 역할·현재 표기 | 상태 | 기준 문서 | 원본 추적 | 비고 |
|---|---|---|---|---|---|---|---|
| `LOC-001` | 미정 | 거점 | 플레이어의 거점 | `provisional` | [`../story/03_player_and_society.md`](../story/03_player_and_society.md) | `STY-0032`, `STY-0061` | 형태, 위치, 명칭은 미정이며 개선 대상이라는 기능만 있음 |
| `DGN-001` | 미정 | 대형 폐던전 | 주요 반복 탐험 폐던전 | `confirmed` | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md) | `STY-0021`, `STY-0076` | 코어 파괴 후에도 오래 남아 같은 던전을 반복 탐험함 |

### 고유 물품

원본에는 `고유 유물`과 `핵심 기록물`이라는 분류만 있고 이름과 정체가 정해진 개별 물품은 없다. 따라서 `ART` ID를 발급하지 않는다.

## ID 보류 및 제외 대상

| 원본 표기 | 상태 | ID를 발급하지 않은 이유 | 원본 추적 |
|---|---|---|---|
| 봉인 관리인 | `rejected` | 현재 버전에서 제거되었고 기능 일부를 성직자가 담당함 | `STY-0050` |
| 암시장 | `deferred` | 선택적 거래 방식일 뿐 특정 조직이나 장소로 확정되지 않음 | `STY-0039`, `STY-0043` |
| 대형 길드, 군대, 학계, 공방, 일반 수색꾼 | 범주 | 개별 고유 개체가 아니라 사회 집단 또는 역할의 일반 범주임 | 원본 전반 |
| 코어 방, 잔여 구역, 기록실 등 | 범주 | 개별 장소가 아니라 반복되는 장소 유형임 | 원본 전반 |

## 집계

| 유형 | 발급 수 |
|---|---:|
| 인물·역할 | 11 |
| 조직 | 2 |
| 장소 | 1 |
| 던전 | 1 |
| 고유 물품 | 0 |
| 합계 | 15 |

## 변경 규칙

1. 미정 이름을 정할 때 기존 ID를 유지한다.
2. 이름 변경은 이전 이름과 변경 근거를 함께 기록한다.
3. 역할 하나가 여러 인물로 분리되거나 여러 역할이 한 인물로 합쳐지면 먼저 관련 Story와 결정 기록을 검토한다.
4. `deferred` 항목을 활성화하거나 제외된 후보를 되살릴 때는 범위 확대 여부를 검토한다.
5. 구현 ID, 저장 키, 번역 키는 개발 구조가 확정된 뒤 별도로 연결한다.

## 현재 상태

`DOC-0104`에서 원본에 이미 존재하는 개체와 역할만 식별했다. `DOC-0505`는 15개 ID의 이름·상태와 Story 근거를 대조해 직접 충돌이 없음을 확인하고 `NPC-002`, `LOC-001`, `DGN-001`의 Story 역링크를 보완했다. `DOC-0506` 자동 검사와 `DOC-0601` 사람 검토를 마쳐 `DOC-0602`에서 `provisional`로 전환했다. 이름·인원·역할 겸임이 미정인 항목은 새 설정으로 채우지 않는다.
