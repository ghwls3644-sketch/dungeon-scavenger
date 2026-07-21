---
id: REFERENCE-GLOSSARY
title: 공식 용어집
document_type: reference
status: draft
source_version: story-v1.5
canonical_for:
  - official_terms
  - term_meaning_boundaries
last_reviewed:
owner: documentation-maintainer
related:
  - ../story/README.md
  - speaker_lexicon.md
  - ../project/migration_manifest.md
---

# 공식 용어집

## 목적

핵심 용어의 공식 표기, 짧은 정의, 의미 범위, 혼동 주의를 관리한다.

## 포함 범위

- 공식 표기와 허용·폐기 명칭
- 한두 문장의 짧은 정의
- 의미 범위와 혼동하기 쉬운 용어
- 상세 Story 및 관련 Design 링크

## 제외 범위

- 세계관 역사와 현상의 상세 작동 원리
- 화자별 은어와 말투
- 코드 ID, 저장 키, 번역 키의 조기 확정

## 항목 형식

### 항목 상태

| 상태 | 의미 | 사용 규칙 |
|---|---|---|
| `confirmed` | 현재 공식 표기와 정의 | 신규 콘텐츠와 UI에서 사용 가능 |
| `provisional` | 임시로 사용하는 명칭 또는 정의 | 지정된 범위에서만 사용 |
| `deprecated` | 교체된 과거 명칭 | 검색·호환 추적 외 신규 사용 금지 |
| `rejected` | 검토했으나 채택하지 않은 후보 | 현재 용어처럼 사용 금지 |

`confirmed` 항목을 바꿀 때 기존 항목을 삭제하지 않는다. 대체 항목이나 변경 이력을 연결하고 이전 표기를 `deprecated`로 보존한다.

### ID 규칙

- 문서 용어 ID는 `TERM-...` 형식의 대문자 식별자를 사용한다.
- ID는 한 번 발급하면 재사용하거나 다른 의미에 할당하지 않는다.
- 공식 표기가 바뀌어도 같은 개념이면 문서 용어 ID는 유지한다.
- 코드 ID, 저장 키, 번역 키는 구현 구조가 확정된 뒤 별도 필드로 연결한다.

### 항목 양식

```markdown
## {공식 표기}

- ID: TERM-...
- 상태: provisional
- 분류:
- 공식 표기:
- 짧은 정의:
- 범위:
- 허용 별칭:
- 폐기된 명칭:
- 혼동 주의:
- 상세 설정:
- 관련 구현:
- 관련 화자 표현:
- 원본 추적:
  - STY-...
- 관련 결정:
- 변경 이력:
```

필수 필드는 `ID`, `상태`, `공식 표기`, `짧은 정의`, `상세 설정`이다. 나머지는 해당 항목에 영향이 있을 때 사용한다. 빈 목록을 채우기 위해 별칭이나 폐기 명칭을 만들지 않는다.

### 구현 이후 선택 필드

```markdown
- 코드 ID:
- 번역 키:
```

표시 명칭 변경만으로 코드 ID, 저장 키, 번역 키를 자동 변경하지 않는다.

## 항목 목록

`DOC-0101`에서 원본 13-1~13-3의 공식 용어와 의미 경계를 이관했다. 항목 상태는 원본에서 확정된 표기 여부를 나타내며, 용어집 문서 자체는 전체 이관 검토 전까지 `draft`다.

| ID | 공식 표기 | 분류 | 상태 |
|---|---|---|---|
| `TERM-DUNGEON` | 던전 | 장소 / 현상 | `confirmed` |
| `TERM-DUNGEON-CORE` | 코어 | 현상 / 기관 | `confirmed` |
| `TERM-CORE-ROOM` | 코어 방 | 장소 | `confirmed` |
| `TERM-RESIDUAL-ENERGY` | 잔존 에너지 | 마력 현상 | `confirmed` |
| `TERM-DUNGEON-OVERFLOW` | 범람 | 마력 현상 | `confirmed` |
| `TERM-DEAD-DUNGEON` | 폐던전 | 장소 / 상태 | `confirmed` |
| `TERM-REMAINING-ZONE` | 잔여 구역 | 장소 | `confirmed` |
| `TERM-SCAVENGER` | 수색꾼 | 직업 / 현장 명칭 | `confirmed` |
| `TERM-SCRAP` | 폐품 | 회수품 | `confirmed` |
| `TERM-REMNANT` | 잔재 | 회수품 / 현상 | `confirmed` |
| `TERM-UNIQUE-ARTIFACT` | 고유 유물 | 회수품 | `confirmed` |
| `TERM-KEY-RECORD` | 핵심 기록물 | 기록물 | `confirmed` |

## 던전

- ID: `TERM-DUNGEON`
- 상태: `confirmed`
- 분류: 장소 / 현상
- 공식 표기: 던전
- 짧은 정의: 세계 곳곳에서 자연 발생하는 마력 변질 공간.
- 범위: 코어의 활성 여부와 관계없이 던전 전체를 가리키는 상위 개념.
- 혼동 주의: 마왕이 만든 공간이나 마왕 봉인의 부산물로 단정하지 않는다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`

## 코어

- ID: `TERM-DUNGEON-CORE`
- 상태: `confirmed`
- 분류: 현상 / 기관
- 공식 표기: 코어
- 짧은 정의: 던전 중심부에 형성되는 마력 핵 또는 공간 유지 기관.
- 범위: 던전의 공간 유지와 마력 순환을 담당하는 중심부.
- 혼동 주의: 생명체, 장치, 자연 현상 중 하나로 정체를 확정하지 않는다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`

## 코어 방

- ID: `TERM-CORE-ROOM`
- 상태: `confirmed`
- 분류: 장소
- 공식 표기: 코어 방
- 짧은 정의: 코어가 실제로 존재하며 그 상태를 육안으로 확인할 수 있는 방.
- 범위: 던전 중심부, 깊은 구역 또는 특수 우회 구역에 형성되는 물리적 장소.
- 혼동 주의: 추상적인 기능 구역이 아니라 확인 가능한 실제 공간이다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`

## 잔존 에너지

- ID: `TERM-RESIDUAL-ENERGY`
- 상태: `confirmed`
- 분류: 마력 현상
- 공식 표기: 잔존 에너지
- 짧은 정의: 코어가 파괴된 뒤에도 폐던전 내부에 남아 있는 마력.
- 범위: 폐품 노출, 잔재 응축, 장치 오작동, 구역 변형을 일으킬 수 있는 잔류 마력.
- 혼동 주의: 던전의 자가 복구나 새로운 고유 유물 생성을 뜻하지 않는다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`

## 범람

- ID: `TERM-DUNGEON-OVERFLOW`
- 상태: `confirmed`
- 분류: 마력 현상
- 공식 표기: 범람
- 짧은 정의: 활성 던전에 축적된 에너지가 넘쳐 몬스터나 마력 현상이 외부로 흘러나오는 현상.
- 범위: 코어가 기능하는 활성 던전에서 발생하는 외부 위협.
- 혼동 주의: 코어가 파괴된 폐던전에는 범람 위험이 없다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`

## 폐던전

- ID: `TERM-DEAD-DUNGEON`
- 상태: `confirmed`
- 분류: 장소 / 상태
- 공식 표기: 폐던전
- 짧은 정의: 코어가 파괴되어 범람 위험은 사라졌지만 내부 위험과 회수품이 남아 있는 던전 전체.
- 범위: 코어 파괴 뒤 완전히 소멸하기 전까지의 던전 전체.
- 허용 별칭: 없음. 공식 문서와 현장 대화 모두 `폐던전`을 사용한다.
- 혼동 주의: 완전히 안전하거나 비어 있는 장소가 아니며, 내부 일부를 뜻하는 `잔여 구역`과 같은 말이 아니다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`
  - `STY-0097`

## 잔여 구역

- ID: `TERM-REMAINING-ZONE`
- 상태: `confirmed`
- 분류: 장소
- 공식 표기: 잔여 구역
- 짧은 정의: 폐던전 내부에서 과거 공략 중 지나쳤거나 발견·기록되지 않은 미답파 구역.
- 범위: 폐던전 전체가 아니라 그 안의 일부 공간.
- 혼동 주의: `폐던전`의 별칭이 아니며, 이미 알려진 주요 공략 루트와 구분한다.
- 상세 설정: [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md)
- 관련 구현: [`../design/repeat_exploration.md`](../design/repeat_exploration.md)
- 원본 추적:
  - `STY-0095`
  - `STY-0097`

## 수색꾼

- ID: `TERM-SCAVENGER`
- 상태: `confirmed`
- 분류: 직업 / 현장 명칭
- 공식 표기: 수색꾼
- 짧은 정의: 폐던전에서 회수품을 찾아 생계를 잇는 사람을 현장에서 부르는 명칭.
- 범위: 플레이어 주변과 실제 현장에서 사용하는 직업 정체성.
- 허용 별칭:
  - 모험가 — 제도상 넓은 분류에서만 사용한다.
  - 폐던전 파견 인원 — 행정 문서에서 사용할 수 있다.
  - 정찰 파견 — 직업명이 아니라 길드의 임무명으로만 사용한다.
- 폐기된 명칭: 없음.
- 혼동 주의:
  - 정찰자는 공식 직업명이 아니라 일부 모험가가 사용하는 오해 섞인 호칭이다.
  - 도적과 잔반 처리는 비하 표현이며 공식 별칭이 아니다.
- 상세 설정: [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- 관련 화자 표현: [`speaker_lexicon.md`](speaker_lexicon.md) — `DOC-0102`에서 이관
- 원본 추적:
  - `STY-0095`
  - `STY-0096`

## 폐품

- ID: `TERM-SCRAP`
- 상태: `confirmed`
- 분류: 회수품
- 공식 표기: 폐품
- 짧은 정의: 던전에 물리적으로 남은 잡동사니와 부품.
- 범위: 반복해서 발견할 수 있는 일반 회수품.
- 혼동 주의: 마력과 기억의 흔적이 얽힌 `잔재`와 구분한다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/item_rules.md`](../design/item_rules.md)
- 원본 추적:
  - `STY-0095`

## 잔재

- ID: `TERM-REMNANT`
- 상태: `confirmed`
- 분류: 회수품 / 현상
- 공식 표기: 잔재
- 짧은 정의: 마력과 기억의 흔적이 엉긴 물질 또는 현상.
- 범위: 감정을 통해 과거 사건이나 마력 반응이 드러날 수 있는 대상.
- 혼동 주의: 일반 폐품이나 확인되지 않은 저주 물품과 같은 말이 아니다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/item_rules.md`](../design/item_rules.md)
- 원본 추적:
  - `STY-0095`

## 고유 유물

- ID: `TERM-UNIQUE-ARTIFACT`
- 상태: `confirmed`
- 분류: 회수품
- 공식 표기: 고유 유물
- 짧은 정의: 특정 사건이나 인물과 연결된 단 하나의 원본 물품.
- 범위: 반복 생성되지 않는 고유 발견물.
- 혼동 주의: 희귀하기만 한 일반 전리품이나 반복 회수품을 포함하지 않는다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/item_rules.md`](../design/item_rules.md)
- 원본 추적:
  - `STY-0095`

## 핵심 기록물

- ID: `TERM-KEY-RECORD`
- 상태: `confirmed`
- 분류: 기록물
- 공식 표기: 핵심 기록물
- 짧은 정의: 던전, 코어, 인물, 사건의 진실을 여는 기록.
- 범위: 세계관 정보와 수집 진행을 여는 고유 기록물.
- 혼동 주의: 일반 문서나 반복해서 얻는 배경 기록 전체를 뜻하지 않는다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/narrative_delivery.md`](../design/narrative_delivery.md)
- 원본 추적:
  - `STY-0095`

## 관련 문서

- [`../story/README.md`](../story/README.md)
- [`speaker_lexicon.md`](speaker_lexicon.md)
- [`../project/migration_manifest.md`](../project/migration_manifest.md)
