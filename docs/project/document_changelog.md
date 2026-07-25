---
id: PROJECT-DOCUMENT-CHANGELOG
title: 문서 구조 변경 이력
document_type: project
status: draft
source_version: management-proposal-v0.2.1
canonical_for:
  - document_structure_changes
last_reviewed:
owner: documentation-maintainer
related:
  - decisions.md
  - migration_manifest.md
  - m2_reference_review.md
  - m4_story_design_review.md
  - ../README.md
---

# 문서 구조 변경 이력

## 목적

파일 분할, 책임 변경, 이름 변경, 기준 문서 전환 등 문서 체계 자체의 변경을 기록한다.

## 포함 범위

- 문서 생성·통합·폐기와 파일명 변경
- 책임 범위와 기준 상태 변경
- Reference 구조 변경

## 제외 범위

- 설정과 시스템 결정의 이유
- 이관 중 새 내용 변경 요청
- Git 커밋을 그대로 복제한 기록

## 변경 이력

DOC-0003 검토 완료 후 기록을 시작한다.

| 날짜 | 티켓 | 변경 | 이유 |
|---|---|---|---|
| 2026-07-21 | `DOC-0106` | [`m2_reference_review.md`](m2_reference_review.md) 생성 | Reference 우선 추출의 책임 중복, 원본 추적, G-M2 검토 결과를 활성 기준 문서와 분리해 보존하기 위해 추가했다. |
| 2026-07-25 | `DOC-0501` | [`m4_term_review.md`](m4_term_review.md) 생성 | 공식 용어 누락·중복 검수 결과와 후속 처리 후보를 Glossary의 현재 정의와 분리해 추적하기 위해 추가했다. |
| 2026-07-25 | `DOC-0502` | [`m4_story_design_review.md`](m4_story_design_review.md) 생성 | Story·Design 상세 정의 중복, 책임 혼합과 확정도 차이를 본문 전환 전에 별도 검수 결과로 추적하기 위해 추가했다. |
