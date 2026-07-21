---
id: PROJECT-MIGRATION-CHANGES
title: 문서 이관 중 변경 대기열
document_type: project
status: draft
source_version: management-proposal-v0.2.1
canonical_for:
  - migration_change_queue
last_reviewed:
owner: project-maintainer
related:
  - migration_manifest.md
  - decisions.md
  - open_questions.md
---

# 문서 이관 중 변경 대기열

문서 분할이 끝날 때까지 새 설정, 용어 변경, 긴급 정정은 이 문서에 먼저 기록한다. 원본과 아카이브는 직접 수정하지 않는다.

## 처리 규칙

- 일반 설정·용어 변경은 ID를 발급하고 대기시킨다.
- 긴급 오류 수정은 영향받는 원본 절과 이관 대상 문서를 함께 적는다.
- 문장 다듬기는 정합성 검토 단계까지 보류한다.
- 코드 ID, 저장 키, 번역 키는 구현 단계 전에는 확정하지 않는다.
- ID 형식은 `MIG-CHG-001`부터 순차적으로 사용하고 재사용하지 않는다.

## 대기 중 변경

현재 등록된 변경 없음.

## 항목 양식

```text
### MIG-CHG-000: 제목

- 요청일:
- 요청 내용:
- 변경 이유:
- 영향받는 원본 절:
- 예상 이관 대상:
- 긴급도: 일반 / 긴급
- 상태: pending / applied / rejected
- 관련 결정·질문:
```
