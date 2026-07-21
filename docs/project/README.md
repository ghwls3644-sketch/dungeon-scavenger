---
title: Project 문서 안내
status: draft
updated: 2026-07-21
---

# 프로젝트 문서

이 디렉터리는 문서 이관과 개발 과정의 결정, 미결정 사항, 변경 이력을 관리한다.

## 문서별 책임

- [`decisions.md`](decisions.md): 승인된 세계관·설계·운영 결정
- [`open_questions.md`](open_questions.md): 미결정·가안·보류 항목
- [`gdd_mapping.md`](gdd_mapping.md): Story·Reference·Design·GDD·구현 영향 연결
- [`migration_manifest.md`](migration_manifest.md): 원본, 활성 문서, 아카이브의 대응 관계와 검증 상태
- [`migration_changes.md`](migration_changes.md): 분할 기간에 접수된 변경의 단일 대기열
- [`story_v1.5_inventory.md`](story_v1.5_inventory.md): 스토리 원본의 장·소제목과 구조화 요소 전체 목록
- [`document_changelog.md`](document_changelog.md): 문서 체계 자체의 변경 이력

## 경계 규칙

- 승인된 내용은 `decisions.md`, 미결정 내용은 `open_questions.md`에 둔다.
- 이관 중 새 내용 변경은 `migration_changes.md`에 먼저 기록한다.
- 설정 내용의 변경 이유와 문서 구조 변경 이력을 섞지 않는다.
- Archive를 현재 설정으로 사용하지 않는다.
