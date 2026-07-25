---
id: REFERENCE-INDEX
title: Reference 문서 안내
document_type: reference
status: draft
source_version: management-proposal-v0.2.1
canonical_for:
  - reference_document_navigation
last_reviewed:
owner: documentation-maintainer
related:
  - ../story/README.md
  - ../design/README.md
  - ../project/migration_manifest.md
  - ../project/m2_reference_review.md
  - ../project/m4_term_review.md
  - ../project/m4_story_design_review.md
  - ../project/m4_speaker_knowledge_review.md
---

# Reference 문서 안내

## 목적

공식적으로 무엇이라 부르는지, 화자에 따라 어떻게 표현하는지, 고유 개체와 사건 순서를 어디서 찾는지 안내한다. 상세 정설은 Story, 작동 규칙은 Design에서 관리한다.

## 문서별 책임

| 문서 | 답하는 질문 |
|---|---|
| [`glossary.md`](glossary.md) | 공식 표기와 짧은 의미 경계는 무엇인가? |
| [`speaker_lexicon.md`](speaker_lexicon.md) | 화자나 집단은 어떤 단어와 말투를 사용하는가? |
| [`entity_index.md`](entity_index.md) | 인물·조직·장소·고유 물품의 기준 문서는 어디인가? |
| [`timeline.md`](timeline.md) | 주요 사건은 어떤 순서로 일어났는가? |

## 적용 우선순위

| 구분 | 문서 | 운영 원칙 |
|---|---|---|
| 필수 | `README.md`, `glossary.md`, `speaker_lexicon.md` | 용어·표현 작업에서 항상 확인 |
| 권장 | `entity_index.md` | 원본에 존재하는 고유 개체만 최소 등록 |
| 선택적 최소 | `timeline.md` | 사건 순서 충돌이 있을 때 확장 |

현재 다섯 파일을 유지하며, 항목 수 증가나 실제 탐색 문제가 확인되기 전에는 Reference 파일을 더 세분화하지 않는다.

## 경계 규칙

- Glossary에는 공식 표기와 짧은 의미 경계만 두고 상세 세계관을 복사하지 않는다.
- Speaker Lexicon의 표현은 객관적 사실이나 화자의 지식 범위를 바꾸지 않는다.
- Tone Guide는 공통 문체, Speaker Lexicon은 집단별 어휘와 말투를 담당한다.
- 표시 명칭과 문서 용어 ID를 코드 ID·저장 키·번역 키와 분리한다.
- 이름이나 연도가 미정인 개체를 채우기 위해 새 설정을 만들지 않는다.

## 정보별 책임

| 정보 | 기준 문서 | 이 문서가 하지 않는 일 |
|---|---|---|
| 공식 표기와 짧은 정의 | [`glossary.md`](glossary.md) | 상세 역사·현상·수치 복제 |
| 화자별 명칭과 은어 | [`speaker_lexicon.md`](speaker_lexicon.md) | 객관적 정의와 지식 진행 결정 |
| 공통 분위기와 문장 작성법 | [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md) | 집단별 어휘 목록 소유 |
| 화자가 아는 사실 | [`../story/04_characters_and_factions.md`](../story/04_characters_and_factions.md) | 대사 표면 전체 저장 |
| 인물·조직·장소 식별 | [`entity_index.md`](entity_index.md) | 인물 설정 본문 복제 |
| 사건 상대 순서 | [`timeline.md`](timeline.md) | 상세 역사 서술 복제 |

## 변경 절차

1. 분할 중 변경이면 [`../project/migration_changes.md`](../project/migration_changes.md)에 먼저 등록한다.
2. 상세 Story 또는 Design 기준과 충돌하지 않는지 확인한다.
3. 공식 정의 변경은 Glossary, 화자 표현 변경은 Speaker Lexicon에서 수행한다.
4. 이전 공식 표기는 삭제하지 않고 `deprecated`로 추적한다.
5. UI, Design, 대사, 저장·번역 영향은 관련 문서 링크와 검색으로 확인한다.
6. 승인된 변경은 관련 결정 ID와 문서 변경 이력을 연결한다.

문서 용어 ID와 화자 표현 ID는 한 번 발급하면 재사용하거나 의미를 바꾸지 않는다.

## 현재 상태

`DOC-0101`에서 공식 용어를 [`glossary.md`](glossary.md)에, `DOC-0102`에서 화자 표현을 [`speaker_lexicon.md`](speaker_lexicon.md)에 등록했다. `DOC-0103`은 공통 문체를 [`../story/07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)로 분리했고, `DOC-0104`는 기존 개체와 역할을 [`entity_index.md`](entity_index.md)에 등록했다. `DOC-0105`는 확정 상대 순서를 [`timeline.md`](timeline.md)에 등록했다. `DOC-0106` 책임 중복 검토 결과는 [`../project/m2_reference_review.md`](../project/m2_reference_review.md)에 기록했으며 G-M2 검토를 통과했다.

`DOC-0501`은 [`../project/m4_term_review.md`](../project/m4_term_review.md)에서 기존 Glossary의 누락과 후보를 분류했다. `DOC-0503`에서 근거가 확정된 핵심 누락 5개와 파일럿 후보 2개를 등록해 Glossary를 19개 항목으로 확장했고, 다른 후보는 Entity Index·Speaker Lexicon·Story 책임 또는 열린 질문 [`Q-017`](../project/open_questions.md), [`Q-018`](../project/open_questions.md)로 분리했다. Story·Design 단일 출처 전환 결과는 [`../project/m4_story_design_review.md`](../project/m4_story_design_review.md)에 기록했다. `DOC-0504`는 [`../project/m4_speaker_knowledge_review.md`](../project/m4_speaker_knowledge_review.md)에서 화자·집단 8개의 직접 표현·지식 충돌이 없음을 확인하고 역할 경계·근거 링크 보완 후보 2건을 사람 검토 대상으로 분리했다. 다음 티켓은 `DOC-0505` 핵심 설정·Entity·Timeline 정합성 검토다.
