---
id: PROJECT-M5-LINK-OMISSION-REVIEW
title: 링크·누락 자동 검사 결과
document_type: project
status: draft
source_version: story-v1.5+management-proposal-v0.2.1
canonical_for:
  - link_omission_review
  - m5_completion_evidence
last_reviewed:
owner: documentation-maintainer
related:
  - migration_manifest.md
  - story_v1.5_inventory.md
  - migration_changes.md
  - m4_term_review.md
  - m4_story_design_review.md
  - m4_speaker_knowledge_review.md
  - m5_core_entity_timeline_review.md
  - m6_human_review.md
  - ../README.md
  - ../story/README.md
  - ../design/README.md
  - ../reference/README.md
  - ../reference/glossary.md
  - ../reference/speaker_lexicon.md
  - ../reference/entity_index.md
  - ../reference/timeline.md
---

# 링크·누락 자동 검사 결과

## 목적

`DOC-0506`에서 활성 Markdown의 상대 경로와 제목 앵커, 문서 탐색 경로, Front Matter 연결, 원본 이관 추적과 주요 ID 누락을 자동 검사한다. 검사 결과는 M5 완료 조건을 판단하는 근거로 사용하되, 영구 검사 스크립트나 CI 도입은 선택 티켓 `DOC-0701` 범위로 남긴다.

## 검사 기준

- 검사일: 2026-07-27
- 기준 커밋: `d55093a` 이후 `DOC-0506` 작업 트리
- 활성 문서 범위: `docs/` 아래 Markdown. `docs/archive/`는 활성 기준이 아니므로 탐색·링크 집계에서 제외
- 동결 예외: `docs/GDD.md`는 링크 검사에는 포함하지만 Front Matter 형식을 강제하지 않음
- 원본 누락 기준: `스토리 정리 v1.5` 1,133행, 제목 103개, 구조화 요소 32개
- 검사 방식: 현재 작업에서 PowerShell로 읽기 전용 검사. 저장소에 영구 검사 스크립트나 CI는 추가하지 않음

## Markdown 링크와 탐색 검사

### 본문 반영 전 검사

| 검사 항목 | 결과 |
|---|---:|
| 활성 Markdown | 35개 |
| 확인한 로컬 Markdown 링크 | 860개 |
| 확인한 제목 앵커 | 148개 |
| 존재하지 않는 링크 대상 | 0개 |
| 존재하지 않는 제목 앵커 | 0개 |
| `docs/README.md`에서 도달할 수 없는 활성 문서 | 0개 |

### 문서 반영 후 최종 검사

| 검사 항목 | 결과 |
|---|---:|
| 활성 Markdown | 36개 |
| 확인한 로컬 Markdown 링크 | 872개 |
| 확인한 제목 앵커 | 148개 |
| 존재하지 않는 링크 대상 | 0개 |
| 존재하지 않는 제목 앵커 | 0개 |
| `docs/README.md`에서 도달할 수 없는 활성 문서 | 0개 |

보고서와 M5 진행 상태를 연결한 뒤 활성 문서 수와 링크 수가 늘어난 최종 상태에서도 같은 검사를 통과했다.

### Archive 링크 판정

활성 문서에서 Archive로 향하는 링크는 3개다.

| 위치 | 목적 | 판정 |
|---|---|---|
| [`docs/README.md`](../README.md) | Archive 진입점 안내 | 보관 문서 안내이며 활성 기준 오용 아님 |
| [`story_v1.5_inventory.md`](story_v1.5_inventory.md) | 동결 Story 원본 사본 추적 | 원본 검증 근거이며 활성 기준 오용 아님 |
| [`story/README.md`](../story/README.md) | 최종 전환 전 원문 기준 경고 | 신규 Story가 아직 원본을 대체하지 않는다는 경고 |

Glossary의 상세 설정 링크 19개는 모두 Story 또는 Design의 실제 문서·앵커로 연결된다. Story의 중앙 진입점은 모든 Story 문서와 Design·Reference 진입점을 함께 연결하므로 양방향 탐색이 가능하다.

## Front Matter와 문서 ID 검사

| 검사 항목 | 결과 |
|---|---:|
| 공통 Front Matter 검사 문서 | 35개 |
| 필수 필드 누락 | 0개 |
| 문서 ID | 35개 |
| 중복 문서 ID | 0개 |
| 확인한 `related` 경로 | 269개 |
| 존재하지 않는 `related` 대상 | 0개 |
| 중복 `canonical_for` 책임 | 0개 |

`docs/GDD.md`는 동결 SHA-256 보존 대상이므로 공통 Front Matter 검사 35개에 포함하지 않았다.

## 원본 이관 누락 검사

| 검사 항목 | 원본·계획 | 실제 | 누락·불일치 |
|---|---:|---:|---:|
| 원본 행 | 1,133 | 1,133 | 0 |
| 제목 | 103 | 인벤토리 103 | 0 |
| 표 | 27 | 인벤토리 27 | 0 |
| 인용 블록 | 4 | 인벤토리 4 | 0 |
| 코드 펜스 | 1 | 인벤토리 1 | 0 |
| 전체 구조화 요소 | 32 | 인벤토리 32 | 0 |
| 제목 줄 범위 | 1~1,133 | 연속 범위 1~1,133 | 0 |
| 인벤토리 대상 파일 | 등록 대상 전체 | 존재 | 0 |
| `planned` 추적 행 | 0 | 0 | 0 |
| 활성 문서에서 찾을 수 없는 추적 ID | 0 | 0 | 0 |

제목 103개는 원본의 실제 제목 순서와 모두 일치한다. 추적 ID 135개는 개별 표기와 `STY-0001`~`STY-0004` 같은 범위 표기를 함께 확장해 확인했다.

## Reference와 관리 ID 검사

| 대상 | 수량 | ID 중복 | 필수 필드·상세 링크 누락 |
|---|---:|---:|---:|
| Glossary | 19 | 0 | 0 |
| Speaker Lexicon | 8 | 0 | 0 |
| Entity Index | 15 | 0 | 0 |
| 결정 | 28 | 0 | 해당 없음 |
| 열린 질문 | 18 | 0 | 해당 없음 |

Glossary 19개 항목은 모두 상세 설정 링크를 갖는다. Speaker Lexicon 8개 항목은 관련 집단, 선호·회피 표현, 말투, 지식 범위 문서와 예시 필드를 갖는다.

## G-M5 완료 조건 판정

| G-M5 조건 | 결과 | 근거 |
|---|---|---|
| 핵심 용어의 짧은 정의와 상세 정설 위치가 분명한가? | 충족 | Glossary 19개 필수 필드와 상세 설정 링크 19개 통과 |
| 공식 용어와 은어가 섞이지 않았는가? | 충족 | Glossary와 Speaker Lexicon의 책임 분리, `DOC-0504` 직접 충돌 0건 |
| 충돌 설정이 해결되거나 질문으로 등록되었는가? | 충족 | `DOC-0505` 직접 충돌 해소, 동결 GDD 문구는 `DOC-0601` 사람 검토로 분리 |
| 요약 문서와 상세 문서가 일치하는가? | 충족 | `DOC-0503`, `DOC-0505` 검수 결과와 링크·추적 ID 검사 통과 |
| 관련 링크가 끊기지 않았는가? | 충족 | 링크 대상·앵커·탐색 누락 0개 |
| 분할 중 변경 요청이 모두 처리되었는가? | 충족 | [`migration_changes.md`](migration_changes.md)의 대기 중 변경 0건 |
| Glossary와 Speaker Lexicon이 서로의 책임을 침범하지 않는가? | 충족 | `DOC-0504` 책임 경계 검수와 항목 필수 필드 검사 통과 |

자동 검사와 기존 M5 검수 근거상 G-M5 조건 7개는 모두 충족한다. `DOC-0506` 완료 후 정합성 검사에서 결과와 후속 사람 검토 대상을 확인했고, 사용자의 진행 지시에 따라 2026-07-28에 G-M5를 통과하고 `DOC-0601`을 시작했다.

## 발견 사항과 처리

- 끊긴 경로·앵커, 탐색 불가능한 활성 문서와 원본 이관 누락은 발견되지 않았다.
- 검사식 초안이 `STY` 범위 표기와 의미형 용어·화자 ID를 개별 숫자 ID로 잘못 해석한 경우가 있었으나, 실제 문서를 확인하고 범위와 ID 형식을 반영한 뒤 누락 0건을 확인했다.
- 이번 티켓에서 새 설정, 용어, 화자 표현, ID와 열린 질문은 추가하지 않았다.
- 자동 검사 결과에 따른 기준 본문 수정은 필요하지 않았다.

## 검토 결과

- 판정: `DOC-0506 검사 완료`
- 링크·앵커 오류: 0건
- 탐색 불가능한 활성 문서: 0개
- Front Matter·관련 경로 오류: 0건
- 원본 제목·구조화 요소 누락: 0건
- 추적·관리 ID 중복 또는 누락: 0건
- G-M5 완료 조건: 7개 모두 충족
- G-M5 결과: `2026-07-28 통과`
- 다음 티켓: `DOC-0601 — 사람 검토 반영`

`DOC-0601` 사람 검토 결과는 [`m6_human_review.md`](m6_human_review.md)에 기록했으며, 이 보고서는 자동 검사 이력으로 `draft`를 유지한다.
