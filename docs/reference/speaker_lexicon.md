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
  - ../story/04_characters_and_factions.md
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

아직 이관된 화자 표현 없음. 원본 7-7, 13-2, 13-5, 13-6은 `DOC-0102`에서 등록한다.

## 관련 문서

- [`glossary.md`](glossary.md)
- [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md)
- [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)
