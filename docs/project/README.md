---
id: PROJECT-INDEX
title: 프로젝트 문서
document_type: project
status: draft
source_version: management-proposal-v0.2.1
canonical_for:
  - project_document_navigation
  - document_metadata_rules
  - document_status_rules
last_reviewed:
owner: documentation-maintainer
related:
  - ../README.md
  - decisions.md
  - open_questions.md
  - gdd_mapping.md
  - migration_manifest.md
  - m2_reference_review.md
  - m4_term_review.md
  - m4_story_design_review.md
  - m4_speaker_knowledge_review.md
  - m5_core_entity_timeline_review.md
  - m5_link_omission_review.md
  - m6_human_review.md
---

# 프로젝트 문서

이 디렉터리는 문서 이관과 개발 과정의 결정, 미결정 사항, 변경 이력을 관리한다.

## 공통 Front Matter

모든 활성 분할 문서는 다음 필드와 순서를 사용한다.

```yaml
---
id: STORY-DUNGEON-CANON
title: 던전 정설
document_type: story
status: draft
source_version: story-v1.5
canonical_for:
  - dungeon_causality
last_reviewed:
owner: narrative-design
related:
  - ../reference/glossary.md
  - ../design/repeat_exploration.md
---
```

| 필드 | 규칙 |
|---|---|
| `id` | 파일명이 바뀌어도 재사용하거나 변경하지 않는 대문자 식별자 |
| `title` | 문서 첫 H1과 동일한 표시 제목 |
| `document_type` | `story`, `design`, `reference`, `project`, `archive` 중 하나 |
| `status` | 아래에 정의한 문서 신뢰 상태 |
| `source_version` | 최초 이관 또는 작성 기준이 된 원본 버전 |
| `canonical_for` | 문서가 소유하는 정보 종류를 `snake_case`로 기록 |
| `last_reviewed` | 전체 내용 검토를 통과한 날짜. 골격 생성일은 기록하지 않음 |
| `owner` | 최종 검토 책임 역할 |
| `related` | 반드시 함께 읽어야 하는 실제 상대 경로 |

`docs/GDD.md`와 `docs/archive/`의 동결 사본은 원본 해시 보존을 위해 이 형식으로 재작성하지 않는다. GDD의 현재 상태는 문서 본문의 기준 선언을 따르고, Archive는 현재 기준으로 사용하지 않는다.

## 문서 상태

| 상태 | 의미 | 사용 규칙 |
|---|---|---|
| `draft` | 이관 또는 작성 중 | 구현·콘텐츠 기준으로 단독 사용 금지 |
| `provisional` | 임시 적용 중 | 문서에 명시된 범위에서만 사용 |
| `confirmed` | 현재 공식 기준 | 구현과 콘텐츠 작성에 사용 가능 |
| `deprecated` | 더 이상 사용하지 않음 | 링크와 변경 추적 외 사용 금지 |
| `archived` | 과거 보존본 | 현재 설정과 구현 기준으로 사용 금지 |

상태 승격과 강등은 검토 결과 및 관련 결정 ID를 남긴 뒤 수행한다. `last_reviewed`는 `provisional` 또는 `confirmed`로 전환할 때 채운다.

## 문서별 책임

- [`decisions.md`](decisions.md): 승인된 세계관·설계·운영 결정
- [`open_questions.md`](open_questions.md): 미결정·가안·보류 항목
- [`gdd_mapping.md`](gdd_mapping.md): Story·Reference·Design·GDD·구현 영향 연결
- [`migration_manifest.md`](migration_manifest.md): 원본, 활성 문서, 아카이브의 대응 관계와 검증 상태
- [`migration_changes.md`](migration_changes.md): 분할 기간에 접수된 변경의 단일 대기열
- [`story_v1.5_inventory.md`](story_v1.5_inventory.md): 스토리 원본의 장·소제목과 구조화 요소 전체 목록
- [`document_changelog.md`](document_changelog.md): 문서 체계 자체의 변경 이력
- [`m2_reference_review.md`](m2_reference_review.md): M2 Reference 책임 중복과 G-M2 검토 결과
- [`m4_term_review.md`](m4_term_review.md): 공식 용어 누락·중복 검수와 `DOC-0503` 처리 결과
- [`m4_story_design_review.md`](m4_story_design_review.md): Story·Design 상세 정의 중복 검수와 단일 출처 전환 결과
- [`m4_speaker_knowledge_review.md`](m4_speaker_knowledge_review.md): 화자 표현과 NPC 지식 정합성 검수, 사람 검토 보완 후보
- [`m5_core_entity_timeline_review.md`](m5_core_entity_timeline_review.md): 핵심 설정·Entity·Timeline 충돌 검수와 처리 결과
- [`m5_link_omission_review.md`](m5_link_omission_review.md): 활성 문서 링크·앵커, 원본 이관 누락과 G-M5 완료 조건 검사 결과
- [`m6_human_review.md`](m6_human_review.md): 사람 검토 승인 결과, 상태 전환 후보와 `DOC-0602` 적용 결과

## 경계 규칙

- 승인된 내용은 `decisions.md`, 미결정 내용은 `open_questions.md`에 둔다.
- 이관 중 새 내용 변경은 `migration_changes.md`에 먼저 기록한다.
- 설정 내용의 변경 이유와 문서 구조 변경 이력을 섞지 않는다.
- Archive를 현재 설정으로 사용하지 않는다.
