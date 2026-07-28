---
id: PROJECT-M6-HUMAN-REVIEW
title: M6 사람 검토와 승인 후보
document_type: project
status: draft
source_version: story-v1.5+gdd-v2.1+management-proposal-v0.2.1
canonical_for:
  - human_review_results
  - status_transition_candidates
last_reviewed:
owner: documentation-maintainer
related:
  - migration_manifest.md
  - migration_changes.md
  - decisions.md
  - open_questions.md
  - m4_speaker_knowledge_review.md
  - m5_core_entity_timeline_review.md
  - m5_link_omission_review.md
  - development_handoff.md
  - ../GDD.md
  - ../story/README.md
  - ../design/README.md
  - ../reference/README.md
  - ../reference/speaker_lexicon.md
---

# M6 사람 검토와 승인 후보

## 목적

`DOC-0601`에서 사람이 확인해야 했던 후보를 승인 결과에 따라 반영하고, 다음 티켓에서 공식 기준으로 전환할 문서 범위를 제안한다. 이 보고서는 승인 결과와 전환 후보만 기록하며 `confirmed` 또는 `provisional` 상태 변경은 `DOC-0602`에서 수행한다.

## 검토 기준

- 검토일: 2026-07-28
- 사람 검토: 사용자가 화자 사전 보완 2건과 GDD 후속 개정 방향 1건을 승인
- Codex 검토: [`m4_speaker_knowledge_review.md`](m4_speaker_knowledge_review.md), [`m5_core_entity_timeline_review.md`](m5_core_entity_timeline_review.md), [`m5_link_omission_review.md`](m5_link_omission_review.md)의 근거와 현재 문서를 재대조
- 선행 관문: G-M5 완료 조건 7개 통과
- 변경 대기열: [`MIG-CHG-004`](migration_changes.md#mig-chg-004-doc-0601-사람-검토-반영)

## 사람 검토 반영 결과

| 후보 | 승인한 방향 | 반영 결과 |
|---|---|---|
| 감정사·연구자 공동 항목 | 기존 제목과 `SPEAKER-APPRAISERS-RESEARCHERS` ID를 유지한다. 공통 분석 어휘는 함께 적용하되 단계별 지식 변화와 현재 대사 예시는 연구자 전용이라고 명시한다. | [`speaker_lexicon.md#감정사--연구자`](../reference/speaker_lexicon.md#감정사--연구자)에 적용 |
| 일부 모험가의 비하·오해 표현 | 표현은 바꾸지 않고 사회적 배경의 기준 문서인 Player and Society를 지식 범위에 추가한다. | [`speaker_lexicon.md#수색꾼을-낮춰-보거나-오해하는-일부-모험가`](../reference/speaker_lexicon.md#수색꾼을-낮춰-보거나-오해하는-일부-모험가)에 적용 |
| GDD 3-4의 범람 표현 | 현재 규칙은 `DEC-004`의 `범람 위험이 사라진다`를 유지한다. 동결 GDD는 이번 티켓에서 수정하지 않고, 동결 해제 후 첫 GDD 개정에서 `사라지거나 극히 낮다`를 현재 규칙에 맞게 고친다. | 현재 기준과 후속 개정 필요성을 이 보고서에 기록. [`GDD.md`](../GDD.md)는 변경하지 않음 |

세 후보 모두 기존 내용의 적용 범위와 추적 위치를 명확히 하는 작업이다. 새 설정, 화자, 대사, 용어, ID, 결정 또는 열린 질문은 추가하지 않았다.

## 미결정 표기 확인

- 공식 표기가 미정인 `감정료 / 감정 수수료`와 `허가증 / 출입 허가`는 각각 [`Q-017`](open_questions.md), [`Q-018`](open_questions.md)로 계속 분리한다.
- Entity Index의 미정 이름·인원·역할 겸임과 Timeline의 미정 연도·기간·행위자는 채우지 않는다.
- GDD 3-4 문구는 현재 규칙을 바꾸는 열린 질문이 아니다. `DEC-004`를 현재 기준으로 사용하고 문구 정정만 후속 개정으로 남긴다.
- 활성 기준 본문에 새로 숨겨진 미결정 사항이나 직접 충돌은 발견되지 않았다.

## 문서 상태 승격 후보

### `confirmed` 후보

다음 17개 문서는 원본 추적, 책임 분리, 중복 정리, 링크·누락 검사와 사람 검토를 마쳤으므로 `DOC-0602`에서 `confirmed`로 전환할 후보로 제안한다.

- Story 9개: [`../story/README.md`](../story/README.md)와 Story 본문 8개
- Design 5개: [`../design/README.md`](../design/README.md)와 이관·검증을 마친 Design 본문 4개
- 필수 Reference 3개: [`../reference/README.md`](../reference/README.md), [`../reference/glossary.md`](../reference/glossary.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md)

이 전환은 문서에 이미 적힌 확정 내용과 미결정 분리를 공식 개발 기준으로 승인하는 것이며, 미결정 수치나 이름까지 확정하는 뜻이 아니다.

### `provisional` 후보

- [`../reference/entity_index.md`](../reference/entity_index.md): 원본에 있는 개체와 역할 15개를 안정적인 문서 ID로 추적하지만 이름·인원·역할 겸임이 미정인 항목이 있다.
- [`../reference/timeline.md`](../reference/timeline.md): 원본에 확정된 상대 순서는 검증했지만 연도·기간·일부 사건의 선후는 의도적으로 미정이다.

두 문서는 현재 내용 범위에서는 사용할 수 있으나 빈 이름이나 시점을 새 설정으로 채우지 않는 조건으로 `provisional` 전환을 제안한다.

### 이번 상태 전환에서 제외

- [`../GDD.md`](../GDD.md)는 Front Matter 상태 전환 대상이 아니며 동결 해제 전까지 직접 수정하지 않는다.
- [`../design/harness_engineering.md`](../design/harness_engineering.md)는 추가 골격만 있고 상세 규칙 이관·검증이 남아 있으므로 `MIG-CHG-005`에 따라 `draft`를 유지한다.
- Project의 이관 대장, 변경 대기열, 인벤토리와 단계별 검토 보고서는 전환 근거와 작업 이력을 기록하는 문서이므로 이번 제품 기준 상태 승격 대상에서 제외한다.
- Archive 경고와 실제 상태 변경은 `DOC-0602`, AGENTS와 GDD·개발 문서 링크 갱신은 `DOC-0603` 범위다.

## 검토 결과

- 판정: `DOC-0601 사람 검토 반영 완료`
- 사람 검토 후보: 3건 승인·처리
- Speaker Lexicon 본문 보완: 2건
- GDD 후속 개정 기록: 1건
- 새 설정·화자·대사·용어·ID·결정·열린 질문: 0건
- `confirmed` 전환 후보: 17개
- `provisional` 전환 후보: 2개
- 다음 검사: `DOC-0601 완료 후 정합성 검사`
- 검사 통과와 사용자 승인 후 다음 티켓: `DOC-0602 — 기준 전환과 Archive 경고`

## DOC-0602 전환 전 검증 정정

`DOC-0602` 시작 시 [`harness_engineering.md`](../design/harness_engineering.md)가 상세 규칙 이관과 검증이 남은 추가 골격임을 확인했다. 이를 `confirmed`로 전환하면 문서의 완료 수준과 상태가 모순되므로 후보에서 제외하고 `draft`를 유지했다. 이 정정으로 `confirmed` 대상은 18개에서 17개가 되었으며, Story·Reference 범위와 `provisional` 대상 2개는 바뀌지 않았다.

## DOC-0602 전환 결과

- `confirmed`: Story 9개, Design 5개, 필수 Reference 3개로 총 17개
- `provisional`: Entity Index와 Timeline 2개
- `draft` 유지: Harness Engineering과 Project의 이관·검토 문서
- Archive 경고: [`../archive/README.md`](../archive/README.md)에 현재 기준 문서 링크와 해시 보존 방식을 명시
- 보존 원문: 직접 수정하지 않아 기록된 SHA-256 유지
- 다음 티켓: `DOC-0603 — AGENTS 및 개발 문서 링크 갱신`

## DOC-0603 기준 인계 결과

- AGENTS가 GDD 개요와 `confirmed` Story·Design·Reference, 제한적 `provisional`, 단독 기준으로 사용할 수 없는 `draft`를 구분해 안내한다.
- GDD가 새 공식 문서와 개발 인계 안내를 직접 연결하며, 상세 기준보다 우선하지 않는 제품·시스템 개요 역할을 명시한다.
- 동결 개발 제안서는 수정하지 않고 [`development_handoff.md`](development_handoff.md)에서 기존 단계·티켓을 현재 기준 문서와 연결한다.
- GDD 3-4의 옛 범람 표현을 `DEC-004`의 `사라진다`로 정정했다.
- `게임 기획 파일/`과 Archive 보존 원문은 수정하지 않았다.
- 다음 검사: `DOC-0603 완료 후 정합성 검사와 G-M6 검토`
