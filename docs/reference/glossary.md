---
id: REFERENCE-GLOSSARY
title: 공식 용어집
document_type: reference
status: draft
source_version: story-v1.5+gdd-v2.1
canonical_for:
  - official_terms
  - term_meaning_boundaries
last_reviewed:
owner: documentation-maintainer
related:
  - ../story/README.md
  - speaker_lexicon.md
  - ../project/migration_manifest.md
  - ../project/m4_term_review.md
  - ../project/open_questions.md
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
| `TERM-ADVENTURER` | 모험가 | 직업 / 제도상 분류 | `confirmed` |
| `TERM-SCAVENGER` | 수색꾼 | 직업 / 현장 명칭 | `confirmed` |
| `TERM-SCOUTING-DISPATCH` | 정찰 파견 | 임무 | `confirmed` |
| `TERM-RECOVERABLE-MATERIAL` | 잔류물 | 회수 대상 상위 분류 | `confirmed` |
| `TERM-UNIDENTIFIED-ITEM` | 미확인 물품 | 아이템 상태 | `confirmed` |
| `TERM-SCRAP` | 폐품 | 회수품 | `confirmed` |
| `TERM-REMNANT` | 잔재 | 회수품 / 현상 | `confirmed` |
| `TERM-UNIQUE-ARTIFACT` | 고유 유물 | 회수품 | `confirmed` |
| `TERM-KEY-RECORD` | 핵심 기록물 | 기록물 | `confirmed` |
| `TERM-APPRAISAL` | 감정 | 시스템 / 행위 | `confirmed` |
| `TERM-RECOVERY-TAX` | 회수세 | 경제 비용 | `confirmed` |
| `TERM-HARNESS-ENGINEERING` | 하네스 엔지니어링 | 기술 체계 / 시스템 | `confirmed` |

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
- 허용 별칭: 없음. 현장 직업명은 `수색꾼`을 사용한다.
- 관련 표현:
  - [`모험가`](#모험가) — 제도상 넓은 직업 분류.
  - 폐던전 파견 인원 — 행정 문서의 설명 표현.
  - [`정찰 파견`](#정찰-파견) — 길드의 임무명.
- 폐기된 명칭: 없음.
- 혼동 주의:
  - 정찰자는 공식 직업명이 아니라 일부 모험가가 사용하는 오해 섞인 호칭이다.
  - 도적과 잔반 처리는 비하 표현이며 공식 별칭이 아니다.
- 상세 설정: [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- 관련 화자 표현: [`speaker_lexicon.md#수색꾼`](speaker_lexicon.md#수색꾼)
- 원본 추적:
  - `STY-0095`
  - `STY-0096`

## 모험가

- ID: `TERM-ADVENTURER`
- 상태: `confirmed`
- 분류: 직업 / 제도상 분류
- 공식 표기: 모험가
- 짧은 정의: 던전 탐사와 공략에 종사하는 사람을 제도상 넓게 가리키는 직업 분류.
- 범위: 정예 공략자부터 하위 직종인 수색꾼까지 포함할 수 있는 상위 범주.
- 혼동 주의: 현장에서 폐던전 회수를 생업으로 삼는 사람의 구체적인 직업 정체성은 [`수색꾼`](#수색꾼)이다.
- 상세 설정: [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- 원본 추적:
  - `STY-0096`
  - GDD 3-6
- 관련 결정: [`DEC-002`](../project/decisions.md)

## 정찰 파견

- ID: `TERM-SCOUTING-DISPATCH`
- 상태: `confirmed`
- 분류: 임무
- 공식 표기: 정찰 파견
- 짧은 정의: 길드가 폐던전 조사와 회수를 위해 부여하는 임무 단위의 공식 표현.
- 범위: 사람이 아니라 수행할 임무를 가리킨다.
- 혼동 주의: [`수색꾼`](#수색꾼)의 직업 별칭이나 `정찰자`라는 별도 직업명이 아니다.
- 상세 설정: [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- 관련 화자 표현: [`speaker_lexicon.md#길드--행정`](speaker_lexicon.md#길드--행정)
- 원본 추적:
  - `STY-0096`
  - GDD 3-6
- 관련 결정: [`DEC-002`](../project/decisions.md)

## 잔류물

- ID: `TERM-RECOVERABLE-MATERIAL`
- 상태: `confirmed`
- 분류: 회수 대상 상위 분류
- 공식 표기: 잔류물
- 짧은 정의: 길드와 행정이 회수 가능한 물품 전체를 가리키는 상위 표현.
- 범위: 미확인 물품, 폐품, 잔재, 고유 유물과 핵심 기록물처럼 회수 대상으로 다루는 물품군.
- 혼동 주의: `회수품`은 일반 설명이나 실제로 들고 나온 물품을 가리킬 수 있지만, 아이템의 독립된 최종 분류는 아니다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/item_rules.md`](../design/item_rules.md)
- 관련 화자 표현: [`speaker_lexicon.md#길드--행정`](speaker_lexicon.md#길드--행정)
- 원본 추적:
  - GDD 8-1
  - GDD 부록 A

## 미확인 물품

- ID: `TERM-UNIDENTIFIED-ITEM`
- 상태: `confirmed`
- 분류: 아이템 상태
- 공식 표기: 미확인 물품
- 짧은 정의: 아직 감정되지 않아 실제 분류와 가치를 알 수 없는 물품의 임시 상태.
- 범위: 감정 전 표시와 처리에만 사용하며, 감정 뒤에는 실제 아이템 분류를 따른다.
- 혼동 주의: 폐품·잔재·고유 유물과 나란한 독립 최종 분류가 아니다.
- 상세 설정: [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md)
- 관련 구현: [`../design/item_rules.md#감정-상태`](../design/item_rules.md#감정-상태)
- 원본 추적:
  - GDD 8-1
  - GDD 8-2

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
  - `STY-0098`

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

## 감정

- ID: `TERM-APPRAISAL`
- 상태: `confirmed`
- 분류: 시스템 / 행위
- 공식 표기: 감정
- 짧은 정의: 미확인 물품의 실제 분류와 가치를 판별하는 과정.
- 범위: 감정사 또는 현장 감정 수단을 통해 물품 정보를 확인하는 시스템 의미.
- 혼동 주의: 인물의 기분이나 정서를 뜻하는 일반어 `감정`과 문맥으로 구분한다.
- 상세 설정: [`../story/05_items_and_discoveries.md#감정과-연구자-보관의-의미`](../story/05_items_and_discoveries.md#감정과-연구자-보관의-의미)
- 관련 구현: [`../design/item_rules.md#감정-상태`](../design/item_rules.md#감정-상태), [`../design/economy_rules.md#비용-항목`](../design/economy_rules.md#비용-항목)
- 원본 추적:
  - GDD 8-2

## 회수세

- ID: `TERM-RECOVERY-TAX`
- 상태: `confirmed`
- 분류: 경제 비용
- 공식 표기: 회수세
- 짧은 정의: 길드가 회수품 판매와 정산 과정에서 부과하는 비용.
- 범위: 폐던전 회수 경제의 공식 비용 항목.
- 혼동 주의: 감정 비용이나 장비 수리비와 별도 항목이다.
- 상세 설정: [`../story/03_player_and_society.md#왜-길드나-군대가-직접-회수하지-않는가`](../story/03_player_and_society.md#왜-길드나-군대가-직접-회수하지-않는가)
- 관련 구현: [`../design/economy_rules.md#비용-항목`](../design/economy_rules.md#비용-항목)
- 관련 화자 표현: [`speaker_lexicon.md#길드--행정`](speaker_lexicon.md#길드--행정)
- 원본 추적:
  - GDD 3-7
  - GDD 10-3

## 하네스 엔지니어링

- ID: `TERM-HARNESS-ENGINEERING`
- 상태: `confirmed`
- 분류: 기술 체계 / 시스템
- 공식 표기: 하네스 엔지니어링
- 짧은 정의: 모듈식 작업 하네스로 분석·우회·안정화·견인·비상 대응을 수행하는 기술 체계.
- 범위: 수색꾼의 생존·회수 장비와 그 조정 기술.
- 혼동 주의: 정면 전투를 위한 강화복이나 공격력 중심 장비 체계가 아니다.
- 상세 설정: [`../design/harness_engineering.md`](../design/harness_engineering.md)
- 관련 제품 기준: [`../GDD.md#7-하네스-엔지니어링`](../GDD.md#7-하네스-엔지니어링)
- 원본 추적:
  - GDD 7장
  - GDD 부록 A

## 관련 문서

- [`../story/README.md`](../story/README.md)
- [`speaker_lexicon.md`](speaker_lexicon.md)
- [`../project/migration_manifest.md`](../project/migration_manifest.md)
- [`../project/m4_term_review.md`](../project/m4_term_review.md)
