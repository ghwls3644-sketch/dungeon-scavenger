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
  - module_boundaries.md
  - m2_reference_review.md
  - m4_story_design_review.md
  - m5_core_entity_timeline_review.md
  - m5_link_omission_review.md
  - m6_human_review.md
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
| 2026-07-25 | `DOC-0503` | Story·Design 중복 10건을 단일 상세 출처와 요약 링크로 전환하고 [`glossary.md`](../reference/glossary.md)를 19개 항목으로 확장 | 세계관 이유·지식·정보와 상태·조건·계산의 상세 책임을 분리하고 공식 용어 누락을 해소하기 위해 변경했다. |
| 2026-07-25 | `DOC-0504` | [`m4_speaker_knowledge_review.md`](m4_speaker_knowledge_review.md) 생성 | 화자 표현 8개와 NPC 지식 범위의 직접 충돌 및 사람 검토 보완 후보를 기준 본문과 분리해 추적하기 위해 추가했다. |
| 2026-07-27 | `DOC-0505` | [`m5_core_entity_timeline_review.md`](m5_core_entity_timeline_review.md) 생성, Timeline 선후 모순 1건 정정과 Entity Story 역링크 3건 보완 | 핵심 설정·Entity·Timeline 대조 결과와 동결 GDD의 사람 검토 후보를 기준 본문과 분리해 추적하기 위해 변경했다. |
| 2026-07-27 | `DOC-0506` | [`m5_link_omission_review.md`](m5_link_omission_review.md) 생성 | 활성 문서 링크·앵커, 탐색 경로, Front Matter와 원본 이관 누락 검사 결과를 기준 본문과 분리해 추적하기 위해 추가했다. |
| 2026-07-28 | `DOC-0601` | [`m6_human_review.md`](m6_human_review.md) 생성, Speaker Lexicon의 적용 범위·근거 링크 2건 보완 | 사람 검토 승인 결과, 동결 GDD의 후속 개정 필요성과 다음 기준 상태 전환 후보를 한곳에서 확인하기 위해 변경했다. |
| 2026-07-28 | `DOC-0602` | Story·Design·필수 Reference 17개를 `confirmed`, Entity Index·Timeline 2개를 `provisional`로 전환하고 Archive 경고 강화 | 검증을 마친 분할 문서를 공식 기준으로 사용하되, 미정 개체·시점과 상세 이관 전 Harness 골격의 제한을 상태로 분명히 하기 위해 변경했다. |
| 2026-07-28 | `DOC-0603` | AGENTS와 GDD를 새 공식 문서 구조로 연결하고 [`development_handoff.md`](development_handoff.md)와 Reference 읽기 순서 추가 | 동결 개발 제안서를 수정하지 않으면서 다른 환경의 Codex가 현재 기준과 기존 개발 단계·티켓을 함께 찾을 수 있게 변경했다. |
| 2026-07-29 | `DEV-0001` | [`project_context.md`](project_context.md), 루트 `project.godot`과 `.gitignore` 생성, `DEC-101`과 GDD 구현 기준을 Godot으로 전환 | 승인된 엔진·언어·렌더러·플랫폼과 재현 가능한 실행·검증 명령을 개발 시작 기준으로 고정하기 위해 변경했다. |
| 2026-07-29 | `DEV-0002` | [`module_boundaries.md`](module_boundaries.md)와 `src/`, `tests/`의 모듈 폴더 생성, GDD 모듈 경계를 실제 Godot 경로로 연결 | 후속 기능이 화면·저장·게임 규칙의 책임을 섞지 않고 정해진 위치와 의존 방향을 따르게 하기 위해 변경했다. |
