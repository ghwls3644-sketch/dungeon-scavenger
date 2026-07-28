---
id: REFERENCE-SPEAKER-LEXICON
title: 화자별 표현
document_type: reference
status: draft
source_version: story-v1.5
canonical_for:
  - speaker_vocabulary
  - speaker_style_surface
last_reviewed:
owner: narrative-design
related:
  - glossary.md
  - ../story/03_player_and_society.md
  - ../story/04_characters_and_factions.md
  - ../story/06_narrative_progression.md
  - ../story/07_tone_and_writing_guide.md
---

# 화자별 표현

## 목적

화자와 집단별 선호 표현, 피하는 표현, 은어, 말투, 예문을 관리한다.

## 포함 범위

- 길드·행정, 상인, 수색꾼, 감정사·연구자 등의 표현
- 공식 표현, 현장 표현, 비하 은어의 구분
- 선호·금지 단어와 문장 표면의 예시
- 인물·집단의 지식 범위 문서 링크

## 제외 범위

- 용어의 객관적 정의
- 화자가 실제로 아는 사실과 지식 진행
- 존재하지 않는 화자나 집단의 신규 생성

## 항목 형식

### ID 규칙

- 화자 또는 집단 표현 ID는 `SPEAKER-...` 형식의 대문자 식별자를 사용한다.
- ID는 한 번 발급하면 재사용하거나 다른 집단에 할당하지 않는다.
- 화자 이름이 미정이면 원본에 존재하는 역할이나 집단을 기준으로 ID를 발급하고 임의 이름을 만들지 않는다.

### 항목 양식

```markdown
## {화자 또는 집단}

- ID: SPEAKER-...
- 관련 인물/집단:
- 선호 표현:
  -
- 피하는 표현:
  -
- 말투:
  -
- 지식 범위 문서:
  -
- 예시:
  -
- 관련 공식 용어:
  -
- 원본 추적:
  - STY-...
- 관련 결정:
```

필수 필드는 `ID`, `관련 인물/집단`, `선호 표현`, `피하는 표현`, `말투`, `지식 범위 문서`, `예시`다. `관련 공식 용어`, `원본 추적`, `관련 결정`은 추적이 필요할 때 사용한다.

### 작성 규칙

- 공식 정의는 [`glossary.md`](glossary.md)에 두고 여기에는 화자가 실제로 선택하는 표현만 둔다.
- 화자의 지식과 오해는 [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)에 두고 링크만 연결한다.
- 공통 분위기와 문장 작성법은 [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)를 따른다.
- 예시는 표현 규칙을 보여주는 최소 문장만 두며 대사 데이터 전체를 저장하지 않는다.
- 은어와 비하 표현을 공식 별칭으로 승격하지 않는다.

## 항목 목록

`DOC-0102`에서 원본 7-7, 13-2, 13-5, 13-6의 화자 표현을 이관했다. 아래 표현은 화자의 태도와 어휘를 보여주는 자료이며 객관적 사실을 정의하지 않는다.

- 연구자의 초·중·후반 예시는 표현 자료다. 적용 시점과 지식 변화는 Story 문서가 결정한다.
- 저주, 불길함, 옛 악에 관한 말은 화자의 믿음이나 편견이며 공식 정의가 아니다.
- 비하 표현은 편견을 드러내는 장면에서만 사용하고 중립 호칭이나 공식 별칭으로 사용하지 않는다.

| ID | 화자 또는 집단 | 표현 성격 |
|---|---|---|
| `SPEAKER-GUILD-ADMIN` | 길드 / 행정 | 공식적, 건조함 |
| `SPEAKER-MERCHANTS` | 상인 | 실리적, 계산적 |
| `SPEAKER-SCAVENGERS` | 수색꾼 | 현장감, 은어 |
| `SPEAKER-APPRAISERS-RESEARCHERS` | 감정사 / 연구자 | 분석적, 호기심 |
| `SPEAKER-CIVILIANS` | 일반인 | 불안, 편견 |
| `SPEAKER-FORMER-ADVENTURERS` | 전직 모험가 | 씁쓸함, 경고 |
| `SPEAKER-CLERGY` | 성직자 | 경계, 신앙적 해석 |
| `SPEAKER-BIASED-ADVENTURERS` | 수색꾼을 낮춰 보거나 오해하는 일부 모험가 | 비하, 오해 |

## 길드 / 행정

- ID: `SPEAKER-GUILD-ADMIN`
- 관련 인물/집단: 길드 문서 작성자와 행정 담당자
- 선호 표현:
  - 잔류물
  - 회수 가능 물품
  - 출입 허가
  - 사고 책임
  - 회수세
  - 모험가 — 제도상 넓은 분류
  - 폐던전 파견 인원 — 행정상 인원 표현
  - 정찰 파견 — 임무명
- 피하는 표현:
  - 도적, 잔반 처리, 정찰자 — 공식 문서에 사용하지 않는다.
  - 수색꾼 — 제도상 독립 직업 분류로 고정하지 않는다.
- 말투:
  - 공식적
  - 건조함
  - 인원보다 허가, 임무, 책임을 중심으로 표현함
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - 문서 표기 예: `회수 가능 물품`, `출입 허가`, `사고 책임`, `회수세`
- 관련 공식 용어:
  - [`TERM-RECOVERABLE-MATERIAL`](glossary.md#잔류물)
  - [`TERM-RECOVERY-TAX`](glossary.md#회수세)
  - [`TERM-ADVENTURER`](glossary.md#모험가)
  - [`TERM-SCAVENGER`](glossary.md#수색꾼)
  - [`TERM-SCOUTING-DISPATCH`](glossary.md#정찰-파견)
- 원본 추적:
  - `STY-0051`
  - `STY-0096`
  - `STY-0100`

## 상인

- ID: `SPEAKER-MERCHANTS`
- 관련 인물/집단: 회수품을 거래하는 상인
- 선호 표현:
  - 폐품
  - 쓸 만한 것
  - 돈 되는 물건
  - 무게값, 무게값 하는 물건
  - 감정서
- 피하는 표현:
  - 없음 — 원본에 별도 금지 표현이 없다.
- 말투:
  - 실리적
  - 계산적
  - 저주 소문과 감정 여부를 거래 가능성으로 판단함
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - “저주 묻었다는 소문이 붙은 건 사양이야. 잔재라면 감정서 붙여 와. 그건 값이 나오니까.”
- 관련 공식 용어:
  - [`TERM-SCRAP`](glossary.md#폐품)
  - [`TERM-REMNANT`](glossary.md#잔재)
  - [`TERM-APPRAISAL`](glossary.md#감정)
- 원본 추적:
  - `STY-0051`
  - `STY-0099`
  - `STY-0100`

## 수색꾼

- ID: `SPEAKER-SCAVENGERS`
- 관련 인물/집단: 플레이어를 포함한 수색꾼 전반
- 선호 표현:
  - 수색꾼 — 현장 기본 명칭
  - 폐품
  - 잔재
  - 흘러나온 것
  - 버릴 짐
  - 잔여 구역
- 피하는 표현:
  - 모험가, 정찰 파견 — 현장 기본 호칭으로 사용하지 않는다.
  - 도적, 잔반 처리 — 자기 집단의 중립 명칭으로 사용하지 않는다.
- 말투:
  - 현장감
  - 은어
  - 회수 가능성과 생존을 먼저 따지는 실리적 반응
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - “마왕이든 뭐든, 들고 나갈 수 있고 팔릴 물건이면 됐지.”
- 관련 공식 용어:
  - [`TERM-ADVENTURER`](glossary.md#모험가)
  - [`TERM-SCAVENGER`](glossary.md#수색꾼)
  - [`TERM-SCOUTING-DISPATCH`](glossary.md#정찰-파견)
  - [`TERM-SCRAP`](glossary.md#폐품)
  - [`TERM-REMNANT`](glossary.md#잔재)
  - [`TERM-REMAINING-ZONE`](glossary.md#잔여-구역)
- 원본 추적:
  - `STY-0051`
  - `STY-0096`
  - `STY-0099`
  - `STY-0100`

## 감정사 / 연구자

- ID: `SPEAKER-APPRAISERS-RESEARCHERS`
- 관련 인물/집단: 감정사와 연구자. 공통 분석 어휘는 함께 적용하고, 단계별 지식 변화와 아래 대사 예시는 연구자에게만 적용한다.
- 선호 표현:
  - 마력 잔향
  - 기억 흔적
  - 원본성
  - 코어 반응
- 피하는 표현:
  - 마왕과 던전의 직접 인과를 증거 없이 확정하는 표현
- 말투:
  - 분석적
  - 호기심
  - 연구자는 진행에 따라 판단 유보에서 직접 인과 약화로 표현이 변함
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
  - [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md)
- 예시:
  - 아래 예시는 모두 연구자 전용이며 감정사 대사 예시가 아니다.
  - `TBL-010` 연구자 정보 변화:
    - 초반: “마왕 전승과 던전 발생 기록이 함께 묶인 문헌은 많지만, 같은 원인이라고 보긴 어렵습니다.”
    - 중반: “당신이 가져온 기록을 보면, 던전 발생은 봉인보다 지맥 이상과 더 자주 겹칩니다.”
    - 후반: “마왕의 이름은 사람들이 던전을 이해하려고 덧씌운 공포에 가까울지도 모릅니다. 적어도 이 기록들만으로는 직접 원인을 말할 수 없습니다.”
  - `TBL-026` 마왕 관련 표현:
    - 연구자 초반: “마왕 전승과 던전 기록이 함께 묶인 문헌은 많지만, 그 둘이 같은 원인이라는 증거는 아직 부족합니다.”
    - 연구자 중반: “이 기록만 보면 던전 발생은 봉인보다 지맥 이상과 더 자주 겹칩니다. 흥미롭군요.”
    - 연구자 후반: “마왕의 이름은 던전을 설명하기 위해 붙은 공포였을지도 모릅니다. 적어도 직접 원인이라고 단정하긴 어렵습니다.”
- 관련 공식 용어:
  - [`TERM-DUNGEON`](glossary.md#던전)
  - [`TERM-DUNGEON-CORE`](glossary.md#코어)
  - [`TERM-REMNANT`](glossary.md#잔재)
  - [`TERM-UNIDENTIFIED-ITEM`](glossary.md#미확인-물품)
  - [`TERM-APPRAISAL`](glossary.md#감정)
- 원본 추적:
  - `STY-0046`
  - `STY-0051`
  - `STY-0099`
  - `STY-0100`

## 일반인

- ID: `SPEAKER-CIVILIANS`
- 관련 인물/집단: 폐던전과 회수품을 직접 다루지 않는 일반인
- 선호 표현:
  - 폐던전 물건
  - 저주 묻은 것
  - 불길한 것, 불길한 물건
- 피하는 표현:
  - 없음 — 원본에 별도 금지 표현이 없다.
- 말투:
  - 불안
  - 편견
  - 회수품을 위험하거나 꺼림칙한 대상으로 뭉뚱그림
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - “폐던전 물건은 집에 들이는 거 아니야.”
- 관련 공식 용어:
  - [`TERM-DEAD-DUNGEON`](glossary.md#폐던전)
  - [`TERM-REMNANT`](glossary.md#잔재)
- 원본 추적:
  - `STY-0051`
  - `STY-0099`
  - `STY-0100`

## 전직 모험가

- ID: `SPEAKER-FORMER-ADVENTURERS`
- 관련 인물/집단: 과거 던전 공략 경험이 있는 전직 모험가
- 선호 표현:
  - 그때 지나친 것, 지나친 방
  - 건드리지 않은 방, 건드리지 않은 물건
  - 값싼 목숨, 싼 목숨
- 피하는 표현:
  - 없음 — 원본에 별도 금지 표현이 없다.
- 말투:
  - 씁쓸함
  - 경고
  - 과거 공략 경험과 위험을 암시함
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - 표현 묶음 예: `지나친 방`, `건드리지 않은 물건`, `싼 목숨`
- 관련 공식 용어:
  - [`TERM-REMAINING-ZONE`](glossary.md#잔여-구역)
- 원본 추적:
  - `STY-0051`
  - `STY-0100`

## 성직자

- ID: `SPEAKER-CLERGY`
- 관련 인물/집단: 마왕과 봉인에 신앙적으로 반응하는 성직자
- 선호 표현:
  - 봉인
  - 오염
  - 금기
  - 옛 악의 그림자
- 피하는 표현:
  - 없음 — 원본에 별도 금지 표현이 없다.
- 말투:
  - 경계
  - 신앙적 해석
  - 가능성과 징조를 말하며 객관적 사실처럼 확정하지 않음
- 지식 범위 문서:
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - “옛 악의 그림자가 다시 드리운 것일지도 모릅니다.”
- 관련 공식 용어:
  - [`TERM-DUNGEON`](glossary.md#던전)
- 원본 추적:
  - `STY-0051`
  - `STY-0099`
  - `STY-0100`

## 수색꾼을 낮춰 보거나 오해하는 일부 모험가

- ID: `SPEAKER-BIASED-ADVENTURERS`
- 관련 인물/집단: 수색꾼을 비하하거나 강한 정찰자로 오해하는 일부 모험가
- 선호 표현:
  - 도적 — 버려진 물품을 줍는 일을 비하할 때 사용
  - 잔반 처리 — 남들이 남긴 것을 줍는다고 비아냥거릴 때 사용
  - 정찰자 — 스카우트된 수색꾼의 활약을 보고 강하다고 오해할 때 사용
- 피하는 표현:
  - 수색꾼 — 편견이나 오해를 드러내는 장면에서는 중립 호칭 대신 왜곡된 호칭을 사용함
- 말투:
  - 비하
  - 편견
  - 강함에 대한 오해
- 지식 범위 문서:
  - [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
  - [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- 예시:
  - 비하 표현: `도적`, `잔반 처리`
  - 오해 섞인 호칭: `정찰자`
- 관련 공식 용어:
  - [`TERM-SCAVENGER`](glossary.md#수색꾼)
- 원본 추적:
  - `STY-0096`

## 관련 문서

- [`glossary.md`](glossary.md)
- [`../story/03_player_and_society.md`](../story/03_player_and_society.md)
- [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md)
- [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)
